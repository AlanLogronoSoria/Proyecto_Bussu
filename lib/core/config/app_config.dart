import 'env.dart';

class AppConfig {
  AppConfig._();

  static const Duration mqttReconnectMinDelay = Duration(seconds: 1);
  static const Duration mqttReconnectMaxDelay = Duration(minutes: 2);
  static const double mqttBackoffMultiplier = 2;
  static const int mqttQos = 1;
  static const Duration mqttKeepAlive = Duration(seconds: 30);
  static const Duration mqttPingInterval = Duration(seconds: 10);

  static const Duration connectivityThrottle = Duration(seconds: 1);

  static const Duration wsReconnectMinDelay = Duration(seconds: 1);
  static const Duration wsReconnectMaxDelay = Duration(seconds: 30);
  static const double wsBackoffMultiplier = 2;

  static const Duration positionInterpolation = Duration(seconds: 5);

  static const int beaconScanDuration = 10;
  static const int etaSmoothingWindow = 6;

  static const double stopGeofenceRadiusMeters = 30;

  static String get supabaseUrl => Env.supabaseUrl;
  static String get supabaseAnonKey => Env.supabaseAnonKey;
}
