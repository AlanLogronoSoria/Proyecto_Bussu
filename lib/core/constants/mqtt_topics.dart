import '../constants/app_roles.dart';

class MqttTopics {
  MqttTopics._();

  static String busTelemetry(String busId) => 'bus/$busId/telemetry';

  static String busStatus(String busId) => 'bus/$busId/status';

  static String busCommand(String busId) => 'bus/$busId/command';

  static String busAlerts(String busId) => 'bus/$busId/alerts';

  static String passengerCount(String busId) => 'bus/$busId/passengers';

  static const String allBuses = 'bus/+/telemetry';

  static String routeUpdates(String routeId) => 'route/$routeId/updates';

  static const String systemAlerts = 'system/alerts';

  static const String systemBroadcast = 'system/broadcast';

  static const String stopRequests = 'stops/requests';

  static String stopApprovals(String stopId) => 'stops/$stopId/approval';

  static String chatMessage(String conversationId) =>
      'chat/$conversationId/message';

  static String clientStatus(String clientId) =>
      'bussu/$clientId/status';

  static String roleTopic(UserRole role) {
    switch (role) {
      case UserRole.usuario:
        return 'role/usuario';
      case UserRole.conductor:
        return 'role/conductor';
      case UserRole.cooperativaAdmin:
        return 'role/cooperativa';
      case UserRole.municipalAdmin:
        return 'role/admin';
    }
  }

  static String busWildcard(String cooperativaId) =>
      'bus/$cooperativaId/+/telemetry';
}
