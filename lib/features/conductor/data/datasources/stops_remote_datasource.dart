import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource remoto para gestión de paradas del conductor.
abstract class StopsRemoteDataSource {
  Future<void> insertStopRequest(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchRouteStops(String routeId);
}

class StopsRemoteDataSourceImpl implements StopsRemoteDataSource {
  final SupabaseClient _client;

  StopsRemoteDataSourceImpl(this._client);

  @override
  Future<void> insertStopRequest(Map<String, dynamic> data) async {
    await _client.from('stop_requests').insert(data);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRouteStops(String routeId) async {
    final response = await _client
        .from('stops')
        .select()
        .eq('route_id', routeId)
        .order('order_index');
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
