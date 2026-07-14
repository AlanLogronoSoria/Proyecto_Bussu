import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/geocoding/nominatim_service.dart';
import '../../../../core/utils/result_mapper.dart';
import '../../../../shared/domain/entities/geocoding_entity.dart';
import '../../../../shared/domain/repositories/geocoding_repository.dart';
import '../datasources/geocoding_remote_datasource.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {
  final GeocodingRemoteDataSource _remote;

  GeocodingRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, GeocodingResultEntity>> search({
    required String query, String? country, String? city, int limit = 5,
  }) async {
    return ResultMapper.fromAsync(() async {
      final result = await _remote.search(query: query, country: country, city: city, limit: limit);
      return GeocodingResultEntity(
        query: result.query,
        places: result.places.map(_mapPlace).toList(),
      );
    });
  }

  GeocodingEntity _mapPlace(NominatimPlace p) => GeocodingEntity(
    lat: p.lat, lng: p.lng, displayName: p.displayName,
    street: p.street, city: p.city, district: p.district, country: p.country,
  );

  @override
  Future<Either<Failure, GeocodingEntity?>> searchAddress(String address) async {
    final result = await search(query: address, limit: 1);
    return result.fold(
      (f) => Left(f),
      (r) => Right(r.places.isNotEmpty ? r.places.first : null),
    );
  }

  @override
  Future<Either<Failure, GeocodingResultEntity>> searchStreet(
    String street, {String? city, String? country}) async {
    return search(query: street, city: city, country: country);
  }

  @override
  Future<Either<Failure, GeocodingResultEntity>> searchUniversity(
    String name, {String? city}) async {
    return search(query: '$name universidad', city: city);
  }

  @override
  Future<Either<Failure, GeocodingResultEntity>> searchNeighborhood(
    String name, {String? city}) async {
    return search(query: '$name barrio', city: city);
  }

  @override
  Future<Either<Failure, GeocodingEntity?>> reverseGeocode({
    required double lat, required double lng,
  }) async {
    return ResultMapper.fromAsync(() async {
      final place = await _remote.reverseGeocode(lat: lat, lng: lng);
      return place != null ? _mapPlace(place) : null;
    });
  }

  @override
  Future<Either<Failure, ({double lat, double lng})?>> forwardGeocode(
    String address) async {
    final result = await searchAddress(address);
    return result.fold(
      (f) => Left(f),
      (r) => Right(r != null ? (lat: r.lat, lng: r.lng) : null),
    );
  }
}
