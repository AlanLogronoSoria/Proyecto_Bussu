abstract class DeviceBindingService {
  /// Obtiene el identificador único e inmutable del hardware del dispositivo.
  /// (Usa device_info_plus).
  Future<String> getHardwareId();

  /// Verifica si el dispositivo actual es el mismo que está vinculado
  /// a la sesión/cuenta activa en backend.
  /// Lanza [DeviceBindingException] si no coincide.
  Future<bool> validateDeviceBinding(String expectedHardwareId);
}
