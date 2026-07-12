import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/favorite_entity.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  final FavoritesRepository _repository;
  GetFavoritesUseCase(this._repository);

  Future<Either<Failure, List<FavoriteEntity>>> execute(String userId) async {
    if (userId.isEmpty) return const Left(ValidationFailure('Usuario requerido'));
    return _repository.getFavorites(userId);
  }
}
