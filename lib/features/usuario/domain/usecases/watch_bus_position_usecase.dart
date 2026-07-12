import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../repositories/bus_tracking_repository.dart';

/// Observa la posición en tiempo real de un bus.
class WatchBusPositionUseCase {
  final BusTrackingRepository _repository;

  WatchBusPositionUseCase(this._repository);

  Stream<Either<Failure, BusEntity>> execute(String busId) {
    return _repository.watchBusPosition(busId);
  }
}
