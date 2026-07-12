import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/coop_trip_history_repository.dart';

class CoopTripHistoryRepositoryImpl implements CoopTripHistoryRepository {
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTripHistory(String coopId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right([
      {'buses': {'plate': 'ABC-123'}, 'routes': {'name': 'Ruta A - Centro'}, 'status': 'completed', 'started_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String()},
      {'buses': {'plate': 'ABC-124'}, 'routes': {'name': 'Ruta B'}, 'status': 'active', 'started_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String()},
      {'buses': {'plate': 'DEF-456'}, 'routes': {'name': 'Ruta C'}, 'status': 'cancelled', 'started_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
    ]);
  }
}
