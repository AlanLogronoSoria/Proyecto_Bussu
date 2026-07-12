import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:bussu/core/utils/eta_calculator.dart';

void main() {
  group('EtaCalculator - EMA Smoothing', () {
    test('empty list returns 0', () {
      expect(EtaCalculator.smoothSpeed([]), 0);
    });

    test('single value returns that value', () {
      expect(EtaCalculator.smoothSpeed([40.0]), closeTo(40.0, 0.01));
    });

    test('alpha=0.3 smooths out sudden stops', () {
      final speeds = [40.0, 42.0, 38.0, 40.0, 0.0, 0.0];
      final smoothed = EtaCalculator.smoothSpeed(speeds, alpha: 0.3);
      expect(smoothed, greaterThan(5));
    });

    test('alpha=0.8 reacts quickly to changes', () {
      final speeds = [40.0, 42.0, 38.0, 40.0, 0.0, 0.0];
      final smoothed = EtaCalculator.smoothSpeed(speeds, alpha: 0.8);
      expect(smoothed, lessThan(8));
    });

    test('fallback activates when speed is near zero', () {
      final smoothed = EtaCalculator.smoothSpeedWithFallback(
        [0, 0, 0, 0, 0, 0],
        alpha: 0.3,
        fallbackSpeedKph: 25.0,
      );
      expect(smoothed, 25.0);
    });

    test('fallback does not activate with normal speeds', () {
      final smoothed = EtaCalculator.smoothSpeedWithFallback(
        [40, 42, 38, 40, 41, 39],
        alpha: 0.3,
        fallbackSpeedKph: 25.0,
      );
      expect(smoothed, greaterThan(1.0));
      expect(smoothed, lessThan(45.0));
    });
  });

  group('EtaCalculator - Haversine', () {
    test('distance between Plaza de Armas and Parque Kennedy', () {
      final dist = EtaCalculator.haversineDistance(
        -12.0464, -77.0428,
        -12.1200, -77.0300,
      );
      expect(dist, greaterThan(8000));
      expect(dist, lessThan(9000));
    });

    test('same point distance is zero', () {
      final dist = EtaCalculator.haversineDistance(
        -12.0464, -77.0428,
        -12.0464, -77.0428,
      );
      expect(dist, closeTo(0, 0.1));
    });
  });

  group('EtaCalculator - ETA calculation', () {
    test('ETA for 1000m at 36kmh is about 100 seconds', () {
      final eta = EtaCalculator.calculateEta(1000, 36);
      expect(eta.inSeconds, greaterThan(90));
      expect(eta.inSeconds, lessThan(130));
    });

    test('ETA is zero for zero distance', () {
      final eta = EtaCalculator.calculateEta(0, 36);
      expect(eta, Duration.zero);
    });

    test('ETA is zero for zero speed', () {
      final eta = EtaCalculator.calculateEta(1000, 0);
      expect(eta, Duration.zero);
    });
  });

  group('EtaCalculator - Progress on Polyline', () {
    final polyline = [
      [-12.0464, -77.0428],
      [-12.0500, -77.0360],
      [-12.0520, -77.0300],
    ];

    test('progress at start point is near 0', () {
      final progress = EtaCalculator.progressOnPolyline(
        polyline, -12.0464, -77.0428,
      );
      expect(progress, lessThan(10));
    });

    test('progress at end point equals total length', () {
      final progress = EtaCalculator.progressOnPolyline(
        polyline, -12.0520, -77.0300,
      );
      final total = EtaCalculator.haversineDistance(-12.0464, -77.0428, -12.0500, -77.0360)
          + EtaCalculator.haversineDistance(-12.0500, -77.0360, -12.0520, -77.0300);
      expect(progress, closeTo(total, 1));
    });

    test('ETA to stop calculates correctly', () {
      final eta = EtaCalculator.etaToStop(
        busProgressMeters: 0,
        stopDistanceMeters: 1500,
        smoothedSpeedKmh: 30,
      );
      expect(eta.inMinutes, 3);
    });

    test('ETA is zero when bus passed the stop', () {
      final eta = EtaCalculator.etaToStop(
        busProgressMeters: 2000,
        stopDistanceMeters: 1500,
        smoothedSpeedKmh: 30,
      );
      expect(eta, Duration.zero);
    });
  });

  group('EtaCalculator - Recent speeds smoothing', () {
    test('smoothRecentSpeeds with valid data', () {
      final speeds = [
        {'speed_kmh': 40.0},
        {'speed_kmh': 42.0},
        {'speed_kmh': 38.0},
      ];
      final result = EtaCalculator.smoothRecentSpeeds(speeds, alpha: 0.3);
      expect(result, greaterThan(30));
      expect(result, lessThan(50));
    });

    test('smoothRecentSpeeds returns fallback with empty list', () {
      final result = EtaCalculator.smoothRecentSpeeds([], fallbackKph: 25.0);
      expect(result, 25.0);
    });
  });

  group('EtaResult', () {
    test('formattedEta for seconds', () {
      final r = EtaResult(
        stopId: 's1', stopName: 'Test', stopOrder: 1,
        distanceMeters: 100, etaSeconds: 30, etaMinutes: 0.5,
        occupancyLevel: 'Baja',
      );
      expect(r.formattedEta, '< 1 min');
    });

    test('formattedEta for minutes', () {
      final r = EtaResult(
        stopId: 's1', stopName: 'Test', stopOrder: 1,
        distanceMeters: 1000, etaSeconds: 300, etaMinutes: 5,
        occupancyLevel: 'Media',
      );
      expect(r.formattedEta, '5 min');
    });

    test('formattedEta for hours', () {
      final r = EtaResult(
        stopId: 's1', stopName: 'Test', stopOrder: 1,
        distanceMeters: 10000, etaSeconds: 5400, etaMinutes: 90,
        occupancyLevel: 'Alta',
      );
      expect(r.formattedEta, '1h 30m');
    });
  });
}
