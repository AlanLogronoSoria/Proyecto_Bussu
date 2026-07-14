import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/output_sanitizer.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/entities/route_entity.dart';
import '../../../usuario/presentation/providers/directions_provider.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../providers/fleet_provider.dart';

class RoutesManagementPage extends ConsumerStatefulWidget {
  const RoutesManagementPage({super.key});
  @override
  ConsumerState<RoutesManagementPage> createState() => _RoutesManagementPageState();
}

class _RoutesManagementPageState extends ConsumerState<RoutesManagementPage> {
  final _nameCtrl = TextEditingController();
  final _slatCtrl = TextEditingController();
  final _slngCtrl = TextEditingController();
  final _elatCtrl = TextEditingController();
  final _elngCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose(); _slatCtrl.dispose(); _slngCtrl.dispose();
    _elatCtrl.dispose(); _elngCtrl.dispose();
    super.dispose();
  }

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
            final distKm = _polylineDistance(r.polyline);
            return Card(
              child: ListTile(
                leading: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: Color(int.parse('FF${r.color.replaceAll('#', '')}', radix: 16)),
                    shape: BoxShape.circle)),
                title: Text(r.name),
                subtitle: Text('${r.stops.length} paradas · ${distKm.toStringAsFixed(1)} km'),
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

  double _polylineDistance(List<List<double>> polyline) {
    double d = 0;
    for (int i = 1; i < polyline.length; i++) {
      final dlat = polyline[i][0] - polyline[i - 1][0];
      final dlng = polyline[i][1] - polyline[i - 1][1];
      final latMid = (polyline[i][0] + polyline[i - 1][0]) / 2;
      const mPerLat = 111320.0;
      final mPerLng = 111320 * _cos(latMid * 3.14159 / 180);
      d += ((dlat * mPerLat) * (dlat * mPerLat) + (dlng * mPerLng) * (dlng * mPerLng)).abs();
    }
    return (d > 0 ? (d < 0 ? 0 : d) : 0) / 1000;
  }

  double _cos(double x) {
    double r = 1, t = 1, f = 1;
    for (int i = 2; i <= 10; i += 2) { t *= -x * x; f *= i * (i - 1); r += t / f; }
    return r;
  }

  void _showCreateDialog() {
    _nameCtrl.clear(); _slatCtrl.clear(); _slngCtrl.clear();
    _elatCtrl.clear(); _elngCtrl.clear();
    _slatCtrl.text = '-12.0464'; _slngCtrl.text = '-77.0428';
    _elatCtrl.text = '-12.0430'; _elngCtrl.text = '-77.0370';

    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Nueva Ruta'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre de la ruta')),
        const SizedBox(height: 12),
        const Text('Coordenadas de inicio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Row(children: [
          Expanded(child: TextField(controller: _slatCtrl, decoration: const InputDecoration(labelText: 'Lat', isDense: true), keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _slngCtrl, decoration: const InputDecoration(labelText: 'Lng', isDense: true), keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        const Text('Coordenadas de fin', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Row(children: [
          Expanded(child: TextField(controller: _elatCtrl, decoration: const InputDecoration(labelText: 'Lat', isDense: true), keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _elngCtrl, decoration: const InputDecoration(labelText: 'Lng', isDense: true), keyboardType: TextInputType.number)),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () async {
          final name = OutputSanitizer.sanitizeName(_nameCtrl.text);
          final nameError = Validators.validateRequired(name, 'Nombre');
          if (nameError != null) return;

          final slat = double.tryParse(_slatCtrl.text) ?? 0;
          final slng = double.tryParse(_slngCtrl.text) ?? 0;
          final elat = double.tryParse(_elatCtrl.text) ?? 0;
          final elng = double.tryParse(_elngCtrl.text) ?? 0;

          final directions = await ref.read(directionsProvider((
            slat: slat, slng: slng, elat: elat, elng: elng,
          )).future);

          if (!mounted) return;
          Navigator.pop(context);

          final repo = ref.read(fleetRepositoryProvider);
          final coopId = ref.read(currentCoopIdProvider);

          if (directions != null) {
            repo.updateRoute(RouteEntity(
              id: '',
              cooperativaId: coopId,
              name: name,
              polyline: directions.polyline,
            ));
            ref.invalidate(routesProvider(coopId));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ruta creada: ${(directions.distanceMeters / 1000).toStringAsFixed(1)} km generados por ORS'), backgroundColor: const Color(0xFF001B44)));
          } else {
            repo.updateRoute(RouteEntity(id: '', cooperativaId: coopId, name: name));
            ref.invalidate(routesProvider(coopId));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Ruta creada sin geometría ORS'), backgroundColor: const Color(0xFFFED000)));
          }
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white), child: const Text('Crear con ORS')),
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
