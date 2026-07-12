import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/cooperativa/domain/entities/fleet_health.dart';
import 'package:bussu/features/cooperativa/domain/entities/route_performance.dart';
import 'package:bussu/features/cooperativa/domain/repositories/fleet_repository.dart';
import 'package:bussu/features/cooperativa/domain/usecases/get_fleet_health_usecase.dart';
import 'package:bussu/features/cooperativa/domain/usecases/get_route_performance_usecase.dart';
import 'package:bussu/features/cooperativa/domain/usecases/assign_driver_usecase.dart';

class MockFleetRepository extends Mock implements FleetRepository {}

void main() {
  late MockFleetRepository repo;
  setUp(() { repo = MockFleetRepository(); });

  group('GetFleetHealthUseCase', () {
    test('debe retornar fleet health', () async {
      final useCase = GetFleetHealthUseCase(repo);
      final health = FleetHealth(totalBuses: 10, activeBuses: 8);
      when(() => repo.getFleetHealth('c1')).thenAnswer((_) async => Right(health));
      final result = await useCase.execute('c1');
      expect(result, Right(health));
    });

    test('debe fallar con coopId vacio', () async {
      final useCase = GetFleetHealthUseCase(repo);
      final result = await useCase.execute('');
      expect(result.isLeft(), true);
    });
  });

  group('GetRoutePerformanceUseCase', () {
    test('debe retornar rendimiento', () async {
      final useCase = GetRoutePerformanceUseCase(repo);
      final perf = [RoutePerformance(routeId: 'r1', routeName: 'Ruta A')];
      when(() => repo.getRoutePerformance('c1')).thenAnswer((_) async => Right(perf));
      final result = await useCase.execute('c1');
      expect(result.isRight(), true);
    });
  });

  group('AssignDriverUseCase', () {
    test('debe asignar conductor exitosamente', () async {
      final useCase = AssignDriverUseCase(repo);
      when(() => repo.assignDriverToBus(driverId: 'd1', busId: 'b1'))
          .thenAnswer((_) async => const Right(null));
      final result = await useCase.execute(driverId: 'd1', busId: 'b1');
      expect(result, const Right(null));
    });

    test('debe fallar con IDs vacios', () async {
      final useCase = AssignDriverUseCase(repo);
      final result = await useCase.execute(driverId: '', busId: 'b1');
      expect(result.isLeft(), true);
    });
  });
}
