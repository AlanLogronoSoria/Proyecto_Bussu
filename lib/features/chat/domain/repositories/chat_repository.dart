import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId);
  Stream<Either<Failure, ChatMessage>> watchMessages(String roomId);
  Future<Either<Failure, void>> sendMessage({required String roomId, required String content});
  Future<Either<Failure, List<ChatConversation>>> listConversations();
}
