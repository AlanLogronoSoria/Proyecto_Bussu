import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class TicketsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getTickets(String userId);
}
