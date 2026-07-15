import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/location_service_impl.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});
