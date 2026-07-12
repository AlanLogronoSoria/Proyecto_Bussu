/// Datos de salud de la flota para el dashboard.
class FleetHealth {
  /// Total de buses registrados en la cooperativa.
  final int totalBuses;

  /// Buses con telemetría activa (últimos 30s).
  final int activeBuses;

  /// Buses en mantenimiento o fuera de servicio.
  final int inactiveBuses;

  /// Alertas activas de la flota.
  final int activeAlerts;

  /// Ocupación promedio de todos los buses activos (%).
  final double averageOccupancy;

  /// Conteo total de pasajeros en todos los buses.
  final int totalPassengers;

  /// Total de conductores registrados.
  final int totalDrivers;

  const FleetHealth({
    this.totalBuses = 0,
    this.activeBuses = 0,
    this.inactiveBuses = 0,
    this.activeAlerts = 0,
    this.averageOccupancy = 0,
    this.totalPassengers = 0,
    this.totalDrivers = 0,
  });

  double get fleetActivityPct =>
      totalBuses > 0 ? activeBuses / totalBuses * 100 : 0;
}
