import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/constants/app_roles.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/auth/domain/entities/auth_user.dart';
import 'package:bussu/features/auth/domain/repositories/auth_repository.dart';
import 'package:bussu/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  group('RegisterUseCase', () {
    const validEmail = 'new@andesmobility.com';
    const validPassword = 'password123';
    const fullName = 'New User';

    test('debe retornar AppUser cuando el registro es exitoso', () async {
      final testUser = AppUser(
        id: 'user-new',
        email: validEmail,
        fullName: fullName,
        role: UserRole.usuario,
        createdAt: DateTime(2026, 1, 1),
      );

      when(
        () => mockRepository.signUp(
          email: validEmail,
          password: validPassword,
          fullName: fullName,
          role: UserRole.usuario,
        ),
      ).thenAnswer((_) async => Right(testUser));

      final result = await useCase.execute(
        email: validEmail,
        password: validPassword,
        confirmPassword: validPassword,
        fullName: fullName,
        role: UserRole.usuario,
      );

      expect(result, equals(Right(testUser)));
    });

    test('debe retornar ValidationFailure cuando passwords no coinciden',
        () async {
      final result = await useCase.execute(
        email: validEmail,
        password: validPassword,
        confirmPassword: 'different',
        fullName: fullName,
        role: UserRole.usuario,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (_) => null), isA<ValidationFailure>());
    });

    test('debe retornar ValidationFailure cuando nombre vacío', () async {
      final result = await useCase.execute(
        email: validEmail,
        password: validPassword,
        confirmPassword: validPassword,
        fullName: '',
        role: UserRole.usuario,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (_) => null), isA<ValidationFailure>());
    });
  });
}
