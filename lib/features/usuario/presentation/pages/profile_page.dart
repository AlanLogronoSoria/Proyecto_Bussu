import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPremium = user?.isPremium ?? false;

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
        const SizedBox(height: 24),
        _WalletCard(balance: 'S/ 24.50'),
        const SizedBox(height: 16),
        _MenuList(items: const [
          _MenuItem(icon: Icons.history, title: 'Historial de viajes'),
          _MenuItem(icon: Icons.bookmark_outline, title: 'Paradas guardadas'),
          _MenuItem(icon: Icons.payment, title: 'Métodos de pago'),
          _MenuItem(icon: Icons.map_outlined, title: 'Mapa de servicio'),
          _MenuItem(icon: Icons.help_outline, title: 'Ayuda y soporte'),
        ]),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => ref.read(authNotifierProvider.notifier).logout(), icon: const Icon(Icons.logout, size: 18), label: const Text('Cerrar sesión'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A), side: const BorderSide(color: Color(0xFFBA1A1A)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final String balance;
  const _WalletCard({required this.balance});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x33002F6C), blurRadius: 12, offset: Offset(0, 4))]), child: Row(children: [
      const Icon(Icons.account_balance_wallet, color: Color(0xFFFED000), size: 32),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Billetera BUSSU', style: TextStyle(fontSize: 13, color: Colors.white70, fontFamily: 'Inter')),
        const SizedBox(height: 2),
        Text(balance, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Inter')),
      ]),
    ]));
  }
}

class _MenuList extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuList({required this.items});
  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: items.map((e) => ListTile(leading: Icon(e.icon, color: const Color(0xFF001B44)), title: Text(e.title, style: const TextStyle(fontSize: 15, color: Color(0xFF001B44), fontFamily: 'Inter')), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: () {})).toList()));
  }
}

class _MenuItem { final IconData icon; final String title; const _MenuItem({required this.icon, required this.title}); }
