import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repo;
  SendMessageUseCase(this._repo);
  Future<Either<Failure, void>> execute({required String roomId, required String content}) {
    return _repo.sendMessage(roomId: roomId, content: content);
  }
}
