class ChatConversation {
  final String id;
  final String driverId;
  final String driverName;
  final String? cooperativaId;
  final String? cooperativaName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String status;

  const ChatConversation({
    required this.id,
    required this.driverId,
    required this.driverName,
    this.cooperativaId,
    this.cooperativaName,
    this.lastMessage = '',
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.status = 'open',
  });
}
