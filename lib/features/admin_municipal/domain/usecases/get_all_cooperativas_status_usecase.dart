import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cooperativa_status.dart';
import '../repositories/network_monitor_repository.dart';

class GetAllCooperativasStatusUseCase {
  final NetworkMonitorRepository _repository;

  GetAllCooperativasStatusUseCase(this._repository);

  Future<Either<Failure, List<CooperativaStatus>>> execute() {
    return _repository.getAllCooperativasStatus();
  }
}
