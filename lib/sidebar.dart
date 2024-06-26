import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_llm_gui/profile_management_page.dart';

import 'chat_provider.dart';
import 'settings_page.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[200],
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: ProfileSelectionWidget(),
          ),
          const Expanded(
            child: ConversationList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              child: const Text('Settings'),
            ),
          ),
        ],
      ),
    );
  }
}

class ConversationList extends StatelessWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return ListView.builder(
          itemCount: chatProvider.conversations.length,
          itemBuilder: (context, index) {
            final conversationCount = chatProvider.conversations.length;
            final conversation =
                chatProvider.conversations[conversationCount - 1 - index];

            return ConversationListTile(conversation: conversation);
          },
        );
      },
    );
  }
}

class ConversationListTile extends StatefulWidget {
  final Conversation conversation;
  const ConversationListTile({super.key, required this.conversation});

  @override
  State<ConversationListTile> createState() => _ConversationListTileState();
}

class _ConversationListTileState extends State<ConversationListTile> {
  bool showButton = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        onEnter: (_) => setState(() => showButton = true),
        onExit: (_) => setState(() => showButton = false),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 0.0),
          title: Text(widget.conversation.title),
          onTap: () => context
              .read<ChatProvider>()
              .setCurrentConversation(widget.conversation.id),
          selected: identical(context.watch<ChatProvider>().currentConversation,
              widget.conversation),
          selectedTileColor: Colors.grey[300],
          trailing: Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: showButton,
            child: IconButton(
              icon: const Icon(Icons.delete_forever_rounded),
              tooltip: 'Delete',
              onPressed: () => context
                  .read<ChatProvider>()
                  .deleteConversation(widget.conversation.id),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileSelectionWidget extends StatelessWidget {
  const ProfileSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        var items = chatProvider.profiles
            .map((ChatSettings item) => DropdownMenuItem<ChatSettings>(
                  value: item,
                  child: Text(item.name),
                ))
            .toList();

        return Row(children: [
          IconButton(
            icon: const Icon(Icons.app_registration),
            tooltip: 'Profile Management',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileManagementPage(),
                ),
              );
            },
          ),
          Expanded(
            child: DropdownButton<ChatSettings>(
              value: chatProvider.currentProfile,
              onChanged: (ChatSettings? newValue) {
                chatProvider.setCurrentProfile(newValue!);
              },
              items: items,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
            onPressed: () {
              chatProvider.createConversation();
            },
          ),
        ]);
      },
    );
  }
}
