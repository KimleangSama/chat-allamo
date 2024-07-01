import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkController {
  final ValueNotifier<InternetStatus?> connectionStatus =
      ValueNotifier(InternetStatus.connected);

  NetworkController(String customURL) {
    reconnect(customURL);
  }

  void reconnect(String customURL) {
    InternetConnection.createInstance(
      customCheckOptions: [
        InternetCheckOption(uri: Uri.parse(customURL)),
      ],
      useDefaultOptions: false,
    ).onStatusChange.listen((status) {
      connectionStatus.value = status;
    });
  }

  void disconnect() {
    connectionStatus.value = InternetStatus.disconnected;
  }
}
