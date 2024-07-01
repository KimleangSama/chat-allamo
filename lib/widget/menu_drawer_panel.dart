import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/model/conversation.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/widget/history_chats.dart';
import 'package:chat_allamo/widget/user_profile_setting.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

class MenuDrawerPanel extends StatelessWidget {
  final ZoomDrawerController z;
  final ValueNotifier<String> filterNotifier = ValueNotifier('');
  final ValueChanged<Conversation> onChatSelection;

  MenuDrawerPanel({
    super.key,
    required this.onChatSelection,
    required this.z,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListenableBuilder(
          listenable: Listenable.merge([
            controller.conversations,
            filterNotifier,
          ]),
          builder: (context, _) {
            final conversations = controller.conversations.value.data ?? [];
            final filter = filterNotifier.value;
            final hasAllArchived =
                conversations.every((element) => element.isArchived);
            return SuperScaffold(
              stretch: true,
              appBar: SuperAppBar(
                title: const Text("ChatAllamo",
                    style: TextStyle(color: textColor, fontSize: 17)),
                backgroundColor: Colors.transparent,
                largeTitle: SuperLargeTitle(
                  enabled: false,
                  largeTitle: "ChatAllamo",
                ),
                shadowColor: Colors.transparent,
                searchBar: SuperSearchBar(
                  resultColor: scaffoldColor,
                  enabled: true,
                  scrollBehavior: SearchBarScrollBehavior.pinned,
                  resultBehavior: SearchBarResultBehavior.visibleOnInput,
                  onChanged: (query) {
                    filterNotifier.value = query;
                  },
                  searchResult: ValueListenableBuilder(
                    valueListenable: filterNotifier,
                    builder: (context, value, _) {
                      bool match(Conversation element) => (element.title)
                          .toLowerCase()
                          .contains(filter.toLowerCase());
                      final filteredConversations = filter.isEmpty
                          ? conversations
                          : conversations.where(match).toList();
                      return HistoryChats(
                        onChatSelection: onChatSelection,
                        conversations: filteredConversations,
                      );
                    },
                  ),
                ),
              ),
              body: Container(
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                color: Colors.transparent,
                child: Column(
                  children: [
                    conversations.isEmpty || hasAllArchived
                        ? Expanded(
                            child: Center(child: NewChatWidget(z: z)),
                          )
                        : Expanded(
                            child: HistoryChats(
                              onChatSelection: onChatSelection,
                              conversations: conversations,
                            ),
                          ),
                    const SizedBox(height: 1.5),
                    const UserProfileSetting(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MenuClass {
  final String title;
  final IconData icon;
  final int index;

  const MenuClass(this.title, this.icon, this.index);
}

class NewChatWidget extends StatelessWidget {
  final ZoomDrawerController z;

  const NewChatWidget({super.key, required this.z});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ChatController>();
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          controller.newConversation();
          z.toggle?.call();
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.add_20_regular, color: textColor),
              SizedBox(
                width: 10,
              ),
              Text("New Chat",
                  style: TextStyle(color: textColor, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
