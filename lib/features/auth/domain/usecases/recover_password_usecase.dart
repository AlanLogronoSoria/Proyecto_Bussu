import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: enviar correo de recuperación de contraseña.
class RecoverPasswordUseCase {
  final AuthRepository _repository;

  RecoverPasswordUseCase(this._repository);

  /// Envía un enlace de recuperación al [email].
  Future<Either<Failure, void>> execute(String email) async {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      return Left(ValidationFailure(emailError));
    }

    return _repository.resetPassword(email);
  }
}
