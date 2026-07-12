/// Entidad que representa una parada en el dominio.
class StopEntity {
  /// Identificador único de la parada.
  final String id;

  /// ID de la ruta a la que pertenece.
  final String? routeId;

  /// Nombre descriptivo de la parada.
  final String name;

  /// Latitud de la parada.
  final double latitude;

  /// Longitud de la parada.
  final double longitude;

  /// Orden de la parada en la ruta (1 = primera).
  final int orderIndex;

  /// Distancia en metros desde el inicio de la polyline de la ruta.
  final double? distanceAlongRoute;

  /// UUID del beacon BLE asociado (si aplica).
  final String? beaconUuid;

  /// Major del beacon BLE.
  final int? beaconMajor;

  /// Minor del beacon BLE.
  final int? beaconMinor;

  const StopEntity({
    required this.id,
    this.routeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.orderIndex,
    this.distanceAlongRoute,
    this.beaconUuid,
    this.beaconMajor,
    this.beaconMinor,
  });

  StopEntity copyWith({
    String? id,
    String? routeId,
    String? name,
    double? latitude,
    double? longitude,
    int? orderIndex,
    double? distanceAlongRoute,
    String? beaconUuid,
    int? beaconMajor,
    int? beaconMinor,
  }) {
    return StopEntity(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      orderIndex: orderIndex ?? this.orderIndex,
      distanceAlongRoute: distanceAlongRoute ?? this.distanceAlongRoute,
      beaconUuid: beaconUuid ?? this.beaconUuid,
      beaconMajor: beaconMajor ?? this.beaconMajor,
      beaconMinor: beaconMinor ?? this.beaconMinor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'StopEntity(id: $id, name: $name, order: $orderIndex)';
}
