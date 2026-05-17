part of 'chat_bloc.dart';


abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ConnectToChat extends ChatEvent {
  final String chatId;
  const ConnectToChat(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class MessageReceived extends ChatEvent {
  final Message message;
  const MessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class SendMessageEvent extends ChatEvent {
  final Message message;
  const SendMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}

class SendFileEvent extends ChatEvent {
  final String chatId;
  final String senderId;
  final Uint8List fileBytes;
  final String fileName;
  const SendFileEvent(this.chatId, this.senderId, this.fileBytes, this.fileName);

  @override
  List<Object> get props => [chatId, senderId, fileBytes, fileName];
}
