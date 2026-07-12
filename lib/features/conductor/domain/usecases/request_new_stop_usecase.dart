import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/stops_repository.dart';

/// Solicita una nueva parada con coordenadas y justificación.
class RequestNewStopUseCase {
  final StopsRepository _repository;

  RequestNewStopUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String driverId,
    required double lat,
    required double lng,
    required String reason,
  }) async {
    final latError = Validators.validateLatitude(lat);
    if (latError != null) return Left(ValidationFailure(latError));

    final lngError = Validators.validateLongitude(lng);
    if (lngError != null) return Left(ValidationFailure(lngError));

    final reasonError = Validators.validateRequired(reason, 'Justificación');
    if (reasonError != null) return Left(ValidationFailure(reasonError));

    return _repository.requestNewStop(
      driverId: driverId,
      lat: lat,
      lng: lng,
      reason: reason,
    );
  }
}
