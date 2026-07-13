import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';

final chatRepositoryProvider = Provider<ChatRepository>((_) => ChatRepositoryImpl());

final conversationsProvider = FutureProvider<List<ChatConversation>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  final result = await repo.listConversations();
  return result.fold((_) => [], (list) => list);
});

Stream<List<ChatMessage>> _messageStream(ChatRepository repo, String roomId) async* {
  final initial = await repo.getMessages(roomId);
  final allMessages = initial.fold((_) => <ChatMessage>[], (msgs) => List<ChatMessage>.from(msgs));
  yield allMessages;

  await for (final either in repo.watchMessages(roomId)) {
    either.fold((_) {}, (msg) {
      allMessages.add(msg);
    });
    yield List<ChatMessage>.from(allMessages);
  }
}

final messagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
  final repo = ref.watch(chatRepositoryProvider);
  return _messageStream(repo, roomId);
});

final sendMessageAction = Provider.family<void Function(String), String>((ref, roomId) {
  return (String content) {
    ref.read(chatRepositoryProvider).sendMessage(roomId: roomId, content: content);
  };
});
