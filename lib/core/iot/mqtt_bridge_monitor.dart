import 'dart:async';

import '../../core/iot/device_registry_service.dart';

/// Monitor de salud del servicio puente MQTT→Supabase.
///
/// Verifica periódicamente que el puente esté recibiendo y procesando
/// telemetría. Si ningún bus ha recibido actualización en [timeoutSeconds],
/// se emite una alerta.
///
/// Flutter consulta la tabla [bridge_health] vía Supabase Realtime
/// para saber el estado del puente sin conexión directa al broker.
class MqttBridgeMonitor {
  final DeviceRegistryService _deviceRegistry;
  Timer? _healthCheckTimer;

  MqttBridgeMonitor(this._deviceRegistry);

  /// Estado actual del puente.
  BridgeHealth _health = const BridgeHealth(
    status: BridgeStatus.unknown,
    lastCheck: null,
  );

  BridgeHealth get health => _health;

  /// Inicia el monitoreo periódico.
  void start({int intervalSeconds = 30}) {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _checkHealth(),
    );
  }

  void _checkHealth() {
    final devices = _deviceRegistry.allDevices;
    if (devices.isEmpty) {
      _health = BridgeHealth(
        status: BridgeStatus.unknown,
        lastCheck: DateTime.now(),
        message: 'Sin dispositivos registrados',
      );
      return;
    }

    final activeDevices = devices.where(
      (d) => d.secondsSinceLastSeen < 30 && d.status == DeviceStatus.online,
    ).length;

    if (activeDevices == 0) {
      _health = BridgeHealth(
        status: BridgeStatus.error,
        lastCheck: DateTime.now(),
        message: 'Ningún dispositivo transmite. Posible fallo del puente.',
        activeDevices: 0,
        totalDevices: devices.length,
      );
    } else if (activeDevices < devices.length) {
      _health = BridgeHealth(
        status: BridgeStatus.degraded,
        lastCheck: DateTime.now(),
        message: '${devices.length - activeDevices} dispositivos sin señal.',
        activeDevices: activeDevices,
        totalDevices: devices.length,
      );
    } else {
      _health = BridgeHealth(
        status: BridgeStatus.healthy,
        lastCheck: DateTime.now(),
        message: 'Todos los dispositivos transmitiendo.',
        activeDevices: activeDevices,
        totalDevices: devices.length,
      );
    }
  }

  /// Detiene el monitoreo.
  void stop() {
    _healthCheckTimer?.cancel();
  }
}

/// Estado de salud del puente MQTT→Supabase.
class BridgeHealth {
  final BridgeStatus status;
  final DateTime? lastCheck;
  final String? message;
  final int activeDevices;
  final int totalDevices;

  const BridgeHealth({
    required this.status,
    this.lastCheck,
    this.message,
    this.activeDevices = 0,
    this.totalDevices = 0,
  });

  double get healthPct =>
      totalDevices > 0 ? activeDevices / totalDevices * 100 : 0;
}

enum BridgeStatus { healthy, degraded, error, unknown }
