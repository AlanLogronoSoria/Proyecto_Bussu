import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, AppUser>> execute({
    required String email,
    required String password,
  }) async {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      return Left(ValidationFailure(emailError));
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      return Left(ValidationFailure(passwordError));
    }

    return _repository.signIn(email: email, password: password);
  }
}
