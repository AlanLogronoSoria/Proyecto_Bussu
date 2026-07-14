import '../../../../core/navigation/ors_service.dart';

abstract class DirectionsRemoteDataSource {
  Future<OrsRouteResult> fetchDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  });
}

class DirectionsRemoteDataSourceImpl implements DirectionsRemoteDataSource {
  final OrsService _ors;

  DirectionsRemoteDataSourceImpl(this._ors);

  @override
  Future<OrsRouteResult> fetchDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    return _ors.getDirections(
      startLat: startLat, startLng: startLng,
      endLat: endLat, endLng: endLng,
    );
  }
}
