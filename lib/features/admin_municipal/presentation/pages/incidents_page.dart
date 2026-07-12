import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/output_sanitizer.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/system_alert.dart';
import '../../domain/repositories/network_monitor_repository.dart';
import '../providers/system_alerts_provider.dart';

/// Alertas del sistema: visualización, creación, resolución y eliminación.
class IncidentsPage extends ConsumerStatefulWidget {
  const IncidentsPage({super.key});

  @override
  ConsumerState<IncidentsPage> createState() => _IncidentsPageState();
}

class _IncidentsPageState extends ConsumerState<IncidentsPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(systemAlertsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas del Sistema')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add_alert),
      ),
      body: alerts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (alertList) => alertList.isEmpty
            ? const Center(child: Text('No hay alertas'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alertList.length,
                prototypeItem: const Card(
                    child: Padding(padding: EdgeInsets.all(16),
                        child: SizedBox(height: 60))),
                itemBuilder: (_, i) {
                  final alert = alertList[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: alert.isResolved
                        ? Colors.grey[100]
                        : _severityColor(alert.severity).withAlpha(20),
                    child: ListTile(
                      leading: Icon(
                        alert.isResolved ? Icons.check_circle : Icons.warning,
                        color: alert.isResolved
                            ? Colors.grey
                            : _severityColor(alert.severity),
                      ),
                      title: Text(alert.title),
                      subtitle: Text(alert.description,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) {
                          final repo = ref.read(
                              networkMonitorRepositoryProvider);
                          if (action == 'resolve') {
                            repo.resolveAlert(alert.id);
                          } else if (action == 'delete') {
                            repo.deleteAlert(alert.id);
                          }
                        },
                        itemBuilder: (_) => [
                          if (!alert.isResolved)
                            const PopupMenuItem(
                              value: 'resolve',
                              child: Text('Resolver'),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
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

  Color _severityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _showCreateDialog(BuildContext context) {
    _titleCtrl.clear();
    _descCtrl.clear();
    String severity = 'medium';
    const scope = 'system';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva Alerta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  value: severity,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Baja')),
                    DropdownMenuItem(value: 'medium', child: Text('Media')),
                    DropdownMenuItem(value: 'high', child: Text('Alta')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => severity = v);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Severidad'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final repo = ref.read(networkMonitorRepositoryProvider);
                final title = OutputSanitizer.sanitizeText(_titleCtrl.text, maxLength: 200);
                final desc = OutputSanitizer.sanitizeText(_descCtrl.text, maxLength: 500);
                final titleError = Validators.validateRequired(title, 'Titulo');
                if (titleError != null) return;
                  repo.createAlert(SystemAlert(
                    id: '',
                    scope: scope,
                    severity: severity,
                    title: title,
                    description: desc,
                  createdAt: DateTime.now(),
                ));
                Navigator.pop(context);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }
}
