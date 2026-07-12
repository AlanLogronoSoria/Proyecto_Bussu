import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/fleet_provider.dart';

class FleetDashboardPage extends ConsumerWidget {
  const FleetDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fleetHealth = ref.watch(fleetHealthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Flota')),
      body: fleetHealth.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar datos')),
        data: (health) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(child: _MetricCard(title: 'Total', value: '${health.totalBuses}', icon: Icons.directions_bus)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: 'Activos', value: '${health.activeBuses}', icon: Icons.check_circle, color: Colors.green)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _MetricCard(title: 'Pasajeros', value: '${health.totalPassengers}', icon: Icons.people)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: 'Ocupación', value: '${health.averageOccupancy.round()}%', icon: Icons.pie_chart)),
            ]),
            const SizedBox(height: 16),
            _SectionTitle(title: 'Gestión'),
            _QuickAction(icon: Icons.people_outline, title: 'Conductores', subtitle: '${health.totalDrivers} registrados', route: '/cooperativa/drivers'),
            _QuickAction(icon: Icons.directions_bus, title: 'Buses', subtitle: '${health.totalBuses} unidades', route: '/cooperativa/buses'),
            _QuickAction(icon: Icons.place_outlined, title: 'Paradas', subtitle: 'Gestión y solicitudes', route: '/cooperativa/stops'),
            _QuickAction(icon: Icons.route_outlined, title: 'Rutas', subtitle: 'Configuración de recorridos', route: '/cooperativa/routes'),
            const SizedBox(height: 16),
            _SectionTitle(title: 'Monitoreo'),
            _QuickAction(icon: Icons.analytics_outlined, title: 'Reportes', subtitle: 'Rendimiento de rutas', route: '/cooperativa/reports'),
            _QuickAction(icon: Icons.insights, title: 'Analytics', subtitle: 'Métricas y estadísticas', route: '/cooperativa/analytics'),
            _QuickAction(icon: Icons.history, title: 'Historial', subtitle: 'Viajes completados', route: '/cooperativa/history'),
            _QuickAction(icon: Icons.warning_amber, title: 'Alertas', subtitle: 'Notificaciones del sistema', route: '/cooperativa/alerts'),
            _QuickAction(icon: Icons.chat_outlined, title: 'Soporte', subtitle: 'Chat con conductores', route: '/chat/default'),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title, value; final IconData icon; final Color? color;
  const _MetricCard({required this.title, required this.value, required this.icon, this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Icon(icon, color: color ?? AppTheme.primary, size: 32),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String title, subtitle, route;
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.route});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed(route),
      ),
    );
  }
}
