/// Niveles de severidad para el registro de eventos.
///
/// Ordenados de menor a mayor criticidad:
/// [LogLevel.debug] < [LogLevel.info] < [LogLevel.warning] < [LogLevel.error] < [LogLevel.fatal]
enum LogLevel {
  /// Información de depuración, solo visible en desarrollo.
  debug,

  /// Eventos informativos del flujo normal de la aplicación.
  info,

  /// Situaciones anómalas que no interrumpen la ejecución pero requieren atención.
  warning,

  /// Errores que afectan una funcionalidad específica pero no bloquean la app.
  error,

  /// Errores críticos que comprometen la estabilidad de la aplicación.
  fatal,
}

/// Abstracción del servicio de logging estructurado.
///
/// Permite registrar eventos con distintos niveles de severidad.
/// La implementación concreta puede enviar logs a la consola, a un
/// archivo local, a un servicio remoto (Sentry, Firebase Crashlytics),
/// o a una combinación de estos según el entorno.
abstract class LogService {
  /// Registra un mensaje de depuración.
  ///
  /// Solo debe ser visible en entornos de desarrollo.
  /// [error] y [stackTrace] son opcionales para contexto adicional.
  void debug(String message, [Object? error, StackTrace? stackTrace]);

  /// Registra un evento informativo del flujo normal.
  void info(String message, [Object? error, StackTrace? stackTrace]);

  /// Registra una advertencia que no interrumpe la ejecución.
  void warning(String message, [Object? error, StackTrace? stackTrace]);

  /// Registra un error que afecta una funcionalidad específica.
  void error(String message, [Object? error, StackTrace? stackTrace]);

  /// Registra un error crítico que compromete la estabilidad.
  void fatal(String message, [Object? error, StackTrace? stackTrace]);
}
