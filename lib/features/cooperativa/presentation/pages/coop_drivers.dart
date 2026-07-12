import 'package:flutter/material.dart';

class CoopDrivers extends StatefulWidget {
  const CoopDrivers({super.key});
  @override
  State<CoopDrivers> createState() => _CoopDriversState();
}

class _CoopDriversState extends State<CoopDrivers> {
  final _nameCtrl = TextEditingController(), _licenseCtrl = TextEditingController();
  final _drivers = [
    {'name': 'Carlos Mendoza', 'photo': 'CM', 'license': 'Q-12345678', 'bus': 'ABC-123', 'status': 'Activo'},
    {'name': 'Luisa Rodriguez', 'photo': 'LR', 'license': 'Q-87654321', 'bus': 'ABC-124', 'status': 'Activo'},
    {'name': 'Pedro Sanchez', 'photo': 'PS', 'license': 'Q-11223344', 'bus': '—', 'status': 'Inactivo'},
    {'name': 'Ana Villanueva', 'photo': 'AV', 'license': 'Q-55667788', 'bus': 'DEF-456', 'status': 'Activo'},
  ];

  @override void dispose() { _nameCtrl.dispose(); _licenseCtrl.dispose(); super.dispose(); }

  void _showDialog({Map<String, String>? d}) {
    if (d != null) { _nameCtrl.text = d['name']!; _licenseCtrl.text = d['license']!; }
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(d != null ? 'Editar Conductor' : 'Nuevo Conductor', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
        const SizedBox(height: 12),
        TextField(controller: _licenseCtrl, decoration: const InputDecoration(labelText: 'Licencia')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44)), child: const Text('Guardar')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: Row(children: [
        const Text('Conductores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const Spacer(),
        ElevatedButton.icon(onPressed: () => _showDialog(), icon: const Icon(Icons.add, size: 18), label: const Text('Nuevo'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      ])),
      const SizedBox(height: 16),
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: _drivers.map((d) => Container(
        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
        child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: const Color(0xFF001B44), child: Text(d['photo']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d['name']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            Text('Lic: ${d['license']} · Bus: ${d['bus']}', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: d['status'] == 'Activo' ? Colors.green.withAlpha(20) : Colors.grey.withAlpha(30), borderRadius: BorderRadius.circular(8)), child: Text(d['status']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: d['status'] == 'Activo' ? Colors.green : const Color(0xFF434750), fontFamily: 'Inter'))),
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.edit, size: 18, color: Color(0xFF434750)), onPressed: () => _showDialog(d: d)),
          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)), onPressed: () {}),
        ]),
      )).toList())),
    ]);
  }
}
