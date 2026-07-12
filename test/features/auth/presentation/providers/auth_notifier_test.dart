import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bussu/core/constants/app_roles.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/auth/domain/entities/auth_user.dart';
import 'package:bussu/features/auth/domain/repositories/auth_repository.dart';
import 'package:bussu/features/auth/presentation/providers/auth_provider.dart';
import 'package:bussu/core/security/device_binding_service.dart';
import 'package:bussu/core/di/injection_container.dart';

class MockAuthRepo extends Mock implements AuthRepository {}
class MockDeviceBinding extends Mock implements DeviceBindingService {}

void main() {
  late ProviderContainer container;
  late MockAuthRepo mockRepo;
  late MockDeviceBinding mockBinding;

  setUp(() {
    mockRepo = MockAuthRepo();
    mockBinding = MockDeviceBinding();
    when(() => mockRepo.onAuthStateChanged).thenAnswer((_) => const Stream.empty());
    when(() => mockBinding.getHardwareId()).thenAnswer((_) async => 'device-1');

    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWith((_) => mockRepo),
      deviceBindingServiceProvider.overrideWith((_) => mockBinding),
    ]);
  });

  tearDown(() { container.dispose(); });

  group('AuthNotifier - login', () {
    test('estado inicial es AuthStatus.initial', () {
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.initial);
    });

    test('login exitoso cambia estado a authenticated', () async {
      final user = AppUser(id: 'u1', email: 'test@test.com', role: UserRole.usuario, createdAt: DateTime.now());
      when(() => mockRepo.signIn(email: 'test@test.com', password: '12345678'))
          .thenAnswer((_) async => Right(user));

      await container.read(authNotifierProvider.notifier).login('test@test.com', '12345678');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.email, 'test@test.com');
    });

    test('login fallido cambia estado a unauthenticated con error', () async {
      when(() => mockRepo.signIn(email: 'bad@test.com', password: 'wrongpassword'))
          .thenAnswer((_) async => const Left(AuthFailure('Credenciales invalidas')));

      await container.read(authNotifierProvider.notifier).login('bad@test.com', 'wrongpassword');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.errorMessage, 'Credenciales invalidas');
    });
  });

  group('AuthNotifier - logout', () {
    test('logout cambia estado a unauthenticated', () async {
      when(() => mockRepo.signOut()).thenAnswer((_) async => const Right(null));
      await container.read(authNotifierProvider.notifier).logout();
      expect(container.read(authNotifierProvider).status, AuthStatus.unauthenticated);
    });
  });

  group('AuthNotifier - recoverPassword', () {
    test('recoverPassword exitoso muestra mensaje', () async {
      when(() => mockRepo.resetPassword('test@test.com'))
          .thenAnswer((_) async => const Right(null));
      await container.read(authNotifierProvider.notifier).recoverPassword('test@test.com');
      final state = container.read(authNotifierProvider);
      expect(state.errorMessage, contains('enviado'));
    });

    test('recoverPassword fallido muestra error', () async {
      when(() => mockRepo.resetPassword('bad@test.com'))
          .thenAnswer((_) async => const Left(ValidationFailure('Email invalido')));
      await container.read(authNotifierProvider.notifier).recoverPassword('bad@test.com');
      expect(container.read(authNotifierProvider).errorMessage, 'Email invalido');
    });
  });
}
