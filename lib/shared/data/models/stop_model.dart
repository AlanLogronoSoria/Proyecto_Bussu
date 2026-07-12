import '../../domain/entities/stop_entity.dart';

/// Modelo de parada con capacidades de serialización.
class StopModel extends StopEntity {
  const StopModel({
    required super.id,
    super.routeId,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.orderIndex,
    super.distanceAlongRoute,
    super.beaconUuid,
    super.beaconMajor,
    super.beaconMinor,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      id: json['id'] as String,
      routeId: json['route_id'] as String?,
      name: json['name'] as String,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      orderIndex: json['order_index'] as int,
      distanceAlongRoute: (json['distance_along_route'] as num?)?.toDouble(),
      beaconUuid: json['beacon_uuid'] as String?,
      beaconMajor: json['beacon_major'] as int?,
      beaconMinor: json['beacon_minor'] as int?,
    );
  }

  StopEntity toEntity() => StopEntity(
        id: id,
        routeId: routeId,
        name: name,
        latitude: latitude,
        longitude: longitude,
        orderIndex: orderIndex,
        distanceAlongRoute: distanceAlongRoute,
        beaconUuid: beaconUuid,
        beaconMajor: beaconMajor,
        beaconMinor: beaconMinor,
      );
}
