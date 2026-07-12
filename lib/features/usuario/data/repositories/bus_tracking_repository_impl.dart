import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result_mapper.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../../../../shared/domain/entities/stop_entity.dart';
import '../../domain/repositories/bus_tracking_repository.dart';
import '../datasources/bus_tracking_remote_datasource.dart';
import '../../../../shared/data/models/bus_model.dart';
import '../../../../shared/data/models/stop_model.dart';

/// Implementación del repositorio de seguimiento de buses.
class BusTrackingRepositoryImpl implements BusTrackingRepository {
  final BusTrackingRemoteDataSource _remoteDataSource;

  BusTrackingRepositoryImpl(this._remoteDataSource);

  @override
  Stream<Either<Failure, BusEntity>> watchBusPosition(String busId) {
    return _remoteDataSource.watchBusPosition(busId).transform(
      StreamTransformer<List<BusModel>, Either<Failure, BusEntity>>.fromHandlers(
        handleData: (models, sink) {
          if (models.isNotEmpty) {
            sink.add(Right(models.first.toEntity()));
          }
        },
        handleError: (error, stackTrace, sink) {
          sink.add(Left(RealtimeFailure(error.toString())));
        },
      ),
    );
  }

  @override
  Stream<Either<Failure, List<BusEntity>>> watchRouteBuses(String routeId) {
    return _remoteDataSource.watchRouteBuses(routeId).transform(
      StreamTransformer<List<BusModel>, Either<Failure, List<BusEntity>>>.fromHandlers(
        handleData: (models, sink) {
          sink.add(Right(models.map((m) => m.toEntity()).toList()));
        },
        handleError: (error, stackTrace, sink) {
          sink.add(Left(RealtimeFailure(error.toString())));
        },
      ),
    );
  }

  @override
  Future<Either<Failure, BusEntity>> getBusPosition(String busId) async {
    return ResultMapper.fromAsync(() async {
      final model = await _remoteDataSource.getBusPosition(busId);
      if (model == null) {
        throw Exception('Bus no encontrado');
      }
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<StopEntity>>> getRouteStops(
    String routeId,
  ) async {
    return ResultMapper.fromAsync(() async {
      final stopsData = await _remoteDataSource.getRouteStops(routeId);
      return stopsData.map((s) => StopModel.fromJson(s).toEntity()).toList();
    });
  }
}
