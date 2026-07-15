import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/maps/tile_provider.dart';
import '../../../admin_municipal/domain/entities/system_alert.dart';
import '../../../admin_municipal/presentation/providers/system_alerts_provider.dart';

class IncidentReportPage extends ConsumerStatefulWidget {
  final String role;
  const IncidentReportPage({super.key, this.role = 'conductor'});
  @override
  ConsumerState<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends ConsumerState<IncidentReportPage> {
  String _incidentType = 'Avería';
  late final TextEditingController _descCtrl;
  LatLng? _pickedLocation;
  final MapController _mapCtrl = MapController();

  static const _types = ['Accidente', 'Avería', 'Congestión', 'Obstrucción', 'Clima', 'Otro'];

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Describe el incidente'), backgroundColor: Color(0xFFBA1A1A)));
      return;
    }
    final repo = ref.read(networkMonitorRepositoryProvider);
    repo.createAlert(SystemAlert(
      id: '',
      scope: 'stop',
      severity: 'medium',
      title: '$_incidentType - ${widget.role}',
      description: _descCtrl.text.trim(),
      createdBy: widget.role,
      latitude: _pickedLocation?.latitude,
      longitude: _pickedLocation?.longitude,
      createdAt: DateTime.now(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incidente reportado'), backgroundColor: Color(0xFF001B44)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Reportar Incidente', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tipo de incidente', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE0E0E0)), borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _incidentType,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF001B44)),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter'),
                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _incidentType = v); },
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Descripción', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe el incidente con detalle...',
                hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Inter'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF001B44))),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Ubicación', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
              const Spacer(),
              Text(_pickedLocation != null ? '${_pickedLocation!.latitude.toStringAsFixed(5)}, ${_pickedLocation!.longitude.toStringAsFixed(5)}' : 'Toca el mapa', style: TextStyle(fontSize: 12, color: _pickedLocation != null ? const Color(0xFF001B44) : const Color(0xFF434750), fontFamily: 'Inter')),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 220,
                child: FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: const LatLng(-12.0464, -77.0428),
                    initialZoom: 14,
                    onTap: (_, p) => setState(() => _pickedLocation = p),
                  ),
                  children: [
                    TileLayer(urlTemplate: OpenStreetMapConfig.defaultUrlTemplate, userAgentPackageName: OpenStreetMapConfig.defaultUserAgent),
                    if (_pickedLocation != null) MarkerLayer(markers: [
                      Marker(point: _pickedLocation!, width: 36, height: 36, child: const Icon(Icons.warning, color: Color(0xFFBA1A1A), size: 36)),
                    ]),
                  ],
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Enviar Incidente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]),
    );
  }
}
