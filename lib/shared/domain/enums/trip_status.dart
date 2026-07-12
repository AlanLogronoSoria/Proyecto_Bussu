/// Estados posibles de un viaje.
enum TripStatus {
  /// El viaje está planificado pero no ha iniciado.
  scheduled,

  /// El viaje está en curso.
  active,

  /// El viaje fue completado exitosamente.
  completed,

  /// El viaje fue cancelado antes de completarse.
  cancelled,
}
