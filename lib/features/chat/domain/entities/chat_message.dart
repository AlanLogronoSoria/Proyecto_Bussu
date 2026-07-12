class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  // TODO (OpenCode): Generar factory fromJson y toJson para Supabase
}
