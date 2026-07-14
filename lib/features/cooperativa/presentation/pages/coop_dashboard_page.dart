import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fleet_provider.dart';
import '../../domain/entities/fleet_health.dart';

class CoopDashboardPage extends ConsumerWidget {
  const CoopDashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(fleetHealthProvider);
    final coopId = ref.watch(currentCoopIdProvider);
    final driversAsync = ref.watch(driversProvider(coopId));
    final pendingAsync = ref.watch(pendingStopRequestsProvider);

    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 16),
      health.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
        error: (_, __) => const SizedBox.shrink(),
        data: (h) => _buildMetrics(h, driversAsync, pendingAsync),
      ),
      const SizedBox(height: 20),
      _buildBusesTable(),
      const SizedBox(height: 20),
      _buildIncidentsPanel(),
    ]);
  }

  Widget _buildMetrics(FleetHealth h, AsyncValue<List> drivers, AsyncValue<List> pending) {
    return Column(children: [
      Row(children: [
        Expanded(child: _buildMetricCard(Icons.directions_bus, '${h.activeBuses}', 'Buses activos', const Color(0xFF001B44))),
        const SizedBox(width: 10),
        Expanded(child: _buildMetricCard(Icons.warning_amber, '3', 'Incidentes', const Color(0xFFBA1A1A))),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _buildMetricCard(Icons.inbox_outlined, pending.whenData((p) => '${p.length}').valueOrNull ?? '...', 'Solicitudes', const Color(0xFFFED000))),
        const SizedBox(width: 10),
        Expanded(child: _buildMetricCard(Icons.people, drivers.whenData((d) => '${d.length}').valueOrNull ?? '...', 'Conductores', const Color(0xFF001B44))),
      ]),
    ]);
  }

  Widget _buildMetricCard(IconData icon, String value, String label, Color color) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
      Icon(icon, color: color, size: 32), const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color, fontFamily: 'Inter')),
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
    ]));
  }

  Widget _buildBusesTable() {
    const buses = [
      {'plate': 'ABC-123', 'route': 'Ruta A', 'driver': 'Carlos M.', 'occupancy': '45%', 'fuel': '75%', 'status': 'En ruta'},
      {'plate': 'ABC-124', 'route': 'Ruta B', 'driver': 'Luisa R.', 'occupancy': '22%', 'fuel': '60%', 'status': 'En ruta'},
      {'plate': 'DEF-456', 'route': 'Ruta C', 'driver': 'Ana V.', 'occupancy': '60%', 'fuel': '88%', 'status': 'En ruta'},
      {'plate': 'ABC-125', 'route': 'Ruta A', 'driver': 'Pedro S.', 'occupancy': '0%', 'fuel': '30%', 'status': 'En pausa'},
    ];
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Buses Activos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), Text('${buses.length} en operación', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))]),
      const SizedBox(height: 16),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columnSpacing: 20, columns: const [
        DataColumn(label: Text('Placa', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 12))),
        DataColumn(label: Text('Ruta', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 12))),
        DataColumn(label: Text('Conductor', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 12))),
        DataColumn(label: Text('Ocup.', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 12))),
        DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 12))),
      ], rows: buses.map((b) => DataRow(cells: [
        DataCell(Text(b['plate']!, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', color: Color(0xFF001B44)))),
        DataCell(Text(b['route']!, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44)))),
        DataCell(Text(b['driver']!, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44)))),
        DataCell(Text(b['occupancy']!, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44)))),
        DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: b['status'] == 'En ruta' ? Colors.green.withAlpha(20) : Colors.orange.withAlpha(30), borderRadius: BorderRadius.circular(6)), child: Text(b['status']!, style: TextStyle(fontSize: 12, fontFamily: 'Inter', color: b['status'] == 'En ruta' ? Colors.green.shade700 : Colors.orange.shade800)))),
      ])).toList())),
    ]));
  }

  Widget _buildIncidentsPanel() {
    const incidents = [
      {'title': 'Frenado brusco ABC-123', 'desc': 'Av. Arequipa 1200 · 10:42', 'severity': 'high'},
      {'title': 'Motor recalentado DEF-456', 'desc': 'En taller desde 08:00', 'severity': 'medium'},
      {'title': 'Puerta no cierra ABC-124', 'desc': 'Reportado por conductor', 'severity': 'low'},
    ];
    Color colorFor(String s) => s == 'high' ? const Color(0xFFBA1A1A) : s == 'medium' ? const Color(0xFFFED000) : Colors.blue;
    final incidentWidgets = incidents.map((inc) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
      Container(width: 4, height: 40, decoration: BoxDecoration(color: colorFor(inc['severity'] as String), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(inc['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        Text(inc['desc'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
      ])),
    ]))).toList();
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Incidentes Activos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFBA1A1A).withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Text('${incidents.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFBA1A1A), fontFamily: 'Inter')))]),
      const SizedBox(height: 14),
      ...incidentWidgets,
    ]));
  }
}
