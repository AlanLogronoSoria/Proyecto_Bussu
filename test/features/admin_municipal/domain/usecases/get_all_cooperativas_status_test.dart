import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/admin_municipal/domain/entities/cooperativa_status.dart';
import 'package:bussu/features/admin_municipal/domain/repositories/network_monitor_repository.dart';
import 'package:bussu/features/admin_municipal/domain/usecases/get_all_cooperativas_status_usecase.dart';

class MockRepo extends Mock implements NetworkMonitorRepository {}

void main() {
  late GetAllCooperativasStatusUseCase useCase;
  late MockRepo repo;

  setUp(() {
    repo = MockRepo();
    useCase = GetAllCooperativasStatusUseCase(repo);
  });

  group('GetAllCooperativasStatusUseCase', () {
    test('debe retornar lista de estados', () async {
      final statuses = [
        CooperativaStatus(id: '1', name: 'Coop A', totalBuses: 10, activeBuses: 8),
      ];

      when(() => repo.getAllCooperativasStatus())
          .thenAnswer((_) async => Right(statuses));

      final result = await useCase.execute();
      expect(result.isRight(), true);
      result.fold((_) {}, (list) => expect(list.length, 1));
    });

    test('debe retornar Failure', () async {
      when(() => repo.getAllCooperativasStatus())
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase.execute();
      expect(result.isLeft(), true);
    });
  });
}
