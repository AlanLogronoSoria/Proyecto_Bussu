import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  @override
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right([
      FavoriteEntity(id: 'f1', userId: userId, itemId: 'r0000000-0000-0000-0000-000000000001', type: FavoriteType.route, name: 'Ruta A - Centro Historico', createdAt: DateTime.now()),
      FavoriteEntity(id: 'f2', userId: userId, itemId: 's0000000-0000-0000-0000-000000000001', type: FavoriteType.stop, name: 'Plaza de Armas', createdAt: DateTime.now()),
    ]);
  }
}
