import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/usecases/get_favorites_usecase.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((_) => FavoritesRepositoryImpl());
final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>((ref) => GetFavoritesUseCase(ref.watch(favoritesRepositoryProvider)));

final favoritesProvider = FutureProvider<List<FavoriteEntity>>((ref) async {
  final useCase = ref.watch(getFavoritesUseCaseProvider);
  final result = await useCase.execute('current');
  return result.fold((_) => [], (f) => f);
});
