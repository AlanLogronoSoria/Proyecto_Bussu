import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../../../../shared/domain/entities/stop_entity.dart';

/// Repositorio de seguimiento de buses en tiempo real.
abstract class BusTrackingRepository {
  /// Observa la posición en tiempo real de un bus específico.
  Stream<Either<Failure, BusEntity>> watchBusPosition(String busId);

  /// Observa múltiples buses de una ruta.
  Stream<Either<Failure, List<BusEntity>>> watchRouteBuses(String routeId);

  /// Obtiene la posición actual de un bus (snapshot único).
  Future<Either<Failure, BusEntity>> getBusPosition(String busId);

  /// Obtiene todas las paradas de una ruta.
  Future<Either<Failure, List<StopEntity>>> getRouteStops(String routeId);
}
