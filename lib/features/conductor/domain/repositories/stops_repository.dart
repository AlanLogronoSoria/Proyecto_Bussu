import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Repositorio de gestión de paradas para el conductor.
abstract class StopsRepository {
  /// Envía una solicitud de nueva parada.
  Future<Either<Failure, void>> requestNewStop({
    required String driverId,
    required double lat,
    required double lng,
    required String reason,
  });

  /// Obtiene las paradas de una ruta.
  Future<Either<Failure, List<Map<String, dynamic>>>> getRouteStops(
    String routeId,
  );
}
