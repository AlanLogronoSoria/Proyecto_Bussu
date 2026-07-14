import '../../../../core/geocoding/nominatim_service.dart';

abstract class GeocodingRemoteDataSource {
  Future<NominatimResult> search({
    required String query,
    String? country,
    String? city,
    int limit = 5,
  });

  Future<NominatimPlace?> reverseGeocode({required double lat, required double lng});
}

class GeocodingRemoteDataSourceImpl implements GeocodingRemoteDataSource {
  final NominatimService _nominatim;

  GeocodingRemoteDataSourceImpl(this._nominatim);

  @override
  Future<NominatimResult> search({
    required String query,
    String? country,
    String? city,
    int limit = 5,
  }) async {
    return _nominatim.search(query: query, country: country, city: city, limit: limit);
  }

  @override
  Future<NominatimPlace?> reverseGeocode({required double lat, required double lng}) async {
    return _nominatim.reverseGeocode(lat: lat, lng: lng);
  }
}
