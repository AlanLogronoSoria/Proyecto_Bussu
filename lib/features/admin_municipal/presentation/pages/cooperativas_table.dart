import 'package:flutter/material.dart';

class CooperativasTable extends StatefulWidget {
  const CooperativasTable({super.key});
  @override
  State<CooperativasTable> createState() => _CooperativasTableState();
}

class _CooperativasTableState extends State<CooperativasTable> {
  final _nameCtrl = TextEditingController(), _rucCtrl = TextEditingController();
  final _coops = <Map<String, dynamic>>[
    {'name': 'TransLima Express', 'ruc': '20100000001', 'buses': 42, 'status': 'Activo'},
    {'name': 'Metropolitano Norte', 'ruc': '20100000002', 'buses': 28, 'status': 'Activo'},
    {'name': 'BusPeru Sur', 'ruc': '20100000003', 'buses': 35, 'status': 'Activo'},
    {'name': 'Rutas Unidas SAC', 'ruc': '20100000004', 'buses': 20, 'status': 'Suspendido'},
    {'name': 'TransAndes', 'ruc': '20100000005', 'buses': 31, 'status': 'Activo'},
    {'name': 'Nueva Esperanza SR', 'ruc': '20100000006', 'buses': 0, 'status': 'Pendiente'},
  ];

  @override void dispose() { _nameCtrl.dispose(); _rucCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Cooperativas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const Spacer(),
          ElevatedButton.icon(onPressed: _showCreate, icon: const Icon(Icons.add, size: 18), label: const Text('Nueva'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
        ]),
        const SizedBox(height: 20),
        Expanded(child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [
            DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
            DataColumn(label: Text('RUC', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
            DataColumn(label: Text('Buses', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
            DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
            DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
          ], rows: _coops.map((c) => DataRow(cells: [
            DataCell(Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Inter'))),
            DataCell(Text(c['ruc'] as String, style: const TextStyle(fontFamily: 'Inter'))),
            DataCell(Text('${c['buses']}', style: const TextStyle(fontFamily: 'Inter'))),
            DataCell(_statusBadge(c['status'] as String)),
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              if (c['status'] == 'Pendiente') ...[
                IconButton(icon: const Icon(Icons.check, color: Colors.green, size: 18), onPressed: () {}),
                IconButton(icon: const Icon(Icons.close, color: Color(0xFFBA1A1A), size: 18), onPressed: () {}),
              ],
              IconButton(icon: const Icon(Icons.edit, color: Color(0xFF434750), size: 18), onPressed: () {}),
            ])),
          ])).toList()),
        ))),
      ])),
    );
  }

  Widget _statusBadge(String s) {
    final c = s == 'Activo' ? Colors.green : s == 'Suspendido' ? const Color(0xFFBA1A1A) : const Color(0xFF001B44);
    final bg = s == 'Activo' ? Colors.green.withAlpha(20) : s == 'Suspendido' ? const Color(0xFFBA1A1A).withAlpha(20) : const Color(0xFFFED000).withAlpha(30);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c, fontFamily: 'Inter')));
  }

  void _showCreate() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Nueva Cooperativa'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
        const SizedBox(height: 12),
        TextField(controller: _rucCtrl, decoration: const InputDecoration(labelText: 'RUC')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44)), child: const Text('Crear')),
      ],
    ));
  }
}
