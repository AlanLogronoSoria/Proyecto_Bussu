import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/system_alert.dart';
import '../repositories/network_monitor_repository.dart';

class GetSystemAlertsUseCase {
  final NetworkMonitorRepository _repository;

  GetSystemAlertsUseCase(this._repository);

  Future<Either<Failure, List<SystemAlert>>> execute() {
    return _repository.getSystemAlerts();
  }
}
