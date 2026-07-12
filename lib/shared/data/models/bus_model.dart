import '../../domain/entities/bus_entity.dart';

/// Modelo de bus con capacidades de serialización Supabase Realtime.
class BusModel extends BusEntity {
  const BusModel({
    required super.id,
    required super.plate,
    super.cooperativaId,
    super.routeId,
    super.capacity = 40,
    super.hardwareDeviceId,
    super.latitude,
    super.longitude,
    super.speedKmh,
    super.heading,
    super.passengerCount = 0,
    super.occupancyPct = 0,
    super.updatedAt,
  });

  /// Crea un [BusModel] desde el payload de Supabase Realtime.
  factory BusModel.fromRealtime(Map<String, dynamic> json) {
    return BusModel(
      id: json['bus_id'] as String,
      plate: json['plate'] as String? ?? '',
      cooperativaId: json['cooperativa_id'] as String?,
      routeId: json['route_id'] as String?,
      capacity: json['capacity'] as int? ?? 40,
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lng'] as num?)?.toDouble(),
      speedKmh: (json['speed_kmh'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      passengerCount: json['passenger_count'] as int? ?? 0,
      occupancyPct: (json['occupancy_pct'] as num?)?.toDouble() ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convierte a la entidad de dominio.
  BusEntity toEntity() => BusEntity(
        id: id,
        plate: plate,
        cooperativaId: cooperativaId,
        routeId: routeId,
        capacity: capacity,
        hardwareDeviceId: hardwareDeviceId,
        latitude: latitude,
        longitude: longitude,
        speedKmh: speedKmh,
        heading: heading,
        passengerCount: passengerCount,
        occupancyPct: occupancyPct,
        updatedAt: updatedAt,
      );

  @override
  String toString() => 'BusModel(id: $id, plate: $plate)';
}
