import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = [
      {'severity': 'high', 'icon': Icons.warning_rounded, 'category': 'Accidente', 'title': 'Desvío en Ruta A por accidente', 'desc': 'La Ruta A toma desvío por Av. Principal. +15 min estimados.', 'time': 'Ahora', 'resolved': false},
      {'severity': 'medium', 'icon': Icons.engineering, 'category': 'Mantenimiento', 'title': 'Cierre temporal en Av. Central', 'desc': 'Obras viales programadas hasta las 18:00. Rutas B y C con desvío.', 'time': 'Hace 10 min', 'resolved': false},
      {'severity': 'low', 'icon': Icons.add_road, 'category': 'Ruta nueva', 'title': 'Nueva ruta D disponible', 'desc': 'Ruta exprés al centro sin paradas intermedias. Ya operativa.', 'time': 'Hace 2 horas', 'resolved': false},
      {'severity': 'low', 'icon': Icons.check_circle, 'category': 'Solucionado', 'title': 'Manifestación en Plaza Norte', 'desc': 'Vías despejadas. Todas las rutas operan con normalidad.', 'time': 'Resuelto ayer', 'resolved': true},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: alerts.length, itemBuilder: (_, i) {
        final a = alerts[i];
        final borderColor = a['severity'] == 'high' ? const Color(0xFFBA1A1A) : a['severity'] == 'medium' ? const Color(0xFFFED000) : const Color(0xFF001B44).withAlpha(40);
        final isResolved = a['resolved'] == true;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: borderColor, width: 4)), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, 2))]),
          child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: isResolved ? Colors.green.withAlpha(20) : borderColor.withAlpha(20), borderRadius: BorderRadius.circular(10)), child: Icon(a['icon'] as IconData, color: isResolved ? Colors.green : borderColor, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(a['category'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: borderColor, fontFamily: 'Inter')),
                const Spacer(),
                Text(a['time'] as String, style: TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter', decoration: isResolved ? TextDecoration.lineThrough : null)),
              ]),
              const SizedBox(height: 4),
              Text(a['title'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter', decoration: isResolved ? TextDecoration.lineThrough : null)),
              const SizedBox(height: 4),
              Text(a['desc'] as String, style: TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter', decoration: isResolved ? TextDecoration.lineThrough : null)),
            ])),
            if (isResolved) const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ])),
        );
      }),
    );
  }
}
