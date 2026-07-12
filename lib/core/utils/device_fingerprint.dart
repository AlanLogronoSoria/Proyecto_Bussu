import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Genera un fingerprint único del dispositivo para el binding de sesión.
///
/// Combina atributos del hardware y SO que son estables durante el ciclo
/// de vida de la app. No cambia entre reinstalaciones en el mismo
/// dispositivo físico (salvo reseteo de fábrica).
class DeviceFingerprint {
  DeviceFingerprint._();

  /// Genera el fingerprint a partir de los datos del dispositivo.
  ///
  /// Retorna un hash SHA-256 hexadecimal de 64 caracteres.
  static Future<String> generate({
    DeviceInfoPlugin? plugin,
  }) async {
    final deviceInfo = plugin ?? DeviceInfoPlugin();

    try {
      final androidInfo = await deviceInfo.androidInfo;
      return _hash('android:${androidInfo.id}:${androidInfo.display}');
    } catch (_) {
      // No es Android
    }

    try {
      final iosInfo = await deviceInfo.iosInfo;
      return _hash('ios:${iosInfo.identifierForVendor}:${iosInfo.utsname.machine}');
    } catch (_) {
      // No es iOS
    }

    try {
      final linuxInfo = await deviceInfo.linuxInfo;
      return _hash('linux:${linuxInfo.machineId}');
    } catch (_) {
      // No es Linux
    }

    try {
      final windowsInfo = await deviceInfo.windowsInfo;
      return _hash('windows:${windowsInfo.deviceId}');
    } catch (_) {
      // No es Windows
    }

    try {
      final macInfo = await deviceInfo.macOsInfo;
      return _hash('macos:${macInfo.systemGUID}');
    } catch (_) {
      // No es macOS
    }

    // Web fallback
    try {
      final webInfo = await deviceInfo.webBrowserInfo;
      return _hash('web:${webInfo.userAgent}:${webInfo.platform}');
    } catch (_) {
      return _hash('unknown:${DateTime.now().millisecondsSinceEpoch}');
    }
  }

  static String _hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
