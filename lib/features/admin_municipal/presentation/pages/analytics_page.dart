import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/system_alerts_provider.dart';

/// Analytics municipal: reporte público y métricas.
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(publicReportProvider);
    final cooperativas = ref.watch(cooperativasStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reporte Público',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  report.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error'),
                    data: (data) => data == null
                        ? const Text('No disponible')
                        : Column(
                            children: [
                              _ReportRow(label: 'Cooperativas', value: '${data['total_cooperativas'] ?? 0}'),
                              _ReportRow(label: 'Buses totales', value: '${data['total_buses'] ?? 0}'),
                              _ReportRow(label: 'Buses activos', value: '${data['total_active_buses'] ?? 0}'),
                              _ReportRow(label: 'Alertas sin resolver', value: '${data['unresolved_alerts'] ?? 0}'),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Rendimiento por Cooperativa',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          cooperativas.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error'),
            data: (list) => Column(
              children: list.map((c) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: Theme.of(context).textTheme.titleSmall),
                              Text('${c.totalBuses} buses · ${c.totalDrivers} conductores',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text('${c.fleetActivityPct.round()}%',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.primary,
                                    )),
                            Text('activo',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
