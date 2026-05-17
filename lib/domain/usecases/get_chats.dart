import 'package:my_msg/domain/entities/chat.dart';
import 'package:my_msg/domain/repositories/chat_repository.dart';

class GetChats {
  final ChatRepository repository;

  GetChats(this.repository);

  Future<List<Chat>> call() {
    return repository.getChats();
  }
}
