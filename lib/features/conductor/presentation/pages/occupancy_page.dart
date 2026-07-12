import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/trip_provider.dart';

/// Pantalla de ocupación: conteo de pasajeros en tiempo real.
class OccupancyPage extends ConsumerWidget {
  const OccupancyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTrip = ref.watch(activeTripProvider);
    final trip = activeTrip.valueOrNull;
    final busId = trip?.busId ?? '';
    final passengerCount =
        ref.watch(passengerCountProvider(busId)).valueOrNull ?? 0;

    final occupancyPct = (trip != null && trip.busId.isNotEmpty)
        ? ((passengerCount / 40.0) * 100.0).clamp(0.0, 100.0).toDouble()
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Ocupación')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OccupancyCircle(percentage: occupancyPct),
              const SizedBox(height: 24),
              Text(
                '$passengerCount / 40 pasajeros',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _occupancyLabel(occupancyPct),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _occupancyColor(occupancyPct),
                    ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _LegendItem(color: Colors.green, label: 'Baja'),
                      _LegendItem(color: Colors.orange, label: 'Media'),
                      _LegendItem(color: Colors.red, label: 'Alta'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _occupancyLabel(double pct) {
    if (pct < 40) return 'Ocupación baja';
    if (pct < 75) return 'Ocupación media';
    return 'Ocupación alta';
  }

  Color _occupancyColor(double pct) {
    if (pct < 40) return Colors.green;
    if (pct < 75) return Colors.orange;
    return Colors.red;
  }
}

class _OccupancyCircle extends StatelessWidget {
  final double percentage;

  const _OccupancyCircle({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final occupancyColor = percentage < 40
        ? Colors.green
        : percentage < 75
            ? Colors.orange
            : Colors.red;
    final animation = AlwaysStoppedAnimation(occupancyColor);

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 12,
            backgroundColor: Colors.grey[200],
            valueColor: animation,
          ),
          Center(
            child: Text(
              '${percentage.round()}%',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
