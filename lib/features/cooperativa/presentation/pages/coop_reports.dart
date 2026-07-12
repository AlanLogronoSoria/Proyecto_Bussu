import 'package:flutter/material.dart';

class CoopReports extends StatelessWidget {
  const CoopReports({super.key});
  @override
  Widget build(BuildContext context) {
    final performance = [
      {'route': 'Ruta A - Centro', 'trips': '124', 'avgSpeed': '32 km/h', 'delays': '12%', 'occupancy': '52%'},
      {'route': 'Ruta B - Miraflores', 'trips': '98', 'avgSpeed': '28 km/h', 'delays': '22%', 'occupancy': '38%'},
      {'route': 'Ruta C - San Isidro', 'trips': '67', 'avgSpeed': '35 km/h', 'delays': '8%', 'occupancy': '45%'},
    ];
    final stopHistory = [
      {'stop': 'Plaza de Armas', 'bus': 'ABC-123', 'arrival': '10:32', 'departure': '10:33', 'delay': '+2 min'},
      {'stop': 'Jr. de la Unión', 'bus': 'ABC-123', 'arrival': '10:38', 'departure': '10:40', 'delay': '0 min'},
      {'stop': 'Parque Kennedy', 'bus': 'ABC-124', 'arrival': '10:45', 'departure': '10:46', 'delay': '+5 min'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Reportes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 16),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]), child: const Row(children: [Icon(Icons.calendar_today, size: 16, color: Color(0xFF434750)), SizedBox(width: 8), Text('Últimos 30 días', style: TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')), Icon(Icons.arrow_drop_down, color: Color(0xFF434750))])),
        ]),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Rendimiento por Ruta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const SizedBox(height: 16),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [
            DataColumn(label: Text('Ruta', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Viajes', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Vel. Prom', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Demoras', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Ocupación', style: TextStyle(fontWeight: FontWeight.w600))),
          ], rows: performance.map((p) => DataRow(cells: [
            DataCell(Text(p['route']!, style: const TextStyle(fontWeight: FontWeight.w500))),
            DataCell(Text(p['trips']!)),
            DataCell(Text(p['avgSpeed']!)),
            DataCell(Text(p['delays']!)),
            DataCell(Text(p['occupancy']!)),
          ])).toList())),
        ])),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Historial de Paradas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const SizedBox(height: 16),
          ...stopHistory.map((s) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: Row(children: [
            Expanded(flex: 2, child: Text(s['stop']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter'))),
            Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFED000).withAlpha(30), borderRadius: BorderRadius.circular(4)), child: Text(s['bus']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF001B44), fontFamily: 'Inter')))),
            const SizedBox(width: 12),
            Text('${s['arrival']} → ${s['departure']}', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
            const SizedBox(width: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: (s['delay']!.contains('+') ? const Color(0xFFBA1A1A) : Colors.green).withAlpha(20), borderRadius: BorderRadius.circular(6)), child: Text(s['delay']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: s['delay']!.contains('+') ? const Color(0xFFBA1A1A) : Colors.green, fontFamily: 'Inter'))),
          ]))),
        ])),
      ])),
    );
  }
}
