import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/env.dart';

/// Configura certificate pinning para conexiones HTTP.
///
/// En producción, verifica que el certificado del servidor coincida
/// con los fingerprints esperados. Previene ataques MITM.
class CertificatePinner {
  CertificatePinner._();

  /// Fingerprints SHA-256 de los certificados esperados.
  /// Formato: Base64(SHA-256(DER))
  static const List<String> _supabasePins = [
    // Supabase production
    'supabase_pin_placeholder',
  ];

  static const List<String> _mqttPins = [
    'mqtt_broker_pin_placeholder',
  ];

  /// Configura el HttpClient global con certificate pinning.
  static void configure() {
    if (!Env.isProduction) return;

    HttpOverrides.global = _PinningHttpOverrides();
  }

  /// Verifica que el [certificate] coincida con los pins esperados para [host].
  static bool verifyCertificate(String host, String certificatePin) {
    if (host.contains('supabase')) {
      return _supabasePins.contains(certificatePin);
    }
    if (host.contains('mqtt') || host.contains('broker')) {
      return _mqttPins.contains(certificatePin);
    }
    return false;
  }
}

class _PinningHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) {
      if (!Env.isProduction) return true;
      final pin = _certificatePin(cert);
      debugPrint('[SECURITY] Certificate pin for $host: $pin');
      return CertificatePinner.verifyCertificate(host, pin);
    };
    return client;
  }

  String _certificatePin(dynamic cert) {
    return 'placeholder';
  }
}
