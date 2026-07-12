import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/favorite_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites(String userId);
}
