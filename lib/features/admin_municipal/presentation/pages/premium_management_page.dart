import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/system_alerts_provider.dart';

/// Gestión de suscripciones premium por el administrador municipal.
class PremiumManagementPage extends ConsumerWidget {
  const PremiumManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(premiumSubscriptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auditoría Premium')),
      body: subs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (subscriptions) => subscriptions.isEmpty
            ? const Center(child: Text('No hay suscripciones'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subscriptions.length,
                prototypeItem: const Card(child: ListTile(title: Text(' '))),
                itemBuilder: (_, i) {
                  final s = subscriptions[i];
                  final profile = s['profiles'] as Map<String, dynamic>? ?? {};
                  final status = s['status'] as String? ?? 'active';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(profile['full_name'] as String? ?? 'Usuario'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile['email'] as String? ?? ''),
                          Text('Plan: ${s['plan_id'] ?? 'premium'}'),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(status),
                        backgroundColor: status == 'active'
                            ? Colors.green.withAlpha(30)
                            : Colors.grey.withAlpha(30),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
