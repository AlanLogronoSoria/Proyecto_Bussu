/// Estado consolidado de una cooperativa para el dashboard municipal.
class CooperativaStatus {
  final String id;
  final String name;
  final String? ruc;
  final int totalBuses;
  final int activeBuses;
  final int totalDrivers;
  final double averageOccupancy;
  final int activeAlerts;
  final int totalTripsCompleted;

  const CooperativaStatus({
    required this.id,
    required this.name,
    this.ruc,
    this.totalBuses = 0,
    this.activeBuses = 0,
    this.totalDrivers = 0,
    this.averageOccupancy = 0,
    this.activeAlerts = 0,
    this.totalTripsCompleted = 0,
  });

  double get fleetActivityPct =>
      totalBuses > 0 ? activeBuses / totalBuses * 100 : 0;
}
