class DirectionsEntity {
  final List<List<double>> polyline;
  final double distanceMeters;
  final double durationSeconds;

  const DirectionsEntity({
    required this.polyline,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}
