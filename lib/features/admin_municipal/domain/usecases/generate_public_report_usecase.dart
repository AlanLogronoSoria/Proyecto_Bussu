import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/network_monitor_repository.dart';

class GeneratePublicReportUseCase {
  final NetworkMonitorRepository _repository;

  GeneratePublicReportUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> execute() {
    return _repository.generatePublicReport();
  }
}
