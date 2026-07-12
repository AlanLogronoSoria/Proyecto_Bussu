import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/admin_municipal/domain/entities/system_alert.dart';
import 'package:bussu/features/admin_municipal/domain/repositories/network_monitor_repository.dart';
import 'package:bussu/features/admin_municipal/domain/usecases/get_system_alerts_usecase.dart';

class MockRepo extends Mock implements NetworkMonitorRepository {}

void main() {
  late GetSystemAlertsUseCase useCase;
  late MockRepo repo;

  setUp(() {
    repo = MockRepo();
    useCase = GetSystemAlertsUseCase(repo);
  });

  group('GetSystemAlertsUseCase', () {
    final testAlerts = [
      SystemAlert(
        id: '1',
        scope: 'system',
        severity: 'high',
        title: 'Test Alert',
        description: 'Test',
        createdAt: DateTime(2026, 1, 1),
      ),
    ];

    test('debe retornar alertas exitosamente', () async {
      when(() => repo.getSystemAlerts())
          .thenAnswer((_) async => Right(testAlerts));

      final result = await useCase.execute();
      expect(result, Right(testAlerts));
    });

    test('debe retornar Failure cuando el repo falla', () async {
      when(() => repo.getSystemAlerts())
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase.execute();
      expect(result.isLeft(), true);
    });
  });
}
