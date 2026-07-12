import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

/// Inicia un nuevo viaje.
class StartTripUseCase {
  final TripRepository _repository;

  StartTripUseCase(this._repository);

  Future<Either<Failure, TripEntity>> execute({
    required String busId,
    required String routeId,
    required String driverId,
  }) async {
    if (busId.isEmpty || routeId.isEmpty || driverId.isEmpty) {
      return Left(ValidationFailure('Bus, ruta y conductor son obligatorios'));
    }

    return _repository.startTrip(
      busId: busId,
      routeId: routeId,
      driverId: driverId,
    );
  }
}
