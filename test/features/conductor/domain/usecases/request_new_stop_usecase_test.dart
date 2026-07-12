import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/conductor/domain/repositories/stops_repository.dart';
import 'package:bussu/features/conductor/domain/usecases/request_new_stop_usecase.dart';

class MockStopsRepository extends Mock implements StopsRepository {}

void main() {
  late RequestNewStopUseCase useCase;
  late MockStopsRepository repo;

  setUp(() { repo = MockStopsRepository(); useCase = RequestNewStopUseCase(repo); });

  test('debe solicitar parada exitosamente', () async {
    when(() => repo.requestNewStop(driverId: 'd1', lat: -12.0, lng: -77.0, reason: 'Test'))
        .thenAnswer((_) async => const Right(null));
    final result = await useCase.execute(driverId: 'd1', lat: -12.0, lng: -77.0, reason: 'Test');
    expect(result, const Right(null));
  });

  test('debe fallar sin justificacion', () async {
    final result = await useCase.execute(driverId: 'd1', lat: -12.0, lng: -77.0, reason: '');
    expect(result.isLeft(), true);
  });

  test('debe fallar con latitud invalida', () async {
    final result = await useCase.execute(driverId: 'd1', lat: 200.0, lng: -77.0, reason: 'Test');
    expect(result.isLeft(), true);
  });

  test('debe fallar con longitud invalida', () async {
    final result = await useCase.execute(driverId: 'd1', lat: -12.0, lng: 200.0, reason: 'Test');
    expect(result.isLeft(), true);
  });
}
