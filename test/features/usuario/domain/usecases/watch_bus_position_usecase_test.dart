import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/shared/domain/entities/bus_entity.dart';
import 'package:bussu/features/usuario/domain/repositories/bus_tracking_repository.dart';
import 'package:bussu/features/usuario/domain/usecases/watch_bus_position_usecase.dart';

class MockBusTrackingRepository extends Mock implements BusTrackingRepository {}

void main() {
  late WatchBusPositionUseCase useCase;
  late MockBusTrackingRepository repo;

  setUp(() { repo = MockBusTrackingRepository(); useCase = WatchBusPositionUseCase(repo); });

  test('debe emitir posicion del bus', () {
    final bus = BusEntity(id: 'b1', plate: 'ABC-123', latitude: -12.0, longitude: -77.0);
    when(() => repo.watchBusPosition('b1')).thenAnswer((_) => Stream.value(Right(bus)));

    useCase.execute('b1').listen(
      expectAsync1((result) {
        expect(result.isRight(), true);
        result.fold((_) {}, (b) {
          expect(b.id, 'b1');
          expect(b.plate, 'ABC-123');
        });
      }),
    );
  });

  test('debe emitir failure cuando el repo falla', () {
    when(() => repo.watchBusPosition('b1'))
        .thenAnswer((_) => Stream.value(const Left(RealtimeFailure('Error'))));

    useCase.execute('b1').listen(
      expectAsync1((result) {
        expect(result.isLeft(), true);
      }),
    );
  });
}
