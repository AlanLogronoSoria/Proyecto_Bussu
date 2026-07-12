import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/admin_municipal/domain/repositories/network_monitor_repository.dart';
import 'package:bussu/features/admin_municipal/domain/usecases/generate_public_report_usecase.dart';

class MockRepo extends Mock implements NetworkMonitorRepository {}

void main() {
  late GeneratePublicReportUseCase useCase;
  late MockRepo repo;

  setUp(() {
    repo = MockRepo();
    useCase = GeneratePublicReportUseCase(repo);
  });

  group('GeneratePublicReportUseCase', () {
    test('debe generar reporte público', () async {
      when(() => repo.generatePublicReport()).thenAnswer(
        (_) async => const Right({'total_buses': 100, 'unresolved_alerts': 5}),
      );

      final result = await useCase.execute();
      expect(result.isRight(), true);
      result.fold(
        (_) {},
        (report) {
          expect(report['total_buses'], 100);
          expect(report['unresolved_alerts'], 5);
        },
      );
    });

    test('debe retornar Failure', () async {
      when(() => repo.generatePublicReport())
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase.execute();
      expect(result.isLeft(), true);
    });
  });
}
