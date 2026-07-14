import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ConductorProfilePage extends ConsumerWidget {
  const ConductorProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 40),
        Center(child: CircleAvatar(radius: 48, backgroundColor: const Color(0xFF001B44), child: Text((user?.fullName ?? 'C')[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Inter')))),
        const SizedBox(height: 12),
        Text(user?.fullName ?? 'Conductor', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 4),
        Text(user?.email ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Dashboard'), content: const Text('Redirigir al panel principal'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () { Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44)), child: const Text('Ir'))])), icon: const Icon(Icons.dashboard_outlined, size: 18), label: const Text('Ver Dashboard'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF001B44), side: const BorderSide(color: Color(0xFF001B44)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        const SizedBox(height: 16),
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
          ListTile(leading: const Icon(Icons.warning_amber_outlined, color: Color(0xFFBA1A1A)), title: const Text('Reportar incidente', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: () {}),
          const Divider(height: 1, indent: 56),
          ListTile(leading: const Icon(Icons.help_outline, color: Color(0xFF001B44)), title: const Text('Ayuda', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: () {}),
          const Divider(height: 1, indent: 56),
          ListTile(leading: const Icon(Icons.headset_mic_outlined, color: Color(0xFF001B44)), title: const Text('Soporte', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: () {}),
        ])),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => ref.read(authNotifierProvider.notifier).logout(), icon: const Icon(Icons.logout, size: 18), label: const Text('Cerrar sesión'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A), side: const BorderSide(color: Color(0xFFBA1A1A)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }
}
