import 'package:flutter/material.dart';

/// Extensiones de conveniencia para [BuildContext].
extension BuildContextX on BuildContext {
  /// Accede al [ThemeData] actual.
  ThemeData get theme => Theme.of(this);

  /// Accede al [ColorScheme] actual.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Accede al [TextTheme] actual.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Accede al [MediaQueryData] actual.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Ancho disponible de la pantalla.
  double get screenWidth => mediaQuery.size.width;

  /// Alto disponible de la pantalla.
  double get screenHeight => mediaQuery.size.height;

  /// `true` si el tema actual es oscuro.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// `true` si el ancho de pantalla es ≥ 600dp (tablet/desktop).
  bool get isTablet => screenWidth >= 600;

  /// `true` si el ancho de pantalla es ≥ 900dp (desktop).
  bool get isDesktop => screenWidth >= 900;
}

/// Extensiones de conveniencia para [String].
extension StringX on String {
  /// `true` si el string es nulo o vacío (ignorando espacios).
  bool get isNullOrEmpty => trim().isEmpty;

  /// `true` si el string no es nulo ni vacío.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Capitaliza la primera letra de cada palabra.
  String get toTitleCase => split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  /// Capitaliza solo la primera letra.
  String get capitalize =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;

  /// Trunca a [maxLength] caracteres agregando '...' si es necesario.
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';
}

/// Extensiones de conveniencia para [DateTime].
extension DateTimeX on DateTime {
  /// `true` si la fecha es hoy.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// `true` si la fecha es ayer.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// `true` si la fecha está en el futuro.
  bool get isFuture => isAfter(DateTime.now());

  /// Retorna el inicio del día (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Retorna el fin del día (23:59:59.999).
  DateTime get endOfDay =>
      DateTime(year, month, day, 23, 59, 59, 999);

  /// `true` si esta fecha está dentro de [duration] desde ahora.
  bool isWithin(Duration duration) {
    return isAfter(DateTime.now().subtract(duration)) && isBefore(DateTime.now().add(duration));
  }
}

/// Extensiones de conveniencia para [Duration].
extension DurationX on Duration {
  /// Formato legible: "1h 30m", "45m", "30s".
  String get toHumanReadable {
    if (inDays > 0) return '${inDays}d ${inHours.remainder(24)}h';
    if (inHours > 0) return '${inHours}h ${inMinutes.remainder(60)}m';
    if (inMinutes > 0) {
      return '${inMinutes}m ${inSeconds.remainder(60)}s';
    }
    return '${inSeconds}s';
  }
}

/// Extensiones de conveniencia para [num].
extension NumX on num {
  /// Formatea como porcentaje: 0.456 → "46%".
  String get toPercent => '${(this * 100).round()}%';

  /// Formatea con [decimals] decimales.
  String toStringAsFixed(int decimals) => toStringAsFixed(decimals);
}
