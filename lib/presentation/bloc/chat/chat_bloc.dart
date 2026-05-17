import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_msg/data/datasources/chat_remote_data_source.dart';
import 'package:my_msg/domain/entities/message.dart';
import 'package:my_msg/domain/usecases/get_messages_stream.dart';
import 'package:my_msg/domain/usecases/send_message.dart';
import 'package:my_msg/domain/repositories/chat_repository.dart';

part 'chat_state.dart';
part 'chat_event.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesStream getMessagesStream;
  final SendMessage sendMessage;
  final ChatRepository repository;
  final ChatRemoteDataSource dataSource;
  StreamSubscription? _messageSubscription;

  ChatBloc({
    required this.getMessagesStream,
    required this.sendMessage,
    required this.repository,
    required this.dataSource,
  }) : super(const ChatState()) {
    on<ConnectToChat>(_onConnectToChat);
    on<MessageReceived>(_onMessageReceived);
    on<SendMessageEvent>(_onSendMessage);
    on<SendFileEvent>(_onSendFile);
  }

  void _onConnectToChat(ConnectToChat event, Emitter<ChatState> emit) {
    // Si el WS no está conectado (ej: sesión restaurada), reconectar.
    // connect() internamente es idempotente si ya hay sesión activa.
    if (!dataSource.isConnected) {
      dataSource.reconnectIfNeeded();
    }

    _messageSubscription?.cancel();
    _messageSubscription = getMessagesStream(event.chatId).listen(
      (message) => add(MessageReceived(message)),
    );
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    // Evitar mensajes duplicados
    if (state.messages.any((m) => m.id == event.message.id)) return;
    emit(state.copyWith(messages: List.of(state.messages)..add(event.message)));
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await sendMessage(event.message);
      // We rely on the WebSocket to stream the message back to us, 
      // but for optimistic UI we could add it to state immediately here.
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSendFile(SendFileEvent event, Emitter<ChatState> emit) async {
    try {
      final fileUrl = await repository.uploadFile(event.fileBytes, event.fileName);
      final msg = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: event.chatId,
        senderId: event.senderId,
        content: '',
        timestamp: DateTime.now(),
        isFile: true,
        fileUrl: fileUrl,
      );
      await sendMessage(msg);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
