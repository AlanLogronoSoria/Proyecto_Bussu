/// Entidad genérica de usuario para datos públicos.
///
/// No contiene información sensible. Para datos completos del usuario
/// autenticado, usar [AppUser] de `features/auth`.
class UserEntity {
  final String id;
  final String? fullName;
  final String? role;
  final bool isPremium;

  const UserEntity({
    required this.id,
    this.fullName,
    this.role,
    this.isPremium = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
