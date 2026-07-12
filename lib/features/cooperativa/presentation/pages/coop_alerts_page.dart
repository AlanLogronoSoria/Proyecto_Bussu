import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin_municipal/presentation/providers/system_alerts_provider.dart';

class CoopAlertsPage extends ConsumerWidget {
  const CoopAlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(systemAlertsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: alerts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('Sin alertas'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                prototypeItem: const Card(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(height: 50))),
                itemBuilder: (_, i) {
                  final a = list[i];
                  final color = a.severity == 'high' ? Colors.red : a.severity == 'medium' ? Colors.orange : Colors.blue;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(a.title, style: Theme.of(context).textTheme.titleSmall),
                            Text(a.description, style: Theme.of(context).textTheme.bodySmall),
                          ])),
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
