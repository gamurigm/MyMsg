import 'package:flutter/material.dart';
import 'package:my_msg/domain/entities/chat.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        chat.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage?.content ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: chat.lastMessage != null
          ? Text(
              "${chat.lastMessage!.timestamp.hour.toString().padLeft(2, '0')}:${chat.lastMessage!.timestamp.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            )
          : null,
      onTap: onTap,
    );
  }
}
