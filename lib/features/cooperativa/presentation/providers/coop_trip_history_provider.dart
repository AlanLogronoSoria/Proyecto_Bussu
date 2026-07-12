import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/coop_trip_history_repository.dart';
import '../../data/repositories/coop_trip_history_repository_impl.dart';
import '../../domain/usecases/get_coop_trip_history_usecase.dart';

final coopTripHistoryRepositoryProvider = Provider<CoopTripHistoryRepository>((_) => CoopTripHistoryRepositoryImpl());
final getCoopTripHistoryUseCaseProvider = Provider<GetCoopTripHistoryUseCase>((ref) => GetCoopTripHistoryUseCase(ref.watch(coopTripHistoryRepositoryProvider)));

final coopTripHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, coopId) async {
  final useCase = ref.watch(getCoopTripHistoryUseCaseProvider);
  final result = await useCase.execute(coopId);
  return result.fold((_) => [], (t) => t);
});
