import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_conversation.dart';
import '../repositories/chat_repository.dart';

class ListConversationsUseCase {
  final ChatRepository _repo;
  ListConversationsUseCase(this._repo);
  Future<Either<Failure, List<ChatConversation>>> execute() {
    return _repo.listConversations();
  }
}
