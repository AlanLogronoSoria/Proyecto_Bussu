/// Configuración específica del subsistema IoT.
///
/// Centraliza todos los parámetros de comunicación con hardware ESP32
/// y el servicio puente MQTT→Supabase. Flutter NUNCA se conecta
/// directamente al broker MQTT; consume datos vía Supabase Realtime.
class IotConfig {
  IotConfig._();

  // ---- MQTT Broker (solo para referencia del puente) ----
  static const String mqttBrokerHost = 'broker.andesmobility.com';
  static const int mqttBrokerPort = 8883;
  static const int mqttQos = 1;
  static const bool mqttUseTls = true;

  // ---- Telemetría ----
  /// Intervalo de publicación de telemetría del ESP32 (segundos).
  static const int telemetryPublishIntervalSec = 5;

  /// Tiempo máximo sin telemetría antes de marcar bus como inactivo.
  static const int telemetryTimeoutSec = 30;

  /// Tamaño del buffer de telemetría offline en el ESP32.
  static const int telemetryOfflineBufferSize = 100;

  // ---- HMAC Validation ----
  /// Clave secreta compartida entre el puente y el ESP32.
  /// En producción, debe configurarse via --dart-define=IOT_HMAC_SECRET=xxx
  static String get hmacSecretKey =>
      String.fromEnvironment('IOT_HMAC_SECRET', defaultValue: 'changeme');

  /// Algoritmo de HMAC: SHA-256.
  static const String hmacAlgorithm = 'HmacSHA256';

  // ---- Device Registry ----
  /// Tiempo máximo para considerar un dispositivo como "visto por última vez".
  static const int deviceSeenTimeoutMin = 5;

  // ---- Bridge Health ----
  /// Intervalo de health check del puente MQTT (segundos).
  static const int bridgeHealthCheckIntervalSec = 30;

  /// Máximo de reintentos de conexión del puente antes de alertar.
  static const int bridgeMaxReconnectAttempts = 10;

  // ---- Persistencia ----
  /// Tamaño máximo de la cola de telemetría offline en Supabase.
  static const int offlineQueueMaxSize = 1000;

  // ---- Topics MQTT ----
  static String telemetryTopic(String busId) => 'bus/$busId/telemetry';
  static String statusTopic(String busId) => 'bus/$busId/status';
  static String commandTopic(String busId) => 'bus/$busId/command';
  static String passengerTopic(String busId) => 'bus/$busId/passengers';
  static String otaCommandTopic(String busId) => 'bus/$busId/ota/command';
  static String otaStatusTopic(String busId) => 'bus/$busId/ota/status';
  static const String bridgeHealthTopic = 'bridge/health';
  static const String bridgeLogTopic = 'bridge/log';
  static const String systemBroadcastTopic = 'system/broadcast';

  // ---- OTA (Over-The-Air Updates) ----
  /// Tamaño máximo de chunk para descarga OTA (bytes).
  static const int otaChunkSize = 4096;

  /// Timeout de descarga OTA (segundos).
  static const int otaDownloadTimeoutSec = 300;

  /// Máximo de reintentos de OTA antes de marcar como fallido.
  static const int otaMaxRetries = 3;

  // ---- Watchdog ----
  /// Timeout del watchdog del ESP32 (segundos).
  /// Si no se alimenta en este tiempo, el ESP32 se reinicia.
  static const int watchdogTimeoutSec = 60;

  /// Tiempo entre heartbeats del hardware (segundos).
  static const int deviceHeartbeatIntervalSec = 10;

  // ---- Device Health ----
  /// Máximo de fallos consecutivos antes de marcar dispositivo como error.
  static const int maxConsecutiveFailures = 3;}
