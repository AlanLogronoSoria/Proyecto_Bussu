/// Utilidades de validación de entrada para formularios y datos.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  static final RegExp _plateRegex = RegExp(r'^[A-Z]{3}-\d{3,4}$');

  static final RegExp _rucRegex = RegExp(r'^\d{11}$');

  /// Valida que el campo no esté vacío. Retorna mensaje de error o `null`.
  static String? validateRequired(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  /// Valida formato de email. Retorna mensaje de error o `null`.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  /// Valida longitud mínima de contraseña. Retorna mensaje de error o `null`.
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres';
    }
    return null;
  }

  /// Valida que dos contraseñas coincidan.
  static String? validatePasswordMatch(String? value, String? confirm) {
    if (value != confirm) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida formato de número telefónico internacional.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Ingresa un número de teléfono válido';
    }
    return null;
  }

  /// Valida formato de placa vehicular peruana (ABC-123).
  static String? validatePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La placa es obligatoria';
    }
    if (!_plateRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Formato de placa inválido (ej. ABC-123)';
    }
    return null;
  }

  /// Valida formato de RUC peruano (11 dígitos).
  static String? validateRUC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El RUC es obligatorio';
    }
    if (!_rucRegex.hasMatch(value.trim())) {
      return 'El RUC debe tener 11 dígitos';
    }
    return null;
  }

  /// Valida que un valor numérico esté dentro de un rango.
  static String? validateRange(
    double? value, {
    required double min,
    required double max,
    String fieldName = 'Valor',
  }) {
    if (value == null) return '$fieldName es obligatorio';
    if (value < min || value > max) {
      return '$fieldName debe estar entre $min y $max';
    }
    return null;
  }

  /// Valida coordenadas GPS válidas.
  static String? validateLatitude(double? value) {
    if (value == null) return 'Latitud es obligatoria';
    if (value < -90 || value > 90) {
      return 'Latitud debe estar entre -90 y 90';
    }
    return null;
  }

  /// Valida coordenadas GPS válidas.
  static String? validateLongitude(double? value) {
    if (value == null) return 'Longitud es obligatoria';
    if (value < -180 || value > 180) {
      return 'Longitud debe estar entre -180 y 180';
    }
    return null;
  }

  /// Aplica múltiples validadores y retorna el primer error.
  static String? validateMultiple(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
