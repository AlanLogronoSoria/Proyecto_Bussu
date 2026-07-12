class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'Error del servidor', this.statusCode]);

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Sin conexión a la red']);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthFailureException implements Exception {
  final String message;
  const AuthFailureException([this.message = 'Error de autenticación']);

  @override
  String toString() => 'AuthFailureException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Error de caché local']);

  @override
  String toString() => 'CacheException: $message';
}

class MqttException implements Exception {
  final String message;
  const MqttException([this.message = 'Error en conexión MQTT']);

  @override
  String toString() => 'MqttException: $message';
}

class RealtimeException implements Exception {
  final String message;
  const RealtimeException([this.message = 'Error en el canal en tiempo real']);

  @override
  String toString() => 'RealtimeException: $message';
}

class WebSocketException implements Exception {
  final String message;
  const WebSocketException([this.message = 'Error en conexión WebSocket']);

  @override
  String toString() => 'WebSocketException: $message';
}

class DeviceBindingException implements Exception {
  final String message;
  const DeviceBindingException([this.message = 'Dispositivo no vinculado']);

  @override
  String toString() => 'DeviceBindingException: $message';
}

class PaymentException implements Exception {
  final String message;
  const PaymentException([this.message = 'Error en el proceso de pago']);

  @override
  String toString() => 'PaymentException: $message';
}
