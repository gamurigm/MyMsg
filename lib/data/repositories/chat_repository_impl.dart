import 'dart:typed_data';
import 'package:my_msg/domain/entities/chat.dart';
import 'package:my_msg/domain/entities/message.dart';
import 'package:my_msg/domain/repositories/chat_repository.dart';
import 'package:my_msg/data/datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Chat>> getChats() async {
    // Simulating fetching recent chats from local DB or REST API
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const Chat(id: 'chat1', name: 'Alice', avatarUrl: ''),
      const Chat(id: 'chat2', name: 'Bob', avatarUrl: ''),
    ];
  }

  @override
  Stream<Message> getMessagesStream(String chatId) {
    // Note: We might filter by chatId in a real scenario
    return remoteDataSource.messageStream.where((message) => message.chatId == chatId);
  }

  @override
  Future<void> sendMessage(Message message) async {
    remoteDataSource.sendMessage(message);
  }

  @override
  Future<String> uploadFile(Uint8List bytes, String fileName) {
    return remoteDataSource.uploadFile(bytes, fileName);
  }
}
