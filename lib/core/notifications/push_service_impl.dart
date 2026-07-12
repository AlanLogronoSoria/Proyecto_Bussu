import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'push_service.dart';

/// Implementación del servicio de notificaciones push usando Supabase Realtime.
///
/// Utiliza el canal de broadcast de Supabase para recibir notificaciones
/// en tiempo real mientras la app está en primer plano.
/// Para notificaciones en segundo plano, se requiere configuración nativa
/// de FCM/APNs y una Edge Function en Supabase que las despache.
class PushServiceImpl implements PushService {
  final SupabaseClient _client;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  final Set<String> _activeTopics = {};

  PushServiceImpl(this._client);

  @override
  Future<void> initialize() async {
    _client.channel('push_messages').onBroadcast(
      event: 'notification',
      callback: (payload) {
        _messageController.add(Map<String, dynamic>.from(payload));
      },
    ).subscribe();
  }

  @override
  Future<String?> getToken() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return null;

      final response = await _client
          .from('device_tokens')
          .select('token')
          .eq('user_id', session.user.id)
          .maybeSingle();

      return response?['token'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>> get onMessageReceived =>
      _messageController.stream;

  @override
  Future<void> subscribeToTopic(String topic) async {
    if (_activeTopics.contains(topic)) return;

    _client.channel('topic_$topic').onBroadcast(
      event: 'notification',
      callback: (payload) {
        _messageController.add(Map<String, dynamic>.from(payload));
      },
    ).subscribe();

    _activeTopics.add(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_activeTopics.contains(topic)) return;

    try {
      await _client.removeChannel(
        _client.channel('topic_$topic'),
      );
    } catch (_) {
      // Channel may already be removed
    }

    _activeTopics.remove(topic);
  }

  /// Libera recursos del servicio de push.
  void dispose() {
    for (final topic in _activeTopics) {
      try {
        _client.removeChannel(_client.channel('topic_$topic'));
      } catch (_) {}
    }
    try {
      _client.removeChannel(_client.channel('push_messages'));
    } catch (_) {}
    _activeTopics.clear();
    _messageController.close();
  }
}
