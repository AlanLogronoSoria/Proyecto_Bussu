import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Posición geográfica obtenida del dispositivo.
class LocationData {
  /// Latitud en grados decimales.
  final double latitude;

  /// Longitud en grados decimales.
  final double longitude;

  /// Precisión horizontal en metros.
  final double? accuracy;

  /// Dirección del movimiento en grados (0 = norte).
  final double? heading;

  /// Velocidad instantánea en km/h.
  final double? speed;

  /// Momento de la lectura.
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  @override
  String toString() =>
      'LocationData($latitude, $longitude, acc:${accuracy}m)';
}

/// Abstracción del servicio de localización del dispositivo.
///
/// Encapsula la obtención de posición GPS para que las capas superiores
/// no dependan de un plugin específico (geolocator, location, etc.).
abstract class LocationService {
  /// Obtiene la posición actual del dispositivo una sola vez.
  ///
  /// Retorna [Left] con [PermissionFailure] si el usuario denegó permisos,
  /// o [NetworkFailure] si el GPS está deshabilitado.
  Future<Either<Failure, LocationData>> getCurrentLocation();

  /// Stream continuo de actualizaciones de posición.
  ///
  /// La frecuencia de emisión depende de la configuración del SO y del
  /// plugin subyacente. Típicamente entre 1 y 5 segundos.
  Stream<LocationData> get onLocationChanged;

  /// Verifica si los permisos de ubicación están concedidos.
  Future<bool> hasPermission();

  /// Solicita permisos de ubicación al usuario.
  ///
  /// Retorna `true` si el permiso fue concedido.
  Future<bool> requestPermission();
}
