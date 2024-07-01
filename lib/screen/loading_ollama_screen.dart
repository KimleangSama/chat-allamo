import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/controller/model_controller.dart';
import 'package:chat_allamo/route/routes.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/jumping_dot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingOllamaScreen extends StatefulWidget {
  const LoadingOllamaScreen({super.key});

  @override
  State<LoadingOllamaScreen> createState() => _LoadingOllamaScreenState();
}

class _LoadingOllamaScreenState extends State<LoadingOllamaScreen> {
  @override
  Widget build(BuildContext context) {
    final modelController = context.watch<ModelController>();
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 1500)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
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
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            home: Scaffold(
              backgroundColor: scaffoldColor,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  JumpingDots(
                    numberOfDots: 5,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 15),
                  const Text("Loading...")
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
