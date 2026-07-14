import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource? _remote;
  final StreamController<ChatMessage> _msgController = StreamController<ChatMessage>.broadcast();
  final StreamController<List<ChatConversation>> _convController = StreamController<List<ChatConversation>>.broadcast();
  final List<ChatMessage> _messages = [];
  final List<ChatConversation> _conversations = [];
  int _nextId = 1;

  ChatRepositoryImpl({ChatRemoteDataSource? remote}) : _remote = remote {
    if (_remote == null) _initMock();
  }

  void _initMock() {
    _addMsg('driver-1', 'Buenos dias, reportando inicio de ruta');
    _addMsg('coop', 'Recibido. Todo en orden?');
    _addMsg('driver-1', 'Si, todo normal. Hay trafico en Av. Central?');
    _addMsg('coop', 'Si, toma la ruta alterna. Te avisamos si se libera.');
    _addMsg('driver-1', 'Entendido, voy por la alterna. Gracias.');
    _conversations.addAll([
      ChatConversation(id: 'conv-1', driverId: 'driver-1', driverName: 'Carlos Mendoza', cooperativaName: 'TransLima Express', lastMessage: 'Entendido, voy por la alterna', lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)), unreadCount: 2, isOnline: true),
      ChatConversation(id: 'conv-2', driverId: 'driver-2', driverName: 'Luisa Rodriguez', cooperativaName: 'TransLima Express', lastMessage: 'Llegando a Miraflores', lastMessageAt: DateTime.now().subtract(const Duration(minutes: 20)), unreadCount: 0, isOnline: false),
    ]);
  }

  void _addMsg(String senderId, String content) {
    final msg = ChatMessage(id: '${_nextId++}', roomId: 'default', senderId: senderId, content: content, createdAt: DateTime.now().subtract(Duration(minutes: _messages.length)));
    _messages.add(msg);
    _msgController.add(msg);
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId) async {
    if (_remote != null) {
      try {
        final msgs = await _remote.fetchMessages(roomId);
        return Right(msgs);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    await Future.delayed(const Duration(milliseconds: 200));
    return Right(_messages.where((m) => m.roomId == roomId).toList());
  }

  @override
  Stream<Either<Failure, ChatMessage>> watchMessages(String roomId) {
    if (_remote != null) {
      return _remote.watchMessages(roomId).map((msg) => Right<Failure, ChatMessage>(msg));
    }
    return _msgController.stream.map((msg) => Right<Failure, ChatMessage>(msg));
  }

  @override
  Future<Either<Failure, void>> sendMessage({required String roomId, required String content}) async {
    if (_remote != null) {
      try {
        await _remote.insertMessage({'room_id': roomId, 'sender_id': 'current_user', 'content': content, 'created_at': DateTime.now().toIso8601String(), 'is_read': false});
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _addMsg('current_user', content);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<ChatConversation>>> listConversations() async {
    if (_remote != null) {
      try {
        final convs = await _remote.fetchConversations('current_user');
        return Right(convs);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    await Future.delayed(const Duration(milliseconds: 250));
    return Right(List.from(_conversations));
  }

  @override
  Stream<Either<Failure, List<ChatConversation>>> watchConversations() {
    if (_remote != null) {
      return _remote.watchConversations('current_user').map((c) => Right<Failure, List<ChatConversation>>([c]));
    }
    return _convController.stream.map((list) => Right<Failure, List<ChatConversation>>(list));
  }

  @override
  Future<Either<Failure, void>> markAsRead(String messageId) async {
    if (_remote != null) {
      try {
        await _remote.markMessageAsRead(messageId);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    for (final m in _messages) {
      if (m.id == messageId) {
        _messages[_messages.indexOf(m)] = m.copyWith(isRead: true);
        break;
      }
    }
    return const Right(null);
  }
}
