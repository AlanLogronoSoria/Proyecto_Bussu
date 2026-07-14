import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/maps/tile_provider.dart';
import '../../../../shared/presentation/widgets/live_map_widget.dart';
import '../../../usuario/presentation/providers/geocoding_provider.dart';
import '../../domain/entities/system_alert.dart';
import '../providers/system_alerts_provider.dart';

class AdminReportsPage extends ConsumerStatefulWidget {
  const AdminReportsPage({super.key});
  @override
  ConsumerState<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends ConsumerState<AdminReportsPage> {
  late final TextEditingController _titleCtrl, _descCtrl, _latCtrl, _lngCtrl;
  SystemAlert? _selected;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(); _descCtrl = TextEditingController();
    _latCtrl = TextEditingController(); _lngCtrl = TextEditingController();
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _latCtrl.dispose(); _lngCtrl.dispose(); super.dispose(); }

  void _createIncident() {
    _titleCtrl.clear(); _descCtrl.clear(); _latCtrl.clear(); _lngCtrl.clear();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Nuevo Incidente', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        const Text('Ubicación (opcional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Row(children: [
          Expanded(child: TextField(controller: _latCtrl, decoration: const InputDecoration(labelText: 'Lat', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _lngCtrl, decoration: const InputDecoration(labelText: 'Lng', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.number)),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          final lat = double.tryParse(_latCtrl.text);
          final lng = double.tryParse(_lngCtrl.text);
          final repo = ref.read(networkMonitorRepositoryProvider);
          repo.createAlert(SystemAlert(id: '', scope: 'system', severity: 'medium', title: _titleCtrl.text, description: _descCtrl.text, latitude: lat, longitude: lng, createdAt: DateTime.now()));
          Navigator.pop(context);
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44)), child: const Text('Crear')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(systemAlertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton(onPressed: _createIncident, backgroundColor: const Color(0xFF001B44), child: const Icon(Icons.add, color: Colors.white)),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 0), child: Row(children: [
          const Text('Reportes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF001B44).withAlpha(20), borderRadius: BorderRadius.circular(8)), child: const Text('Incidentes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
        ])),
        const SizedBox(height: 12),
        Expanded(child: alertsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
          error: (_, __) => const Center(child: Text('Error al cargar incidentes')),
          data: (alerts) => ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: alerts.length + 1, itemBuilder: (_, i) {
            if (i == 0 && _selected != null) return _buildIncidentDetail();
            final idx = _selected != null ? i - 1 : i;
            if (idx >= alerts.length) return const SizedBox.shrink();
            final a = alerts[idx];
            return _buildIncidentCard(a, ref);
          }),
        )),
      ]),
    );
  }

  Widget _buildIncidentCard(SystemAlert a, WidgetRef ref) {
    final color = a.severity == 'high' ? const Color(0xFFBA1A1A) : a.severity == 'medium' ? const Color(0xFFFED000) : Colors.blue;
    final addressAsync = a.latitude != null && a.longitude != null
        ? ref.watch(addressLookupProvider((lat: a.latitude!, lng: a.longitude!))).valueOrNull
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: a.isResolved ? Colors.grey.shade100 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
      child: InkWell(
        onTap: () => setState(() => _selected = _selected?.id == a.id ? null : a),
        borderRadius: BorderRadius.circular(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 4, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10),
            Expanded(child: Text(a.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF001B44), fontFamily: 'Inter', decoration: a.isResolved ? TextDecoration.lineThrough : null))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: a.isResolved ? Colors.green.withAlpha(20) : const Color(0xFFBA1A1A).withAlpha(20), borderRadius: BorderRadius.circular(6)), child: Text(a.isResolved ? 'Resuelto' : 'Pendiente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: a.isResolved ? Colors.green.shade700 : const Color(0xFFBA1A1A)))),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 18, color: _selected?.id == a.id ? const Color(0xFF001B44) : Colors.grey),
            if (!a.isResolved) PopupMenuButton(itemBuilder: (_) => [
              const PopupMenuItem(value: 'resolve', child: Text('Resolver')),
              const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Color(0xFFBA1A1A)))),
            ], onSelected: (v) {}),
          ]),
          const SizedBox(height: 6),
          Text(a.description, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4),
            Text(a.createdBy ?? 'Admin', style: const TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter')),
            const SizedBox(width: 12),
            Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600), const SizedBox(width: 4),
            Text(_fmt(a.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter')),
            if (a.latitude != null && a.longitude != null) ...[
              const Spacer(),
              const Icon(Icons.location_on, size: 14, color: Color(0xFF001B44)),
              const SizedBox(width: 2),
              Flexible(child: Text(addressAsync ?? 'Cargando...', style: const TextStyle(fontSize: 11, color: Color(0xFF001B44), fontFamily: 'Inter'), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ]),
        ]),
      ),
    );
  }

  Widget _buildIncidentDetail() {
    final a = _selected!;
    final hasLocation = a.latitude != null && a.longitude != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (hasLocation) ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: SizedBox(
            height: 180,
            child: FlutterMap(
              options: MapOptions(initialCenter: LatLng(a.latitude!, a.longitude!), initialZoom: 16),
              children: [
                TileLayer(urlTemplate: OpenStreetMapConfig.defaultUrlTemplate, userAgentPackageName: OpenStreetMapConfig.defaultUserAgent),
                MarkerLayer(markers: [
                  Marker(point: LatLng(a.latitude!, a.longitude!), width: 40, height: 40, child: const Icon(Icons.warning, color: Color(0xFFBA1A1A), size: 32)),
                ]),
              ],
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Text(a.description, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
          const SizedBox(height: 10),
          Row(children: [const Icon(Icons.person, size: 16, color: Color(0xFF434750)), const SizedBox(width: 4), Text(a.createdBy ?? 'Admin', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))]),
          if (hasLocation) ...[
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.location_on, size: 16, color: Color(0xFF001B44)), const SizedBox(width: 4), Expanded(child: Text('${a.latitude!.toStringAsFixed(5)}, ${a.longitude!.toStringAsFixed(5)}', style: const TextStyle(fontSize: 13, color: Color(0xFF001B44), fontFamily: 'Inter')))]),
          ],
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.calendar_today, size: 14, color: Color(0xFF434750)), const SizedBox(width: 4), Text(_fmt(a.createdAt), style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))]),
        ])),
      ]),
    );
  }

  String _fmt(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
