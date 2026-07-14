import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/geocoding_entity.dart';

abstract class GeocodingRepository {
  Future<Either<Failure, GeocodingResultEntity>> search({
    required String query,
    String? country,
    String? city,
    int limit = 5,
  });

  Future<Either<Failure, GeocodingEntity?>> searchAddress(String address);

  Future<Either<Failure, GeocodingResultEntity>> searchStreet(
    String street, {String? city, String? country});

  Future<Either<Failure, GeocodingResultEntity>> searchUniversity(
    String name, {String? city});

  Future<Either<Failure, GeocodingResultEntity>> searchNeighborhood(
    String name, {String? city});

  Future<Either<Failure, GeocodingEntity?>> reverseGeocode({
    required double lat,
    required double lng,
  });

  Future<Either<Failure, ({double lat, double lng})?>> forwardGeocode(
    String address);
}
