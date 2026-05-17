import 'package:my_msg/domain/entities/message.dart';
import 'package:my_msg/domain/repositories/chat_repository.dart';

class GetMessagesStream {
  final ChatRepository repository;

  GetMessagesStream(this.repository);

  Stream<Message> call(String chatId) {
    return repository.getMessagesStream(chatId);
  }
}
