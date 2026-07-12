import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin_municipal/presentation/providers/system_alerts_provider.dart';
import '../../../admin_municipal/domain/entities/system_alert.dart';

class ConductorAlertsPage extends ConsumerWidget {
  const ConductorAlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(systemAlertsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Sin alertas'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            prototypeItem: const Card(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(height: 60))),
            itemBuilder: (_, i) {
              final a = alerts[i];
              final color = _severityColor(a.severity);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 4, height: 60,
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 4),
                            Text(a.description, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
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

  Color _severityColor(String severity) {
    switch (severity) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.blue;
    }
  }
}
