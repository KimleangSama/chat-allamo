import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/model/conversation.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/setting_pref.dart';
import 'package:chat_allamo/widget/chat_actions.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryChats extends StatefulWidget {
  final List<Conversation> conversations;
  final ValueChanged<Conversation> onChatSelection;

  const HistoryChats({
    super.key,
    required this.conversations,
    required this.onChatSelection,
  });

  @override
  State<HistoryChats> createState() => _HistoryChats();
}

class _HistoryChats extends State<HistoryChats> {
  @override
  Widget build(BuildContext context) {
    final controller = context.read<ChatController>();
    final prefs = context.read<SharedPreferences>();
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.selectedConversation,
      ]),
      builder: (context, _) {
        final selectedConversation = controller.selectedConversation.value;
        return Container(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final conversation = widget.conversations[index];
              final subtitle =
                  '${conversation.formattedDate} - ${conversation.model}';
              if (conversation.isArchived) return const SizedBox();
              return InkWell(
                borderRadius: BorderRadius.circular(7.5),
                onTap: () {
                  setState(() {
                    hapticFeedbackEffect(prefs);
                    widget.onChatSelection(conversation);
                  });
                },
                onLongPress: () {
                  showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => ChatActions(
                      conversation: conversation,
                      chatController: controller,
                      isSelectedModelShouldAppear: false,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: conversation.id == selectedConversation?.id
                        ? textPaddingColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7.5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conversation.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(subtitle, style: const TextStyle(fontSize: 12))
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          hapticFeedbackEffect(prefs);
                          controller.toggleFavorite(conversation);
                        },
                        icon: conversation.isFavorite
                            ? const Icon(FluentIcons.heart_20_filled)
                            : const Icon(FluentIcons.heart_20_regular),
                      )
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 10);
            },
            itemCount: widget.conversations.length,
          ),
        );
      },
    );
  }
}
