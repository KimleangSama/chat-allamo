import 'dart:async';

import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/controller/model_controller.dart';
import 'package:chat_allamo/controller/network_controller.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/invalid_url_exception.dart';
import 'package:chat_allamo/util/setting_pref.dart';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OllamaConfigurationScreen extends StatefulWidget {
  const OllamaConfigurationScreen({super.key});

  @override
  State<OllamaConfigurationScreen> createState() =>
      _OllamaConfigurationScreenState();
}

class _OllamaConfigurationScreenState extends State<OllamaConfigurationScreen> {
  final ollamaServerController = TextEditingController();
  final systemPromptController = TextEditingController();
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    final chatController = context.read<ChatController>();
    final modelController = context.read<ModelController>();
    final prefs = context.watch<SharedPreferences>();
    final networkController = context.read<NetworkController>();
    ollamaServerController.text = getOllamaURL(prefs);
    systemPromptController.text = getSystemPrompt(prefs);
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text('Configurations',
            style: TextStyle(
              fontSize: 17,
              color: textColor,
            )),
        backgroundColor: appBarColor,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          modelController.models,
          modelController.currentModel,
          networkController.connectionStatus,
        ]),
        builder: (context, child) {
          final Model? currentModel = modelController.currentModel.value;
          List<Model> listModels = modelController.models.value.data ?? [];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ollama Server Configuration",
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: textPaddingColor,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ollamaServerController,
                              decoration: InputDecoration(
                                hintText: 'Ollama Server URL',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () async {
                              try {
                                final serverURL = ollamaServerController.text;
                                if (serverURL.isEmpty) {
                                  toast(
                                      "Default Ollama URL server will be used.");
                                  return;
                                }
                                if (!serverURL.startsWith('http://') &&
                                    !serverURL.startsWith('https://')) {
                                  throw InvalidURLException(
                                      'Ollama URL server should start with http:// or https://');
                                }
                                setOllamaURL(prefs, serverURL);
                                chatController.serverOllamaURL.value =
                                    serverURL;
                                networkController.disconnect();
                                toast("Restart app to apply changes.");
                              } on InvalidURLException catch (e) {
                                toast(e.message);
                              } catch (e) {
                                toast(
                                    "Failed to save configuration. Please try again.");
                              }
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: buttonColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 14,
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(color: textColor, fontSize: 15),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: systemPromptController,
                        decoration: InputDecoration(
                          hintText:
                              'Custom system prompt (autosave, do not click Save button.)',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        onChanged: (value) {
                          timer?.cancel();
                          timer = Timer(const Duration(milliseconds: 1000), () {
                            setSystemPrompt(prefs, value);
                            chatController.systemPrompt.value = value;
                            toast("System prompt saved.");
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              'assets/icons/logo.png',
                              width: 32,
                              height: 32,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("Default Model",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                              )),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: borderColor,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: Container(),
                                dropdownColor: canvasColor,
                                value: currentModel?.model ?? '',
                                items: listModels.map<DropdownMenuItem<String>>(
                                    (Model model) {
                                  final value = model.model ?? '';
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        style: const TextStyle(
                                          color: textColor,
                                        )),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  modelController.selectModelNamed(value!);
                                },
                                hint: const Text(
                                  "Select model",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Learn more text
                      const SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Custom system configurations will be applied to all new conversations.",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                            ),
                            onPressed: () async {
                              if (!await launchUrl(Uri.parse(
                                  "https://ollama.com/blog/how-to-prompt-code-llama"))) {
                                throw Exception(
                                    'Could not launch https://ollama.com/blog/how-to-prompt-code-llama');
                              }
                            },
                            child: const Text(
                              "Learn more",
                              style: TextStyle(
                                color: buttonColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
