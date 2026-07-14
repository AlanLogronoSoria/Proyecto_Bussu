import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/domain/entities/stop_entity.dart';
import '../../../../shared/presentation/widgets/live_map_widget.dart';
import '../providers/system_alerts_provider.dart';
import '../../domain/entities/municipal_overview.dart';

class AdminOverviewPage extends ConsumerWidget {
  const AdminOverviewPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(municipalOverviewProvider);
    final coopStatus = ref.watch(cooperativasStatusProvider);

    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Overview Municipal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 16),
      overview.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
        error: (_, __) => const SizedBox.shrink(),
        data: (o) => _buildMetrics(o),
      ),
      const SizedBox(height: 16),
      _buildQuickLinks(context),
      const SizedBox(height: 20),
      _buildMapCard(),
      const SizedBox(height: 20),
      _buildCooperativasTable(coopStatus),
      const SizedBox(height: 20),
      _buildIncidentSummary(),
    ]);
  }

  Widget _buildMetrics(MunicipalOverview o) => Column(children: [
    Row(children: [
      _metricCard(Icons.business, '${o.totalCooperativas}', 'Cooperativas', const Color(0xFF001B44)),
      const SizedBox(width: 10),
      _metricCard(Icons.directions_bus, '${o.totalBuses}', 'Buses Totales', const Color(0xFF001B44)),
    ]),
    const SizedBox(height: 10),
    Row(children: [
      _metricCard(Icons.people, '${o.totalDrivers}', 'Conductores', const Color(0xFF001B44)),
      const SizedBox(width: 10),
      _metricCard(Icons.warning_amber, '${o.activeAlerts}', 'Incidentes', const Color(0xFFBA1A1A)),
    ]),
  ]);

  Widget _metricCard(IconData icon, String value, String label, Color color) => Expanded(child: Container(
    padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
    child: Column(children: [Icon(icon, color: color, size: 32), const SizedBox(height: 8), Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color, fontFamily: 'Inter')), Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))]),
  ));

  Widget _buildQuickLinks(BuildContext ctx) => Container(
    padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Gestión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 12),
      _linkTile(Icons.business, 'Cooperativas', 'CRUD completo de cooperativas', () => Navigator.pushNamed(ctx, '/admin/cooperativas')),
      _linkTile(Icons.workspace_premium, 'Premium', 'Administrar suscripciones', () => Navigator.pushNamed(ctx, '/admin/premium')),
      _linkTile(Icons.group, 'Usuarios', 'Gestionar roles y permisos', () => Navigator.pushNamed(ctx, '/admin/users')),
    ]),
  );

  Widget _linkTile(IconData icon, String title, String sub, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: ListTile(leading: Icon(icon, color: const Color(0xFF001B44)), title: Text(title, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), subtitle: Text(sub, style: const TextStyle(fontSize: 12, fontFamily: 'Inter', color: Color(0xFF434750))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: onTap, dense: true, contentPadding: EdgeInsets.zero),
  );

  Widget _buildMapCard() {
    const mockStops = [
      StopEntity(id: 'a1', name: 'Plaza de Armas', latitude: -12.0464, longitude: -77.0428, orderIndex: 1),
      StopEntity(id: 'a2', name: 'Jr. de la Union', latitude: -12.0452, longitude: -77.0410, orderIndex: 2),
    ];
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
      clipBehavior: Clip.antiAlias,
      height: 200,
      child: Stack(children: [
        LiveMapWidget(initialPosition: const CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 13), stops: mockStops),
        Positioned(top: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.map, size: 16, color: Color(0xFF001B44)), SizedBox(width: 6), Text('Visualización general', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))]))),
      ]),
    );
  }

  Widget _buildCooperativasTable(AsyncValue<List> coopStatus) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Estado de Cooperativas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 12),
      coopStatus.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
        error: (_, __) => const Text('Error'),
        data: (List list) {
          const columns = [
            DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            DataColumn(label: Text('RUC', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            DataColumn(label: Text('Buses', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            DataColumn(label: Text('Actividad', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          ];
          final rows = list.map((c) {
            return DataRow(cells: [
              DataCell(Text((c.name ?? '') as String, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44)))),
              DataCell(Text((c.ruc ?? '') as String, style: const TextStyle(fontFamily: 'Inter'))),
              DataCell(Text('${c.activeBuses}/${c.totalBuses}', style: const TextStyle(fontFamily: 'Inter'))),
              DataCell(Text('${c.fleetActivityPct.toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600))),
            ]);
          }).toList();
          return SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columnSpacing: 16, columns: columns, rows: rows));
        },
      ),
    ]));
  }

  Widget _buildIncidentSummary() {
    const incidents = [
      {'title': 'Frenado brusco ABC-123', 'route': 'Ruta A', 'status': 'Pendiente', 'severity': 'high'},
      {'title': 'Motor recalentado DEF-456', 'route': 'Ruta C', 'status': 'En revisión', 'severity': 'medium'},
      {'title': 'Puerta no cierra ABC-124', 'route': 'Ruta B', 'status': 'Resuelto', 'severity': 'low'},
    ];
    Color sevColor(String s) => s == 'high' ? const Color(0xFFBA1A1A) : s == 'medium' ? const Color(0xFFFED000) : Colors.blue;
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Últimos Incidentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), Text('${incidents.length} activos', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))]),
      const SizedBox(height: 12),
      ...incidents.map((inc) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
        Container(width: 4, height: 36, decoration: BoxDecoration(color: sevColor(inc['severity']!), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(inc['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          Row(children: [Text(inc['route']!, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: inc['status'] == 'Pendiente' ? const Color(0xFFBA1A1A).withAlpha(20) : inc['status'] == 'En revisión' ? const Color(0xFFFED000).withAlpha(40) : Colors.green.withAlpha(20), borderRadius: BorderRadius.circular(4)), child: Text(inc['status']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: inc['status'] == 'Pendiente' ? const Color(0xFFBA1A1A) : inc['status'] == 'En revisión' ? const Color(0xFF001B44) : Colors.green.shade700)))]),
        ])),
      ]))),
    ]));
  }
}
