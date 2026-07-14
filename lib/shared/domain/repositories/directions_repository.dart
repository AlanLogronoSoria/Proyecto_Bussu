import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/directions_entity.dart';

abstract class DirectionsRepository {
  Future<Either<Failure, DirectionsEntity>> getDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  });
}
