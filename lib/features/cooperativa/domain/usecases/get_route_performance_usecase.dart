import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/route_performance.dart';
import '../repositories/fleet_repository.dart';

class GetRoutePerformanceUseCase {
  final FleetRepository _repository;

  GetRoutePerformanceUseCase(this._repository);

  Future<Either<Failure, List<RoutePerformance>>> execute(
    String cooperativaId,
  ) async {
    if (cooperativaId.isEmpty) {
      return const Left(ValidationFailure('ID de cooperativa requerido'));
    }
    return _repository.getRoutePerformance(cooperativaId);
  }
}
