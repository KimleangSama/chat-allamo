import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isHapticFeedback(SharedPreferences prefs) {
  return prefs.getBool('hapticFeedback') ?? true;
}

void setHapticFeedback(SharedPreferences prefs, bool value) {
  prefs.setBool('hapticFeedback', value);
}

String getSystemPrompt(SharedPreferences prefs) {
  return prefs.getString('systemPrompt') ?? '';
}

void setSystemPrompt(SharedPreferences prefs, String value) {
  prefs.setString('systemPrompt', value);
}

String getOllamaURL(SharedPreferences prefs) {
  return prefs.getString('ollamaURL') ?? '';
}

void setOllamaURL(SharedPreferences prefs, String value) {
  prefs.setString('ollamaURL', value);
}

void hapticFeedbackEffect(SharedPreferences prefs) {
  if (isHapticFeedback(prefs)) {
    HapticFeedback.lightImpact();
  }
}