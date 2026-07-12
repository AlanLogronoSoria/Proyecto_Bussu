/// Métricas consolidadas a nivel ciudad para el dashboard municipal.
class MunicipalOverview {
  final int totalCooperativas;
  final int totalBuses;
  final int totalActiveBuses;
  final int totalDrivers;
  final int totalPassengers;
  final int activeAlerts;
  final double systemHealthPct;

  const MunicipalOverview({
    this.totalCooperativas = 0,
    this.totalBuses = 0,
    this.totalActiveBuses = 0,
    this.totalDrivers = 0,
    this.totalPassengers = 0,
    this.activeAlerts = 0,
    this.systemHealthPct = 0,
  });
}
