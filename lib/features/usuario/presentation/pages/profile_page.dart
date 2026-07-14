import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPremium = user?.isPremium ?? false;
    final notifEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Profile', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 16),
        Center(child: CircleAvatar(radius: 48, backgroundColor: const Color(0xFF001B44), child: Text((user?.fullName ?? 'U')[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w600)))),
        const SizedBox(height: 12),
        Text(user?.fullName ?? 'Usuario', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 4),
        Text(user?.email ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
        const SizedBox(height: 12),
        if (isPremium) Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFED000), borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.workspace_premium, size: 16, color: Color(0xFF001B44)), SizedBox(width: 6), Text('Premium Member', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))]))),
        if (!isPremium) const SizedBox(height: 16),
        if (!isPremium) SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFED000), side: const BorderSide(color: Color(0xFFFED000)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 12)), child: const Text('Upgrade a Premium', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')))),
        const SizedBox(height: 24),
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
          ListTile(leading: const Icon(Icons.star_outline, color: Color(0xFF001B44)), title: const Text('Rutas Favoritas', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: () {}),
          const Divider(height: 1, indent: 56),
          ListTile(leading: const Icon(Icons.notifications_outlined, color: Color(0xFF001B44)), title: const Text('Notificaciones', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: Switch(value: notifEnabled, activeColor: const Color(0xFF001B44), onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).state = v)),
          const Divider(height: 1, indent: 56),
          ListTile(leading: const Icon(Icons.help_outline, color: Color(0xFF001B44)), title: const Text('Ayuda y soporte', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: () {}),
        ])),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => ref.read(authNotifierProvider.notifier).logout(), icon: const Icon(Icons.logout, size: 18), label: const Text('Cerrar sesión'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A), side: const BorderSide(color: Color(0xFFBA1A1A)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }
}
