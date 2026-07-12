import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';

class MunicipalNotificationsPage extends ConsumerWidget {
  const MunicipalNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Push Notifications', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Alertas del sistema'),
                  subtitle: const Text('Notificar incidentes a todos los usuarios'),
                  value: true,
                  onChanged: (_) {},
                ),
                SwitchListTile(
                  title: const Text('Reportes automáticos'),
                  subtitle: const Text('Enviar reporte semanal a cooperativas'),
                  value: false,
                  onChanged: (_) {},
                ),
                SwitchListTile(
                  title: const Text('Notificar nuevos registros'),
                  subtitle: const Text('Alertar cuando una cooperativa se registra'),
                  value: true,
                  onChanged: (_) {},
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Webhooks', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.green.withAlpha(30), child: const Icon(Icons.check, color: Colors.green, size: 20)),
                  title: const Text('bus_arrival_push'),
                  subtitle: const Text('bus_stop_events → Edge Function'),
                ),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.orange.withAlpha(30), child: const Icon(Icons.warning, color: Colors.orange, size: 20)),
                  title: const Text('trip_started_notify'),
                  subtitle: const Text('trips INSERT → Edge Function'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
