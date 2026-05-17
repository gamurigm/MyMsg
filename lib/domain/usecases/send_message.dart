import 'package:my_msg/domain/entities/message.dart';
import 'package:my_msg/domain/repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<void> call(Message message) {
    return repository.sendMessage(message);
  }
}
