import 'dart:io';

import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/model/conversation.dart';
import 'package:chat_allamo/screen/ollama_model_list_screen.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatActions extends StatefulWidget {
  final Conversation? conversation;
  final ChatController chatController;
  final bool isSelectedModelShouldAppear;

  const ChatActions({
    super.key,
    required this.conversation,
    required this.chatController,
    this.isSelectedModelShouldAppear = true,
  });

  @override
  State<ChatActions> createState() => _ChatActionsState();
}

class _ChatActionsState extends State<ChatActions> {
  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appBarColor,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.isSelectedModelShouldAppear)
              ListTile(
                title: const Text(
                  'Select Model',
                  style: TextStyle(color: textColor),
                ),
                leading: const Icon(
                  FluentIcons.apps_20_regular,
                  color: textColor,
                ),
                trailing: const Icon(FluentIcons.chevron_right_16_regular),
                onTap: () {
                  showCupertinoModalBottomSheet(
                    expand: false,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const OllamaModelListScreen(),
                  );
                },
              ),
            if (widget.conversation == null)
              ListTile(
                title: const Text(
                  'Help and Info',
                  style: TextStyle(color: textColor),
                ),
                leading: const Icon(
                  FluentIcons.info_16_regular,
                  color: textColor,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _launchUrl(Uri.parse("https://ollama.com/library"));
                },
              ),
            if (widget.conversation != null)
              Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Rename',
                      style: TextStyle(color: textColor),
                    ),
                    leading: const Icon(FluentIcons.edit_20_regular,
                        color: textColor),
                    onTap: () {
                      _showRenameDialog(context);
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Archive',
                      style: TextStyle(color: textColor),
                    ),
                    leading: const Icon(FluentIcons.archive_20_regular,
                        color: textColor),
                    onTap: () {
                      widget.chatController.toggleArchive(
                        widget.conversation!,
                      );
                      widget.chatController.newConversation();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    leading: const Icon(FluentIcons.delete_20_regular,
                        color: Colors.red),
                    onTap: () {
                      _showDeleteDialog(context);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    if (Platform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => CupertinoAlertDialog(
          title: const Text(
            'Rename Conversation',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: CupertinoTextField(
              controller: controller..text = widget.conversation?.title ?? '',
              placeholder: 'New Title',
              style: const TextStyle(color: textColor),
            ),
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                widget.chatController.renameConversationTitle(
                  widget.conversation!,
                  controller.text,
                );
                Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AlertDialog(
          backgroundColor: textPaddingColor,
          title: const Text(
            'Rename Conversation',
            style: TextStyle(fontSize: 17),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller
                      ..text = widget.conversation?.title ?? '',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'New Title',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                widget.chatController.renameConversationTitle(
                    widget.conversation!, controller.text);
                Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) {
          return CupertinoAlertDialog(
            title: const Text('Delete Conversation'),
            content: const Text(
                'Are you sure you want to delete this conversation?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text('Delete'),
                onPressed: () {
                  widget.chatController
                      .deleteConversation(widget.conversation!);
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (Platform.isAndroid) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) {
          return AlertDialog(
            title: const Text('Delete Conversation'),
            content: const Text(
                'Are you sure you want to delete this conversation?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  widget.chatController
                      .deleteConversation(widget.conversation!);
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
