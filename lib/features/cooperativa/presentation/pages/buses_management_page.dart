import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/security/output_sanitizer.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../providers/fleet_provider.dart';

class BusesManagementPage extends ConsumerStatefulWidget {
  const BusesManagementPage({super.key});
  @override
  ConsumerState<BusesManagementPage> createState() => _BusesManagementPageState();
}

class _BusesManagementPageState extends ConsumerState<BusesManagementPage> {
  final _plateCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  @override
  void dispose() { _plateCtrl.dispose(); _capacityCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final coopId = ref.watch(currentCoopIdProvider);
    final busesAsync = ref.watch(busesProvider(coopId));

    return Scaffold(
      appBar: AppBar(title: const Text('Buses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(), child: const Icon(Icons.add)),
      body: busesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (buses) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: buses.length,
          prototypeItem: const Card(child: ListTile(title: Text(' '))),
          itemBuilder: (_, i) {
            final b = buses[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppTheme.primary,
                    child: Text(b.plate.isNotEmpty ? b.plate[0] : 'B', style: const TextStyle(color: Colors.white))),
                title: Text(b.plate),
                subtitle: Text('Capacidad: ${b.capacity} · ${b.routeId ?? "Sin ruta"}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditDialog(b),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCreateDialog() {
    _plateCtrl.clear(); _capacityCtrl.clear();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Nuevo Bus'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _plateCtrl, decoration: const InputDecoration(labelText: 'Placa')),
        TextField(controller: _capacityCtrl, decoration: const InputDecoration(labelText: 'Capacidad'), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          final repo = ref.read(fleetRepositoryProvider);
          final coopId = ref.read(currentCoopIdProvider);
          final plate = OutputSanitizer.sanitizePlate(_plateCtrl.text);
          final plateError = Validators.validateRequired(plate, 'Placa');
          if (plateError != null) return;
          repo.createBus(plate: plate, cooperativaId: coopId, capacity: int.tryParse(_capacityCtrl.text) ?? 40);
          Navigator.pop(context);
          ref.invalidate(busesProvider(coopId));
        }, child: const Text('Crear')),
      ],
    ));
  }

  void _showEditDialog(BusEntity bus) {
    _plateCtrl.text = bus.plate;
    _capacityCtrl.text = '${bus.capacity}';
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Editar Bus'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _plateCtrl, decoration: const InputDecoration(labelText: 'Placa')),
        TextField(controller: _capacityCtrl, decoration: const InputDecoration(labelText: 'Capacidad'), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          final repo = ref.read(fleetRepositoryProvider);
          final plate = OutputSanitizer.sanitizePlate(_plateCtrl.text);
          final plateError = Validators.validateRequired(plate, 'Placa');
          if (plateError != null) return;
          repo.updateBus(bus.copyWith(plate: plate, capacity: int.tryParse(_capacityCtrl.text) ?? bus.capacity));
          Navigator.pop(context);
          ref.invalidate(busesProvider(ref.read(currentCoopIdProvider)));
        }, child: const Text('Guardar')),
      ],
    ));
  }
}
