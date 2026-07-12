import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/eta_calculator.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../repositories/bus_tracking_repository.dart';
import '../repositories/eta_repository.dart';

/// Calcula el ETA de un bus a una parada combinando datos de tracking y ruta.
class CalculateEtaUseCase {
  final EtaRepository _etaRepository;
  final BusTrackingRepository _trackingRepository;

  CalculateEtaUseCase(this._etaRepository, this._trackingRepository);

  Future<Either<Failure, Duration>> execute({
    required String busId,
    required String stopId,
  }) async {
    return _etaRepository.calculateEta(busId: busId, stopId: stopId);
  }

  /// Calcula ETA usando velocidad suavizada y proyección en polyline.
  ///
  /// Útil cuando se tiene la geometría de la ruta y la posición del bus
  /// localmente sin necesidad de consultar al backend.
  Duration calculateLocalEta({
    required BusEntity bus,
    required List<List<double>> polyline,
    required double stopDistanceMeters,
    required List<double> recentSpeeds,
    double alpha = 0.3,
    double fallbackSpeedKph = 25.0,
  }) {
    if (bus.latitude == null || bus.longitude == null) {
      return Duration.zero;
    }

    final busProgress = EtaCalculator.progressOnPolyline(
      polyline,
      bus.latitude!,
      bus.longitude!,
    );

    final smoothedSpeed = EtaCalculator.smoothSpeedWithFallback(
      recentSpeeds,
      alpha: alpha,
      fallbackSpeedKph: fallbackSpeedKph,
    );

    return EtaCalculator.etaToStop(
      busProgressMeters: busProgress,
      stopDistanceMeters: stopDistanceMeters,
      smoothedSpeedKmh: smoothedSpeed,
    );
  }
}
