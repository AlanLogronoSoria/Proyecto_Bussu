import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/shared/domain/entities/bus_entity.dart';
import 'package:bussu/features/usuario/data/datasources/bus_tracking_remote_datasource.dart';
import 'package:bussu/features/usuario/data/repositories/bus_tracking_repository_impl.dart';
import 'package:bussu/shared/data/models/bus_model.dart';

class MockBusTrackingRemoteDS extends Mock implements BusTrackingRemoteDataSource {}

void main() {
  late BusTrackingRepositoryImpl repo;
  late MockBusTrackingRemoteDS ds;

  setUp(() { ds = MockBusTrackingRemoteDS(); repo = BusTrackingRepositoryImpl(ds); });

  test('watchBusPosition debe emitir BusEntity', () {
    final model = BusModel(id: 'b1', plate: 'ABC-123', latitude: -12.0, longitude: -77.0);
    when(() => ds.watchBusPosition('b1'))
        .thenAnswer((_) => Stream.value([model]));

    repo.watchBusPosition('b1').listen(
      expectAsync1((result) {
        expect(result.isRight(), true);
        result.fold((_) {}, (bus) => expect(bus.id, 'b1'));
      }),
    );
  });

  test('watchBusPosition debe emitir Failure en error', () {
    when(() => ds.watchBusPosition('b1'))
        .thenAnswer((_) => Stream.error(Exception('Realtime error')));

    repo.watchBusPosition('b1').listen(
      expectAsync1((result) {
        expect(result.isLeft(), true);
        expect(result.fold((l) => l, (_) => null), isA<RealtimeFailure>());
      }),
    );
  });

  test('getBusPosition debe retornar BusEntity', () async {
    final model = BusModel(id: 'b1', plate: 'ABC-123');
    when(() => ds.getBusPosition('b1')).thenAnswer((_) async => model);
    final result = await repo.getBusPosition('b1');
    expect(result.isRight(), true);
  });

  test('getBusPosition debe retornar Failure si no existe', () async {
    when(() => ds.getBusPosition('b1')).thenAnswer((_) async => null);
    final result = await repo.getBusPosition('b1');
    expect(result.isLeft(), true);
  });
}
