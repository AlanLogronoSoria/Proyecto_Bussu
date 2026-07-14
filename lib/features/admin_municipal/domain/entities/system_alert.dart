/// Alerta del sistema a nivel municipal.
class SystemAlert {
  final String id;
  final String scope;
  final String severity;
  final String title;
  final String description;
  final String? routeId;
  final String? createdBy;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const SystemAlert({
    required this.id,
    required this.scope,
    required this.severity,
    required this.title,
    required this.description,
    this.routeId,
    this.createdBy,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.resolvedAt,
  });

  SystemAlert copyWith({
    String? id,
    String? scope,
    String? severity,
    String? title,
    String? description,
    String? routeId,
    String? createdBy,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return SystemAlert(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      routeId: routeId ?? this.routeId,
      createdBy: createdBy ?? this.createdBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  bool get isResolved => resolvedAt != null;
}
