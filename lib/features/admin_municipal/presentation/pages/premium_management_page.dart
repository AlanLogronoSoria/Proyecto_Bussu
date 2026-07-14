import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/system_alerts_provider.dart';

class PremiumManagementPage extends ConsumerStatefulWidget {
  const PremiumManagementPage({super.key});
  @override
  ConsumerState<PremiumManagementPage> createState() => _PremiumManagementPageState();
}

class _PremiumManagementPageState extends ConsumerState<PremiumManagementPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final subsAsync = ref.watch(premiumSubscriptionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Gestión Premium', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showActivateDialog(ref), backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, icon: const Icon(Icons.add), label: const Text('Activar Premium', style: TextStyle(fontFamily: 'Inter'))),
      body: subsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
        error: (_, __) => const Center(child: Text('Error al cargar suscripciones', style: TextStyle(fontFamily: 'Inter'))),
        data: (subs) {
          final active = subs.where((s) => s['status'] == 'active').length;
          final expired = subs.where((s) => s['status'] == 'expired').length;
          final suspended = subs.where((s) => s['status'] == 'suspended').length;

          final filtered = _filter == 'all' ? subs : subs.where((s) => s['status'] == _filter).toList();

          return ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              _summaryCard('Activos', '$active', Colors.green, ref), const SizedBox(width: 10),
              _summaryCard('Expirados', '$expired', Colors.orange, ref), const SizedBox(width: 10),
              _summaryCard('Suspendidos', '$suspended', const Color(0xFFBA1A1A), ref),
            ]),
            const SizedBox(height: 16),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
              _filterChip('Todos', 'all'),
              const SizedBox(width: 8),
              _filterChip('Activos', 'active'),
              const SizedBox(width: 8),
              _filterChip('Expirados', 'expired'),
              const SizedBox(width: 8),
              _filterChip('Suspendidos', 'suspended'),
            ])),
            const SizedBox(height: 16),
            const Text('Usuarios Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const SizedBox(height: 12),
            if (filtered.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Sin suscripciones en este filtro', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF434750))))),
            ...filtered.map((s) { return _buildSubCard(s, ref); }),
            const SizedBox(height: 80),
          ]);
        },
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color, WidgetRef ref) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
      child: Column(children: [Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color, fontFamily: 'Inter')), Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter'))]),
    ));
  }

  Widget _filterChip(String label, String value) {
    final active = _filter == value;
    return GestureDetector(onTap: () => setState(() => _filter = value), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: active ? const Color(0xFF001B44) : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? const Color(0xFF001B44) : const Color(0xFFE0E0E0))), child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: active ? Colors.white : const Color(0xFF434750)))));
  }

  Widget _buildSubCard(Map<String, dynamic> s, WidgetRef ref) {
    final profile = s['profiles'] as Map<String, dynamic>? ?? {};
    final name = profile['full_name'] as String? ?? 'Usuario';
    final email = profile['email'] as String? ?? '';
    final status = s['status'] as String? ?? 'active';
    final planId = s['plan_id'] as String? ?? 'premium';
    final id = s['id'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: const Color(0xFF001B44), child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            Text(email, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(
              color: status == 'active' ? Colors.green.withAlpha(20) : status == 'suspended' ? const Color(0xFFBA1A1A).withAlpha(20) : Colors.orange.withAlpha(30),
              borderRadius: BorderRadius.circular(8)),
              child: Text(status == 'active' ? 'Activo' : status == 'suspended' ? 'Suspendido' : 'Expirado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: status == 'active' ? Colors.green.shade700 : status == 'suspended' ? const Color(0xFFBA1A1A) : Colors.orange.shade800))),
            const SizedBox(height: 4),
            Text('Plan: $planId', style: const TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter')),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          if (status == 'active') Expanded(child: OutlinedButton.icon(onPressed: () => _suspend(id, ref), icon: const Icon(Icons.pause_circle_outline, size: 16), label: const Text('Suspender'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A), side: const BorderSide(color: Color(0xFFBA1A1A)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 10)))),
          if (status == 'suspended' || status == 'expired') Expanded(child: ElevatedButton.icon(onPressed: () => _activate(id, ref), icon: const Icon(Icons.check_circle_outline, size: 16), label: const Text('Activar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 10)))),
        ]),
      ]),
    );
  }

  void _suspend(String id, WidgetRef ref) {
    final repo = ref.read(networkMonitorRepositoryProvider);
    repo.updateSubscriptionStatus(id, 'suspended');
    ref.invalidate(premiumSubscriptionsProvider);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium suspendido'), backgroundColor: Color(0xFF001B44)));
  }

  void _activate(String id, WidgetRef ref) {
    final repo = ref.read(networkMonitorRepositoryProvider);
    repo.updateSubscriptionStatus(id, 'active');
    ref.invalidate(premiumSubscriptionsProvider);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium activado'), backgroundColor: Colors.green));
  }

  void _showActivateDialog(WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Activar Premium a Usuario', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del usuario', labelStyle: TextStyle(fontFamily: 'Inter'), border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(fontFamily: 'Inter'), border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
          final repo = ref.read(networkMonitorRepositoryProvider);
          repo.updateSubscriptionStatus(emailCtrl.text.trim(), 'active');
          ref.invalidate(premiumSubscriptionsProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suscripción activada'), backgroundColor: Colors.green));
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white), child: const Text('Activar', style: TextStyle(fontFamily: 'Inter'))),
      ],
    ));
  }
}
