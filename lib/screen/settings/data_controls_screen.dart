import 'dart:io';

import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';

class DataControlsScreen extends StatelessWidget {
  const DataControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = context.read<ChatController>();
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text(
          'Data Controls',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
        ),
        backgroundColor: appBarColor,
      ),
      body: SafeArea(
        bottom: false,
        child: SettingsList(
          darkTheme:
              const SettingsThemeData(settingsListBackground: scaffoldColor),
          sections: [
            SettingsSection(
              title: const Text('DATA'),
              tiles: [
                // SettingsTile(
                //   title: const Text('Export Chats [NOT WORK YET]'),
                //   onPressed: (BuildContext context) {},
                // ),
                SettingsTile(
                  title: const Text('Arhive All Chats'),
                  onPressed: (BuildContext context) {
                    showPopupDialogBasedOnDevice(context, chatController, true);
                  },
                ),
                SettingsTile(
                  title: Text('Delete All Chats',
                      style: TextStyle(color: Colors.red.shade500)),
                  onPressed: (BuildContext context) {
                    showPopupDialogBasedOnDevice(
                        context, chatController, false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showPopupDialogBasedOnDevice(
      BuildContext context, ChatController chatController, bool isArchived) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(
                isArchived ? 'Archive Conversation' : 'Delete Conversation'),
            content: Text(isArchived
                ? 'Are you sure you want to archive this conversation?'
                : 'Are you sure you want to delete this conversation?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  isArchived ? 'Archive' : 'Delete',
                  style:
                      TextStyle(color: isArchived ? Colors.blue : Colors.red),
                ),
                onPressed: () {
                  if (isArchived) {
                    chatController.archiveAllConversations();
                  } else {
                    chatController.deleteAllConversations();
                  }
                  chatController.newConversation();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
                isArchived ? 'Archive Conversation' : 'Delete Conversation'),
            content: Text(isArchived
                ? 'Are you sure you want to archive this conversation?'
                : 'Are you sure you want to delete this conversation?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  isArchived ? 'Archive' : 'Delete',
                  style:
                      TextStyle(color: isArchived ? Colors.blue : Colors.red),
                ),
                onPressed: () {
                  if (isArchived) {
                    chatController.archiveAllConversations();
                  } else {
                    chatController.deleteAllConversations();
                  }
                  chatController.newConversation();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
