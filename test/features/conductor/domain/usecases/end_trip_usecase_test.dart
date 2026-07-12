import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/conductor/domain/repositories/trip_repository.dart';
import 'package:bussu/features/conductor/domain/usecases/end_trip_usecase.dart';

class MockTripRepository extends Mock implements TripRepository {}

void main() {
  late EndTripUseCase useCase;
  late MockTripRepository repo;

  setUp(() {
    repo = MockTripRepository();
    useCase = EndTripUseCase(repo);
  });

  group('EndTripUseCase', () {
    test('debe finalizar viaje exitosamente', () async {
      when(() => repo.endTrip('trip-1'))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase.execute('trip-1');
      expect(result, const Right(null));
    });

    test('debe fallar con tripId vacío', () async {
      final result = await useCase.execute('');
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (_) => null), isA<ValidationFailure>());
    });
  });
}
