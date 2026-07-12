import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/security/output_sanitizer.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/entities/route_entity.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../providers/fleet_provider.dart';

class RoutesManagementPage extends ConsumerStatefulWidget {
  const RoutesManagementPage({super.key});
  @override
  ConsumerState<RoutesManagementPage> createState() => _RoutesManagementPageState();
}

class _RoutesManagementPageState extends ConsumerState<RoutesManagementPage> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final coopId = ref.watch(currentCoopIdProvider);
    final routesAsync = ref.watch(routesProvider(coopId));

    return Scaffold(
      appBar: AppBar(title: const Text('Rutas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(), child: const Icon(Icons.add)),
      body: routesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (routes) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: routes.length,
          prototypeItem: const Card(child: ListTile(title: Text(' '))),
          itemBuilder: (_, i) {
            final r = routes[i];
            return Card(
              child: ListTile(
                leading: Container(width: 12, height: 12,
                    decoration: BoxDecoration(
                        color: Color(int.parse('FF${r.color.replaceAll('#', '')}', radix: 16)),
                        shape: BoxShape.circle)),
                title: Text(r.name),
                subtitle: Text('${r.stops.length} paradas'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditDialog(r),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCreateDialog() {
    _nameCtrl.clear();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Nueva Ruta'),
      content: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          final repo = ref.read(fleetRepositoryProvider);
          final coopId = ref.read(currentCoopIdProvider);
          final name = OutputSanitizer.sanitizeName(_nameCtrl.text);
          final nameError = Validators.validateRequired(name, 'Nombre');
          if (nameError != null) return;
          repo.updateRoute(RouteEntity(id: '', cooperativaId: coopId, name: name));
          Navigator.pop(context);
          ref.invalidate(routesProvider(coopId));
        }, child: const Text('Crear')),
      ],
    ));
  }

  void _showEditDialog(RouteEntity route) {
    _nameCtrl.text = route.name;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Editar Ruta'),
      content: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          final name = OutputSanitizer.sanitizeName(_nameCtrl.text);
          final nameError = Validators.validateRequired(name, 'Nombre');
          if (nameError != null) return;
          ref.read(fleetRepositoryProvider).updateRoute(route.copyWith(name: name));
          Navigator.pop(context);
          ref.invalidate(routesProvider(ref.read(currentCoopIdProvider)));
        }, child: const Text('Guardar')),
      ],
    ));
  }
}
