import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_roles.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

final notifToggleProvider = StateProvider<bool>((ref) => true);

class UnifiedProfilePage extends ConsumerWidget {
  const UnifiedProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = user?.role;
    final isPremium = user?.isPremium ?? false;
    final notifs = ref.watch(notifToggleProvider);

    final isUsuario = role == UserRole.usuario;
    final isConductor = role == UserRole.conductor;

    return ListView(padding: const EdgeInsets.all(16), children: [
      const SizedBox(height: 24),
      const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 20),
      Center(child: CircleAvatar(radius: 48, backgroundColor: const Color(0xFF001B44), child: Text((user?.fullName ?? '?')[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Inter')))),
      const SizedBox(height: 12),
      Text(user?.fullName ?? 'Usuario', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 4),
      Text(user?.email ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
      const SizedBox(height: 8),
      _buildRoleBadge(role, isPremium),
      const SizedBox(height: 24),
      if (isUsuario && isPremium) ...[
        _buildAccountSection(context, ref, isUsuario),
        const SizedBox(height: 20),
      ],
      if (isUsuario && !isPremium) ...[
        _buildUpgradeBanner(),
        const SizedBox(height: 16),
      ],
      if (isConductor) ...[
        _buildDashboardButton(context),
        const SizedBox(height: 16),
      ],
      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
        if (isUsuario) ...[
          _buildListItem(Icons.star_outline, 'Rutas Favoritas', const Color(0xFF001B44), () {}),
          const Divider(height: 1, indent: 56),
        ],
        _buildListItem(Icons.warning_amber_outlined, 'Reportar incidente', const Color(0xFFBA1A1A), () {}),
        const Divider(height: 1, indent: 56),
        _buildListItem(Icons.help_outline, 'Ayuda', const Color(0xFF001B44), () {}),
        const Divider(height: 1, indent: 56),
        _buildListItem(Icons.headset_mic_outlined, 'Soporte', const Color(0xFF001B44), () {}),
        const Divider(height: 1, indent: 56),
        ListTile(leading: const Icon(Icons.notifications_outlined, color: Color(0xFF001B44)), title: const Text('Notificaciones', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: Switch(value: notifs, activeColor: const Color(0xFF001B44), onChanged: (v) => ref.read(notifToggleProvider.notifier).state = v)),
      ])),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => ref.read(authNotifierProvider.notifier).logout(), icon: const Icon(Icons.logout, size: 18), label: const Text('Cerrar sesión'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A), side: const BorderSide(color: Color(0xFFBA1A1A)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
    ]);
  }

  Widget _buildRoleBadge(UserRole? role, bool isPremium) {
    String text; Color color; IconData icon;
    if (isPremium) { text = 'Premium Member'; color = const Color(0xFFFED000); icon = Icons.workspace_premium; }
    else if (role == UserRole.conductor) { text = 'Conductor'; color = Colors.orange; icon = Icons.directions_bus; }
    else if (role == UserRole.cooperativaAdmin) { text = 'Admin Cooperativa'; color = const Color(0xFFFED000); icon = Icons.business; }
    else if (role == UserRole.municipalAdmin) { text = 'Admin Municipal'; color = Colors.purple; icon = Icons.shield; }
    else { text = 'Usuario'; color = Colors.grey; icon = Icons.person; }
    return Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color, fontFamily: 'Inter'))])));
  }

  Widget _buildUpgradeBanner() {
    return SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.workspace_premium, size: 18), label: const Text('Upgrade a Premium'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFED000), side: const BorderSide(color: Color(0xFFFED000)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))));
  }

  Widget _buildDashboardButton(BuildContext ctx) {
    return SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Dashboard en tab Viaje'), backgroundColor: Color(0xFF001B44))), icon: const Icon(Icons.dashboard_outlined, size: 18), label: const Text('Ver Dashboard'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF001B44), side: const BorderSide(color: Color(0xFF001B44)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))));
  }

  Widget _buildAccountSection(BuildContext ctx, WidgetRef ref, bool isUsuario) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
      _buildListItem(Icons.person_outline, 'Información personal', const Color(0xFF001B44), () {}),
      const Divider(height: 1, indent: 56),
      _buildListItem(Icons.receipt_outlined, 'Historial de viajes', const Color(0xFF001B44), () {}),
    ]));
  }

  Widget _buildListItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: color), title: Text(title, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: onTap);
  }
}
