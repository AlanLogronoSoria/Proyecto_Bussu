import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/trip_entity.dart';

/// Repositorio de gestión de viajes del conductor.
abstract class TripRepository {
  /// Inicia un nuevo viaje asignando bus y ruta.
  Future<Either<Failure, TripEntity>> startTrip({
    required String busId,
    required String routeId,
    required String driverId,
  });

  /// Finaliza el viaje activo.
  Future<Either<Failure, void>> endTrip(String tripId);

  /// Obtiene el viaje activo del conductor.
  Future<Either<Failure, TripEntity?>> getActiveTrip(String driverId);

  /// Stream del viaje activo en tiempo real.
  Stream<Either<Failure, TripEntity>> watchActiveTrip(String driverId);

  /// Publica telemetría (GPS, velocidad) del bus.
  Future<Either<Failure, void>> publishTelemetry({
    required String busId,
    required double lat,
    required double lng,
    required double speedKmh,
    required double heading,
  });

  /// Actualiza el conteo de pasajeros.
  Future<Either<Failure, void>> updatePassengerCount({
    required String busId,
    required int count,
  });

  /// Obtiene el historial de viajes del conductor.
  Future<Either<Failure, List<TripEntity>>> getTripHistory(String driverId);
}
