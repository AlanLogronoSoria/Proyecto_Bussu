import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../../../../shared/domain/entities/route_entity.dart';
import '../../../../shared/domain/entities/stop_entity.dart';

/// Repositorio de cálculo de ETA y gestión de rutas.
abstract class EtaRepository {
  /// Calcula el ETA de un bus a una parada específica.
  Future<Either<Failure, Duration>> calculateEta({
    required String busId,
    required String stopId,
  });

  /// Obtiene el ETA para todas las paradas de una ruta desde un bus.
  Stream<Either<Failure, Map<String, Duration>>> watchEtas({
    required String busId,
    required String routeId,
  });

  /// Obtiene las rutas disponibles para el usuario.
  Future<Either<Failure, List<RouteEntity>>> getAvailableRoutes();

  /// Obtiene los detalles de una ruta con sus buses activos.
  Future<Either<Failure, RouteWithBuses>> getRouteWithBuses(String routeId);
}

/// Agrupación de una ruta con sus buses activos y ETAs.
class RouteWithBuses {
  final RouteEntity route;
  final List<BusEntity> activeBuses;
  final Map<String, List<Duration>> etasByBus;

  const RouteWithBuses({
    required this.route,
    this.activeBuses = const [],
    this.etasByBus = const {},
  });
}
