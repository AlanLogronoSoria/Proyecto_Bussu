import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/fleet_health.dart';
import '../repositories/fleet_repository.dart';

class GetFleetHealthUseCase {
  final FleetRepository _repository;

  GetFleetHealthUseCase(this._repository);

  Future<Either<Failure, FleetHealth>> execute(String cooperativaId) async {
    if (cooperativaId.isEmpty) {
      return const Left(ValidationFailure('ID de cooperativa requerido'));
    }
    return _repository.getFleetHealth(cooperativaId);
  }
}
