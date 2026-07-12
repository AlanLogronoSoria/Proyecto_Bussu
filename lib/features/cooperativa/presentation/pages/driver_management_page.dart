import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../providers/fleet_provider.dart';

/// CRUD de conductores de la cooperativa.
class DriverManagementPage extends ConsumerStatefulWidget {
  const DriverManagementPage({super.key});

  @override
  ConsumerState<DriverManagementPage> createState() =>
      _DriverManagementPageState();
}

class _DriverManagementPageState extends ConsumerState<DriverManagementPage> {
  @override
  Widget build(BuildContext context) {
    final coopId = ref.watch(currentCoopIdProvider);
    final driversAsync = ref.watch(driversProvider(coopId));
    final busesAsync = ref.watch(busesProvider(coopId));

    return Scaffold(
      appBar: AppBar(title: const Text('Conductores')),
      body: driversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (drivers) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: drivers.length,
          prototypeItem: const Card(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(height: 100))),
          itemBuilder: (_, i) => _DriverCard(
            driver: drivers[i],
            buses: busesAsync.valueOrNull ?? [],
            onAssignBus: (busId) async {
              final repo = ref.read(fleetRepositoryProvider);
              await repo.assignDriverToBus(
                driverId: drivers[i].id,
                busId: busId,
              );
              ref.invalidate(driversProvider(coopId));
            },
          ),
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DriverEntity driver;
  final List<BusEntity> buses;
  final void Function(String busId) onAssignBus;

  const _DriverCard({
    required this.driver,
    required this.buses,
    required this.onAssignBus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Text(driver.fullName.isNotEmpty
                      ? driver.fullName[0].toUpperCase()
                      : '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.fullName,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(driver.email,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  driver.assignedBusId != null
                      ? Icons.check_circle
                      : Icons.warning_amber,
                  color: driver.assignedBusId != null
                      ? Colors.green
                      : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              driver.assignedBusPlate != null
                  ? 'Bus: ${driver.assignedBusPlate}'
                  : 'Sin bus asignado',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAssignDialog(context),
                icon: const Icon(Icons.directions_bus, size: 18),
                label: const Text('Asignar Bus'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Asignar Bus'),
        children: buses.map((bus) {
          return SimpleDialogOption(
            onPressed: () {
              onAssignBus(bus.id);
              Navigator.pop(context);
            },
            child: Text('${bus.plate} (Cap: ${bus.capacity})'),
          );
        }).toList(),
      ),
    );
  }
}
