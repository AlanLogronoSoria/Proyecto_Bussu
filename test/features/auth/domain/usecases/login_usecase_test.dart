import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/constants/app_roles.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/auth/domain/entities/auth_user.dart';
import 'package:bussu/features/auth/domain/repositories/auth_repository.dart';
import 'package:bussu/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  final testUser = AppUser(
    id: 'user-123',
    email: 'test@andesmobility.com',
    fullName: 'Test User',
    role: UserRole.usuario,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const validEmail = 'test@andesmobility.com';
    const validPassword = 'password123';
    const invalidEmail = 'not-an-email';
    const shortPassword = '123';

    test('debe retornar AppUser cuando el login es exitoso', () async {
      when(
        () => mockRepository.signIn(
          email: validEmail,
          password: validPassword,
        ),
      ).thenAnswer((_) async => Right(testUser));

      final result = await useCase.execute(
        email: validEmail,
        password: validPassword,
      );

      expect(result, equals(Right(testUser)));
      verify(
        () => mockRepository.signIn(
          email: validEmail,
          password: validPassword,
        ),
      ).called(1);
    });

    test(
        'debe retornar ValidationFailure cuando el email es inválido',
        () async {
      final result = await useCase.execute(
        email: invalidEmail,
        password: validPassword,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (_) => null), isA<ValidationFailure>());
      verifyNever(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test(
        'debe retornar ValidationFailure cuando contraseña corta',
        () async {
      final result = await useCase.execute(
        email: validEmail,
        password: shortPassword,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (_) => null), isA<ValidationFailure>());
      verifyNever(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('debe retornar AuthFailure cuando el repositorio falla', () async {
      when(
        () => mockRepository.signIn(
          email: validEmail,
          password: validPassword,
        ),
      ).thenAnswer(
        (_) async => const Left(AuthFailure('Credenciales inválidas')),
      );

      final result = await useCase.execute(
        email: validEmail,
        password: validPassword,
      );

      expect(result, equals(const Left(AuthFailure('Credenciales inválidas'))));
    });
  });
}
