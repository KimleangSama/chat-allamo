import 'package:chat_allamo/theme/constant.dart';
import 'package:flutter/material.dart';

class AboutDevScreen extends StatelessWidget {
  const AboutDevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/icons/ollama.png'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Kea Kimleang',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Text(
                'Mail: kimleang.rscher@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const Text(
                'Graduated M.S. Degree in AI Convergence',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chat Allamo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Chat Allamo is an unofficial, feature-rich, and extensible app with a user-friendly UI, designed to operate on both Android and iOS devices. It essentially provides a ChatGPT app UI that lets you connect to your private, self-hosted Ollama models.',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Why named it Allamo? Allamo = AI + Ollama, also with the first and last letters 'O' switched to 'a' to create the name.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Privacy [DO NOT UPLOAD PRIVATE IMAGE] - The app uses Firebase solely for storing image data. However, the app does not store any other user conversation data.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Freemium: The app is 100% free to use, with premium features available in other apps.',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "On Device DB: The app ONLY uses an on-device database to store conversation data.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "No Account Required: The app does not require any login or account creation to use its features, providing a hassle-free experience.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Private Self-Hosted Server: The app allows you to connect to your private, self-hosted Ollama models, ensuring that your data is secure and private.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Custom System Prompt: The app allows you to customize the system prompt to generate more accurate and relevant responses from the Ollama models.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Many Models Conversations: The app supports the selection of various Ollama models to effortlessly engage and harness their unique strengths for optimal responses.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Continous Update: The app will be updated regularly to provide the best user experience and to keep up with the latest Ollama models and features.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
