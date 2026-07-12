import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class UserTripHistoryRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getTripHistory(String userId);
}
