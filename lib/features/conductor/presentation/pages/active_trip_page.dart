import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActiveTripPage extends StatefulWidget {
  const ActiveTripPage({super.key});
  @override
  State<ActiveTripPage> createState() => _ActiveTripPageState();
}

class _ActiveTripPageState extends State<ActiveTripPage> {
  int _passengerCount = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(initialCameraPosition: const CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 15)),
          Positioned(top: 56, left: 16, right: 16, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFED000), borderRadius: BorderRadius.circular(8)), child: const Text('En Ruta', style: TextStyle(color: Color(0xFF001B44), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
            const SizedBox(width: 12),
            const Expanded(child: Text('Próxima: Plaza de Armas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
            const Text('1.2 km', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
          ]))),
          Positioned(bottom: 0, left: 0, right: 0, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 16, offset: Offset(0, -4))]), padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Pasajeros a bordo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF434750), fontFamily: 'Inter')),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton.filled(onPressed: () => setState(() => _passengerCount = (_passengerCount - 1).clamp(0, 40)), icon: const Icon(Icons.remove), style: IconButton.styleFrom(backgroundColor: const Color(0xFF001B44).withAlpha(20), foregroundColor: const Color(0xFF001B44))),
              const SizedBox(width: 24),
              Text('$_passengerCount', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
              const SizedBox(width: 24),
              IconButton.filled(onPressed: () => setState(() => _passengerCount = (_passengerCount + 1).clamp(0, 40)), icon: const Icon(Icons.add), style: IconButton.styleFrom(backgroundColor: const Color(0xFF001B44).withAlpha(20), foregroundColor: const Color(0xFF001B44))),
            ]),
            const SizedBox(height: 2),
            Text('/ 40 capacidad', style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _passengerCount / 40, minHeight: 6, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(Color(0xFFFED000)))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.warning_amber, size: 18), label: const Text('Incidente'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFBA1A1A), side: const BorderSide(color: Color(0xFFBA1A1A)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.stop_circle, size: 18), label: const Text('Finalizar'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            ]),
          ]))),
        ],
      ),
    );
  }
}
