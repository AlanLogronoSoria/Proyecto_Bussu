import '../../../../shared/domain/enums/trip_status.dart';

/// Entidad que representa un viaje activo o completado.
class TripEntity {
  /// ID único del viaje.
  final String id;

  /// ID del bus asignado.
  final String busId;

  /// ID de la ruta del viaje.
  final String routeId;

  /// ID del conductor.
  final String driverId;

  /// Momento de inicio del viaje.
  final DateTime? startedAt;

  /// Momento de finalización del viaje.
  final DateTime? endedAt;

  /// Estado actual del viaje.
  final TripStatus status;

  /// Conteo de pasajeros actual.
  final int passengerCount;

  /// Porcentaje de ocupación.
  final double occupancyPct;

  /// Velocidad actual en km/h.
  final double? speedKmh;

  /// Coordenadas actuales.
  final double? latitude;
  final double? longitude;

  const TripEntity({
    required this.id,
    required this.busId,
    required this.routeId,
    required this.driverId,
    this.startedAt,
    this.endedAt,
    this.status = TripStatus.scheduled,
    this.passengerCount = 0,
    this.occupancyPct = 0,
    this.speedKmh,
    this.latitude,
    this.longitude,
  });

  TripEntity copyWith({
    String? id,
    String? busId,
    String? routeId,
    String? driverId,
    DateTime? startedAt,
    DateTime? endedAt,
    TripStatus? status,
    int? passengerCount,
    double? occupancyPct,
    double? speedKmh,
    double? latitude,
    double? longitude,
  }) {
    return TripEntity(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      routeId: routeId ?? this.routeId,
      driverId: driverId ?? this.driverId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      passengerCount: passengerCount ?? this.passengerCount,
      occupancyPct: occupancyPct ?? this.occupancyPct,
      speedKmh: speedKmh ?? this.speedKmh,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Duration? get tripDuration {
    if (startedAt == null) return null;
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt!);
  }

  @override
  String toString() => 'TripEntity(id: $id, status: $status)';
}
