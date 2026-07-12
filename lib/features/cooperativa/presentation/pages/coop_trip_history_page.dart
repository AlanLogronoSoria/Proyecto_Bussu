import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import '../providers/fleet_provider.dart';
import '../providers/coop_trip_history_provider.dart';

class CoopTripHistoryPage extends ConsumerWidget {
  const CoopTripHistoryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coopId = ref.watch(currentCoopIdProvider);
    final trips = ref.watch(coopTripHistoryProvider(coopId));
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Viajes')),
      body: trips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (history) => history.isEmpty
            ? const Center(child: Text('Sin historial'))
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: history.length, prototypeItem: const Card(child: ListTile(title: Text(' '))),
                itemBuilder: (_, i) {
                  final t = history[i]; final bus = t['buses'] as Map<String, dynamic>? ?? {}; final route = t['routes'] as Map<String, dynamic>? ?? {};
                  return Card(child: ListTile(title: Text(route['name'] as String? ?? 'Ruta'), subtitle: Text('${bus['plate'] ?? ''} - ${t['status'] ?? ''}'), trailing: Text(t['started_at'] != null ? DateFormatter.short(DateTime.parse(t['started_at'] as String)) : '')));
                }),
      ),
    );
  }
}
