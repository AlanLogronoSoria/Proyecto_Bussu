import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/driver_entity.dart';
import '../repositories/fleet_repository.dart';

class AssignDriverUseCase {
  final FleetRepository _repository;

  AssignDriverUseCase(this._repository);

  Future<Either<Failure, void>> execute({
    required String driverId,
    required String busId,
  }) async {
    if (driverId.isEmpty || busId.isEmpty) {
      return const Left(ValidationFailure('Conductor y bus son obligatorios'));
    }
    return _repository.assignDriverToBus(driverId: driverId, busId: busId);
  }
}
