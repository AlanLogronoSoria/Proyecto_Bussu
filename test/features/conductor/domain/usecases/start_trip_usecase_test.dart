import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/conductor/domain/repositories/trip_repository.dart';
import 'package:bussu/features/conductor/domain/usecases/start_trip_usecase.dart';
import 'package:bussu/features/conductor/domain/entities/trip_entity.dart';
import 'package:bussu/shared/domain/enums/trip_status.dart';

class MockTripRepository extends Mock implements TripRepository {}

void main() {
  late StartTripUseCase useCase;
  late MockTripRepository repo;

  setUp(() { repo = MockTripRepository(); useCase = StartTripUseCase(repo); });

  group('StartTripUseCase', () {
    final testTrip = TripEntity(id: 't1', busId: 'b1', routeId: 'r1', driverId: 'd1', startedAt: DateTime.now(), status: TripStatus.active);

    test('debe iniciar viaje exitosamente', () async {
      when(() => repo.startTrip(busId: 'b1', routeId: 'r1', driverId: 'd1'))
          .thenAnswer((_) async => Right(testTrip));
      final result = await useCase.execute(busId: 'b1', routeId: 'r1', driverId: 'd1');
      expect(result, Right(testTrip));
    });

    test('debe fallar con busId vacio', () async {
      final result = await useCase.execute(busId: '', routeId: 'r1', driverId: 'd1');
      expect(result.isLeft(), true);
    });

    test('debe fallar con routeId vacio', () async {
      final result = await useCase.execute(busId: 'b1', routeId: '', driverId: 'd1');
      expect(result.isLeft(), true);
    });
  });
}
