import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/system_alerts_provider.dart';

class AdminDriversPage extends ConsumerWidget {
  const AdminDriversPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 0), child: Row(children: [
        const Text('Conductores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF001B44).withAlpha(20), borderRadius: BorderRadius.circular(8)), child: usersAsync.when(data: (u) => Text('Total: ${u.length}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), loading: () => const SizedBox.shrink(), error: (_, __) => const SizedBox.shrink())),
      ])),
      const SizedBox(height: 12),
      Expanded(child: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
        error: (_, __) => const Center(child: Text('Error al cargar')),
        data: (users) => ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: users.length, prototypeItem: const SizedBox(height: 80), itemBuilder: (_, i) {
          final u = users[i];
          final fullName = (u['full_name'] as String?) ?? '';
          final email = (u['email'] as String?) ?? '';
          final role = (u['role'] as String?) ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
            child: Row(children: [
              CircleAvatar(radius: 24, backgroundColor: const Color(0xFF001B44), child: Text(fullName.isNotEmpty ? fullName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
                if (email.isNotEmpty) Text(email, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _roleColor(role).withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Text(_roleLabel(role), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: _roleColor(role)))),
            ]),
          );
        }),
      )),
    ]);
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'conductor': return Colors.orange;
      case 'cooperativa_admin': return Colors.blue;
      case 'municipal_admin': return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'conductor': return 'Conductor';
      case 'cooperativa_admin': return 'Admin Coop';
      case 'municipal_admin': return 'Admin Municipal';
      default: return 'Usuario';
    }
  }
}
