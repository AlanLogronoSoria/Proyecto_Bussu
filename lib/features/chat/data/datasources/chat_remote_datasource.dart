import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_conversation.dart';

class ChatRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChatRemoteDataSource(this.supabaseClient);

  Future<List<ChatMessage>> fetchMessages(String roomId) async {
    final response = await supabaseClient
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: true);
    return (response as List<dynamic>).map((m) => ChatMessage.fromJson(m as Map<String, dynamic>)).toList();
  }

  Stream<ChatMessage> watchMessages(String roomId) {
    return supabaseClient
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((data) => ChatMessage.fromJson(data as Map<String, dynamic>));
  }

  Future<void> insertMessage(Map<String, dynamic> data) async {
    await supabaseClient.from('chat_messages').insert(data);
  }

  Future<void> markMessageAsRead(String messageId) async {
    await supabaseClient.from('chat_messages').update({'is_read': true}).eq('id', messageId);
  }

  Future<List<ChatConversation>> fetchConversations(String userId) async {
    final response = await supabaseClient
        .from('chat_conversations')
        .select()
        .or('driver_id.eq.$userId,cooperativa_id.eq.$userId')
        .order('last_message_at', ascending: false);
    return (response as List<dynamic>).map((c) => ChatConversation.fromJson(c as Map<String, dynamic>)).toList();
  }

  Stream<ChatConversation> watchConversations(String userId) {
    return supabaseClient
        .from('chat_conversations')
        .stream(primaryKey: ['id'])
        .eq('driver_id', userId)
        .map((data) => ChatConversation.fromJson(data as Map<String, dynamic>));
  }

  Future<void> upsertConversation(Map<String, dynamic> data) async {
    await supabaseClient.from('chat_conversations').upsert(data);
  }
}
