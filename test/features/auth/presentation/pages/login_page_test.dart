import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bussu/core/constants/app_roles.dart';
import 'package:bussu/core/error/failures.dart';
import 'package:bussu/features/auth/domain/entities/auth_user.dart';
import 'package:bussu/features/auth/domain/repositories/auth_repository.dart';
import 'package:bussu/features/auth/presentation/providers/auth_provider.dart';
import 'package:bussu/features/auth/presentation/pages/login_page.dart';
import 'package:bussu/core/security/device_binding_service.dart';
import 'package:bussu/core/di/injection_container.dart';

class MockAuthRepo extends Mock implements AuthRepository {}
class MockDeviceBinding extends Mock implements DeviceBindingService {}

Widget createLoginPage(MockAuthRepo repo, MockDeviceBinding binding) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWith((_) => repo),
      deviceBindingServiceProvider.overrideWith((_) => binding),
    ],
    child: const MaterialApp(home: LoginPage()),
  );
}

void main() {
  late MockAuthRepo mockRepo;
  late MockDeviceBinding mockBinding;

  setUp(() {
    mockRepo = MockAuthRepo();
    mockBinding = MockDeviceBinding();
    when(() => mockRepo.onAuthStateChanged).thenAnswer((_) => const Stream.empty());
    when(() => mockBinding.getHardwareId()).thenAnswer((_) async => 'd1');
  });

  group('LoginPage widget', () {
    testWidgets('debe mostrar campos de email y password', (tester) async {
      await tester.pumpWidget(createLoginPage(mockRepo, mockBinding));
      await tester.pumpAndSettle();
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('debe mostrar titulo BUSSU', (tester) async {
      await tester.pumpWidget(createLoginPage(mockRepo, mockBinding));
      await tester.pumpAndSettle();
      expect(find.text('BUSSU'), findsOneWidget);
    });

    testWidgets('debe tener link a registro', (tester) async {
      await tester.pumpWidget(createLoginPage(mockRepo, mockBinding));
      await tester.pumpAndSettle();
      expect(find.text('¿No tienes cuenta? Regístrate'), findsOneWidget);
    });

    testWidgets('debe tener link a recuperar password', (tester) async {
      await tester.pumpWidget(createLoginPage(mockRepo, mockBinding));
      await tester.pumpAndSettle();
      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    });
  });
}
