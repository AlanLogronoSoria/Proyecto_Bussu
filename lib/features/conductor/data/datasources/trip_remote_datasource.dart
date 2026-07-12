import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource remoto para operaciones CRUD de viajes.
abstract class TripRemoteDataSource {
  /// Inserta un nuevo viaje y retorna los datos creados.
  Future<Map<String, dynamic>> insertTrip(Map<String, dynamic> data);

  /// Actualiza un viaje (finalizar, cambiar estado).
  Future<void> updateTrip(String tripId, Map<String, dynamic> data);

  /// Obtiene el viaje activo de un conductor.
  Future<Map<String, dynamic>?> fetchActiveTrip(String driverId);

  /// Stream del viaje activo.
  Stream<List<Map<String, dynamic>>> watchActiveTrip(String driverId);

  /// Actualiza el conteo de pasajeros.
  Future<void> upsertPassengerCount(String busId, int count);

  /// Obtiene el historial de viajes.
  Future<List<Map<String, dynamic>>> fetchTripHistory(
    String driverId, {
    int limit = 50,
  });
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final SupabaseClient _client;

  TripRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> insertTrip(Map<String, dynamic> data) async {
    final response = await _client.from('trips').insert(data).select().single();
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    await _client.from('trips').update(data).eq('id', tripId);
  }

  @override
  Future<Map<String, dynamic>?> fetchActiveTrip(String driverId) async {
    try {
      final response = await _client
          .from('trips')
          .select()
          .eq('driver_id', driverId)
          .eq('status', 'active')
          .maybeSingle();
      return response as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchActiveTrip(String driverId) {
    return _client
        .from('trips')
        .stream(primaryKey: ['id'])
        .map((rows) => (rows as List<dynamic>).cast<Map<String, dynamic>>());
  }

  @override
  Future<void> upsertPassengerCount(String busId, int count) async {
    await _client.from('bus_live_position').upsert({
      'bus_id': busId,
      'passenger_count': count,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTripHistory(
    String driverId, {
    int limit = 50,
  }) async {
    final response = await _client
        .from('trips')
        .select()
        .eq('driver_id', driverId)
        .order('started_at', ascending: false)
        .limit(limit);
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
