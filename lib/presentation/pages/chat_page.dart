import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_msg/domain/entities/chat.dart';
import 'package:my_msg/domain/entities/message.dart';
import 'package:my_msg/presentation/bloc/chat/chat_bloc.dart';
import 'package:my_msg/presentation/widgets/organisms/chat_history.dart';
import 'package:my_msg/presentation/widgets/molecules/message_input_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_msg/presentation/pages/connection_page.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  final String currentUsername;

  const ChatPage({super.key, required this.chat, this.currentUsername = 'Guest'});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ConnectToChat(widget.chat.id));
  }

  void _handleSendText(String text) {
    final msg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: widget.currentUsername,
      content: text,
      timestamp: DateTime.now(),
    );
    context.read<ChatBloc>().add(SendMessageEvent(msg));
  }

  Future<void> _handleSendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      if (mounted) {
        context.read<ChatBloc>().add(
          SendFileEvent(widget.chat.id, widget.currentUsername, file.bytes!, file.name),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF121820).withOpacity(0.9),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              child: Icon(Icons.public, color: Color(0xFF00E5FF)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.chat.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
                const Text('Online', style: TextStyle(fontSize: 12, color: Color(0xFF00B8D4))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF00E5FF)),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ConnectionPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E14), Color(0xFF121820)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state.error != null) {
                    return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.white)));
                  }
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum_outlined, size: 80, color: const Color(0xFF00E5FF).withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            '¡Bienvenido al chat!',
                            style: TextStyle(color: const Color(0xFF00E5FF), fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(color: const Color(0xFF00E5FF).withOpacity(0.5), blurRadius: 10)]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Envía un mensaje o comparte un archivo para empezar.',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return SelectionArea(
                    child: ChatHistory(
                      messages: state.messages,
                      currentUserId: widget.currentUsername,
                    ),
                  );
                },
              ),
            ),
            MessageInputField(
              onSendText: _handleSendText,
              onSendFile: _handleSendFile,
            ),
          ],
        ),
      ),
    );
  }
}
