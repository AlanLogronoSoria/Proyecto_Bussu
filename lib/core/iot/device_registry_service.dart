import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registro de dispositivos ESP32 conectados al sistema.
///
/// Flutter no se comunica directamente con los ESP32, pero necesita
/// conocer el estado del hardware para mostrar indicadores de:
/// - Última telemetría recibida
/// - Estado de conexión del bus
/// - Alertas de hardware desconectado
class DeviceRegistryService {
  final Map<String, DeviceInfo> _devices = {};

  /// Registra un dispositivo en el registro local.
  void register(String deviceId, String busId) {
    _devices[deviceId] = DeviceInfo(
      deviceId: deviceId,
      busId: busId,
      firstSeen: DateTime.now(),
      lastSeen: DateTime.now(),
      status: DeviceStatus.online,
    );
  }

  /// Actualiza la última vez que se recibió telemetría del dispositivo.
  void heartbeat(String deviceId) {
    final device = _devices[deviceId];
    if (device != null) {
      device.lastSeen = DateTime.now();
      device.status = DeviceStatus.online;
      device.consecutiveFailures = 0;
    }
  }

  /// Marca el dispositivo con un fallo de comunicación.
  void recordFailure(String deviceId) {
    final device = _devices[deviceId];
    if (device != null) {
      device.consecutiveFailures++;
      if (device.consecutiveFailures >= 3) {
        device.status = DeviceStatus.error;
      }
    }
  }

  /// Marca el dispositivo como desconectado.
  void markOffline(String deviceId) {
    final device = _devices[deviceId];
    if (device != null) {
      device.status = DeviceStatus.offline;
    }
  }

  /// Obtiene información de un dispositivo.
  DeviceInfo? getDevice(String deviceId) => _devices[deviceId];

  /// Lista todos los dispositivos registrados.
  List<DeviceInfo> get allDevices => _devices.values.toList();

  /// Lista dispositivos con problemas (offline o error).
  List<DeviceInfo> get problematicDevices =>
      allDevices.where((d) => d.hasIssue).toList();

  /// Elimina un dispositivo del registro.
  void unregister(String deviceId) {
    _devices.remove(deviceId);
  }
}

/// Información de un dispositivo ESP32 en el sistema.
class DeviceInfo {
  final String deviceId;
  final String busId;
  final DateTime firstSeen;
  DateTime lastSeen;
  DeviceStatus status;
  int consecutiveFailures;

  DeviceInfo({
    required this.deviceId,
    required this.busId,
    required this.firstSeen,
    required this.lastSeen,
    required this.status,
    this.consecutiveFailures = 0,
  });

  /// `true` si el dispositivo está offline o en error.
  bool get hasIssue => status != DeviceStatus.online;

  /// Segundos desde la última telemetría.
  int get secondsSinceLastSeen =>
      DateTime.now().difference(lastSeen).inSeconds;
}

/// Estado de conexión de un dispositivo ESP32.
enum DeviceStatus { online, offline, error, maintenance }

/// Provider singleton del registro de dispositivos.
final deviceRegistryProvider = Provider<DeviceRegistryService>((ref) {
  return DeviceRegistryService();
});
