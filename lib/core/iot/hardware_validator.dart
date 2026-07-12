import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'iot_config.dart';

/// Validador de autenticidad de hardware ESP32 via HMAC.
///
/// Cada ESP32 tiene un `hardware_device_id` y comparte una clave secreta
/// con el servicio puente. En cada mensaje de telemetría, el ESP32 incluye
/// un HMAC-SHA256 calculado sobre (deviceId + timestamp + payload).
///
/// El puente valida este HMAC antes de escribir en Supabase, garantizando
/// que solo dispositivos autorizados publiquen telemetría.
class HardwareValidator {
  HardwareValidator._();

  /// Calcula el HMAC esperado para un dispositivo y payload.
  ///
  /// [hardwareDeviceId] — ID único del ESP32 registrado en [buses.hardware_device_id].
  /// [timestamp] — timestamp Unix en segundos del mensaje.
  /// [payload] — cuerpo del mensaje de telemetría serializado.
  /// [secret] — clave secreta compartida (por defecto [IotConfig.hmacSecretKey]).
  static String calculateHmac({
    required String hardwareDeviceId,
    required int timestamp,
    required String payload,
    String? secret,
  }) {
    final key = utf8.encode(secret ?? IotConfig.hmacSecretKey);
    final message = '$hardwareDeviceId:$timestamp:$payload';
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(utf8.encode(message));
    return digest.toString();
  }

  /// Valida que el HMAC recibido coincida con el esperado.
  ///
  /// Retorna `true` si el dispositivo está autenticado correctamente.
  /// Rechaza mensajes con más de [maxAgeSeconds] de antigüedad para
  /// prevenir ataques de replay.
  static bool validateHmac({
    required String hardwareDeviceId,
    required int timestamp,
    required String payload,
    required String receivedHmac,
    int maxAgeSeconds = 60,
    String? secret,
  }) {
    // Prevenir replay attacks: timestamp muy antiguo
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if ((now - timestamp).abs() > maxAgeSeconds) {
      return false;
    }

    final expectedHmac = calculateHmac(
      hardwareDeviceId: hardwareDeviceId,
      timestamp: timestamp,
      payload: payload,
      secret: secret,
    );

    return _constantTimeCompare(expectedHmac, receivedHmac);
  }

  /// Comparación en tiempo constante para prevenir timing attacks.
  static bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
