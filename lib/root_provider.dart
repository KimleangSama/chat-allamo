import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/controller/model_controller.dart';
import 'package:chat_allamo/controller/network_controller.dart';
import 'package:chat_allamo/route/routes.dart';
import 'package:chat_allamo/screen/loading_ollama_screen.dart';
import 'package:chat_allamo/service/conversation_service.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class RootProvider extends StatefulWidget {
  final Database db;
  final SharedPreferences prefs;
  final String customURL;
  final String? ollamaBaseUrl;

  const RootProvider({
    required this.db,
    required this.prefs,
    required this.customURL,
    this.ollamaBaseUrl,
    super.key,
  });

  @override
  State<RootProvider> createState() => _RootProviderState();
}

class _RootProviderState extends State<RootProvider> {
  late final ollamaClient = OllamaClient(baseUrl: widget.ollamaBaseUrl);
  late final modelController = ModelController(
    client: ollamaClient,
    prefs: widget.prefs,
  )..init();
  late final NetworkController networkController =
      NetworkController(widget.customURL);
  late final ConversationService conversationService =
      ConversationService(widget.db);

  @override
  Widget build(final BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: ollamaClient),
        Provider.value(value: modelController),
        Provider.value(value: conversationService),
        Provider.value(value: widget.prefs),
        Provider.value(value: networkController),
      ],
      child: ValueListenableBuilder(
        valueListenable: networkController.connectionStatus,
        builder: (context, connectivity, _) {
          if (connectivity == InternetStatus.connected) {
            modelController.loadModels();
          }
          return ValueListenableBuilder(
            valueListenable: modelController.models,
            builder: (context, models, _) => ValueListenableBuilder(
              valueListenable: modelController.currentModel,
              builder: (context, model, _) {
                if (model == null) {
                  return const LoadingOllamaScreen();
                }
                return Provider(
                  create: (context) => ChatController(
                    client: modelController.client,
                    model: modelController.currentModel,
                    conversationService: context.read(),
                  )..loadHistory(),
                  child: MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    title: 'Chat App',
                    routerConfig: mainRouters,
                    theme: ThemeData.dark(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
