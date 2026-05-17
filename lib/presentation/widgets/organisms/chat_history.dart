import 'package:flutter/material.dart';
import 'package:my_msg/domain/entities/message.dart';
import 'package:my_msg/presentation/widgets/molecules/chat_bubble.dart';

class ChatHistory extends StatelessWidget {
  final List<Message> messages;
  final String currentUserId;

  const ChatHistory({
    super.key,
    required this.messages,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true, // asumiendo que los mensajes más nuevos están al principio, o hacemos un sort
      padding: const EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Asumimos listado ordenado de más reciente a más antiguo si reverse es true, 
        // pero Bloc puede mandar la lista en orden cronológico, así que ajustamos:
        final message = messages[messages.length - 1 - index];
        return ChatBubble(
          message: message,
          isMe: message.senderId == currentUserId,
        );
      },
    );
  }
}
