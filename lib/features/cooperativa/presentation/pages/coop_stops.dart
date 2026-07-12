import 'package:flutter/material.dart';

class CoopStops extends StatelessWidget {
  const CoopStops({super.key});
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 700;
    final p = wide ? 20.0 : 12.0;

    final stopsList = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Paradas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 12),
      Container(height: wide ? 180 : 140, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), clipBehavior: Clip.antiAlias, child: const Center(child: Icon(Icons.map, size: 48, color: Color(0xFF001B44)))),
      const SizedBox(height: 12),
      Expanded(child: _StopsTable()),
    ]);

    final pendingPanel = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Solicitudes pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFED000).withAlpha(40), borderRadius: BorderRadius.circular(8)), child: const Text('2', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')))]),
      const SizedBox(height: 12),
      _PendingCard(loc: 'Av. Arequipa 1200', driver: 'Carlos M.', reason: 'Alta demanda', date: '12 may'),
      _PendingCard(loc: 'Calle Las Flores 300', driver: 'Luisa R.', reason: 'Zona residencial', date: '10 may'),
    ]);

    if (wide) {
      return Padding(padding: EdgeInsets.all(p), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 3, child: stopsList),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: pendingPanel),
      ]));
    }
    return ListView(padding: EdgeInsets.all(p), children: [
      const Text('Paradas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 12),
      SizedBox(height: 140, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)), clipBehavior: Clip.antiAlias, child: const Center(child: Icon(Icons.map, size: 48, color: Color(0xFF001B44))))),
      const SizedBox(height: 12),
      SizedBox(height: 200, child: _StopsTable()),
      const SizedBox(height: 16),
      pendingPanel,
    ]);
  }
}

class _StopsTable extends StatelessWidget {
  final _stops = const [
    {'name': 'Plaza de Armas', 'route': 'Ruta A', 'order': '1'},
    {'name': 'Jr. de la Union', 'route': 'Ruta A', 'order': '2'},
    {'name': 'Parque Universitario', 'route': 'Ruta A', 'order': '3'},
    {'name': 'Parque Kennedy', 'route': 'Ruta B', 'order': '1'},
    {'name': 'Larcomar', 'route': 'Ruta B', 'order': '2'},
  ];
  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: ListView(padding: const EdgeInsets.all(8), children: _stops.map((s) => Container(
      margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFF001B44).withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(s['order']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44))))),
        const SizedBox(width: 12),
        Expanded(child: Text(s['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter'))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFED000).withAlpha(40), borderRadius: BorderRadius.circular(6)), child: Text(s['route']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter'))),
      ]),
    )).toList()));
  }
}

class _PendingCard extends StatelessWidget {
  final String loc, driver, reason, date;
  const _PendingCard({required this.loc, required this.driver, required this.reason, required this.date});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(loc, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 4),
        Text('$driver · $date · $reason', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A), side: const BorderSide(color: Color(0xFFBA1A1A)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Rechazar'))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Aprobar'))),
        ]),
      ]),
    );
  }
}
