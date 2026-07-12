import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/tickets_repository.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTickets(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right([
      {'route_name': 'Ruta A - Centro', 'status': 'active', 'amount': '2.50'},
      {'route_name': 'Ruta B - Miraflores', 'status': 'used', 'amount': '2.50'},
    ]);
  }
}
