import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento seguro para tokens, claves y datos sensibles.
///
/// Utiliza Keychain (iOS) y EncryptedSharedPreferences (Android).
/// NUNCA almacena tokens en SharedPreferences plano.
class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Guarda un valor seguro asociado a [key].
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Lee un valor seguro asociado a [key].
  static Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  /// Elimina un valor seguro.
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Elimina todos los valores seguros (logout).
  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// Verifica si el almacenamiento seguro está disponible.
  static Future<bool> isAvailable() async {
    try {
      await _storage.read(key: '_health_check');
      return true;
    } catch (_) {
      return false;
    }
  }
}
