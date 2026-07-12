import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_roles.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, AppUser>> execute({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required UserRole role,
  }) async {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      return Left(ValidationFailure(emailError));
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      return Left(ValidationFailure(passwordError));
    }

    final matchError =
        Validators.validatePasswordMatch(password, confirmPassword);
    if (matchError != null) {
      return Left(ValidationFailure(matchError));
    }

    final nameError = Validators.validateRequired(fullName, 'Nombre');
    if (nameError != null) {
      return Left(ValidationFailure(nameError));
    }

    return _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }
}
