/// Entidad que representa un bus en el dominio.
class BusEntity {
  /// Identificador único del bus (UUID).
  final String id;

  /// Placa del bus.
  final String plate;

  /// ID de la cooperativa a la que pertenece.
  final String? cooperativaId;

  /// ID de la ruta asignada actualmente.
  final String? routeId;

  /// Capacidad máxima de pasajeros.
  final int capacity;

  /// ID del hardware ESP32 vinculado al bus.
  final String? hardwareDeviceId;

  /// Última posición conocida (latitud).
  final double? latitude;

  /// Última posición conocida (longitud).
  final double? longitude;

  /// Velocidad actual en km/h.
  final double? speedKmh;

  /// Dirección del movimiento en grados (0 = norte).
  final double? heading;

  /// Conteo actual de pasajeros.
  final int passengerCount;

  /// Porcentaje de ocupación calculado.
  final double occupancyPct;

  /// Marca de tiempo de la última actualización.
  final DateTime? updatedAt;

  const BusEntity({
    required this.id,
    required this.plate,
    this.cooperativaId,
    this.routeId,
    this.capacity = 40,
    this.hardwareDeviceId,
    this.latitude,
    this.longitude,
    this.speedKmh,
    this.heading,
    this.passengerCount = 0,
    this.occupancyPct = 0,
    this.updatedAt,
  });

  BusEntity copyWith({
    String? id,
    String? plate,
    String? cooperativaId,
    String? routeId,
    int? capacity,
    String? hardwareDeviceId,
    double? latitude,
    double? longitude,
    double? speedKmh,
    double? heading,
    int? passengerCount,
    double? occupancyPct,
    DateTime? updatedAt,
  }) {
    return BusEntity(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      cooperativaId: cooperativaId ?? this.cooperativaId,
      routeId: routeId ?? this.routeId,
      capacity: capacity ?? this.capacity,
      hardwareDeviceId: hardwareDeviceId ?? this.hardwareDeviceId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmh: speedKmh ?? this.speedKmh,
      heading: heading ?? this.heading,
      passengerCount: passengerCount ?? this.passengerCount,
      occupancyPct: occupancyPct ?? this.occupancyPct,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Nivel de ocupación categorizado para usuarios free.
  String get occupancyLevel {
    if (occupancyPct < 40) return 'Baja';
    if (occupancyPct < 75) return 'Media';
    return 'Alta';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BusEntity(id: $id, plate: $plate, occupancy: $occupancyPct%)';
}
