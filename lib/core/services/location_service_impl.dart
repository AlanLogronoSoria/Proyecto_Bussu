import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../error/failures.dart';
import 'location_service.dart';

class LocationServiceImpl implements LocationService {
  StreamSubscription<Position>? _positionSub;
  final StreamController<LocationData> _locationController = StreamController<LocationData>.broadcast();

  @override
  Future<Either<Failure, LocationData>> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result != LocationPermission.whileInUse && result != LocationPermission.always) {
          return const Left(PermissionFailure('Permiso de ubicación denegado'));
        }
      } else if (permission == LocationPermission.deniedForever) {
        return const Left(PermissionFailure('Permiso de ubicación denegado permanentemente. Actívalo en ajustes.'));
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      return Right(_toLocationData(position));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Stream<LocationData> get onLocationChanged {
    _startListening();
    return _locationController.stream;
  }

  void _startListening() {
    if (_positionSub != null) return;
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      _locationController.add(_toLocationData(position));
    });
  }

  LocationData _toLocationData(Position p) {
    return LocationData(
      latitude: p.latitude,
      longitude: p.longitude,
      accuracy: p.accuracy,
      heading: p.heading,
      speed: p.speed,
      timestamp: p.timestamp,
    );
  }

  @override
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  @override
  Future<bool> requestPermission() async {
    final result = await Geolocator.requestPermission();
    return result == LocationPermission.whileInUse || result == LocationPermission.always;
  }

  void dispose() {
    _positionSub?.cancel();
    _locationController.close();
  }
}
