import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/fleet_provider.dart';

class CoopAnalyticsPage extends ConsumerWidget {
  const CoopAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perf = ref.watch(routePerformanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: perf.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (performances) {
          if (performances.isEmpty) return const Center(child: Text('Sin datos'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: performances.length,
            prototypeItem: const Card(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(height: 80))),
            itemBuilder: (_, i) {
              final p = performances[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.routeName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatBox(label: 'Viajes', value: '${p.totalTrips}'),
                          _StatBox(label: 'Completados', value: '${p.completionRate.round()}%'),
                          _StatBox(label: 'Ocupación', value: '${p.averageOccupancy.round()}%'),
                          _StatBox(label: 'Velocidad', value: '${p.averageSpeedKmh.round()} km/h'),
                        ],
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

class _StatBox extends StatelessWidget {
  final String label, value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary)),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
