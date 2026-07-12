import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/trip_history_repository.dart';

class GetUserTripHistoryUseCase {
  final UserTripHistoryRepository _repository;
  GetUserTripHistoryUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> execute(String userId) async {
    return _repository.getTripHistory(userId);
  }
}
