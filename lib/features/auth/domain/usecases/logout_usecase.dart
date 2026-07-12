import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: cerrar sesión.
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Cierra la sesión activa y limpia el estado local.
  Future<Either<Failure, void>> execute() async {
    return _repository.signOut();
  }
}
