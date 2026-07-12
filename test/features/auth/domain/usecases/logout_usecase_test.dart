import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/auth/domain/repositories/auth_repository.dart';
import 'package:bussu/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    test('debe retornar Right cuando el logout es exitoso', () async {
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase.execute();

      expect(result, equals(const Right(null)));
      verify(() => mockRepository.signOut()).called(1);
    });

    test('debe retornar AuthFailure cuando el repositorio falla', () async {
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => Left(AuthFailure('Error al cerrar sesión')));

      final result = await useCase.execute();

      expect(result.isLeft(), true);
      expect(
        result.fold((l) => l, (_) => null),
        isA<AuthFailure>(),
      );
    });
  });
}
