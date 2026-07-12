import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_roles.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

/// Repositorio de autenticación.
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña.
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario.
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  /// Cierra la sesión activa.
  Future<Either<Failure, void>> signOut();

  /// Envía un correo de recuperación de contraseña.
  Future<Either<Failure, void>> resetPassword(String email);

  /// Verifica si hay una sesión activa y retorna el usuario.
  Future<AppUser?> getCurrentUser();

  /// Stream que emite el usuario autenticado cuando cambia
  /// el estado de la sesión.
  Stream<AppUser?> get onAuthStateChanged;

  /// Obtiene el token de acceso actual.
  Future<String?> get accessToken;

  /// Refresca manualmente la sesión.
  Future<Either<Failure, void>> refreshSession();

  /// Actualiza el [deviceId] en el perfil del usuario.
  Future<Either<Failure, void>> updateDeviceId(String deviceId);
}
