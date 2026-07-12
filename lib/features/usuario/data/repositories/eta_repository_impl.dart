import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/eta_calculator.dart';
import '../../../../core/utils/result_mapper.dart';
import '../../../../shared/data/models/bus_model.dart';
import '../../../../shared/data/models/route_model.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../../../../shared/domain/entities/route_entity.dart';
import '../../domain/repositories/eta_repository.dart';
import '../datasources/eta_remote_datasource.dart';

/// Implementación del repositorio de ETA y rutas usando [EtaRemoteDataSource].
class EtaRepositoryImpl implements EtaRepository {
  final EtaRemoteDataSource _remote;

  EtaRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, Duration>> calculateEta({
    required String busId,
    required String stopId,
  }) async {
    return ResultMapper.fromAsync(() async {
      final busData = await _remote.fetchBusPosition(busId);
      if (busData == null) throw Exception('Bus no encontrado');

      final busLat = (busData['lat'] as num).toDouble();
      final busLng = (busData['lng'] as num).toDouble();
      final speed = (busData['speed_kmh'] as num?)?.toDouble() ?? 0;

      final stopData = await _remote.fetchStopData(stopId);
      if (stopData == null) throw Exception('Parada no encontrada');

      final routeId = stopData['route_id'] as String;
      final stopDistance =
          (stopData['distance_along_route'] as num?)?.toDouble() ?? 0;

      if (stopDistance <= 0 || speed <= 0) return Duration.zero;

      final polyline = await _remote.fetchRoutePolyline(routeId);
      if (polyline == null) return Duration.zero;

      final busProgress = EtaCalculator.progressOnPolyline(
        polyline,
        busLat,
        busLng,
      );

      return EtaCalculator.etaToStop(
        busProgressMeters: busProgress,
        stopDistanceMeters: stopDistance,
        smoothedSpeedKmh: speed,
      );
    });
  }

  @override
  Future<Either<Failure, List<RouteEntity>>> getAvailableRoutes() async {
    return ResultMapper.fromAsync(() async {
      final data = await _remote.fetchAvailableRoutes();
      return data.map((r) => RouteModel.fromJson(r).toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, RouteWithBuses>> getRouteWithBuses(
    String routeId,
  ) async {
    return ResultMapper.fromAsync(() async {
      final data = await _remote.fetchRouteWithBuses(routeId);
      if (data == null) throw Exception('Ruta no encontrada');

      final route = RouteModel.fromJson(
          data['route'] as Map<String, dynamic>).toEntity();

      final buses = (data['buses'] as List<dynamic>)
          .map((b) => BusModel.fromRealtime(b as Map<String, dynamic>).toEntity())
          .toList();

      return RouteWithBuses(route: route, activeBuses: buses);
    });
  }

  @override
  Stream<Either<Failure, Map<String, Duration>>> watchEtas({
    required String busId,
    required String routeId,
  }) async* {
    final busStream = _remote.watchBusPosition(busId);

    await for (final rows in busStream) {
      if (rows.isEmpty) continue;

      final bus = BusModel.fromRealtime(rows.first);
      if (bus.latitude == null || bus.longitude == null) continue;

      try {
        final routeResult =
            await _remote.fetchRoutePolyline(routeId);
        if (routeResult == null) continue;

        final stopsResult = await _remote.fetchRouteStops(routeId);

        final busProgress = EtaCalculator.progressOnPolyline(
          routeResult,
          bus.latitude!,
          bus.longitude!,
        );

        final etas = <String, Duration>{};
        final speed = bus.speedKmh ?? 0;

        for (final stop in stopsResult) {
          final sid = stop['id'] as String;
          final stopDist =
              (stop['distance_along_route'] as num?)?.toDouble() ?? 0;
          final remaining = stopDist - busProgress;
          if (remaining > 0 && speed > 0) {
            etas[sid] = EtaCalculator.calculateEta(remaining, speed);
          } else {
            etas[sid] = Duration.zero;
          }
        }

        yield Right(etas);
      } catch (e) {
        yield Left(ServerFailure(e.toString()));
      }
    }
  }
}
