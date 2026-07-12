import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/config/env.dart';
import 'output_sanitizer.dart';

/// Logger seguro que nunca expone PII en producción.
///
/// En debug: imprime mensajes completos a consola.
/// En producción: sanitiza datos sensibles y puede enviar a un servicio
/// de monitoreo (Sentry, Firebase Crashlytics).
class SecureLogger {
  SecureLogger._();

  static void info(String message, [Object? error]) {
    _log('INFO', message, error);
  }

  static void warning(String message, [Object? error]) {
    _log('WARN', message, error);
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    final sanitized = OutputSanitizer.sanitizeForLog(message);
    if (Env.isProduction) {
      debugPrint('[ERROR] $sanitized');
      if (error != null) {
        debugPrint('[ERROR] ${OutputSanitizer.sanitizeForLog(error.toString())}');
      }
    } else {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('[ERROR] $error');
      if (stack != null) debugPrint(stack.toString());
    }
  }

  static void fatal(String message, [Object? error, StackTrace? stack]) {
    _log('FATAL', message, error);
    if (stack != null && !Env.isProduction) {
      debugPrint(stack.toString());
    }
  }

  static void _log(String level, String message, Object? error) {
    if (Env.isProduction) {
      final sanitized = OutputSanitizer.sanitizeForLog(message);
      debugPrint('[$level] $sanitized');
    } else {
      debugPrint('[$level] $message');
      if (error != null) debugPrint('[$level] $error');
    }
  }
}
