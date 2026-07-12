import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../error/failures.dart';
import '../error/exceptions.dart';

/// Cliente para invocar Edge Functions de Supabase.
///
/// Centraliza todas las llamadas a funciones serverless para:
/// - Validar device binding tras login
/// - Enviar notificaciones push
/// - Obtener reportes consolidados (alternativa a RPC directo)
class EdgeFunctionsClient {
  final SupabaseClient _client;

  EdgeFunctionsClient(this._client);

  /// Valida el device binding tras login.
  ///
  /// Llama a [validate-device-binding] con el [userId] y [deviceId].
  /// Retorna `true` si el dispositivo está vinculado correctamente.
  /// Lanza [DeviceBindingException] si el dispositivo no está autorizado.
  Future<Either<Failure, bool>> validateDeviceBinding({
    required String userId,
    required String deviceId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'validate-device-binding',
        body: {
          'user_id': userId,
          'device_id': deviceId,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['blocked'] == true) {
        return const Left(DeviceBindingFailure(
          'Dispositivo no autorizado. Contacta al administrador.',
        ));
      }

      return Right(data['bound'] == true);
    } catch (e) {
      return Left(ServerFailure('Error validando dispositivo: $e'));
    }
  }

  /// Invoca la función RPC [get_municipal_report].
  Future<Either<Failure, Map<String, dynamic>>> getMunicipalReport() async {
    try {
      final response = await _client.rpc('get_municipal_report');
      return Right(response as Map<String, dynamic>);
    } catch (e) {
      return Left(ServerFailure('Error obteniendo reporte: $e'));
    }
  }

  /// Invoca la función RPC [get_route_performance].
  Future<Either<Failure, List<Map<String, dynamic>>>> getRoutePerformance(
    String cooperativaId,
  ) async {
    try {
      final response = await _client.rpc(
        'get_route_performance',
        params: {'coop_id': cooperativaId},
      );
      return Right((response as List<dynamic>).cast<Map<String, dynamic>>());
    } catch (e) {
      return Left(ServerFailure('Error obteniendo rendimiento: $e'));
    }
  }

  /// Invoca la función RPC [get_active_buses_on_route].
  Future<Either<Failure, List<Map<String, dynamic>>>> getActiveBusesOnRoute(
    String routeId,
  ) async {
    try {
      final response = await _client.rpc(
        'get_active_buses_on_route',
        params: {'route_id_param': routeId},
      );
      return Right((response as List<dynamic>).cast<Map<String, dynamic>>());
    } catch (e) {
      return Left(ServerFailure('Error obteniendo buses activos: $e'));
    }
  }

  /// Invoca la función RPC [get_driver_trip_history].
  Future<Either<Failure, List<Map<String, dynamic>>>> getDriverTripHistory(
    String driverId, {
    int limit = 50,
  }) async {
    try {
      final response = await _client.rpc(
        'get_driver_trip_history',
        params: {
          'driver_id_param': driverId,
          'limit_param': limit,
        },
      );
      return Right((response as List<dynamic>).cast<Map<String, dynamic>>());
    } catch (e) {
      return Left(ServerFailure('Error obteniendo historial: $e'));
    }
  }

  /// Registra presencia de usuario en parada (BLE detect).
  Future<Either<Failure, void>> registerStopPresence({
    required String userId,
    required String stopId,
  }) async {
    try {
      await _client.from('user_stop_presence').insert({
        'user_id': userId,
        'stop_id': stopId,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error registrando presencia: $e'));
    }
  }

  /// Registra/actualiza el token de dispositivo para push notifications.
  Future<Either<Failure, void>> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      await _client.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': platform,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error registrando token: $e'));
    }
  }
}
