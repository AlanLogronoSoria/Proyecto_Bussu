import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource del contador infrarrojo de pasajeros.
///
/// Lee el conteo de pasajeros desde Supabase (publicado por el ESP32).
/// El ESP32 usa sensores IR/ToF para contar entradas/salidas.
abstract class IrPassengerCounterDataSource {
  /// Obtiene el conteo actual de pasajeros.
  Future<int> getCurrentCount(String busId);

  /// Stream del conteo en tiempo real.
  Stream<int> watchPassengerCount(String busId);

  /// Actualiza el conteo (usado internamente, no por el conductor).
  Future<void> updateCount(String busId, int count);
}

class IrPassengerCounterDataSourceImpl
    implements IrPassengerCounterDataSource {
  final SupabaseClient _client;

  IrPassengerCounterDataSourceImpl(this._client);

  @override
  Future<int> getCurrentCount(String busId) async {
    try {
      final response = await _client
          .from('bus_live_position')
          .select('passenger_count')
          .eq('bus_id', busId)
          .single();

      return response['passenger_count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Stream<int> watchPassengerCount(String busId) {
    return _client
        .from('bus_live_position')
        .stream(primaryKey: ['bus_id'])
        .eq('bus_id', busId)
        .map((rows) {
      if (rows.isEmpty) return 0;
      return rows.first['passenger_count'] as int? ?? 0;
    });
  }

  @override
  Future<void> updateCount(String busId, int count) async {
    await _client.from('bus_live_position').upsert({
      'bus_id': busId,
      'passenger_count': count,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
