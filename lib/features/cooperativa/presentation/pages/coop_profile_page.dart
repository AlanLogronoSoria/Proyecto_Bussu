import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final cooperativaNotificationsEnabledProvider = StateProvider<bool>((ref) => true);

class CoopProfilePage extends ConsumerWidget {
  const CoopProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final notifs = ref.watch(cooperativaNotificationsEnabledProvider);

    return ListView(padding: const EdgeInsets.all(16), children: [
      const SizedBox(height: 24),
      const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 20),
      Center(child: CircleAvatar(radius: 48, backgroundColor: const Color(0xFF001B44), child: Text((user?.fullName ?? 'C')[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Inter')))),
      const SizedBox(height: 12),
      Text(user?.fullName ?? 'Cooperativa', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 4),
      Text(user?.email ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
      const SizedBox(height: 8),
      Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFED000).withAlpha(30), borderRadius: BorderRadius.circular(8)), child: const Text('Admin Cooperativa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')))),
      const SizedBox(height: 28),
      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
        ListTile(leading: const Icon(Icons.warning_amber_outlined, color: Color(0xFFBA1A1A)), title: const Text('Reportar incidente', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: () {}),
        const Divider(height: 1, indent: 56),
        ListTile(leading: const Icon(Icons.help_outline, color: Color(0xFF001B44)), title: const Text('Ayuda', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: () {}),
        const Divider(height: 1, indent: 56),
        ListTile(leading: const Icon(Icons.notifications_outlined, color: Color(0xFF001B44)), title: const Text('Notificaciones', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: Switch(value: notifs, activeColor: const Color(0xFF001B44), onChanged: (v) => ref.read(cooperativaNotificationsEnabledProvider.notifier).state = v)),
      ])),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => ref.read(authNotifierProvider.notifier).logout(), icon: const Icon(Icons.logout, size: 18), label: const Text('Cerrar sesión'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A), side: const BorderSide(color: Color(0xFFBA1A1A)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
    ]);
  }
}
