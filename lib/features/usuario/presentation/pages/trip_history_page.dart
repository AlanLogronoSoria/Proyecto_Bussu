import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import '../providers/trip_history_provider.dart';

class TripHistoryPage extends ConsumerWidget {
  const TripHistoryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Viajes')),
      body: trips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (history) => history.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.history, size: 80, color: Colors.grey[400]), const SizedBox(height: 16), const Text('Sin historial de viajes')]))
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: history.length, prototypeItem: const Card(child: ListTile(title: Text(' '))),
                itemBuilder: (_, i) {
                  final trip = history[i];
                  return Card(child: ListTile(
                    title: Text(trip['route_name'] as String? ?? 'Ruta'),
                    subtitle: Text('${trip['bus_plate'] ?? ''}  ${trip['started_at'] != null ? DateFormatter.short(DateTime.parse(trip['started_at'] as String)) : ''}'),
                    trailing: Chip(label: Text(trip['status'] as String? ?? 'completed')),
                  ));
                }),
      ),
    );
  }
}
