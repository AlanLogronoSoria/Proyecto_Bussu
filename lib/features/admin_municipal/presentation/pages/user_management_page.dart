import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/network_monitor_repository.dart';
import '../providers/system_alerts_provider.dart';

/// Gestión de usuarios por el administrador municipal.
class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (userList) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userList.length,
          prototypeItem: const Card(child: ListTile(title: Text(' '))),
          itemBuilder: (_, i) {
            final u = userList[i];
            final role = u['role'] as String? ?? 'usuario';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    (u['full_name'] as String? ?? 'U')[0].toUpperCase(),
                  ),
                ),
                title: Text(u['full_name'] as String? ?? 'Sin nombre'),
                subtitle: Text(
                  u['email'] as String? ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (newRole) {
                    ref
                        .read(networkMonitorRepositoryProvider)
                        .updateUserRole(u['id'] as String, newRole);
                    ref.invalidate(allUsersProvider);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'usuario',
                      child: Text('Usuario'),
                    ),
                    const PopupMenuItem(
                      value: 'conductor',
                      child: Text('Conductor'),
                    ),
                    const PopupMenuItem(
                      value: 'cooperativa_admin',
                      child: Text('Admin Cooperativa'),
                    ),
                    const PopupMenuItem(
                      value: 'municipal_admin',
                      child: Text('Admin Municipal'),
                    ),
                  ],
                  child: Chip(
                    label: Text(role, style: const TextStyle(fontSize: 12)),
                    backgroundColor: _roleColor(role).withAlpha(30),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'municipal_admin':
        return Colors.purple;
      case 'cooperativa_admin':
        return Colors.blue;
      case 'conductor':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
