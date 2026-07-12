import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class CoopTripHistoryRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getTripHistory(String coopId);
}
