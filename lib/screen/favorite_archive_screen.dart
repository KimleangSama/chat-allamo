import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/model/conversation.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/setting_pref.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteArchiveScreen extends StatefulWidget {
  const FavoriteArchiveScreen({super.key});

  @override
  State<FavoriteArchiveScreen> createState() => _FavoriteArchiveScreenState();
}

class _FavoriteArchiveScreenState extends State<FavoriteArchiveScreen> {
  late int tabIndex = 1;

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<SharedPreferences>();
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text(
          'Favorites & Archive',
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: CustomSlidingSegmentedControl<int>(
                fixedWidth: 135,
                fromMax: true,
                children: const {
                  1: Text(
                    'Favorite',
                    textAlign: TextAlign.center,
                  ),
                  2: Text(
                    'Archive',
                    textAlign: TextAlign.center,
                  ),
                },
                decoration: BoxDecoration(
                  color: textPaddingColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                thumbDecoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.3),
                      blurRadius: 3.0,
                      spreadRadius: 1.0,
                      offset: const Offset(
                        2.0,
                        2.0,
                      ),
                    ),
                  ],
                ),
                onValueChanged: (int value) {
                  setState(() {
                    tabIndex = value;
                  });
                  hapticFeedbackEffect(prefs);
                },
              ),
            ),
            Flexible(
              child: tabIndex == 1
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      child: const FavoriteWidget(),
                    )
                  : Container(
                      padding: const EdgeInsets.all(10),
                      child: const ArchiveWidget(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationListWidget extends StatelessWidget {
  final bool Function(Conversation) filterCondition;
  final String emptyMessage;
  final IconData actionIcon;
  final void Function(ChatController, Conversation) onActionPressed;

  const ConversationListWidget({
    super.key,
    required this.filterCondition,
    required this.emptyMessage,
    required this.actionIcon,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final chatController = context.read<ChatController>();
    return ListenableBuilder(
      listenable: Listenable.merge([
        chatController.conversations,
      ]),
      builder: (context, _) {
        final conversations = chatController.conversations.value.data ?? [];
        final filteredCount =
            conversations.where(filterCondition).toList().length;
        if (filteredCount == 0) {
          return Center(
            child: Text(emptyMessage, style: const TextStyle(color: textColor)),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: conversations.length,
          separatorBuilder: (context, index) => const SizedBox(),
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            if (filterCondition(conversation)) {
              final subtitle =
                  '${conversation.formattedDate} - ${conversation.model}';
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(7.5),
                  onTap: () {
                    if (!conversation.isArchived) {
                      chatController.selectConversation(conversation);
                      toast(
                          "Selected '${conversation.title}'. Go to chat screen.");
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.5),
                      color: Colors.transparent,
                      border: Border.all(
                        color: filterCondition(conversation)
                            ? textPaddingColor
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
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
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(subtitle,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              onActionPressed(chatController, conversation),
                          icon: Icon(actionIcon),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Container();
          },
        );
      },
    );
  }
}

class FavoriteWidget extends StatelessWidget {
  const FavoriteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ConversationListWidget(
      filterCondition: (conversation) =>
          conversation.isFavorite && !conversation.isArchived,
      emptyMessage: 'No favorite conversation',
      actionIcon: FluentIcons.heart_20_filled,
      onActionPressed: (chatController, conversation) {
        chatController.toggleFavorite(conversation);
      },
    );
  }
}

class ArchiveWidget extends StatelessWidget {
  const ArchiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ConversationListWidget(
      filterCondition: (conversation) => conversation.isArchived,
      emptyMessage: 'No archived conversation',
      actionIcon: FluentIcons.archive_20_regular,
      onActionPressed: (chatController, conversation) {
        chatController.toggleArchive(conversation);
      },
    );
  }
}
