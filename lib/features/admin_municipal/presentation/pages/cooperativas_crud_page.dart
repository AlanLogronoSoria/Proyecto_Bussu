import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/security/output_sanitizer.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/repositories/network_monitor_repository.dart';
import '../providers/system_alerts_provider.dart';

/// CRUD de cooperativas para el administrador municipal.
class CooperativasCrudPage extends ConsumerStatefulWidget {
  const CooperativasCrudPage({super.key});

  @override
  ConsumerState<CooperativasCrudPage> createState() =>
      _CooperativasCrudPageState();
}

class _CooperativasCrudPageState extends ConsumerState<CooperativasCrudPage> {
  final _nameController = TextEditingController();
  final _rucController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(cooperativasStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cooperativas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        child: const Icon(Icons.add),
      ),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cooperativas) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cooperativas.length,
          prototypeItem: const Card(child: ListTile(title: Text(' '))),
          itemBuilder: (_, i) {
            final c = cooperativas[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(c.name),
                subtitle: c.ruc != null ? Text('RUC: ${c.ruc}') : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${c.fleetActivityPct.round()}% activo',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () =>
                          ref.read(networkMonitorRepositoryProvider).deleteCooperativa(c.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva Cooperativa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _rucController,
              decoration: const InputDecoration(labelText: 'RUC'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = OutputSanitizer.sanitizeName(_nameController.text);
              final ruc = OutputSanitizer.sanitizeRuc(_rucController.text);
              final nameError = Validators.validateRequired(name, 'Nombre');
              if (nameError != null) return;
              ref.read(networkMonitorRepositoryProvider).createCooperativa({
                'name': name,
                'ruc': ruc,
              });
              Navigator.pop(context);
              ref.invalidate(cooperativasStatusProvider);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
