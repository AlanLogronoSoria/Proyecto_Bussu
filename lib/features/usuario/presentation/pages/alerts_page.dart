import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../admin_municipal/presentation/providers/system_alerts_provider.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(systemAlertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Alerts', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
        error: (_, __) => const Center(child: Text('Error al cargar alertas')),
        data: (alerts) {
          if (alerts.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16), const Text('No hay alertas activas', style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF434750))),
          ]));
          return ListView.builder(padding: const EdgeInsets.all(16), itemCount: alerts.length, prototypeItem: const SizedBox(height: 100), itemBuilder: (_, i) {
            final a = alerts[i];
            if (a.scope != 'route' && a.scope != 'stop' && a.scope != 'system') return const SizedBox.shrink();
            final color = a.severity == 'high' ? const Color(0xFFBA1A1A) : a.severity == 'medium' ? const Color(0xFFFED000) : Colors.blue;
            return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: color, width: 4)), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: a.isResolved ? Colors.green.withAlpha(20) : color.withAlpha(20), borderRadius: BorderRadius.circular(10)), child: Icon(a.isResolved ? Icons.check_circle : Icons.warning_amber, color: a.isResolved ? Colors.green : color, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF001B44), fontFamily: 'Inter', decoration: a.isResolved ? TextDecoration.lineThrough : null)),
                const SizedBox(height: 4),
                Text(a.description, style: TextStyle(fontSize: 13, color: const Color(0xFF434750), fontFamily: 'Inter', decoration: a.isResolved ? TextDecoration.lineThrough : null)),
              ])),
              if (a.isResolved) const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ]));
          });
        },
      ),
    );
  }
}
