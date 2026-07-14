import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/entities/geocoding_entity.dart';
import '../../../../shared/domain/repositories/geocoding_repository.dart';

class ReverseGeocodeUseCase {
  final GeocodingRepository _repo;
  ReverseGeocodeUseCase(this._repo);

  Future<Either<Failure, GeocodingEntity?>> execute({required double lat, required double lng}) async {
    final latErr = Validators.validateLatitude(lat);
    if (latErr != null) return Left(ValidationFailure(latErr));
    final lngErr = Validators.validateLongitude(lng);
    if (lngErr != null) return Left(ValidationFailure(lngErr));
    return _repo.reverseGeocode(lat: lat, lng: lng);
  }
}
