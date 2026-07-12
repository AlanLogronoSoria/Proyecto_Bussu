import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/auth/domain/repositories/auth_repository.dart';
import 'package:bussu/features/auth/domain/usecases/recover_password_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RecoverPasswordUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RecoverPasswordUseCase(mockRepository);
  });

  group('RecoverPasswordUseCase', () {
    const validEmail = 'user@andesmobility.com';

    test('debe retornar Right cuando el email es válido y se envía', () async {
      when(() => mockRepository.resetPassword(validEmail))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase.execute(validEmail);

      expect(result, equals(const Right(null)));
      verify(() => mockRepository.resetPassword(validEmail)).called(1);
    });

    test('debe retornar ValidationFailure cuando el email es inválido',
        () async {
      final result = await useCase.execute('invalid-email');

      expect(result.isLeft(), true);
      expect(
        result.fold((l) => l, (_) => null),
        isA<ValidationFailure>(),
      );
      verifyNever(() => mockRepository.resetPassword(any()));
    });

    test('debe retornar AuthFailure cuando el repositorio falla', () async {
      when(() => mockRepository.resetPassword(validEmail))
          .thenAnswer((_) async => Left(AuthFailure('Usuario no encontrado')));

      final result = await useCase.execute(validEmail);

      expect(result.isLeft(), true);
      expect(
        result.fold((l) => l, (_) => null),
        isA<AuthFailure>(),
      );
    });
  });
}
