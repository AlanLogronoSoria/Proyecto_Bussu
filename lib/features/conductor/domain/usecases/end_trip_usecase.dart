import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/trip_repository.dart';

/// Finaliza el viaje activo.
class EndTripUseCase {
  final TripRepository _repository;

  EndTripUseCase(this._repository);

  Future<Either<Failure, void>> execute(String tripId) async {
    if (tripId.isEmpty) {
      return Left(ValidationFailure('ID del viaje es obligatorio'));
    }

    return _repository.endTrip(tripId);
  }
}
