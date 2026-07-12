import 'package:intl/intl.dart';

/// Utilidades de formateo de fechas, horas y duraciones para la UI.
///
/// Centraliza todos los formatos de visualización para mantener
/// consistencia en toda la aplicación.
class DateFormatter {
  DateFormatter._();

  static const String _locale = 'es_PE';

  /// Retorna una representación relativa al momento actual.
  ///
  /// Ejemplos: "Hace 2 min", "Hace 3 horas", "Ayer", "12 may".
  static String relative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Ahora';
    }
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'Hace $m ${_plural(m, 'minuto', 'minutos')}';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'Hace $h ${_plural(h, 'hora', 'horas')}';
    }
    if (diff.inDays == 1) {
      return 'Ayer';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return 'Hace $d ${_plural(d, 'día', 'días')}';
    }

    return DateFormat('d MMM', _locale).format(dateTime);
  }

  /// Formato corto: "12 may 2026, 14:30".
  static String short(DateTime dateTime) {
    return DateFormat('d MMM yyyy, HH:mm', _locale).format(dateTime);
  }

  /// Formato completo: "12 de mayo de 2026, 14:30:00".
  static String full(DateTime dateTime) {
    return DateFormat("d 'de' MMMM 'de' yyyy, HH:mm:ss", _locale)
        .format(dateTime);
  }

  /// Solo hora: "14:30".
  static String time(DateTime dateTime) {
    return DateFormat('HH:mm', _locale).format(dateTime);
  }

  /// Solo fecha: "12 may 2026".
  static String date(DateTime dateTime) {
    return DateFormat('d MMM yyyy', _locale).format(dateTime);
  }

  /// Duración en formato legible: "1h 30m", "45m", "2h".
  static String duration(Duration duration) {
    if (duration.inDays > 0) {
      final d = duration.inDays;
      final h = duration.inHours.remainder(24);
      if (h > 0) {
        return '$d ${_plural(d, 'día', 'días')} $h ${_plural(h, 'hora', 'horas')}';
      }
      return '$d ${_plural(d, 'día', 'días')}';
    }
    if (duration.inHours > 0) {
      final h = duration.inHours;
      final m = duration.inMinutes.remainder(60);
      if (m > 0) {
        return '${h}h ${m}m';
      }
      return '${h}h';
    }
    if (duration.inMinutes > 0) {
      final m = duration.inMinutes;
      return '${m}m';
    }
    final s = duration.inSeconds;
    return '${s}s';
  }

  /// Duración en formato HH:MM:SS.
  static String durationHMS(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// ETA formateado: "Llegada estimada: 14:45 (en 12 min)".
  static String eta(DateTime arrivalTime, Duration remaining) {
    final timeStr = DateFormat('HH:mm', _locale).format(arrivalTime);
    final remainingStr = duration(remaining);
    return '$timeStr ($remainingStr)';
  }

  /// Ocupación formateada: "45% Ocupado".
  static String occupancy(double percentage) {
    final rounded = percentage.round();
    return '$rounded% Ocupado';
  }

  /// Velocidad formateada: "32 km/h".
  static String speed(double kmh) {
    return '${kmh.round()} km/h';
  }

  static String _plural(int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }
}
