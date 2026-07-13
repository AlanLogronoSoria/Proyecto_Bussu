import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final StreamController<ChatMessage> _controller = StreamController<ChatMessage>.broadcast();
  final List<ChatMessage> _messages = [];
  int _nextId = 1;

  ChatRepositoryImpl() {
    _add('driver-1', 'Buenos dias, reportando inicio de ruta');
    _add('coop', 'Recibido. Todo en orden?');
    _add('driver-1', 'Si, todo normal. Hay trafico en Av. Central?');
    _add('coop', 'Si, toma la ruta alterna. Te avisamos si se libera.');
    _add('driver-1', 'Entendido, voy por la alterna. Gracias.');
  }

  void _add(String senderId, String content) {
    final msg = ChatMessage(
      id: '${_nextId++}',
      roomId: 'default',
      senderId: senderId,
      content: content,
      createdAt: DateTime.now().subtract(Duration(minutes: _messages.length)),
    );
    _messages.add(msg);
    _controller.add(msg);
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Right(_messages.toList());
  }

  @override
  Stream<Either<Failure, ChatMessage>> watchMessages(String roomId) {
    return _controller.stream.map((msg) => Right<Failure, ChatMessage>(msg));
  }

  @override
  Future<Either<Failure, void>> sendMessage({required String roomId, required String content}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _add('current_user', content);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<ChatConversation>>> listConversations() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return Right([
      ChatConversation(id: 'conv-1', driverId: 'driver-1', driverName: 'Carlos Mendoza', cooperativaName: 'TransLima Express', lastMessage: 'Entendido, voy por la alterna', lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)), unreadCount: 2),
      ChatConversation(id: 'conv-2', driverId: 'driver-2', driverName: 'Luisa Rodriguez', cooperativaName: 'TransLima Express', lastMessage: 'Llegando a Miraflores', lastMessageAt: DateTime.now().subtract(const Duration(minutes: 20)), unreadCount: 0),
    ]);
  }
}
