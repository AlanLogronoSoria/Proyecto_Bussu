import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/fleet_provider.dart';

/// Reportes de la cooperativa: rendimiento de rutas e historial.
class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(routePerformanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: performanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar')),
        data: (performances) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: performances.length,
          prototypeItem: const Card(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(height: 80))),
          itemBuilder: (_, i) {
            final p = performances[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.routeName,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatBox(
                            label: 'Viajes',
                            value: '${p.totalTrips}'),
                        _StatBox(
                            label: 'Completados',
                            value: '${p.completionRate.round()}%'),
                        _StatBox(
                            label: 'Ocupación',
                            value: '${p.averageOccupancy.round()}%'),
                        _StatBox(
                            label: 'Pasajeros',
                            value: '${p.totalPassengers}'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  )),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  )),
        ],
      ),
    );
  }
}
