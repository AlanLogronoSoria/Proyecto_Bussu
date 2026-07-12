import 'dart:math';

/// Utilidades de cálculo de ETA (Tiempo Estimado de Arribo).
///
/// Implementa el algoritmo descrito en la arquitectura:
/// 1. Suavizado de velocidad con media móvil exponencial (EMA).
/// 2. Proyección sobre polyline para obtener progreso del bus.
/// 3. Cálculo de ETA como distancia restante / velocidad suavizada.
class EtaCalculator {
  EtaCalculator._();

  /// Suaviza una serie de velocidades usando media móvil exponencial (EMA).
  ///
  /// [speeds] — velocidades recientes en km/h (más reciente al final).
  /// [alpha] — factor de suavizado (0 < alpha ≤ 1).
  ///   Valores cercanos a 0 dan más peso a lecturas antiguas (más suave).
  ///   Valores cercanos a 1 dan más peso a la última lectura (más reactivo).
  ///
  /// Si [speeds] está vacía, retorna 0.
  static double smoothSpeed(List<double> speeds, {double alpha = 0.3}) {
    if (speeds.isEmpty) return 0;

    double ema = speeds.first;
    for (int i = 1; i < speeds.length; i++) {
      ema = alpha * speeds[i] + (1 - alpha) * ema;
    }
    return ema;
  }

  /// Calcula la velocidad suavizada con respaldo (fallback).
  ///
  /// Si la velocidad suavizada es 0 (bus detenido), usa [fallbackSpeedKph]
  /// como estimación basada en datos históricos del segmento/horario.
  /// [fallbackSpeedKph] debe provenir de [bus_telemetry_history] (promedio
  /// histórico de ese tramo a esa hora).
  static double smoothSpeedWithFallback(
    List<double> speeds, {
    double alpha = 0.3,
    double fallbackSpeedKph = 25.0,
  }) {
    final smoothed = smoothSpeed(speeds, alpha: alpha);
    if (smoothed < 1.0 && fallbackSpeedKph > 0) {
      return fallbackSpeedKph;
    }
    return smoothed;
  }

  /// Calcula el ETA en minutos para recorrer [distanceMeters] a [speedKmh].
  ///
  /// Si [speedKmh] ≤ 0, retorna [Duration.zero] para evitar división por cero.
  static Duration calculateEta(double distanceMeters, double speedKmh) {
    if (speedKmh <= 0 || distanceMeters <= 0) return Duration.zero;
    final hours = distanceMeters / 1000.0 / speedKmh;
    final minutes = (hours * 60).round();
    return Duration(minutes: minutes);
  }

  /// Proyecta un punto (lat, lng) sobre una polyline y retorna el progreso
  /// en metros desde el inicio.
  ///
  /// [polyline] — lista de puntos [lat, lng] que definen la ruta.
  /// [lat], [lng] — coordenadas del bus.
  ///
  /// Algoritmo: encuentra el segmento más cercano a la posición del bus
  /// y proyecta sobre él para obtener la distancia acumulada.
  static double progressOnPolyline(
    List<List<double>> polyline,
    double lat,
    double lng,
  ) {
    if (polyline.isEmpty) return 0;

    double minDistance = double.infinity;
    int bestSegment = 0;
    double bestProjection = 0;

    for (int i = 0; i < polyline.length - 1; i++) {
      final p1 = polyline[i];
      final p2 = polyline[i + 1];

      final projection = _projectPointOnSegment(p1[0], p1[1], p2[0], p2[1], lat, lng);
      final projLat = p1[0] + projection * (p2[0] - p1[0]);
      final projLng = p1[1] + projection * (p2[1] - p1[1]);

      final distance = _haversineDistance(lat, lng, projLat, projLng);
      if (distance < minDistance) {
        minDistance = distance;
        bestSegment = i;
        bestProjection = projection;
      }
    }

    double cumulativeDistance = 0;
    for (int i = 0; i < bestSegment; i++) {
      cumulativeDistance += _haversineDistance(
        polyline[i][0],
        polyline[i][1],
        polyline[i + 1][0],
        polyline[i + 1][1],
      );
    }

    cumulativeDistance += bestProjection * _haversineDistance(
      polyline[bestSegment][0],
      polyline[bestSegment][1],
      polyline[bestSegment + 1][0],
      polyline[bestSegment + 1][1],
    );

    return cumulativeDistance;
  }

  /// Distancia en metros entre dos puntos geográficos (fórmula Haversine).
  static double haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return _haversineDistance(lat1, lng1, lat2, lng2);
  }

  /// Calcula el ETA a una parada específica con todos los parámetros.
  ///
  /// [busProgressMeters] — distancia del bus desde el inicio de la ruta.
  /// [stopDistanceMeters] — distancia de la parada desde el inicio.
  /// [smoothedSpeedKmh] — velocidad suavizada del bus.
  ///
  /// Retorna el [Duration] estimado para llegar. Si la parada ya fue superada
  /// o los parámetros son inválidos, retorna [Duration.zero].
  static Duration etaToStop({
    required double busProgressMeters,
    required double stopDistanceMeters,
    required double smoothedSpeedKmh,
  }) {
    final remaining = stopDistanceMeters - busProgressMeters;
    if (remaining <= 0 || smoothedSpeedKmh <= 0) return Duration.zero;
    return calculateEta(remaining, smoothedSpeedKmh);
  }

  static double _projectPointOnSegment(
    double ax,
    double ay,
    double bx,
    double by,
    double px,
    double py,
  ) {
    final dx = bx - ax;
    final dy = by - ay;
    if (dx == 0 && dy == 0) return 0;

    final t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
    return t.clamp(0.0, 1.0);
  }

  static double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371000;

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180.0;

  /// Interpreta la respuesta del RPC [calculate_etas_for_route].
  ///
  /// [rows] — filas retornadas por la RPC, cada una con stop_id, stop_name,
  /// stop_order, distance_meters, eta_seconds, eta_minutes, occupancy_level.
  static List<EtaResult> parseRpcResults(List<Map<String, dynamic>> rows) {
    return rows.map((r) {
      return EtaResult(
        stopId: r['stop_id'] as String,
        stopName: r['stop_name'] as String? ?? '',
        stopOrder: r['stop_order'] as int? ?? 0,
        distanceMeters: (r['distance_meters'] as num?)?.toDouble() ?? 0,
        etaSeconds: (r['eta_seconds'] as num?)?.toDouble() ?? 0,
        etaMinutes: (r['eta_minutes'] as num?)?.toDouble() ?? 0,
        occupancyLevel: r['occupancy_level'] as String? ?? 'Baja',
      );
    }).toList();
  }

  /// Interpreta la respuesta del RPC [get_bus_route_progress].
  static BusProgressResult parseProgressResult(Map<String, dynamic> data) {
    return BusProgressResult(
      busLat: (data['bus_lat'] as num?)?.toDouble() ?? 0,
      busLng: (data['bus_lng'] as num?)?.toDouble() ?? 0,
      speedKmh: (data['speed_kmh'] as num?)?.toDouble() ?? 0,
      progressMeters: (data['progress_meters'] as num?)?.toDouble() ?? 0,
      routeLengthMeters: (data['route_length_meters'] as num?)?.toDouble() ?? 0,
      distanceToNextStop: (data['distance_to_next_stop'] as num?)?.toDouble() ?? 0,
      nextStopId: data['next_stop_id'] as String?,
      nextStopName: data['next_stop_name'] as String?,
      etaSeconds: (data['eta_seconds'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Aplica media móvil exponencial a una lista de velocidades recientes
  /// obtenidas del RPC [get_recent_speeds].
  ///
  /// [recentSpeeds] — lista de Map con keys 'speed_kmh' y opcional 'recorded_at'.
  /// [alpha] — factor de suavizado (0 < alpha ≤ 1).
  static double smoothRecentSpeeds(
    List<Map<String, dynamic>> recentSpeeds, {
    double alpha = 0.3,
    double fallbackKph = 20.0,
  }) {
    if (recentSpeeds.isEmpty) return fallbackKph;

    final speeds = recentSpeeds
        .map((s) => (s['speed_kmh'] as num).toDouble())
        .where((s) => s > 0)
        .toList();

    if (speeds.isEmpty) return fallbackKph;

    return smoothSpeed(speeds.reversed.toList(), alpha: alpha);
  }
}

/// Resultado de ETA para una parada específica.
class EtaResult {
  final String stopId;
  final String stopName;
  final int stopOrder;
  final double distanceMeters;
  final double etaSeconds;
  final double etaMinutes;
  final String occupancyLevel;

  const EtaResult({
    required this.stopId,
    required this.stopName,
    required this.stopOrder,
    required this.distanceMeters,
    required this.etaSeconds,
    required this.etaMinutes,
    required this.occupancyLevel,
  });

  Duration get etaDuration => Duration(seconds: etaSeconds.round());

  String get formattedEta {
    if (etaMinutes < 1) return '< 1 min';
    if (etaMinutes < 60) return '${etaMinutes.round()} min';
    final hours = etaMinutes ~/ 60;
    final mins = etaMinutes.round() % 60;
    return '${hours}h ${mins}m';
  }

  @override
  String toString() => 'EtaResult($stopName: $formattedEta)';
}

/// Progreso del bus en la ruta calculado por PostGIS.
class BusProgressResult {
  final double busLat;
  final double busLng;
  final double speedKmh;
  final double progressMeters;
  final double routeLengthMeters;
  final double distanceToNextStop;
  final String? nextStopId;
  final String? nextStopName;
  final double etaSeconds;

  const BusProgressResult({
    required this.busLat,
    required this.busLng,
    required this.speedKmh,
    required this.progressMeters,
    required this.routeLengthMeters,
    required this.distanceToNextStop,
    this.nextStopId,
    this.nextStopName,
    required this.etaSeconds,
  });

  double get progressPercent =>
      routeLengthMeters > 0 ? (progressMeters / routeLengthMeters * 100).clamp(0, 100) : 0;

  Duration get etaDuration => Duration(seconds: etaSeconds.round());
}
