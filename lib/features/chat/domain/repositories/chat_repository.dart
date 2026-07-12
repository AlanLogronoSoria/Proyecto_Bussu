import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Obtiene el historial de mensajes de una sala específica
  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId);

  /// Suscripción en tiempo real a nuevos mensajes de una sala
  Stream<Either<Failure, ChatMessage>> watchMessages(String roomId);

  /// Envía un nuevo mensaje
  Future<Either<Failure, void>> sendMessage({
    required String roomId,
    required String content,
  });
}
