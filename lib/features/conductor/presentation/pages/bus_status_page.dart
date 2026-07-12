import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/trip_provider.dart';

class BusStatusPage extends ConsumerWidget {
  const BusStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTrip = ref.watch(activeTripProvider);
    final trip = activeTrip.valueOrNull;
    final status = ref.watch(busHardwareStatusProvider(trip?.busId ?? ''));

    return Scaffold(
      appBar: AppBar(title: const Text('Estado del Bus')),
      body: status.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Sin datos del bus')),
        data: (hw) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusTile(
              title: 'Conexión',
              value: hw.isOnline ? 'En línea' : 'Desconectado',
              icon: hw.isOnline ? Icons.wifi : Icons.wifi_off,
              color: hw.isOnline ? Colors.green : Colors.red,
            ),
            _StatusTile(
              title: 'GPS',
              value: hw.isGpsLocked ? 'Señal OK' : 'Sin señal',
              icon: hw.isGpsLocked ? Icons.gps_fixed : Icons.gps_off,
              color: hw.isGpsLocked ? Colors.green : Colors.red,
            ),
            _StatusTile(
              title: 'OBD',
              value: hw.isObdConnected ? 'Conectado' : 'Desconectado',
              icon: hw.isObdConnected ? Icons.sensors : Icons.sensors_off,
              color: hw.isObdConnected ? Colors.green : Colors.red,
            ),
            _StatusTile(
              title: 'Última telemetría',
              value: '${DateTime.now().difference(hw.lastTelemetryAt).inSeconds}s',
              icon: Icons.timer,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Card(
              color: hw.isFullyOperational
                  ? Colors.green.withAlpha(20)
                  : Colors.red.withAlpha(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      hw.isFullyOperational ? Icons.check_circle : Icons.error,
                      color: hw.isFullyOperational ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        hw.isFullyOperational
                            ? 'Todos los sistemas funcionando'
                            : 'Atención: revisar sistemas',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatusTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
