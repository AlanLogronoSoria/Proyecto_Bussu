import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result_mapper.dart';
import '../../domain/repositories/stops_repository.dart';
import '../datasources/stops_remote_datasource.dart';

/// Implementación del repositorio de paradas usando [StopsRemoteDataSource].
class StopsRepositoryImpl implements StopsRepository {
  final StopsRemoteDataSource _remote;

  StopsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, void>> requestNewStop({
    required String driverId,
    required double lat,
    required double lng,
    required String reason,
  }) async {
    return ResultMapper.fromAsync(() {
      return _remote.insertStopRequest({
        'driver_id': driverId,
        'proposed_lat': lat,
        'proposed_lng': lng,
        'justification': reason,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRouteStops(
    String routeId,
  ) async {
    return ResultMapper.fromAsync(() => _remote.fetchRouteStops(routeId));
  }
}
