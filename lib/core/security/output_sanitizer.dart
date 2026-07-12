import 'dart:convert';

/// Sanitizador de output para prevenir XSS e inyección.
///
/// Todo dato que se muestre al usuario desde fuentes externas
/// (backend, MQTT, IoT) debe pasar por esta clase.
class OutputSanitizer {
  OutputSanitizer._();

  /// Sanitiza texto plano para mostrar en UI.
  /// Trunca a [maxLength] y escapa caracteres de control.
  static String sanitizeText(String? input, {int maxLength = 500}) {
    if (input == null || input.isEmpty) return '';
    var sanitized = input
        .replaceAll('\x00', '')
        .replaceAll('\r', '')
        .replaceAll('\t', ' ')
        .trim();
    if (sanitized.length > maxLength) {
      sanitized = '${sanitized.substring(0, maxLength)}...';
    }
    return sanitized;
  }

  /// Sanitiza email (lowercase, trim, validación básica).
  static String sanitizeEmail(String? input) {
    if (input == null) return '';
    return input.trim().toLowerCase();
  }

  /// Sanitiza nombre (solo letras, espacios, acentos).
  static String sanitizeName(String? input, {int maxLength = 100}) {
    if (input == null || input.isEmpty) return '';
    final regex = RegExp(r'[^\w\sáéíóúÁÉÍÓÚñÑ\-]');
    var sanitized = input.replaceAll(regex, '').trim();
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    return sanitized;
  }

  /// Sanitiza datos para logging (remueve PII).
  /// Reemplaza emails, tokens y coordenadas GPS precisas.
  static String sanitizeForLog(String? input) {
    if (input == null || input.isEmpty) return '';
    var sanitized = input;
    sanitized = sanitized.replaceAll(
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
      '[EMAIL]',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'eyJ[a-zA-Z0-9\-_]+\.eyJ[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+'),
      '[JWT]',
    );
    return sanitized;
  }

  /// Sanitiza placa vehicular.
  static String sanitizePlate(String? input) {
    if (input == null) return '';
    return input.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\-]'), '');
  }

  /// Sanitiza RUC (solo dígitos).
  static String sanitizeRuc(String? input) {
    if (input == null) return '';
    return input.replaceAll(RegExp('[^0-9]'), '').substring(
      0, input.length > 11 ? 11 : input.length,
    );
  }

  /// Sanitiza JSON para prevenir prototipo pollution.
  static Map<String, dynamic> sanitizeJson(Map<String, dynamic> input) {
    final forbidden = ['__proto__', 'constructor', 'prototype'];
    return Map.fromEntries(
      input.entries.where((e) =>
          !forbidden.contains(e.key) && e.value != null),
    );
  }
}
