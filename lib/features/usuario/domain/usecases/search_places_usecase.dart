import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/entities/geocoding_entity.dart';
import '../../../../shared/domain/repositories/geocoding_repository.dart';

class SearchPlacesUseCase {
  final GeocodingRepository _repo;
  SearchPlacesUseCase(this._repo);

  Future<Either<Failure, GeocodingResultEntity>> execute({
    required String query, String? country, String? city, int limit = 5,
  }) async {
    if (query.trim().isEmpty) return const Left(ValidationFailure('La búsqueda no puede estar vacía'));
    return _repo.search(query: query.trim(), country: country, city: city, limit: limit);
  }
}
