import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_allamo/model/conversation.dart';
import 'package:chat_allamo/service/conversation_service.dart';
import 'package:chat_allamo/util/random_string.dart';
import 'package:chat_allamo/util/setting_pref.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/async_result.dart';

Conversation emptyConversationWith(String model) => Conversation(
      lastUpdate: DateTime.now(),
      model: model,
      title: 'New Chat',
      messages: [],
      isFavorite: false,
    );

class ChatController {
  final OllamaClient _client;

  final FocusNode promptFieldFocusNode = FocusNode();
  final TextEditingController promptFieldController = TextEditingController();
  final ValueNotifier<int> indexOfEditingMessage = ValueNotifier(-1);
  final ValueNotifier<String> editingMessage = ValueNotifier("");

  ScrollController scrollController = ScrollController();

  ValueNotifier<XFile?> selectedImage = ValueNotifier(null);

  final ValueNotifier<Model?> model;

  final ConversationService _conversationService;

  final ValueNotifier<Conversation> conversation;

  final ValueNotifier<(String, String, String?, String)> lastReply =
      ValueNotifier(('', '', '', ''));

  final ValueNotifier<bool> loading = ValueNotifier(false);

  final ValueNotifier<AsyncData<List<Conversation>>> conversations =
      ValueNotifier(const Data([]));

  final ValueNotifier<Conversation?> selectedConversation = ValueNotifier(null);

  final ValueNotifier<String?> serverOllamaURL = ValueNotifier("");
  final ValueNotifier<String?> systemPrompt = ValueNotifier("");

  ChatController({
    required OllamaClient client,
    required this.model,
    required ConversationService conversationService,
    Conversation? initialConversation,
  })  : _client = client,
        _conversationService = conversationService,
        conversation = ValueNotifier(
          initialConversation ??
              emptyConversationWith(model.value?.model ?? '/'),
        );

  Future<void> loadHistory() async {
    conversations.value = const Pending();
    try {
      conversations.value =
          Data(await _conversationService.loadConversations());
      systemPrompt.value = await SharedPreferences.getInstance()
          .then((prefs) => getSystemPrompt(prefs));
    } catch (err) {
      if (kDebugMode) {
        print("Error $err");
      }
    }
  }

  StreamSubscription? streamSubscription;
  StreamController<GenerateChatCompletionResponse>? streamController;

  Future<bool> chat() async {
    if (model.value == null) return false;
    scrollController = ScrollController();
    streamController = StreamController<GenerateChatCompletionResponse>();

    final modelName = model.value!.model;

    if (modelName != null) {
      loading.value = true;
      final question = promptFieldController.text;
      promptFieldController.clear();
      lastReply.value = (question, '', null, modelName);

      final XFile? image = selectedImage.value;

      String? imageURL;
      String? b64Image;

      if (image != null) {
        b64Image = base64Encode(await image.readAsBytes());
        final storageRef = FirebaseStorage.instance.ref();
        final filename = generateFileName();
        final imageRef = storageRef.child('images/$filename');
        await imageRef.putFile(File(image.path));
        imageURL = await imageRef.getDownloadURL();
      }
      lastReply.value = (
        question,
        '',
        imageURL,
        modelName,
      );
      final generateChatCompletionRequest = GenerateChatCompletionRequest(
        model: modelName,
        messages: [
          if (systemPrompt.value!.isNotEmpty)
            Message(
              role: MessageRole.system,
              content: systemPrompt.value!,
            ),
          for (final qa in conversation.value.messages) ...[
            Message(role: MessageRole.user, content: qa.$1),
            Message(role: MessageRole.assistant, content: qa.$2),
          ],
          Message(
            role: MessageRole.user,
            content: question,
            images: b64Image != null ? [b64Image] : null,
          ),
        ],
      );
      final streamResponse = _client.generateChatCompletionStream(
        request: generateChatCompletionRequest,
      );
      streamSubscription = streamResponse.listen(
        (chunk) {
          streamController?.add(chunk);
        },
        onDone: () {
          // Close the StreamController when the stream completes
          streamController?.close();
        },
        onError: (error) {
          // Handle errors and close the StreamController
          streamController?.addError(error);
          streamController?.close();
        },
        cancelOnError: true,
      );
      try {
        await for (final chunk in streamController!.stream) {
          lastReply.value = (
            lastReply.value.$1,
            '${lastReply.value.$2}${chunk.message?.content ?? ''}',
            imageURL,
            modelName,
          );
          scrollToEnd(milliseconds: 80);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error $e");
        }
      } finally {
        cancelGenerateChat();
      }

      final messages = conversation.value.messages;
      final firstQuestion = messages.isNotEmpty ? messages.first.$1 : question;
      conversation.value = conversation.value.copyWith(
        newModel: modelName,
        newMessages: messages..add(lastReply.value),
        newTitle: conversation.value.title == "New Chat"
            ? firstQuestion
            : conversation.value.title,
      );
      _conversationService.saveConversation(conversation.value);
      loadHistory();
      selectConversation(conversation.value);

      loading.value = false;
      deleteImage();

      Future.delayed(const Duration(milliseconds: 150), scrollToEnd);
      return true;
    }
    return false;
  }

  Future<void> cancelGenerateChat() async {
    streamSubscription?.cancel();
    streamController?.close();
    loading.value = false;
  }

  void scrollToEnd({int milliseconds = 200}) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: milliseconds),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> addImage(XFile? image) async {
    selectedImage.value = image;
  }

  void deleteImage() {
    selectedImage.value = null;
  }

  void selectConversation(Conversation value) {
    conversation.value = value;
    selectedConversation.value = value;
    scrollToEnd(milliseconds: 50);
  }

  void removeSelectedConversation() {
    selectedConversation.value = null;
  }

  Future<void> renameConversationTitle(
      Conversation toConversation, String title) async {
    toConversation = toConversation.copyWith(newTitle: title);
    _conversationService.renameConversationTitle(toConversation);
    loadHistory();
    selectConversation(toConversation);
  }

  void newConversation() {
    removeSelectedConversation();
    conversation.value = Conversation(
      lastUpdate: DateTime.now(),
      model: model.value?.model ?? '/',
      title: 'New Chat',
      messages: [],
      isFavorite: false,
    );
  }

  Future<void> deleteConversation(Conversation deleteConversation) async {
    selectedConversation.value = null;
    conversation.value = emptyConversationWith(model.value?.model ?? '/');
    await _conversationService.deleteConversation(deleteConversation);
    loadHistory();
  }

  Future<void> deleteAllConversations() async {
    await _conversationService.deleteAllConversations();
    loadHistory();
    removeSelectedConversation();
    newConversation();
  }

  void toggleFavorite(Conversation toConversation) {
    toConversation =
        toConversation.copyFavoriteWith(isFavorite: !toConversation.isFavorite);
    _conversationService.toggleFavorite(toConversation);
    conversations.value = Data(conversations.value.data!
        .map((e) => e.id == toConversation.id ? toConversation : e)
        .toList());
  }

  void toggleArchive(Conversation toConversation) {
    toConversation = toConversation.copyIsArchivedWith(
        isArchived: !toConversation.isArchived);
    _conversationService.toggleArchive(toConversation);
    conversations.value = Data(conversations.value.data!
        .map((e) => e.id == toConversation.id ? toConversation : e)
        .toList());
  }

  void archiveAllConversations() {
    if (conversations.value.data!.isEmpty) return;
    for (var conversation in conversations.value.data!) {
      toggleArchive(conversation);
    }
  }

  Future<void> chatWithEditingMessage() async {
    if (model.value == null) return;
    scrollController = ScrollController();
    streamController = StreamController<GenerateChatCompletionResponse>();

    final modelName = model.value!.model;

    if (modelName != null) {
      loading.value = true;
      final question = promptFieldController.text;
      promptFieldController.clear();
      lastReply.value = (question, '', null, modelName);
      final generateChatCompletionRequest = GenerateChatCompletionRequest(
        model: modelName,
        messages: [
          if (systemPrompt.value!.isNotEmpty)
            Message(
              role: MessageRole.system,
              content: systemPrompt.value!,
            ),
          for (final qa in conversation.value.messages) ...[
            Message(role: MessageRole.user, content: qa.$1),
            Message(role: MessageRole.assistant, content: qa.$2),
          ],
          Message(
            role: MessageRole.user,
            content: question,
            images: null,
          ),
        ],
      );
      final streamResponse = _client.generateChatCompletionStream(
        request: generateChatCompletionRequest,
      );
      streamSubscription = streamResponse.listen(
        (chunk) {
          streamController?.add(chunk);
        },
        onDone: () {
          // Close the StreamController when the stream completes
          streamController?.close();
        },
        onError: (error) {
          // Handle errors and close the StreamController
          streamController?.addError(error);
          streamController?.close();
        },
        cancelOnError: true,
      );
      try {
        await for (final chunk in streamController!.stream) {
          lastReply.value = (
            lastReply.value.$1,
            '${lastReply.value.$2}${chunk.message?.content ?? ''}',
            null,
            modelName,
          );
          scrollToEnd(milliseconds: 80);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error $e");
        }
      } finally {
        cancelGenerateChat();
      }

      final messages = conversation.value.messages;
      final firstQuestion = messages.isNotEmpty ? messages.first.$1 : question;
      conversation.value = conversation.value.copyWith(
        newModel: modelName,
        newMessages: messages..add(lastReply.value),
        newTitle: conversation.value.title == "New Chat"
            ? firstQuestion
            : conversation.value.title,
      );
      conversation.value
          .replaceMessageAt(indexOfEditingMessage.value, lastReply.value);
      _conversationService.saveConversation(conversation.value);
      // loadHistory();
      // selectConversation(conversation.value);

      loading.value = false;

      Future.delayed(const Duration(milliseconds: 150), scrollToEnd);
    }
  }

  void cancelEditMessage() {
    indexOfEditingMessage.value = -1;
  }
}
