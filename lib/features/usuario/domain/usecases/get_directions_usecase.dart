import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/entities/directions_entity.dart';
import '../../../../shared/domain/repositories/directions_repository.dart';

class GetDirectionsUseCase {
  final DirectionsRepository _repository;

  GetDirectionsUseCase(this._repository);

  Future<Either<Failure, DirectionsEntity>> execute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final slat = Validators.validateLatitude(startLat);
    if (slat != null) return Left(ValidationFailure(slat));
    final slng = Validators.validateLongitude(startLng);
    if (slng != null) return Left(ValidationFailure(slng));
    final elat = Validators.validateLatitude(endLat);
    if (elat != null) return Left(ValidationFailure(elat));
    final elng = Validators.validateLongitude(endLng);
    if (elng != null) return Left(ValidationFailure(elng));

    return _repository.getDirections(
      startLat: startLat, startLng: startLng,
      endLat: endLat, endLng: endLng,
    );
  }
}
