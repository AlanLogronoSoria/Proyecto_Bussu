import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tickets_provider.dart';

class TicketsPage extends ConsumerWidget {
  const TicketsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tickets', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: tickets.when(loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))), error: (_, __) => const Center(child: Text('Error')), data: (list) {
        if (list.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16), const Text('No tienes tickets activos', style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF434750))),
        ]));
        return ListView.builder(padding: const EdgeInsets.all(16), itemCount: list.length, itemBuilder: (_, i) {
          final t = list[i];
          return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, 2))]), padding: const EdgeInsets.all(16), child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF001B44).withAlpha(20), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.confirmation_number, color: Color(0xFF001B44), size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t['route_name'] as String? ?? 'Ticket', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
              const SizedBox(height: 2),
              Text('${t['date'] ?? '12 may 2026'} · ${t['status'] ?? 'Activo'}', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
            ])),
            Column(children: [
              Text('S/ ${t['amount'] ?? '2.50'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
              const SizedBox(height: 4),
              if (t['status'] == 'active' || t['status'] == 'Activo')
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(20)), child: const Text('Ver QR', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
            ]),
          ]));
        });
      }),
    );
  }
}
