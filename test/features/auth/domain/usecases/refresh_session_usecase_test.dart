import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/auth/domain/repositories/auth_repository.dart';
import 'package:bussu/features/auth/domain/usecases/refresh_session_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RefreshSessionUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RefreshSessionUseCase(mockRepository);
  });

  group('RefreshSessionUseCase', () {
    test('debe retornar Right cuando el refresh es exitoso', () async {
      when(() => mockRepository.refreshSession())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase.execute();

      expect(result, equals(const Right(null)));
      verify(() => mockRepository.refreshSession()).called(1);
    });

    test('debe retornar AuthFailure cuando falla el refresh', () async {
      when(() => mockRepository.refreshSession()).thenAnswer(
        (_) async => Left(AuthFailure('Token expirado')),
      );

      final result = await useCase.execute();

      expect(result.isLeft(), true);
      expect(
        result.fold((l) => l, (_) => null),
        isA<AuthFailure>(),
      );
    });
  });
}
