import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/controller/model_controller.dart';
import 'package:chat_allamo/controller/network_controller.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/jumping_dot.dart';
import 'package:chat_allamo/util/markdown/code_element_builder.dart';
import 'package:chat_allamo/util/markdown/editor_highlighter_style.dart';
import 'package:chat_allamo/util/markdown/highlighter.dart';
import 'package:chat_allamo/util/setting_pref.dart';
import 'package:chat_allamo/widget/app_chat_bar.dart';
import 'package:chat_allamo/widget/bottom_chat_message.dart';
import 'package:chat_allamo/widget/chat_message/generated_message.dart';
import 'package:chat_allamo/widget/chat_message/sender_message.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:chat_allamo/widget/menu_drawer_panel.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shared_preferences/shared_preferences.dart';

final ZoomDrawerController z = ZoomDrawerController();

class ZoomDrawerScreen extends StatefulWidget {
  const ZoomDrawerScreen({super.key});

  @override
  State<ZoomDrawerScreen> createState() => _ZoomDrawerScreenState();
}

class _ZoomDrawerScreenState extends State<ZoomDrawerScreen> {
  final ValueNotifier<bool> scrollIndicator = ValueNotifier(false);
  late bool needScroll = false;

  @override
  Widget build(BuildContext context) {
    final chatController = context.read<ChatController>();
    final modelController = context.read<ModelController>();
    final networkController = context.read<NetworkController>();
    final prefs = context.read<SharedPreferences>();
    return ZoomDrawer(
      controller: z,
      borderRadius: 40,
      showShadow: false,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.fastOutSlowIn,
      slideWidth: MediaQuery.of(context).size.width * 0.85,
      duration: const Duration(milliseconds: 500),
      angle: -2,
      menuBackgroundColor: canvasColor,
      mainScreen: ValueListenableBuilder(
        valueListenable: scrollIndicator,
        builder: (context, value, _) => Scaffold(
          backgroundColor: scaffoldColor,
          appBar: AppChatBar(z: z),
          body: ListenableBuilder(
            listenable: Listenable.merge(
              [
                chatController.loading,
                chatController.serverOllamaURL,
                chatController.systemPrompt,
                chatController.conversation,
                networkController.connectionStatus,
              ],
            ),
            builder: (context, _) {
              final loading = chatController.loading.value;
              final systemPrompt = chatController.systemPrompt.value;
              final messages = chatController.conversation.value.messages;
              final title = chatController.conversation.value.title;
              final date = chatController.conversation.value.formattedDate;
              final connectionToInternet =
                  networkController.connectionStatus.value;
              final bool isConnected =
                  connectionToInternet == InternetStatus.connected;
              if (messages.isNotEmpty && needScroll) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  chatController.scrollToEnd(milliseconds: 500);
                  needScroll = false;
                });
              }
              return Scaffold(
                backgroundColor: scaffoldColor,
                body: SafeArea(
                  top: false,
                  bottom: false,
                  maintainBottomViewPadding: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (messages.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints.tightForFinite(),
                          margin: const EdgeInsets.only(
                              top: 8.0, bottom: 3.0, left: 8.0, right: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: textPaddingColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              Text(date),
                            ],
                          ),
                        ),
                      if (systemPrompt!.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints.tightForFinite(),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 3.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: canvasColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  "System Prompt: $systemPrompt",
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  context.push('/settings/configurations');
                                },
                                child: const Text("Update",
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Column(
                            children: [
                              Flexible(
                                child: loading
                                    ? _displayEmptyAndListOfMessages(
                                        chatController,
                                        loading,
                                        messages,
                                        isConnected)
                                    : NotificationListener<
                                        ScrollEndNotification>(
                                        onNotification: (scrollEnd) {
                                          final metrics = scrollEnd.metrics;
                                          scrollIndicator.value =
                                              metrics.pixels <
                                                  metrics.maxScrollExtent - 10;
                                          return true;
                                        },
                                        child: _displayEmptyAndListOfMessages(
                                            chatController,
                                            loading,
                                            messages,
                                            isConnected),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      isConnected
                          ? BottomChatMessage(scrollIndicator: scrollIndicator)
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: textPaddingColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(FluentIcons.wifi_off_24_regular),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      context.push('/settings/configurations');
                                    },
                                    child: const Text("Server is unavailable.",
                                        style: TextStyle(
                                            fontSize: 16,
                                            decoration:
                                                TextDecoration.underline)),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.miniCenterFloat,
                floatingActionButton: messages.isNotEmpty &&
                        scrollIndicator.value
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: FloatingActionButton.small(
                          backgroundColor: textPaddingColor,
                          foregroundColor: Colors.white,
                          child:
                              const Icon(FluentIcons.chevron_down_20_regular),
                          onPressed: () {
                            hapticFeedbackEffect(prefs);
                            chatController.scrollToEnd();
                          },
                        ),
                      )
                    : null,
              );
            },
          ),
          // bottomNavigationBar: BottomAppNavBar(),
        ),
      ),
      menuScreen: MenuDrawerPanel(
        z: z,
        onChatSelection: (conversation) async {
          // /*await */ modelController.selectModelNamed(conversation.model);
          hapticFeedbackEffect(prefs);
          if (chatController.selectedConversation.value == conversation) {
            z.toggle?.call();
            chatController.scrollToEnd(milliseconds: 500);
            return;
          }
          modelController.selectModelNamed(conversation.model);
          chatController.selectConversation(conversation);
          z.toggle?.call();
          needScroll = true;
        },
      ),
    );
  }

  Widget _displayEmptyAndListOfMessages(
      ChatController chatController, bool loading, messages, bool isConnected) {
    if (messages.isEmpty && !loading) {
      return Center(
        child: Text(
          textAlign: TextAlign.center,
          !isConnected
              ? 'Server is unavailable.\nYou cannot send messages!\n You can view history chats from menu.'
              : 'Start a conversation!',
        ),
      );
    }
    return ListView(
      cacheExtent: 999999,
      controller: chatController.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (!loading)
          for (int i = 0; i < messages.length; i++)
            QuestionAnswerView(index: i, qa: messages[i]),
        // qa = question answer
        if (loading && chatController.lastReply.value.$2.isEmpty)
          const ChatInteractionView(),
      ],
    );
  }
}

class QuestionAnswerView extends StatelessWidget {
  // String = question, String = answer, XFile? = image, String = model name to display
  final int index;
  final (String, String, String?, String) qa;

  const QuestionAnswerView({super.key, required this.index, required this.qa});

  @override
  Widget build(BuildContext context) {
    final chatController = context.read<ChatController>();
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(7.5),
            onLongPress: () async {
              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) {
                  return Material(
                    color: appBarColor,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ListTile(
                          //   title: const Text(
                          //     'Read Aloud',
                          //     style: TextStyle(color: textColor),
                          //   ),
                          //   leading: const Icon(
                          //     FluentIcons.read_aloud_20_regular,
                          //     color: textColor,
                          //   ),
                          //   onTap: () async {
                          //   },
                          // ),
                          ListTile(
                            title: const Text(
                              'Copy',
                              style: TextStyle(color: textColor),
                            ),
                            leading: const Icon(
                              FluentIcons.copy_20_regular,
                              color: textColor,
                            ),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: qa.$1));
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Edit',
                              style: TextStyle(color: textColor),
                            ),
                            leading: const Icon(
                              FluentIcons.edit_20_regular,
                              color: textColor,
                            ),
                            onTap: () {
                              chatController.indexOfEditingMessage.value =
                                  index;
                              chatController.editingMessage.value = qa.$1;
                              chatController.promptFieldFocusNode.requestFocus();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: SenderMessage(
              question: qa.$1,
              imageURL: qa.$3,
            ),
          ),
          Text(qa.$4, style: const TextStyle(color: textColor)),
          GeneratedMessage(message: qa.$2),
        ],
      ),
    );
  }
}

// Loading with animated streaming text
class ChatInteractionView extends StatelessWidget {
  const ChatInteractionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ChatController>();
    final prefs = context.read<SharedPreferences>();
    final loading = controller.loading.value;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: ListenableBuilder(
        listenable: Listenable.merge([
          controller.lastReply,
          controller.selectedImage,
        ]),
        builder: (context, _) {
          final qa = controller.lastReply.value;
          final image = controller.selectedImage.value;
          hapticFeedbackEffect(prefs);
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    children: [
                      const Text("Previous messages..."),
                      const SizedBox(height: 5),
                      SenderMessage(
                        question: qa.$1,
                        imageURL: image?.path,
                        isNetworkImage: false,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, top: 5, bottom: 5),
                      child: loading && qa.$2.isEmpty
                          ? JumpingDots(
                              radius: 6,
                              numberOfDots: 4,
                              color: textColor,
                              animationDuration: Durations.long1,
                            )
                          : const CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/icons/ollama.png'),
                              backgroundColor: Colors.transparent,
                              radius: 14,
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2.5),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: qa.$2.isEmpty
                                ? Colors.transparent
                                : scaffoldColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: Markdown(
                            data: qa.$2.isEmpty ? '' : qa.$2,
                            physics: const NeverScrollableScrollPhysics(),
                            syntaxHighlighter:
                                MdHightLighter(editorHighlighterStyle),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            styleSheetTheme:
                                MarkdownStyleSheetBaseTheme.material,
                            inlineSyntaxes: const [],
                            extensionSet: md.ExtensionSet.gitHubWeb,
                            onSelectionChanged: (_, __, ___) {},
                            shrinkWrap: true,
                            builders: {'code': CodeElementBuilder()},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
