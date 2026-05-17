import 'dart:typed_data';
import 'package:my_msg/domain/entities/chat.dart';
import 'package:my_msg/domain/entities/message.dart';

abstract class ChatRepository {
  Future<List<Chat>> getChats();
  Stream<Message> getMessagesStream(String chatId);
  Future<void> sendMessage(Message message);
  Future<String> uploadFile(Uint8List bytes, String fileName);
}
