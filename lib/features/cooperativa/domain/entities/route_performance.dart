/// Reporte de rendimiento de una ruta.
class RoutePerformance {
  final String routeId;
  final String routeName;
  final int totalTrips;
  final int completedTrips;
  final double averageOccupancy;
  final double averageSpeedKmh;
  final int totalPassengers;

  const RoutePerformance({
    required this.routeId,
    required this.routeName,
    this.totalTrips = 0,
    this.completedTrips = 0,
    this.averageOccupancy = 0,
    this.averageSpeedKmh = 0,
    this.totalPassengers = 0,
  });

  double get completionRate =>
      totalTrips > 0 ? completedTrips / totalTrips * 100 : 0;
}
