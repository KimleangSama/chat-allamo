import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/controller/model_controller.dart';
import 'package:chat_allamo/controller/network_controller.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/setting_pref.dart';
import 'package:chat_allamo/widget/chat_actions.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppChatBar extends StatefulWidget implements PreferredSizeWidget {
  final ZoomDrawerController z;

  const AppChatBar({super.key, required this.z});

  @override
  State<AppChatBar> createState() => _AppChatBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppChatBar extends State<AppChatBar> {
  @override
  Widget build(BuildContext context) {
    final controller = context.read<ModelController>();
    final chatController = context.read<ChatController>();
    final networkController = context.read<NetworkController>();
    final prefs = context.read<SharedPreferences>();
    return AppBar(
      backgroundColor: appBarColor,
      title: ListenableBuilder(
        listenable: Listenable.merge(
          [
            controller.currentModel,
            chatController.selectedConversation,
            networkController.connectionStatus,
          ],
        ),
        builder: (context, child) {
          final model = controller.currentModel.value;
          final selectedConversation =
              chatController.selectedConversation.value;
          final connectivity = networkController.connectionStatus.value;
          final bool isConnected = connectivity == InternetStatus.connected;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (!isConnected)
                    ? null
                    : () {
                        hapticFeedbackEffect(prefs);
                        showCupertinoModalBottomSheet(
                          expand: false,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ChatActions(
                            conversation: selectedConversation,
                            chatController: chatController,
                          ),
                        );
                      },
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Chat Allamo",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                          ),
                        ),
                        if (isConnected)
                          Text(
                            model?.model ?? 'Select Model',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 13,
                            ),
                          )
                      ],
                    ),
                    if (isConnected)
                      const IconButton(
                        icon: Icon(FluentIcons.chevron_down_24_regular),
                        color: textColor,
                        iconSize: 15,
                        onPressed: null,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          FluentIcons.list_20_regular,
          color: textColor,
        ),
        onPressed: () {
          hapticFeedbackEffect(prefs);
          widget.z.toggle?.call();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(
            FluentIcons.copy_add_20_regular,
            color: textColor,
          ),
          onPressed: () {
            hapticFeedbackEffect(prefs);
            chatController.newConversation();
          },
        ),
      ],
    );
  }
}
