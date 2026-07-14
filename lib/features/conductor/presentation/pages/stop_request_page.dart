import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/trip_provider.dart';

class StopRequestPage extends ConsumerStatefulWidget {
  const StopRequestPage({super.key});
  @override
  ConsumerState<StopRequestPage> createState() => _StopRequestPageState();
}

class _StopRequestPageState extends ConsumerState<StopRequestPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  LatLng? _position;
  bool _hasBench = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _position == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una ubicación y escribe un nombre')));
      return;
    }
    setState(() => _sending = true);
    final uc = ref.read(requestNewStopUseCaseProvider);
    final result = await uc.execute(driverId: 'current-driver', lat: _position!.latitude, lng: _position!.longitude, reason: '${_nameCtrl.text}\n${_descCtrl.text}\nBanca: ${_hasBench ? "si" : "no"}');
    if (!mounted) return;
    setState(() => _sending = false);
    result.fold(
      (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar solicitud'), backgroundColor: Color(0xFFBA1A1A))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada a stop_requests'), backgroundColor: Color(0xFF001B44)));
        _nameCtrl.clear();
        _descCtrl.clear();
        setState(() { _position = null; _hasBench = false; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Solicitar parada', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          height: 240,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            const GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 15), zoomControlsEnabled: false),
            if (_position != null) Center(child: const Icon(Icons.location_pin, size: 40, color: Color(0xFF001B44))),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => setState(() => _position = const LatLng(-12.0464, -77.0428)), icon: const Icon(Icons.my_location, size: 18), label: const Text('Mi ubicación'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        ]),
        const SizedBox(height: 20),
        TextFormField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Nombre de la parada', hintText: 'Ej: Av. La Marina cdra 5', labelStyle: const TextStyle(color: Color(0xFF001B44), fontFamily: 'Inter'), hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Inter'), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF001B44))))),
        const SizedBox(height: 14),
        TextFormField(controller: _descCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Descripción', hintText: 'Referencias, tipo de pavimento, etc.', labelStyle: const TextStyle(color: Color(0xFF001B44), fontFamily: 'Inter'), hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Inter'), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF001B44))))),
        const SizedBox(height: 14),
        SwitchListTile(title: const Text('Cuenta con banca', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44))), value: _hasBench, onChanged: (v) => setState(() => _hasBench = v), activeColor: const Color(0xFF001B44), dense: true, contentPadding: EdgeInsets.zero),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _sending ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFED000), foregroundColor: const Color(0xFF001B44), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')), child: Text(_sending ? 'Enviando...' : 'Enviar solicitud'))),
      ]),
    );
  }
}
