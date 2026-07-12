import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cooperativa_status.dart';
import '../../domain/entities/municipal_overview.dart';
import '../../domain/entities/system_alert.dart';
import '../../domain/repositories/network_monitor_repository.dart';
import '../../domain/usecases/generate_public_report_usecase.dart';
import '../../domain/usecases/get_all_cooperativas_status_usecase.dart';
import '../../domain/usecases/get_system_alerts_usecase.dart';

final networkMonitorRepositoryProvider =
    Provider<NetworkMonitorRepository>((_) {
  throw UnimplementedError('Registra en injection_container');
});

final getSystemAlertsUseCaseProvider =
    Provider<GetSystemAlertsUseCase>((ref) {
  return GetSystemAlertsUseCase(ref.watch(networkMonitorRepositoryProvider));
});

final getAllCooperativasStatusUseCaseProvider =
    Provider<GetAllCooperativasStatusUseCase>((ref) {
  return GetAllCooperativasStatusUseCase(
    ref.watch(networkMonitorRepositoryProvider),
  );
});

final generatePublicReportUseCaseProvider =
    Provider<GeneratePublicReportUseCase>((ref) {
  return GeneratePublicReportUseCase(
    ref.watch(networkMonitorRepositoryProvider),
  );
});

// ---- Streams & Futures ----

final municipalOverviewProvider =
    StreamProvider<MunicipalOverview>((ref) {
  final repo = ref.watch(networkMonitorRepositoryProvider);
  return repo.watchMunicipalOverview()
      .where((e) => e.isRight())
      .map((e) => e.fold((_) => const MunicipalOverview(), (o) => o))
      .distinct();
});

final cooperativasStatusProvider =
    FutureProvider<List<CooperativaStatus>>((ref) async {
  final repo = ref.watch(networkMonitorRepositoryProvider);
  final result = await repo.getAllCooperativasStatus();
  return result.fold((_) => [], (c) => c);
});

final systemAlertsProvider =
    StreamProvider<List<SystemAlert>>((ref) {
  final repo = ref.watch(networkMonitorRepositoryProvider);
  return repo.watchSystemAlerts()
      .where((e) => e.isRight())
      .map((e) => e.fold((_) => <SystemAlert>[], (a) => a))
      .distinct((a, b) => a.length == b.length);
});

final premiumSubscriptionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(networkMonitorRepositoryProvider);
  final result = await repo.getPremiumSubscriptions();
  return result.fold((_) => [], (s) => s);
});

final allUsersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(networkMonitorRepositoryProvider);
  final result = await repo.getAllUsers();
  return result.fold((_) => [], (u) => u);
});

final publicReportProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final repo = ref.watch(networkMonitorRepositoryProvider);
  final result = await repo.generatePublicReport();
  return result.fold((_) => null, (r) => r);
});
