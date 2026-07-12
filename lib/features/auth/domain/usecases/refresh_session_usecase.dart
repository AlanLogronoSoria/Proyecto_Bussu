import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: refrescar la sesión manualmente.
///
/// Se usa cuando una llamada API falla con 401 para renovar el token
/// antes de reintentar.
class RefreshSessionUseCase {
  final AuthRepository _repository;

  RefreshSessionUseCase(this._repository);

  Future<Either<Failure, void>> execute() async {
    return _repository.refreshSession();
  }
}
