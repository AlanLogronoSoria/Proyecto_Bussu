import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/trip_repository.dart';

/// Publica telemetría del bus (GPS, velocidad).
class PublishTelemetryUseCase {
  final TripRepository _repository;

  PublishTelemetryUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String busId,
    required double lat,
    required double lng,
    required double speedKmh,
    required double heading,
  }) async {
    final latError = Validators.validateLatitude(lat);
    if (latError != null) return Left(ValidationFailure(latError));

    final lngError = Validators.validateLongitude(lng);
    if (lngError != null) return Left(ValidationFailure(lngError));

    if (speedKmh < 0) {
      return const Left(ValidationFailure('Velocidad no puede ser negativa'));
    }

    if (heading < 0 || heading > 360) {
      return const Left(ValidationFailure('Heading debe estar entre 0 y 360'));
    }

    return _repository.publishTelemetry(
      busId: busId,
      lat: lat,
      lng: lng,
      speedKmh: speedKmh,
      heading: heading,
    );
  }
}
