import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../providers/fleet_provider.dart';

/// Gestión de paradas: visualización y aprobación de solicitudes pendientes.
class StopManagementPage extends ConsumerWidget {
  const StopManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingStopRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Paradas')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Paradas'),
                Tab(text: 'Solicitudes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const Center(
                      child: Text('Lista de paradas')),
                  pendingAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (requests) => requests.isEmpty
                        ? const Center(
                            child: Text('No hay solicitudes pendientes'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: requests.length,
                            prototypeItem: const Card(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(height: 120))),
                            itemBuilder: (_, i) {
                              final r = requests[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r['justification'] as String? ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Lat: ${r['proposed_lat']}, Lng: ${r['proposed_lng']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () {
                                              final repo = ref.read(
                                                  fleetRepositoryProvider);
                                              repo.rejectStopRequest(
                                                  r['id'] as String);
                                              ref.invalidate(
                                                  pendingStopRequestsProvider);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  AppTheme.error,
                                            ),
                                            child:
                                                const Text('Rechazar'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              final repo = ref.read(
                                                  fleetRepositoryProvider);
                                              repo.approveStopRequest(
                                                  r['id'] as String);
                                              ref.invalidate(
                                                  pendingStopRequestsProvider);
                                            },
                                            child: const Text('Aprobar'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
