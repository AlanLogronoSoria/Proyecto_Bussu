import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/tickets_repository.dart';

class GetTicketsUseCase {
  final TicketsRepository _repository;
  GetTicketsUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> execute(String userId) async {
    return _repository.getTickets(userId);
  }
}
