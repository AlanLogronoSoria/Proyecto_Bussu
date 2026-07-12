import 'package:dartz/dartz.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

/// Mapea excepciones del dominio a [Failure]s para el flujo [Either].
///
/// Centraliza la lógica de conversión para que repositories y use cases
/// no tengan lógica repetida de try-catch + mapping.
class ResultMapper {
  ResultMapper._();

  /// Convierte una excepción en el [Failure] correspondiente.
  static Failure mapExceptionToFailure(Object e, StackTrace stackTrace) {
    switch (e) {
      case ServerException():
        return ServerFailure(e.message);
      case NetworkException():
        return NetworkFailure(e.message);
      case AuthFailureException():
        return AuthFailure(e.message);
      case CacheException():
        return CacheFailure(e.message);
      case MqttException():
        return MqttFailure(e.message);
      case RealtimeException():
        return RealtimeFailure(e.message);
      case WebSocketException():
        return WebSocketFailure(e.message);
      case DeviceBindingException():
        return DeviceBindingFailure(e.message);
      case PaymentException():
        return PaymentFailure(e.message);
      default:
        return UnknownFailure(e.toString());
    }
  }

  /// Ejecuta una operación asíncrona [fn] y captura cualquier excepción,
  /// retornando su equivalente [Failure].
  static Future<Either<Failure, T>> fromAsync<T>(
    Future<T> Function() fn,
  ) async {
    try {
      final result = await fn();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(mapExceptionToFailure(e, stackTrace));
    }
  }

  /// Ejecuta una operación síncrona [fn] y captura cualquier excepción,
  /// retornando su equivalente [Failure].
  static Either<Failure, T> fromSync<T>(T Function() fn) {
    try {
      final result = fn();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(mapExceptionToFailure(e, stackTrace));
    }
  }

  /// Convierte un Stream que puede lanzar excepciones en un
  /// Stream<Either<Failure, T>> seguro.
  static Stream<Either<Failure, T>> fromStream<T>(Stream<T> stream) {
    return stream.map(Right<Failure, T>.new).handleError(
      (Object error, StackTrace stackTrace) =>
          Left<Failure, T>(mapExceptionToFailure(error, stackTrace)),
    );
  }
}
