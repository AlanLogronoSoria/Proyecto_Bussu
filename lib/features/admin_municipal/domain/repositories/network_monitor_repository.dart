import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cooperativa_status.dart';
import '../entities/municipal_overview.dart';
import '../entities/system_alert.dart';

/// Repositorio de monitoreo de red para el administrador municipal.
abstract class NetworkMonitorRepository {
  // Overview
  Future<Either<Failure, MunicipalOverview>> getMunicipalOverview();
  Stream<Either<Failure, MunicipalOverview>> watchMunicipalOverview();

  // Cooperativas
  Future<Either<Failure, List<CooperativaStatus>>> getAllCooperativasStatus();
  Future<Either<Failure, List<Map<String, dynamic>>>> getCooperativas();
  Future<Either<Failure, void>> createCooperativa(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateCooperativa(Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteCooperativa(String id);

  // Alertas
  Future<Either<Failure, List<SystemAlert>>> getSystemAlerts();
  Stream<Either<Failure, List<SystemAlert>>> watchSystemAlerts();
  Future<Either<Failure, void>> createAlert(SystemAlert alert);
  Future<Either<Failure, void>> resolveAlert(String alertId);
  Future<Either<Failure, void>> deleteAlert(String alertId);

  // Premium
  Future<Either<Failure, List<Map<String, dynamic>>>> getPremiumSubscriptions();
  Future<Either<Failure, void>> updateSubscriptionStatus(
    String id,
    String status,
  );

  // Users
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllUsers();
  Future<Either<Failure, void>> updateUserRole(String userId, String role);

  // Reports
  Future<Either<Failure, Map<String, dynamic>>> generatePublicReport();
}
