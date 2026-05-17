import 'package:flutter/material.dart';
import 'package:my_msg/domain/entities/chat.dart';
import 'package:my_msg/presentation/widgets/molecules/chat_list_item.dart';
import 'package:my_msg/presentation/pages/chat_page.dart';

class HomePage extends StatefulWidget {
  final String currentUsername;

  const HomePage({super.key, this.currentUsername = 'Guest'});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Chat> _chats = [
    const Chat(id: 'global', name: 'Global Room', lastMessage: null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text('MyMsg - ${widget.currentUsername}'),
        backgroundColor: const Color(0xFF2C6BED),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.public, color: Colors.white),
            ),
            title: Text(chat.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Únete para chatear', style: TextStyle(color: Colors.white54)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(chat: chat, currentUsername: widget.currentUsername),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
