import 'dart:io';

import 'package:chat_allamo/db/conversation_db.dart';
import 'package:chat_allamo/firebase_options.dart';
import 'package:chat_allamo/root_provider.dart';
import 'package:chat_allamo/util/setting_pref.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final db = await initDB();

  final String ollamaURL = getOllamaURL(prefs);

  final customURL = ollamaURL == ""
      ? Platform.isAndroid
          ? "${dotenv.env["OLLAMA_API_URL_ANDROID"]}"
          : "${dotenv.env["OLLAMA_API_URL_IOS"]}"
      : ollamaURL;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    RootProvider(
      db: db,
      prefs: prefs,
      customURL: customURL,
      ollamaBaseUrl: "$customURL/api",
    ),
  );
}
