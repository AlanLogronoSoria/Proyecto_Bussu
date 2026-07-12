import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/trip_history_repository.dart';

class UserTripHistoryRepositoryImpl implements UserTripHistoryRepository {
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTripHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right([
      {'route_name': 'Ruta A - Centro', 'bus_plate': 'ABC-123', 'started_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(), 'status': 'completed'},
      {'route_name': 'Ruta B - Miraflores', 'bus_plate': 'ABC-124', 'started_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(), 'status': 'completed'},
    ]);
  }
}
