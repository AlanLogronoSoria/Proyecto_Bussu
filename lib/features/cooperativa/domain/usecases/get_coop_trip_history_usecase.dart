import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/coop_trip_history_repository.dart';

class GetCoopTripHistoryUseCase {
  final CoopTripHistoryRepository _repository;
  GetCoopTripHistoryUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> execute(String coopId) async {
    return _repository.getTripHistory(coopId);
  }
}
