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
  final bool isOnline;

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
    this.isOnline = false,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      driverName: json['driver_name'] as String? ?? '',
      cooperativaId: json['cooperativa_id'] as String?,
      cooperativaName: json['cooperativa_name'] as String?,
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      unreadCount: json['unread_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'open',
      isOnline: json['is_online'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'driver_id': driverId,
    'driver_name': driverName,
    'cooperativa_id': cooperativaId,
    'cooperativa_name': cooperativaName,
    'last_message': lastMessage,
    'last_message_at': lastMessageAt.toIso8601String(),
    'unread_count': unreadCount,
    'status': status,
    'is_online': isOnline,
  };

  ChatConversation copyWith({
    String? id, String? driverId, String? driverName, String? cooperativaId,
    String? cooperativaName, String? lastMessage, DateTime? lastMessageAt,
    int? unreadCount, String? status, bool? isOnline,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      cooperativaId: cooperativaId ?? this.cooperativaId,
      cooperativaName: cooperativaName ?? this.cooperativaName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
