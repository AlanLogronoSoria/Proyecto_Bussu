import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/system_alerts_provider.dart';

class MunicipalOverviewPage extends ConsumerWidget {
  const MunicipalOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(municipalOverviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Visión Municipal')),
      body: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar datos')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HealthRing(percentage: data.systemHealthPct),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _MetricCard(title: 'Cooperativas', value: '${data.totalCooperativas}', icon: Icons.business)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: 'Buses Totales', value: '${data.totalBuses}', icon: Icons.directions_bus)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _MetricCard(title: 'Buses Activos', value: '${data.totalActiveBuses}', icon: Icons.check_circle, color: Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: 'Pasajeros', value: '${data.totalPassengers}', icon: Icons.people)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _MetricCard(title: 'Alertas', value: '${data.activeAlerts}', icon: Icons.warning, color: Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: 'Conductores', value: '${data.totalDrivers}', icon: Icons.person)),
            ]),
            const SizedBox(height: 24),
            const _SectionTitle('Gestión'),
            _QuickAction(icon: Icons.add_business, title: 'Cooperativas', subtitle: 'CRUD de cooperativas', route: '/admin/cooperativas'),
            _QuickAction(icon: Icons.people, title: 'Usuarios', subtitle: 'Gestión de roles', route: '/admin/users'),
            _QuickAction(icon: Icons.workspace_premium, title: 'Premium', subtitle: 'Auditoría de suscripciones', route: '/admin/premium'),
            const SizedBox(height: 16),
            const _SectionTitle('Monitoreo'),
            _QuickAction(icon: Icons.warning_amber, title: 'Incidentes', subtitle: 'Alertas del sistema', route: '/admin/incidents'),
            _QuickAction(icon: Icons.analytics, title: 'Analytics', subtitle: 'Métricas y reportes', route: '/admin/analytics'),
            _QuickAction(icon: Icons.assessment, title: 'Reportes', subtitle: 'Reporte público', route: '/admin/reports'),
            _QuickAction(icon: Icons.notifications_active, title: 'Notificaciones', subtitle: 'Push y avisos', route: '/admin/notifications'),
            _QuickAction(icon: Icons.settings, title: 'Configuración', subtitle: 'Parámetros del sistema', route: '/admin/config'),
          ],
        ),
      ),
    );
  }
}

class _HealthRing extends StatelessWidget {
  final double percentage;
  const _HealthRing({required this.percentage});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(children: [
          SizedBox(width: 80, height: 80,
            child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(value: percentage / 100, strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(percentage > 70 ? Colors.green : Colors.orange)),
              Center(child: Text('${percentage.round()}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
            ])),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Salud del Sistema', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(percentage > 70 ? 'Sistema operativo' : 'Atención requerida',
                style: Theme.of(context).textTheme.bodySmall),
          ])),
        ]),
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
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Icon(icon, color: color ?? AppTheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
      ])),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium));
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String title, subtitle, route;
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.route});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(leading: Icon(icon, color: AppTheme.primary), title: Text(title),
          subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(route)),
    );
  }
}
