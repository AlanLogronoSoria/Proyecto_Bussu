import 'package:flutter/material.dart';

class AdminIncidents extends StatefulWidget {
  const AdminIncidents({super.key});
  @override
  State<AdminIncidents> createState() => _AdminIncidentsState();
}

class _AdminIncidentsState extends State<AdminIncidents> {
  final _titleCtrl = TextEditingController(), _descCtrl = TextEditingController();
  String _severity = 'medium';

  final _alerts = <Map<String, dynamic>>[
    {'title': 'Desvio masivo en Ruta A por accidente', 'desc': '3 cooperativas afectadas.', 'severity': 'high', 'route': 'Ruta A', 'time': 'Ahora', 'author': 'Admin Municipal', 'resolved': false},
    {'title': 'Mantenimiento programado', 'desc': 'Servidores offline 2:00-4:00 AM.', 'severity': 'medium', 'route': 'Sistema', 'time': 'Programado', 'author': 'Admin Municipal', 'resolved': false},
    {'title': 'Nueva cooperativa registrada', 'desc': 'Rutas Unidas SAC pendiente de verificacion.', 'severity': 'low', 'route': 'Admin', 'time': 'Hace 2h', 'author': 'Sistema', 'resolved': false},
    {'title': 'Manifestacion en Plaza Norte', 'desc': 'Vias despejadas.', 'severity': 'high', 'route': 'Varias', 'time': 'Resuelto', 'author': 'Admin', 'resolved': true},
  ];

  @override void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Color _sevColor(String s) => s == 'high' ? const Color(0xFFBA1A1A) : s == 'medium' ? const Color(0xFFFED000) : Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          const Text('System Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const Spacer(),
          ElevatedButton.icon(onPressed: _showCreateDialog, icon: const Icon(Icons.add_alert, size: 18), label: const Text('Nueva Alerta'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
        ]),
        const SizedBox(height: 20),
        ...buildAlertCards(),
      ]),
    );
  }

  List<Widget> buildAlertCards() {
    return _alerts.map((a) {
      final sev = a['severity'] as String;
      final title = a['title'] as String;
      final desc = a['desc'] as String;
      final route = a['route'] as String;
      final time = a['time'] as String;
      final author = a['author'] as String;
      final resolved = a['resolved'] as bool;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: _sevColor(sev), width: 4)), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _sevColor(sev).withAlpha(20), borderRadius: BorderRadius.circular(6)), child: Text(sev == 'high' ? 'Alta Severidad' : sev == 'medium' ? 'Media' : 'Informativa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _sevColor(sev), fontFamily: 'Inter'))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(border: Border.all(color: const Color(0xFF434750).withAlpha(60)), borderRadius: BorderRadius.circular(6)), child: Text(route, style: const TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter'))),
            const Spacer(),
            Text(time, style: TextStyle(fontSize: 12, color: const Color(0xFF434750), fontFamily: 'Inter', decoration: resolved ? TextDecoration.lineThrough : null)),
            if (resolved) ...[const SizedBox(width: 8), const Icon(Icons.check_circle, color: Colors.green, size: 18)],
          ]),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF001B44), fontFamily: 'Inter', decoration: resolved ? TextDecoration.lineThrough : null)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 14, color: const Color(0xFF434750), fontFamily: 'Inter', decoration: resolved ? TextDecoration.lineThrough : null)),
          const SizedBox(height: 4),
          Text('Creado por $author', style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
        ]),
      );
    }).toList();
  }

  void _showCreateDialog() {
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: const Text('Nueva Alerta', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Titulo', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripcion', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _severity, items: const [
          DropdownMenuItem(value: 'high', child: Text('Alta')),
          DropdownMenuItem(value: 'medium', child: Text('Media')),
          DropdownMenuItem(value: 'low', child: Text('Informativa')),
        ], onChanged: (v) { if (v != null) setState(() => _severity = v); }, decoration: const InputDecoration(labelText: 'Severidad')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44)), child: const Text('Crear')),
      ],
    )));
  }
}
