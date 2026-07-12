import 'package:flutter/material.dart';

class MunicipalOverview extends StatelessWidget {
  const MunicipalOverview({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          _MetricCard(label: 'Buses Activos', value: '156', subtitle: 'en la ciudad', color: const Color(0xFF001B44), icon: Icons.directions_bus),
          const SizedBox(width: 16),
          _MetricCard(label: 'Conductores', value: '342', subtitle: 'registrados', color: const Color(0xFF001B44), icon: Icons.people),
          const SizedBox(width: 16),
          _MetricCard(label: 'Cooperativas', value: '8', subtitle: 'operando', color: const Color(0xFF001B44), icon: Icons.business),
          const SizedBox(width: 16),
          _MetricCard(label: 'Alertas', value: '5', subtitle: 'activas', color: const Color(0xFFBA1A1A), icon: Icons.warning_amber),
        ]),
        const SizedBox(height: 20),
        Container(height: 320, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), clipBehavior: Clip.antiAlias, child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map, size: 64, color: Color(0xFF001B44)), SizedBox(height: 8), Text('Mapa de densidad de buses por zona', style: TextStyle(color: Color(0xFF434750), fontFamily: 'Inter'))]))),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 2, child: _CoopSummary()),
          const SizedBox(width: 20),
          Expanded(child: _RecentAlerts()),
        ]),
      ]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, subtitle; final Color color; final IconData icon;
  const _MetricCard({required this.label, required this.value, required this.subtitle, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
      Icon(icon, color: color, size: 28), const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color, fontFamily: 'Inter')),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter')),
      Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter')),
    ])));
  }
}

class _CoopSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coops = [
      {'name': 'TransLima Express', 'ruc': '20100000001', 'buses': 42, 'active': 38, 'status': 'Activo'},
      {'name': 'Metropolitano Norte', 'ruc': '20100000002', 'buses': 28, 'active': 22, 'status': 'Activo'},
      {'name': 'BusPerú Sur', 'ruc': '20100000003', 'buses': 35, 'active': 30, 'status': 'Activo'},
      {'name': 'Rutas Unidas', 'ruc': '20100000004', 'buses': 20, 'active': 18, 'status': 'Suspendido'},
      {'name': 'TransAndes', 'ruc': '20100000005', 'buses': 31, 'active': 29, 'status': 'Activo'},
    ];
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Cooperativas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 16),
      Table(columnWidths: const {0: FlexColumnWidth(2.5), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1.5)}, border: TableBorder(horizontalInside: BorderSide(color: Color(0xFFE8E8E8))), children: [
        TableRow(children: ['Nombre', 'Buses', 'Activos', 'Estado'].map((h) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(h, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF434750), fontFamily: 'Inter')))).toList()),
        ...coops.map((c) { final n = c['name'] as String; final b = c['buses'] as String; final a = c['active'] as String; final s = c['status'] as String;
          return TableRow(children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(n, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter'))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(b, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter'))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(a, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green, fontFamily: 'Inter'))),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: s == 'Activo' ? Colors.green.withAlpha(20) : const Color(0xFFBA1A1A).withAlpha(20), borderRadius: BorderRadius.circular(6)),
            child: Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: s == 'Activo' ? Colors.green : const Color(0xFFBA1A1A), fontFamily: 'Inter')),
          )),
        ]); }),
      ]),
    ]));
  }
}

class _RecentAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alerts = [
      {'title': 'Desvío masivo Ruta A', 'desc': '3 cooperativas afectadas', 'severity': 'high', 'route': 'Ruta A'},
      {'title': 'Mantenimiento programado', 'desc': 'Domingo 2-4 AM', 'severity': 'medium', 'route': 'Sistema'},
      {'title': 'Nueva cooperativa', 'desc': 'Rutas Unidas en revisión', 'severity': 'low', 'route': 'Admin'},
    ];
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Alertas Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 16),
      ...alerts.map((a) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
        Container(width: 4, height: 44, decoration: BoxDecoration(color: a['severity'] == 'high' ? const Color(0xFFBA1A1A) : a['severity'] == 'medium' ? const Color(0xFFFED000) : Colors.blue, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(a['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: a['severity'] == 'high' ? const Color(0xFFBA1A1A).withAlpha(20) : const Color(0xFFFED000).withAlpha(30), borderRadius: BorderRadius.circular(4)), child: Text(a['route']!, style: const TextStyle(fontSize: 10, color: Color(0xFF434750), fontFamily: 'Inter')))]),
          const SizedBox(height: 2),
          Text(a['desc']!, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
        ])),
      ]))),
    ]));
  }
}
