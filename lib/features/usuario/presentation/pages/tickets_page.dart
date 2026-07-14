import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/tickets_provider.dart';

class TicketsPage extends ConsumerWidget {
  const TicketsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPremium = user?.isPremium ?? false;

    if (!isPremium) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('Tickets', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.workspace_premium, size: 64, color: Color(0xFFFED000)),
          const SizedBox(height: 16),
          const Text('Funcionalidad Premium', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const SizedBox(height: 8),
          const Text('Actualiza a Premium para acceder\na tus tickets y boletería digital.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFED000), foregroundColor: const Color(0xFF001B44), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Upgrade a Premium', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter'))),
        ])),
      );
    }

    final ticketsAsync = ref.watch(ticketsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Tickets', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ticketsAsync.when(loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))), error: (_, __) => const Center(child: Text('Error')), data: (tickets) {
        if (tickets.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey[300]), const SizedBox(height: 16), const Text('No tienes tickets activos', style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF434750)))]));
        return ListView.builder(padding: const EdgeInsets.all(16), itemCount: tickets.length, prototypeItem: const Card(child: ListTile(title: Text(' '))), itemBuilder: (_, i) {
          final t = tickets[i];
          return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, 2))]), padding: const EdgeInsets.all(16), child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF001B44).withAlpha(20), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.confirmation_number, color: Color(0xFF001B44), size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t['route_name'] as String? ?? 'Ticket', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const SizedBox(height: 2), Text('${t['date'] ?? '12 may 2026'} · ${t['status'] ?? 'Activo'}', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))])),
            Text('S/ ${t['amount'] ?? '2.50'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
          ]));
        });
      }),
    );
  }
}
