import 'package:equatable/equatable.dart';
import 'message.dart';

class Chat extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final Message? lastMessage;

  const Chat({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.lastMessage,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, lastMessage];
}
