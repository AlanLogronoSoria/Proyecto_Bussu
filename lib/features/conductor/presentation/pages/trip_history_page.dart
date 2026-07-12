import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/trip_provider.dart';

class DriverTripHistoryPage extends ConsumerWidget {
  const DriverTripHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(tripHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Viajes')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Sin historial de viajes'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            prototypeItem: const Card(child: ListTile(title: Text(' '), subtitle: Text(' '))),
            itemBuilder: (_, i) {
              final t = trips[i];
              final color = t.status.toString().contains('completed')
                  ? Colors.green
                  : t.status.toString().contains('cancelled')
                      ? Colors.red
                      : Colors.orange;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withAlpha(30),
                    child: Icon(Icons.directions_bus, color: color, size: 20),
                  ),
                  title: Text('${t.busId} · ${t.routeId}'),
                  subtitle: Text(
                    t.startedAt != null
                        ? DateFormatter.short(t.startedAt!)
                        : 'Sin fecha',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormatter.duration(t.tripDuration ?? Duration.zero),
                          style: Theme.of(context).textTheme.bodySmall),
                      Chip(
                        label: Text(t.status.toString().split('.').last,
                            style: const TextStyle(fontSize: 10)),
                        backgroundColor: color.withAlpha(20),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
