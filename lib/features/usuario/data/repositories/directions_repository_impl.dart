import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result_mapper.dart';
import '../../../../shared/domain/entities/directions_entity.dart';
import '../../../../shared/domain/repositories/directions_repository.dart';
import '../datasources/directions_remote_datasource.dart';

class DirectionsRepositoryImpl implements DirectionsRepository {
  final DirectionsRemoteDataSource _remote;

  DirectionsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, DirectionsEntity>> getDirections({
    required double startLat, required double startLng,
    required double endLat, required double endLng,
  }) async {
    return ResultMapper.fromAsync(() async {
      final result = await _remote.fetchDirections(
        startLat: startLat, startLng: startLng,
        endLat: endLat, endLng: endLng,
      );
      return DirectionsEntity(
        polyline: result.polyline,
        distanceMeters: result.distanceMeters,
        durationSeconds: result.durationSeconds,
      );
    });
  }
}
