enum UserRole {
  usuario,
  conductor,
  cooperativaAdmin,
  municipalAdmin;

  bool get isPassenger => this == UserRole.usuario;
  bool get isDriver => this == UserRole.conductor;
  bool get isCooperativeAdmin => this == UserRole.cooperativaAdmin;
  bool get isMunicipalAdmin => this == UserRole.municipalAdmin;
  bool get isAdmin => isCooperativeAdmin || isMunicipalAdmin;

  String get pathPrefix {
    switch (this) {
      case UserRole.usuario:
        return '/usuario';
      case UserRole.conductor:
        return '/conductor';
      case UserRole.cooperativaAdmin:
        return '/cooperativa';
      case UserRole.municipalAdmin:
        return '/admin';
    }
  }

  String get toDatabaseValue {
    switch (this) {
      case UserRole.usuario:
        return 'usuario';
      case UserRole.conductor:
        return 'conductor';
      case UserRole.cooperativaAdmin:
        return 'cooperativa_admin';
      case UserRole.municipalAdmin:
        return 'municipal_admin';
    }
  }

  static UserRole fromString(String role) {
    switch (role) {
      case 'usuario':
        return UserRole.usuario;
      case 'conductor':
        return UserRole.conductor;
      case 'cooperativa_admin':
        return UserRole.cooperativaAdmin;
      case 'municipal_admin':
        return UserRole.municipalAdmin;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }
}
