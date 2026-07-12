import 'package:flutter/material.dart';

class CoopFleetDashboard extends StatelessWidget {
  const CoopFleetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 600;
    final p = wide ? 20.0 : 12.0;

    return ListView(padding: EdgeInsets.all(p), children: [
      Container(height: wide ? 220 : 160, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), clipBehavior: Clip.antiAlias, child: const Center(child: Icon(Icons.map, size: 64, color: Color(0xFF001B44)))),
      const SizedBox(height: 16),
      if (wide) ...[
        Row(children: _cards()),
      ] else ...[
        _CardItem(label: 'Fleet Health', value: '42', subtitle: 'Activos', color: const Color(0xFF001B44)),
        const SizedBox(height: 8),
        _CardItem(label: 'Alertas', value: '3', subtitle: 'Activas', color: const Color(0xFFBA1A1A)),
        const SizedBox(height: 8),
        _CardItem(label: 'Ocupacion', value: '52%', subtitle: 'Promedio', color: const Color(0xFFFED000)),
      ],
      const SizedBox(height: 16),
      _BusesList(),
      const SizedBox(height: 16),
      _AlertsPanel(),
    ]);
  }

  List<Widget> _cards() => [
    Expanded(child: _CardItem(label: 'Fleet Health', value: '42', subtitle: 'Activos', color: const Color(0xFF001B44))),
    const SizedBox(width: 12),
    Expanded(child: _CardItem(label: 'Alertas', value: '3', subtitle: 'Activas', color: const Color(0xFFBA1A1A))),
    const SizedBox(width: 12),
    Expanded(child: _CardItem(label: 'Ocupacion', value: '52%', subtitle: 'Promedio', color: const Color(0xFFFED000))),
  ];
}

class _CardItem extends StatelessWidget {
  final String label, value, subtitle; final Color color;
  const _CardItem({required this.label, required this.value, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
      Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: color, fontFamily: 'Inter')),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter')),
      Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
    ]));
  }
}

class _BusesList extends StatelessWidget {
  final _buses = const [
    {'plate': 'ABC-123', 'route': 'Ruta A - Centro', 'driver': 'Carlos M.', 'status': 'Activo', 'occ': '45%'},
    {'plate': 'ABC-124', 'route': 'Ruta B - Miraflores', 'driver': 'Luisa R.', 'status': 'Activo', 'occ': '22%'},
    {'plate': 'ABC-125', 'route': 'Ruta A - Centro', 'driver': 'Pedro S.', 'status': 'En pausa', 'occ': '0%'},
    {'plate': 'DEF-456', 'route': 'Ruta C - San Isidro', 'driver': 'Ana V.', 'status': 'Activo', 'occ': '60%'},
  ];
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Buses Activos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 12),
      Table(columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2.5), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1.5), 4: FlexColumnWidth(1)}, border: TableBorder(horizontalInside: BorderSide(color: Color(0xFFE8E8E8))), children: [
        TableRow(children: ['Placa', 'Ruta', 'Conductor', 'Estado', 'Ocup.'].map((h) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(h, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF434750), fontFamily: 'Inter')))).toList()),
        ..._buses.map((b) { final active = b['status'] == 'Activo';
          return TableRow(children: [
            _cell(b['plate']!, bold: true), _cell(b['route']!), _cell(b['driver']!),
            _badge(b['status']!, color: active ? Colors.green : Colors.orange), _cell(b['occ']!, bold: true),
          ]);
        }),
      ]),
    ]));
  }
  Widget _cell(String t, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w600 : FontWeight.w400, color: const Color(0xFF001B44), fontFamily: 'Inter')));
  Widget _badge(String t, {required Color color}) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(6)), child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color, fontFamily: 'Inter'))));
}

class _AlertsPanel extends StatelessWidget {
  final _alerts = const [
    {'title': 'Desvio Ruta A', 'desc': 'Obras en Jr. Union. +15 min.', 'severity': 'high'},
    {'title': 'Mantenimiento ABC-125', 'desc': 'En taller hasta las 18:00.', 'severity': 'medium'},
    {'title': 'Alta demanda Ruta C', 'desc': '+40% pasajeros esta semana.', 'severity': 'low'},
  ];
  Color _c(String s) => s == 'high' ? const Color(0xFFBA1A1A) : s == 'medium' ? const Color(0xFFFED000) : Colors.blue;
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Alertas Activas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFBA1A1A).withAlpha(20), borderRadius: BorderRadius.circular(8)), child: const Text('3', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFBA1A1A), fontFamily: 'Inter')))]),
      const SizedBox(height: 16),
      ..._alerts.map((a) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
        Container(width: 4, height: 40, decoration: BoxDecoration(color: _c(a['severity']!), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          Text(a['desc']!, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
        ])),
      ]))),
    ]));
  }
}
