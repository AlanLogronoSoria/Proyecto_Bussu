import 'stop_entity.dart';

/// Entidad que representa una ruta de transporte.
class RouteEntity {
  /// Identificador único de la ruta.
  final String id;

  /// ID de la cooperativa propietaria.
  final String? cooperativaId;

  /// Nombre de la ruta (ej. "Ruta A - Centro").
  final String name;

  /// Color de la ruta para visualización en mapa (hex).
  final String color;

  /// Lista de coordenadas [lat, lng] que definen la polyline de la ruta.
  final List<List<double>> polyline;

  /// Paradas ordenadas de la ruta.
  final List<StopEntity> stops;

  const RouteEntity({
    required this.id,
    this.cooperativaId,
    required this.name,
    this.color = '#001B44',
    this.polyline = const [],
    this.stops = const [],
  });

  RouteEntity copyWith({
    String? id,
    String? cooperativaId,
    String? name,
    String? color,
    List<List<double>>? polyline,
    List<StopEntity>? stops,
  }) {
    return RouteEntity(
      id: id ?? this.id,
      cooperativaId: cooperativaId ?? this.cooperativaId,
      name: name ?? this.name,
      color: color ?? this.color,
      polyline: polyline ?? this.polyline,
      stops: stops ?? this.stops,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RouteEntity(id: $id, name: $name)';
}
