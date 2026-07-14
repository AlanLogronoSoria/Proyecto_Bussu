import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoopReportsPage extends ConsumerWidget {
  const CoopReportsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(length: 3, child: Column(children: [
      const Padding(padding: EdgeInsets.fromLTRB(16, 20, 16, 0), child: Text('Reportes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter'))),
      const SizedBox(height: 12),
      TabBar(labelColor: const Color(0xFF001B44), unselectedLabelColor: const Color(0xFF434750), indicatorColor: const Color(0xFFFED000), labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13), tabs: const [
        Tab(text: 'Historial Arduino'),
        Tab(text: 'Historial Incidentes'),
        Tab(text: 'Buses Activos'),
      ]),
      Expanded(child: TabBarView(children: [
        _buildArduinoHistory(),
        _buildIncidentHistory(),
        _buildActiveBuses(),
      ])),
    ]));
  }

  Widget _buildArduinoHistory() {
    const logs = [
      {'bus': 'ABC-123', 'status': 'OK', 'oil_pressure': '32 PSI', 'rpm': '1200', 'temp': '92°C', 'time': '10:42'},
      {'bus': 'ABC-124', 'status': 'OK', 'oil_pressure': '30 PSI', 'rpm': '1350', 'temp': '88°C', 'time': '10:38'},
      {'bus': 'DEF-456', 'status': 'WARN', 'oil_pressure': '25 PSI', 'rpm': '980', 'temp': '105°C', 'time': '10:35'},
      {'bus': 'ABC-123', 'status': 'OK', 'oil_pressure': '31 PSI', 'rpm': '1400', 'temp': '90°C', 'time': '10:30'},
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Últimos ${logs.length} registros', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columnSpacing: 16, columns: const [
          DataColumn(label: Text('Bus', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Aceite', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('RPM', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Temp', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Hora', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        ], rows: logs.map((l) => DataRow(cells: [
          DataCell(Text(l['bus']!, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
          DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: l['status'] == 'WARN' ? const Color(0xFFBA1A1A).withAlpha(20) : Colors.green.withAlpha(20), borderRadius: BorderRadius.circular(4)), child: Text(l['status']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: l['status'] == 'WARN' ? const Color(0xFFBA1A1A) : Colors.green.shade700)))),
          DataCell(Text(l['oil_pressure']!, style: const TextStyle(fontFamily: 'Inter'))),
          DataCell(Text(l['rpm']!, style: const TextStyle(fontFamily: 'Inter'))),
          DataCell(Text(l['temp']!, style: const TextStyle(fontFamily: 'Inter'))),
          DataCell(Text(l['time']!, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF434750)))),
        ])).toList())),
      ])),
    ]);
  }

  Widget _buildIncidentHistory() {
    const incidents = [
      {'type': 'Frenado brusco', 'bus': 'ABC-123', 'driver': 'Carlos M.', 'location': 'Av. Arequipa 1200', 'time': '10:42', 'severity': 'high'},
      {'type': 'Puerta no cierra', 'bus': 'ABC-124', 'driver': 'Luisa R.', 'location': 'Parque Kennedy', 'time': '09:15', 'severity': 'low'},
      {'type': 'Motor recalentado', 'bus': 'DEF-456', 'driver': 'Ana V.', 'location': 'San Isidro', 'time': '08:00', 'severity': 'medium'},
      {'type': 'Aceleración violenta', 'bus': 'ABC-123', 'driver': 'Carlos M.', 'location': 'Larcomar', 'time': '07:30', 'severity': 'medium'},
    ];
    Color c(String s) => s == 'high' ? const Color(0xFFBA1A1A) : s == 'medium' ? const Color(0xFFFED000) : Colors.blue;
    return ListView(padding: const EdgeInsets.all(16), children: incidents.map((inc) => Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
      child: Row(children: [
        Container(width: 4, height: 48, decoration: BoxDecoration(color: c(inc['severity']!), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(inc['type']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          Text('${inc['bus']} · ${inc['driver']}', style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
          Row(children: [
            Text(inc['location']!, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
            const Spacer(),
            Text(inc['time']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF434750), fontFamily: 'Inter')),
          ]),
        ])),
      ]),
    )).toList());
  }

  Widget _buildActiveBuses() {
    const buses = [
      {'plate': 'ABC-123', 'driver': 'Carlos M.', 'route': 'Ruta A', 'occupancy': '45%', 'status': 'En ruta'},
      {'plate': 'ABC-124', 'driver': 'Luisa R.', 'route': 'Ruta B', 'occupancy': '22%', 'status': 'En ruta'},
      {'plate': 'DEF-456', 'driver': 'Ana V.', 'route': 'Ruta C', 'occupancy': '60%', 'status': 'En ruta'},
      {'plate': 'ABC-125', 'driver': 'Pedro S.', 'route': 'Ruta A', 'occupancy': '0%', 'status': 'En pausa'},
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Text('Buses en operación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), Text('${buses.length} buses', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))]),
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columnSpacing: 16, columns: const [
          DataColumn(label: Text('Placa', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Conductor', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Ruta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Ocup.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        ], rows: buses.map((b) => DataRow(cells: [
          DataCell(Text(b['plate']!, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', color: Color(0xFF001B44)))),
          DataCell(Text(b['driver']!, style: const TextStyle(fontFamily: 'Inter'))),
          DataCell(Text(b['route']!, style: const TextStyle(fontFamily: 'Inter'))),
          DataCell(Text(b['occupancy']!, style: const TextStyle(fontFamily: 'Inter'))),
          DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: b['status'] == 'En ruta' ? Colors.green.withAlpha(20) : Colors.orange.withAlpha(30), borderRadius: BorderRadius.circular(6)), child: Text(b['status']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: b['status'] == 'En ruta' ? Colors.green.shade700 : Colors.orange.shade800)))),
        ])).toList())),
      ])),
    ]);
  }
}
