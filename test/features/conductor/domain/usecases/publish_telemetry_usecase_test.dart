import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/conductor/domain/repositories/trip_repository.dart';
import 'package:bussu/features/conductor/domain/usecases/publish_telemetry_usecase.dart';

class MockTripRepository extends Mock implements TripRepository {}

void main() {
  late PublishTelemetryUseCase useCase;
  late MockTripRepository repo;

  setUp(() {
    repo = MockTripRepository();
    useCase = PublishTelemetryUseCase(repo);
  });

  group('PublishTelemetryUseCase', () {
    test('debe publicar telemetría exitosamente', () async {
      when(
        () => repo.publishTelemetry(
          busId: 'bus-1',
          lat: -12.0464,
          lng: -77.0428,
          speedKmh: 45,
          heading: 180,
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase.execute(
        busId: 'bus-1',
        lat: -12.0464,
        lng: -77.0428,
        speedKmh: 45,
        heading: 180,
      );
      expect(result, const Right(null));
    });

    test('debe fallar con latitud inválida', () async {
      final result = await useCase.execute(
        busId: 'bus-1',
        lat: -100,
        lng: -77.0428,
        speedKmh: 45,
        heading: 180,
      );
      expect(result.isLeft(), true);
    });

    test('debe fallar con velocidad negativa', () async {
      final result = await useCase.execute(
        busId: 'bus-1',
        lat: -12.0464,
        lng: -77.0428,
        speedKmh: -5,
        heading: 180,
      );
      expect(result.isLeft(), true);
    });
  });
}
