import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/maps/tile_provider.dart';
import '../../../admin_municipal/presentation/providers/system_alerts_provider.dart';
import '../../../admin_municipal/domain/entities/system_alert.dart' as s;

class CoopReportsPage extends ConsumerStatefulWidget {
  const CoopReportsPage({super.key});
  @override
  ConsumerState<CoopReportsPage> createState() => _CoopReportsPageState();
}

class _CoopReportsPageState extends ConsumerState<CoopReportsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  SystemAlert? _selectedIncident;
  String _incidentFilter = 'all';

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(padding: EdgeInsets.fromLTRB(16, 20, 16, 0), child: Text('Reportes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter'))),
      const SizedBox(height: 12),
      TabBar(controller: _tabCtrl, labelColor: const Color(0xFF001B44), unselectedLabelColor: const Color(0xFF434750), indicatorColor: const Color(0xFFFED000), labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13), tabs: const [
        Tab(text: 'Historial Arduino'),
        Tab(text: 'Incidentes'),
        Tab(text: 'Buses Activos'),
      ]),
      Expanded(child: TabBarView(controller: _tabCtrl, children: [
        _buildArduinoHistory(),
        _buildIncidentsTab(),
        _buildActiveBuses(),
      ])),
    ]);
  }

  Widget _buildIncidentsTab() {
    final alertsAsync = ref.watch(systemAlertsProvider);
    if (_selectedIncident != null) return _buildIncidentMap();
    return alertsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
      error: (_, __) => const Center(child: Text('Error')),
      data: (alerts) {
        final filtered = _incidentFilter == 'all'
            ? alerts
            : alerts.where((a) => a.severity == _incidentFilter).toList();
        return ListView(padding: const EdgeInsets.all(16), children: [
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            _filterChip('Todos', 'all'), const SizedBox(width: 8),
            _filterChip('Alta', 'high'), const SizedBox(width: 8),
            _filterChip('Media', 'medium'), const SizedBox(width: 8),
            _filterChip('Baja', 'low'),
          ])),
          const SizedBox(height: 12),
          ...filtered.map((a) => _buildIncidentCard(a)),
        ]);
      },
    );
  }

  Widget _filterChip(String label, String value) {
    final active = _incidentFilter == value;
    final color = value == 'high' ? const Color(0xFFBA1A1A) : value == 'medium' ? const Color(0xFFFED000) : value == 'low' ? Colors.blue : const Color(0xFF001B44);
    return GestureDetector(onTap: () => setState(() => _incidentFilter = value), child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: active ? color : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? color : const Color(0xFFE0E0E0))),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: active ? Colors.white : const Color(0xFF434750))),
    ));
  }

  Widget _buildIncidentCard(SystemAlert a) {
    final color = a.severity == 'high' ? const Color(0xFFBA1A1A) : a.severity == 'medium' ? const Color(0xFFFED000) : Colors.blue;
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
      child: InkWell(
        onTap: () => setState(() => _selectedIncident = a),
        borderRadius: BorderRadius.circular(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 4, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10),
            Expanded(child: Text(a.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF001B44), fontFamily: 'Inter', decoration: a.isResolved ? TextDecoration.lineThrough : null))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: a.isResolved ? Colors.green.withAlpha(20) : const Color(0xFFBA1A1A).withAlpha(20), borderRadius: BorderRadius.circular(6)), child: Text(a.isResolved ? 'Resuelto' : 'Pendiente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: a.isResolved ? Colors.green.shade700 : const Color(0xFFBA1A1A)))),
          ]),
          const SizedBox(height: 6),
          Text(a.description, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4),
            Text(a.createdBy ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter')),
            const Spacer(),
            if (a.latitude != null) const Icon(Icons.location_on, size: 14, color: Color(0xFF001B44)),
            if (a.latitude != null) const SizedBox(width: 2),
            if (a.latitude != null) Text('Ver ubicación', style: const TextStyle(fontSize: 11, color: Color(0xFF001B44), fontFamily: 'Inter')),
          ]),
        ]),
      ),
    );
  }

  Widget _buildIncidentMap() {
    final a = _selectedIncident!;
    final hasLocation = a.latitude != null && a.longitude != null;
    return Column(children: [
      if (hasLocation) SizedBox(
        height: 200,
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
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 24, decoration: BoxDecoration(color: a.severity == 'high' ? const Color(0xFFBA1A1A) : a.severity == 'medium' ? const Color(0xFFFED000) : Colors.blue, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(child: Text(a.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
          IconButton(onPressed: () => setState(() => _selectedIncident = null), icon: const Icon(Icons.close, color: Color(0xFF434750))),
        ]),
        const SizedBox(height: 8),
        Text(a.description, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
        const SizedBox(height: 10),
        if (hasLocation) Row(children: [const Icon(Icons.location_on, size: 16, color: Color(0xFF001B44)), const SizedBox(width: 4), Text('${a.latitude!.toStringAsFixed(5)}, ${a.longitude!.toStringAsFixed(5)}', style: const TextStyle(fontSize: 13, color: Color(0xFF001B44), fontFamily: 'Inter'))]),
        const SizedBox(height: 4),
        Row(children: [const Icon(Icons.person, size: 16, color: Color(0xFF434750)), const SizedBox(width: 4), Text(a.createdBy ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))]),
        const SizedBox(height: 4),
        Text('${a.createdAt.year}-${a.createdAt.month.toString().padLeft(2, '0')}-${a.createdAt.day.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
      ])),
    ]);
  }

  Widget _buildArduinoHistory() {
    const logs = [
      {'bus': 'ABC-123', 'status': 'OK', 'oil_pressure': '32 PSI', 'rpm': '1200', 'temp': '92°C', 'time': '10:42'},
      {'bus': 'ABC-124', 'status': 'OK', 'oil_pressure': '30 PSI', 'rpm': '1350', 'temp': '88°C', 'time': '10:38'},
      {'bus': 'DEF-456', 'status': 'WARN', 'oil_pressure': '25 PSI', 'rpm': '980', 'temp': '105°C', 'time': '10:35'},
    ];
    final rows = logs.map((l) => DataRow(cells: [
      DataCell(Text(l['bus']!, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
      DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: l['status'] == 'WARN' ? const Color(0xFFBA1A1A).withAlpha(20) : Colors.green.withAlpha(20), borderRadius: BorderRadius.circular(4)), child: Text(l['status']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: l['status'] == 'WARN' ? const Color(0xFFBA1A1A) : Colors.green.shade700)))),
      DataCell(Text(l['oil_pressure']!, style: const TextStyle(fontFamily: 'Inter'))),
      DataCell(Text(l['rpm']!, style: const TextStyle(fontFamily: 'Inter'))),
      DataCell(Text(l['temp']!, style: const TextStyle(fontFamily: 'Inter'))),
      DataCell(Text(l['time']!, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF434750)))),
    ])).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [
        DataColumn(label: Text('Bus', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Aceite', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('RPM', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Temp', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Hora', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
      ], rows: rows))),
    ]);
  }

  Widget _buildActiveBuses() {
    const buses = [
      {'plate': 'ABC-123', 'driver': 'Carlos M.', 'route': 'Ruta A', 'occupancy': '45%', 'status': 'En ruta'},
      {'plate': 'ABC-124', 'driver': 'Luisa R.', 'route': 'Ruta B', 'occupancy': '22%', 'status': 'En ruta'},
      {'plate': 'DEF-456', 'driver': 'Ana V.', 'route': 'Ruta C', 'occupancy': '60%', 'status': 'En ruta'},
    ];
    final busRows = buses.map((b) => DataRow(cells: [
      DataCell(Text(b['plate']!, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', color: Color(0xFF001B44)))),
      DataCell(Text(b['driver']!, style: const TextStyle(fontFamily: 'Inter'))),
      DataCell(Text(b['route']!, style: const TextStyle(fontFamily: 'Inter'))),
      DataCell(Text(b['occupancy']!, style: const TextStyle(fontFamily: 'Inter'))),
      DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: b['status'] == 'En ruta' ? Colors.green.withAlpha(20) : Colors.orange.withAlpha(30), borderRadius: BorderRadius.circular(6)), child: Text(b['status']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: b['status'] == 'En ruta' ? Colors.green.shade700 : Colors.orange.shade800)))),
    ])).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [
        DataColumn(label: Text('Placa', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Conductor', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Ruta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Ocup.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
      ], rows: busRows))),
    ]);
  }
}

typedef SystemAlert = s.SystemAlert;
