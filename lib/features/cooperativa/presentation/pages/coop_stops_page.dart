import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/domain/entities/stop_entity.dart';
import '../../../../shared/presentation/widgets/live_map_widget.dart';
import '../providers/fleet_provider.dart';

class CoopStopsPage extends ConsumerStatefulWidget {
  const CoopStopsPage({super.key});
  @override
  ConsumerState<CoopStopsPage> createState() => _CoopStopsPageState();
}

class _CoopStopsPageState extends ConsumerState<CoopStopsPage> {
  int _tabIdx = 0;
  late final TextEditingController _nameCtrl;
  LatLng? _newStopPos;

  final _stopsList = [
    {'name': 'Plaza de Armas', 'route': 'Ruta A', 'order': '1', 'lat': -12.045, 'lng': -77.031},
    {'name': 'Jr. de la Union', 'route': 'Ruta A', 'order': '2', 'lat': -12.046, 'lng': -77.032},
    {'name': 'Parque Universitario', 'route': 'Ruta A', 'order': '3', 'lat': -12.047, 'lng': -77.033},
    {'name': 'Parque Kennedy', 'route': 'Ruta B', 'order': '1', 'lat': -12.048, 'lng': -77.034},
    {'name': 'Larcomar', 'route': 'Ruta B', 'order': '2', 'lat': -12.049, 'lng': -77.035},
  ];

  final _requestPins = [
    {'driver': 'Carlos M.', 'lat': -12.0482, 'lng': -77.0410, 'reason': 'Alta demanda'},
    {'driver': 'Luisa R.', 'lat': -12.0492, 'lng': -77.0425, 'reason': 'Zona residencial'},
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _addStop() {
    if (_newStopPos == null || _nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toca el mapa y escribe un nombre'), backgroundColor: Color(0xFFBA1A1A)));
      return;
    }
    setState(() {
      _stopsList.add({'name': _nameCtrl.text.trim(), 'route': 'Nueva', 'order': (_stopsList.length + 1).toString(), 'lat': _newStopPos!.latitude, 'lng': _newStopPos!.longitude});
      _nameCtrl.clear();
      _newStopPos = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parada agregada'), backgroundColor: Color(0xFF001B44)));
  }

  List<StopEntity> _buildStops() => _stopsList.map((s) => StopEntity(id: s['order'] as String, name: s['name'] as String, latitude: (s['lat'] as num).toDouble(), longitude: (s['lng'] as num).toDouble(), orderIndex: int.tryParse(s['order'] as String) ?? 0)).toList();

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingStopRequestsProvider);
    final stops = _buildStops();

    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(children: [
        const Text('Paradas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const Spacer(),
        Container(decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [
          _buildTabBtn(0, 'Mapa'),
          _buildTabBtn(1, 'Solicitudes'),
        ])),
      ])),
      const SizedBox(height: 8),
      Expanded(child: _tabIdx == 0 ? _buildMapView(stops) : _buildRequestsView(pendingAsync)),
    ]);
  }

  Widget _buildTabBtn(int idx, String label) {
    final active = _tabIdx == idx;
    return GestureDetector(onTap: () => setState(() => _tabIdx = idx), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: active ? const Color(0xFF001B44) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: active ? Colors.white : const Color(0xFF434750)))));
  }

  Widget _buildMapView(List<StopEntity> stops) {
    final requestMarkers = _tabIdx == 0 ? _requestPins.map((r) => Marker(
      markerId: MarkerId('req_${r['driver']}'),
      position: LatLng(r['lat'] as double, r['lng'] as double),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: r['driver'] as String, snippet: r['reason'] as String),
    )).toList() : <Marker>[];

    final pinMarkers = _newStopPos != null ? [
      Marker(markerId: const MarkerId('new_stop'), position: _newStopPos!, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), infoWindow: const InfoWindow(title: 'Nueva parada')),
    ] : <Marker>[];

    return Column(children: [
      Expanded(child: LiveMapWidget(
        initialPosition: const CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 14),
        stops: stops,
        extraMarkers: [...requestMarkers, ...pinMarkers],
        onMapTapped: (pos) => setState(() => _newStopPos = pos),
      )),
      Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Nombre de la nueva parada', hintStyle: TextStyle(fontSize: 13, fontFamily: 'Inter'), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Color(0xFFE0E0E0))), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: _addStop, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFED000), foregroundColor: const Color(0xFF001B44), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
      ])),
      SizedBox(height: 160, child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: stops.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
        child: Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFF001B44).withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('${s.orderIndex}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44))))),
          const SizedBox(width: 12),
          Expanded(child: Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: Color(0xFF001B44)))),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF434750)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)), onPressed: () {}),
        ]),
      )).toList())),
    ]);
  }

  Widget _buildRequestsView(AsyncValue<List<Map<String, dynamic>>> async) {
    final mockRequests = [
      {'id': '1', 'driver_name': 'Carlos M.', 'proposed_lat': '-12.0467', 'proposed_lng': '-77.0433', 'justification': 'Alta demanda en la zona', 'created_at': '2026-07-12'},
      {'id': '2', 'driver_name': 'Luisa R.', 'proposed_lat': '-12.0472', 'proposed_lng': '-77.0441', 'justification': 'Zona residencial sin parada', 'created_at': '2026-07-10'},
    ];

    return StatefulBuilder(builder: (context, setLocalState) {
      final reqMarkers = mockRequests.map((r) => Marker(
        markerId: MarkerId('req_${r['id']}'),
        position: LatLng(double.tryParse(r['proposed_lat'] as String) ?? 0, double.tryParse(r['proposed_lng'] as String) ?? 0),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: r['driver_name'] as String, snippet: r['justification'] as String),
      )).toList();

      return ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
        const SizedBox(height: 8),
        SizedBox(height: 160, child: LiveMapWidget(initialPosition: const CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 14), stops: [], extraMarkers: reqMarkers)),
        const SizedBox(height: 12),
        const Text('Solicitudes pendientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 8),
        ...mockRequests.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.location_on, size: 18, color: Color(0xFF001B44)), const SizedBox(width: 6), Expanded(child: Text('${r['proposed_lat']}, ${r['proposed_lng']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')))]),
              const SizedBox(height: 6),
              Text('Conductor: ${r['driver_name']}', style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Color(0xFF434750))),
              Text('Motivo: ${r['justification']}', style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Color(0xFF434750))),
              Text('Fecha: ${r['created_at']}', style: const TextStyle(fontSize: 12, fontFamily: 'Inter', color: Color(0xFF434750))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () { setLocalState(() { mockRequests.remove(r); }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud rechazada'))); }, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A), side: const BorderSide(color: Color(0xFFBA1A1A)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Rechazar', style: TextStyle(fontFamily: 'Inter')))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: () { setLocalState(() { mockRequests.remove(r); }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud aprobada'), backgroundColor: Color(0xFF001B44))); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Aprobar', style: TextStyle(fontFamily: 'Inter')))),
              ]),
            ])),
          ),
        )),
        if (mockRequests.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Sin solicitudes pendientes', style: TextStyle(color: Color(0xFF434750), fontFamily: 'Inter')))),
      ]);
    });
  }
}
