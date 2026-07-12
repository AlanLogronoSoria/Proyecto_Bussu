import 'package:device_info_plus/device_info_plus.dart';

import '../error/exceptions.dart';
import '../utils/device_fingerprint.dart';
import 'device_binding_service.dart';

/// Implementación del servicio de vinculación de dispositivo único.
///
/// Genera un fingerprint del hardware usando [DeviceFingerprint] y lo
/// compara contra el [profiles.device_id] almacenado en Supabase.
///
/// El flujo de validación:
/// 1. Login exitoso → se consulta `profiles.device_id`.
/// 2. Si es `null` (primer login) → se registra el fingerprint actual.
/// 3. Si coincide → acceso normal.
/// 4. Si no coincide → se lanza [DeviceBindingException].
class DeviceBindingServiceImpl implements DeviceBindingService {
  final DeviceInfoPlugin _deviceInfo;

  DeviceBindingServiceImpl(this._deviceInfo);

  @override
  Future<String> getHardwareId() async {
    return DeviceFingerprint.generate(plugin: _deviceInfo);
  }

  @override
  Future<bool> validateDeviceBinding(String expectedHardwareId) async {
    final currentId = await getHardwareId();

    if (expectedHardwareId.isEmpty) {
      return true;
    }

    if (currentId != expectedHardwareId) {
      throw const DeviceBindingException(
        'El dispositivo actual no coincide con el registrado. '
        'Por seguridad, la sesión ha sido bloqueada.',
      );
    }

    return true;
  }
}
