import 'package:flutter/material.dart';

class PremiumTable extends StatelessWidget {
  const PremiumTable({super.key});
  @override
  Widget build(BuildContext context) {
    final subs = [
      {'name': 'María García', 'start': '12 ene 2026', 'status': 'Activo', 'expires': '12 feb 2026', 'plan': 'Mensual', 'amount': 'S/ 15.90'},
      {'name': 'Juan López', 'start': '05 ene 2026', 'status': 'Activo', 'expires': '05 ene 2027', 'plan': 'Anual', 'amount': 'S/ 129.90'},
      {'name': 'Rosa Mendoza', 'start': '20 dic 2025', 'status': 'Expirado', 'expires': '20 ene 2026', 'plan': 'Mensual', 'amount': 'S/ 15.90'},
      {'name': 'Pedro Castillo', 'start': '15 feb 2026', 'status': 'Activo', 'expires': '15 mar 2026', 'plan': 'Mensual', 'amount': 'S/ 15.90'},
      {'name': 'Ana Torres', 'start': '01 nov 2025', 'status': 'Cancelado', 'expires': '01 dic 2025', 'plan': 'Anual', 'amount': 'S/ 129.90'},
    ];

    final activeSubs = subs.where((s) => s['status'] == 'Activo').length;
    final totalRevenue = subs.where((s) => s['status'] != 'Cancelado').length * 15.90;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Premium Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 16),
        Row(children: [
          _SummaryCard(label: 'Suscripciones Activas', value: '$activeSubs', color: Colors.green),
          const SizedBox(width: 16),
          _SummaryCard(label: 'Ingresos estimados', value: 'S/ ${totalRevenue.toStringAsFixed(2)}', color: const Color(0xFF001B44)),
          const SizedBox(width: 16),
          _SummaryCard(label: 'Tasa de renovación', value: '78%', color: const Color(0xFFFED000)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _StatusFilter(label: 'Todos', active: true), const SizedBox(width: 8),
          _StatusFilter(label: 'Activos', active: false), const SizedBox(width: 8),
          _StatusFilter(label: 'Expirados', active: false), const SizedBox(width: 8),
          _StatusFilter(label: 'Cancelados', active: false),
        ]),
        const SizedBox(height: 20),
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [
          DataColumn(label: Text('Usuario', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Inicio', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Plan', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Expira', style: TextStyle(fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600))),
        ], rows: subs.map((s) => DataRow(cells: [
          DataCell(Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(Text(s['start']!)),
          DataCell(Text(s['plan']!)),
          DataCell(Text(s['amount']!)),
          DataCell(Text(s['expires']!)),
          DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(
            color: s['status'] == 'Activo' ? Colors.green.withAlpha(20) : s['status'] == 'Expirado' ? Colors.orange.withAlpha(20) : Colors.grey.withAlpha(30),
            borderRadius: BorderRadius.circular(6)),
            child: Text(s['status']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: s['status'] == 'Activo' ? Colors.green : s['status'] == 'Expirado' ? Colors.orange : const Color(0xFF434750))))),
        ])).toList()))),
      ]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value; final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color, fontFamily: 'Inter')),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
    ])));
  }
}

class _StatusFilter extends StatelessWidget {
  final String label; final bool active;
  const _StatusFilter({required this.label, required this.active});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: active ? const Color(0xFF001B44) : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? const Color(0xFF001B44) : const Color(0xFFE0E0E0))), child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : const Color(0xFF434750), fontFamily: 'Inter')));
  }
}
