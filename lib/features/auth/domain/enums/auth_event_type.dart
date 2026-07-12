/// Eventos del ciclo de vida de autenticación (dominio).
///
/// Reemplaza `AuthChangeEvent` de Supabase para mantener la capa de
/// dominio libre de dependencias de infraestructura.
enum AuthEventType {
  /// El usuario inició sesión exitosamente.
  signedIn,

  /// El usuario cerró sesión.
  signedOut,

  /// El token de acceso fue refrescado automáticamente.
  tokenRefreshed,

  /// Los datos del usuario fueron actualizados.
  userUpdated,

  /// La cuenta del usuario fue eliminada.
  userDeleted,

  /// El usuario solicitó recuperación de contraseña.
  passwordRecovery,

  /// Se detectó una sesión existente al iniciar la app.
  initialSession,
}
