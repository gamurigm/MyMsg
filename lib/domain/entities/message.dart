import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isFile;
  final String? fileUrl;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isFile = false,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [id, chatId, senderId, content, timestamp, isFile, fileUrl];
}
