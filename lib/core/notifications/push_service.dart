abstract class PushService {
  /// Inicializa el servicio de mensajería (FCM/Supabase)
  /// Solicita permisos de notificación al SO.
  Future<void> initialize();

  /// Obtiene el token actual del dispositivo para push notifications
  Future<String?> getToken();

  /// Stream para escuchar mensajes entrantes mientras la app está activa
  Stream<Map<String, dynamic>> get onMessageReceived;

  /// Método para suscribirse a un tópico específico (ej. ruta_123)
  Future<void> subscribeToTopic(String topic);

  /// Método para desuscribirse de un tópico
  Future<void> unsubscribeFromTopic(String topic);
}
