import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';

class MunicipalConfigPage extends ConsumerWidget {
  const MunicipalConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Parámetros del Sistema', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Radio de geocerca'),
                  subtitle: const Text('30 metros'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Intervalo de telemetría'),
                  subtitle: const Text('5 segundos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Timeout de bus inactivo'),
                  subtitle: const Text('30 segundos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Ventana de suavizado ETA'),
                  subtitle: const Text('6 lecturas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Límites del Sistema', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ListTile(title: const Text('Máx. cooperativas'), subtitle: const Text('Ilimitado')),
                ListTile(title: const Text('Máx. buses por cooperativa'), subtitle: const Text('200')),
                ListTile(title: const Text('Máx. conductores por cooperativa'), subtitle: const Text('500')),
                ListTile(title: const Text('Retención de telemetría'), subtitle: const Text('90 días')),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
