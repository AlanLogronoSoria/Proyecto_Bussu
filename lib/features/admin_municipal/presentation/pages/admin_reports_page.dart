import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/system_alerts_provider.dart';

class AdminReportsPage extends ConsumerStatefulWidget {
  const AdminReportsPage({super.key});
  @override
  ConsumerState<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends ConsumerState<AdminReportsPage> {
  late final TextEditingController _titleCtrl, _descCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  void _createIncident() {
    _titleCtrl.clear(); _descCtrl.clear();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Nuevo Incidente', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
        const SizedBox(height: 8),
        TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripción')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incidente creado'), backgroundColor: Color(0xFF001B44))); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44)), child: const Text('Crear')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(systemAlertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton(onPressed: _createIncident, backgroundColor: const Color(0xFF001B44), child: const Icon(Icons.add, color: Colors.white)),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 0), child: Row(children: [const Text('Reportes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF001B44).withAlpha(20), borderRadius: BorderRadius.circular(8)), child: const Text('Incidentes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')))])),
        const SizedBox(height: 12),
        Expanded(child: alertsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
          error: (_, __) => const Center(child: Text('Error al cargar incidentes')),
          data: (alerts) => ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: alerts.length, prototypeItem: const SizedBox(height: 100), itemBuilder: (_, i) {
            final a = alerts[i];
            final color = a.severity == 'high' ? const Color(0xFFBA1A1A) : a.severity == 'medium' ? const Color(0xFFFED000) : Colors.blue;
            return Container(
              margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: a.isResolved ? Colors.grey.shade100 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 4, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10),
                  Expanded(child: Text(a.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF001B44), fontFamily: 'Inter', decoration: a.isResolved ? TextDecoration.lineThrough : null))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: a.isResolved ? Colors.green.withAlpha(20) : const Color(0xFFBA1A1A).withAlpha(20), borderRadius: BorderRadius.circular(6)), child: Text(a.isResolved ? 'Resuelto' : 'Pendiente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: a.isResolved ? Colors.green.shade700 : const Color(0xFFBA1A1A)))),
                  if (!a.isResolved) PopupMenuButton(itemBuilder: (_) => [
                    const PopupMenuItem(value: 'resolve', child: Text('Resolver')),
                    const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Color(0xFFBA1A1A)))),
                  ], onSelected: (v) { setState(() {}); }),
                ]),
                const SizedBox(height: 6),
                Text(a.description, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4),
                  Text(a.createdBy ?? 'Admin', style: const TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter')),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600), const SizedBox(width: 4),
                  Text(_fmt(a.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter')),
                ]),
              ]),
            );
          }),
        )),
      ]),
    );
  }

  String _fmt(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
