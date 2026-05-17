part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<Message> messages;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [messages, error];
}
