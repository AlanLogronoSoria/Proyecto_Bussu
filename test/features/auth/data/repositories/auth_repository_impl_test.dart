import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bussu/core/constants/app_roles.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bussu/features/auth/data/models/auth_user_model.dart';
import 'package:bussu/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bussu/features/auth/domain/enums/auth_event_type.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repo;
  late MockAuthRemoteDataSource ds;

  final testModel = AppUserModel(
    id: 'u1', email: 'test@test.com', fullName: 'Test User',
    role: UserRole.usuario, createdAt: DateTime(2026, 1, 1),
  );

  setUp(() { ds = MockAuthRemoteDataSource(); repo = AuthRepositoryImpl(ds); });

  group('signIn', () {
    test('debe retornar AppUser en exito', () async {
      when(() => ds.signIn('test@test.com', '12345678'))
          .thenAnswer((_) async => testModel);
      final result = await repo.signIn(email: 'test@test.com', password: '12345678');
      expect(result.isRight(), true);
    });

    test('debe retornar Failure en error', () async {
      when(() => ds.signIn('bad@test.com', 'wrong'))
          .thenThrow(Exception('Auth error'));
      final result = await repo.signIn(email: 'bad@test.com', password: 'wrong');
      expect(result.isLeft(), true);
    });
  });

  group('signOut', () {
    test('debe cerrar sesion exitosamente', () async {
      when(() => ds.signOut()).thenAnswer((_) async {});
      final result = await repo.signOut();
      expect(result, const Right(null));
    });
  });

  group('onAuthStateChanged', () {
    test('debe emitir usuario en signedIn', () {
      when(() => ds.onAuthStateChange)
          .thenAnswer((_) => Stream.value(AuthEventType.signedIn));
      when(() => ds.currentSession).thenReturn(null);

      repo.onAuthStateChanged.listen(
        expectAsync1((user) { expect(user, null); }),
      );
    });
  });

  group('getCurrentUser', () {
    test('debe retornar null sin sesion', () async {
      when(() => ds.currentSession).thenReturn(null);
      final user = await repo.getCurrentUser();
      expect(user, null);
    });
  });
}
