import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/trip_history_repository.dart';
import '../../data/repositories/trip_history_repository_impl.dart';
import '../../domain/usecases/get_user_trip_history_usecase.dart';

final userTripHistoryRepositoryProvider = Provider<UserTripHistoryRepository>((_) => UserTripHistoryRepositoryImpl());
final getUserTripHistoryUseCaseProvider = Provider<GetUserTripHistoryUseCase>((ref) => GetUserTripHistoryUseCase(ref.watch(userTripHistoryRepositoryProvider)));

final tripHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final useCase = ref.watch(getUserTripHistoryUseCaseProvider);
  final result = await useCase.execute('current');
  return result.fold((_) => [], (t) => t);
});
