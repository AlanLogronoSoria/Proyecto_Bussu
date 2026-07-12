import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result_mapper.dart';
import '../../../../shared/domain/enums/trip_status.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/obd_telemetry_datasource.dart';
import '../datasources/trip_remote_datasource.dart';

/// Implementación del repositorio de viajes del conductor.
class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _tripRemote;
  final ObdTelemetryDataSource _obdDataSource;

  TripRepositoryImpl(this._tripRemote, this._obdDataSource);

  @override
  Future<Either<Failure, TripEntity>> startTrip({
    required String busId,
    required String routeId,
    required String driverId,
  }) async {
    return ResultMapper.fromAsync(() async {
      final now = DateTime.now().toIso8601String();
      final data = await _tripRemote.insertTrip({
        'bus_id': busId,
        'route_id': routeId,
        'driver_id': driverId,
        'started_at': now,
        'status': 'active',
      });

      return TripEntity(
        id: data['id'] as String,
        busId: busId,
        routeId: routeId,
        driverId: driverId,
        startedAt: DateTime.parse(now),
        status: TripStatus.active,
      );
    });
  }

  @override
  Future<Either<Failure, void>> endTrip(String tripId) async {
    return ResultMapper.fromAsync(() async {
      await _tripRemote.updateTrip(tripId, {
        'ended_at': DateTime.now().toIso8601String(),
        'status': 'completed',
      });
    });
  }

  @override
  Future<Either<Failure, TripEntity?>> getActiveTrip(String driverId) async {
    try {
      final data = await _tripRemote.fetchActiveTrip(driverId);
      if (data == null) return const Right(null);

      return Right(TripEntity(
        id: data['id'] as String,
        busId: data['bus_id'] as String,
        routeId: data['route_id'] as String,
        driverId: data['driver_id'] as String,
        startedAt: data['started_at'] != null
            ? DateTime.parse(data['started_at'] as String)
            : null,
        status: TripStatus.active,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, TripEntity>> watchActiveTrip(String driverId) {
    return _tripRemote.watchActiveTrip(driverId).map((rows) {
      final activeTrips = rows.where((t) {
        return t['driver_id'] == driverId && t['status'] == 'active';
      }).toList();

      if (activeTrips.isEmpty) {
        return Left<Failure, TripEntity>(
          ValidationFailure('No hay viaje activo'),
        );
      }

      final data = activeTrips.first;
      return Right<Failure, TripEntity>(TripEntity(
        id: data['id'] as String,
        busId: data['bus_id'] as String,
        routeId: data['route_id'] as String,
        driverId: data['driver_id'] as String,
        startedAt: data['started_at'] != null
            ? DateTime.parse(data['started_at'] as String)
            : null,
        status: TripStatus.active,
      ));
    });
  }

  @override
  Future<Either<Failure, void>> publishTelemetry({
    required String busId,
    required double lat,
    required double lng,
    required double speedKmh,
    required double heading,
  }) async {
    return ResultMapper.fromAsync(() {
      return _obdDataSource.publishTelemetry(
        busId: busId,
        lat: lat,
        lng: lng,
        speedKmh: speedKmh,
        heading: heading,
      );
    });
  }

  @override
  Future<Either<Failure, void>> updatePassengerCount({
    required String busId,
    required int count,
  }) async {
    return ResultMapper.fromAsync(() {
      return _tripRemote.upsertPassengerCount(busId, count);
    });
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getTripHistory(
    String driverId,
  ) async {
    return ResultMapper.fromAsync(() async {
      final data = await _tripRemote.fetchTripHistory(driverId);

      return data.map((trip) {
        return TripEntity(
          id: trip['id'] as String,
          busId: trip['bus_id'] as String,
          routeId: trip['route_id'] as String,
          driverId: trip['driver_id'] as String,
          startedAt: trip['started_at'] != null
              ? DateTime.parse(trip['started_at'] as String)
              : null,
          endedAt: trip['ended_at'] != null
              ? DateTime.parse(trip['ended_at'] as String)
              : null,
          status: _parseStatus(trip['status'] as String?),
        );
      }).toList();
    });
  }

  TripStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return TripStatus.active;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.scheduled;
    }
  }
}
