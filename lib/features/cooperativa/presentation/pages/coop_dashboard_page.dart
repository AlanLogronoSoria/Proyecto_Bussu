import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fleet_provider.dart';
import '../../domain/entities/fleet_health.dart';
import '../../../admin_municipal/presentation/providers/system_alerts_provider.dart';

class CoopDashboardPage extends ConsumerWidget {
  const CoopDashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(fleetHealthProvider);
    final coopId = ref.watch(currentCoopIdProvider);
    final driversAsync = ref.watch(driversProvider(coopId));
    final pendingAsync = ref.watch(pendingStopRequestsProvider);
    final alertsAsync = ref.watch(systemAlertsProvider);

    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 16),
      health.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
        error: (_, __) => const SizedBox.shrink(),
        data: (h) => _buildMetrics(h, driversAsync, pendingAsync, alertsAsync),
      ),
    ]);
  }

  Widget _buildMetrics(FleetHealth h, AsyncValue<List> drivers, AsyncValue<List> pending, AsyncValue<List> alerts) {
    final driverCount = drivers.whenData((d) => '${d.length}').valueOrNull ?? '...';
    final pendingCount = pending.whenData((p) => '${p.length}').valueOrNull ?? '...';

    return Column(children: [
      Row(children: [
        Expanded(child: _metricCard(Icons.directions_bus, '${h.activeBuses}/${h.totalBuses}', 'Buses activos', const Color(0xFF001B44))),
        const SizedBox(width: 12),
        Expanded(child: _metricCard(Icons.people, driverCount, 'Conductores', const Color(0xFF001B44))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _metricCard(Icons.inbox_outlined, pendingCount, 'Solicitudes', const Color(0xFFFED000))),
        const SizedBox(width: 12),
        Expanded(child: _metricCard(Icons.warning_amber, alerts.whenData((a) => '${a.length}').valueOrNull ?? '...', 'Incidentes', const Color(0xFFBA1A1A))),
      ]),
    ]);
  }

  Widget _metricCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 12, offset: Offset(0, 4))]),
      child: Column(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 16),
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: color, fontFamily: 'Inter')),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF434750), fontFamily: 'Inter')),
      ]),
    );
  }
}
