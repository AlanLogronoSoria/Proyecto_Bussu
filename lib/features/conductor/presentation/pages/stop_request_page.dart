import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StopRequestPage extends StatefulWidget {
  const StopRequestPage({super.key});
  @override
  State<StopRequestPage> createState() => _StopRequestPageState();
}

class _StopRequestPageState extends State<StopRequestPage> {
  final _reasonCtrl = TextEditingController();
  final _requests = [
    {'location': 'Jr. de la Unión 450', 'reason': 'Alta demanda de pasajeros', 'status': 'Pendiente', 'date': '12 may'},
    {'location': 'Av. Arequipa 1200', 'reason': 'Nueva zona residencial', 'status': 'Aprobada', 'date': '8 may'},
    {'location': 'Calle Las Flores 300', 'reason': 'Solicitada por vecinos', 'status': 'Rechazada', 'date': '3 may'},
  ];

  @override
  void dispose() { _reasonCtrl.dispose(); super.dispose(); }

  Color _statusColor(String status) => status == 'Aprobada' ? Colors.green : status == 'Rechazada' ? const Color(0xFFBA1A1A) : const Color(0xFFFED000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Solicitar parada', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(height: 180, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), clipBehavior: Clip.antiAlias, child: GoogleMap(initialCameraPosition: const CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 16), myLocationButtonEnabled: true, zoomControlsEnabled: false)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nueva solicitud', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const SizedBox(height: 12),
          TextField(controller: _reasonCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Justificación de la parada...', hintStyle: TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter'), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), filled: true, fillColor: Color(0xFFF8F9FA))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFED000), foregroundColor: const Color(0xFF001B44), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Enviar solicitud', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter')))),
        ])),
        const SizedBox(height: 16),
        const Text('Solicitudes previas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 8),
        ..._requests.map((r) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Row(children: [
          Container(width: 4, height: 48, decoration: BoxDecoration(color: _statusColor(r['status']!), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r['location']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            Text(r['reason']!, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _statusColor(r['status']!).withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Text('${r['status']} · ${r['date']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(r['status']!), fontFamily: 'Inter'))),
        ]))),
      ]),
    );
  }
}
