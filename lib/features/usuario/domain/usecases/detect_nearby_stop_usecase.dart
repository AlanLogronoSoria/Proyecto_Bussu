import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/eta_calculator.dart';
import '../../../../shared/domain/entities/stop_entity.dart';
import '../repositories/bus_tracking_repository.dart';

/// Detecta la parada más cercana al usuario usando el repositorio de tracking.
class DetectNearbyStopUseCase {
  final BusTrackingRepository _repository;

  DetectNearbyStopUseCase(this._repository);

  /// Retorna la parada más cercana si está a menos de [maxDistanceMeters].
  ///
  /// [userLat] y [userLng] son las coordenadas actuales del usuario.
  /// [routeId] filtra paradas de una ruta específica.
  Future<Either<Failure, StopEntity?>> execute({
    required double userLat,
    required double userLng,
    required String routeId,
    double maxDistanceMeters = 30.0,
  }) async {
    final result = await _repository.getRouteStops(routeId);

    return result.fold(
      (failure) => Left(failure),
      (stops) {
        StopEntity? nearest;
        double minDistance = double.infinity;

        for (final stop in stops) {
          final distance = _haversineDistance(
            userLat,
            userLng,
            stop.latitude,
            stop.longitude,
          );
          if (distance < minDistance && distance <= maxDistanceMeters) {
            minDistance = distance;
            nearest = stop;
          }
        }

        return Right(nearest);
      },
    );
  }

  double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return EtaCalculator.haversineDistance(lat1, lng1, lat2, lng2);
  }
}
