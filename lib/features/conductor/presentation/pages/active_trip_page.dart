import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/domain/entities/route_entity.dart';
import '../../../../shared/domain/entities/stop_entity.dart';
import '../../../../shared/presentation/widgets/live_map_widget.dart';
import '../providers/trip_provider.dart';
import 'driver_dashboard_page.dart';

class ActiveTripPage extends ConsumerStatefulWidget {
  const ActiveTripPage({super.key});
  @override
  ConsumerState<ActiveTripPage> createState() => _ActiveTripPageState();
}

class _ActiveTripPageState extends ConsumerState<ActiveTripPage> {
  int _passengerCount = 0;
  bool _routeStarted = false;
  LatLng? _stopRequestPin;

  final RouteEntity _mockRoute = RouteEntity(
    id: 'route-a', name: 'Ruta A - Centro',
    polyline: const [[-12.0464, -77.0428], [-12.0450, -77.0410], [-12.0440, -77.0390], [-12.0430, -77.0370]],
    stops: [
      const StopEntity(id: 's1', name: 'Plaza de Armas', latitude: -12.0464, longitude: -77.0428, orderIndex: 1),
      const StopEntity(id: 's2', name: 'Jr. de la Union', latitude: -12.0452, longitude: -77.0410, orderIndex: 2),
      const StopEntity(id: 's3', name: 'Parque Universitario', latitude: -12.0440, longitude: -77.0390, orderIndex: 3),
    ],
  );

  void _confirmPassengerChange(int newCount) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Confirmar cambio', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      content: Text('¿Cambiar conteo de $_passengerCount a $newCount pasajeros?', style: const TextStyle(fontFamily: 'Inter')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () { setState(() => _passengerCount = newCount); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44)), child: const Text('Confirmar')),
      ],
    ));
  }

  void _endTrip() {
    ref.read(tripActiveProvider.notifier).state = false;
    ref.read(endTripUseCaseProvider).execute('current-trip');
  }

  @override
  Widget build(BuildContext context) {
    final hasActive = ref.watch(hasActiveTripProvider);
    if (!hasActive) return const DriverDashboardPage();

    final extraMarkers = <Marker>[];
    if (_stopRequestPin != null) {
      extraMarkers.add(Marker(
        markerId: const MarkerId('stop_request'),
        position: _stopRequestPin!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Solicitud de parada'),
      ));
    }

    return Scaffold(
      body: Stack(children: [
        LiveMapWidget(
          initialPosition: const CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 15),
          activeRoute: _routeStarted ? _mockRoute : null,
          stops: _routeStarted ? _mockRoute.stops : [],
          extraMarkers: extraMarkers,
          onMapTapped: (pos) { if (_routeStarted) setState(() => _stopRequestPin = pos); },
        ),
        Positioned(top: 56, left: 16, right: 16, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _routeStarted ? const Color(0xFFFED000) : Colors.grey[300]!, borderRadius: BorderRadius.circular(8)), child: Text(_routeStarted ? 'En Ruta' : 'Detenido', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _routeStarted ? const Color(0xFF001B44) : const Color(0xFF434750), fontFamily: 'Inter'))),
          const SizedBox(width: 12),
          const Expanded(child: Text('Próxima: Plaza de Armas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
        ]))),
        if (!_routeStarted) Positioned.fill(child: Center(child: ElevatedButton.icon(
          onPressed: () => setState(() => _routeStarted = true),
          icon: const Icon(Icons.play_circle, size: 28),
          label: const Text('Iniciar ruta'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
        ))),
        if (_routeStarted) Positioned(bottom: 0, left: 0, right: 0, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 16, offset: Offset(0, -4))]), padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 12),
          Row(children: [
            if (_stopRequestPin != null) ...[
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Text('${_stopRequestPin!.latitude.toStringAsFixed(5)}, ${_stopRequestPin!.longitude.toStringAsFixed(5)}', style: const TextStyle(fontSize: 11, fontFamily: 'Inter', color: Color(0xFF001B44)))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud de parada enviada'), backgroundColor: Color(0xFF001B44))); setState(() => _stopRequestPin = null); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), textStyle: const TextStyle(fontSize: 12)), child: const Text('Enviar solicitud')),
            ] else ...[
              const Text('Toca el mapa para solicitar una parada', style: TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
            ],
          ]),
          const SizedBox(height: 16),
          const Text('Pasajeros a bordo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF434750), fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton.filled(onPressed: () => _confirmPassengerChange((_passengerCount - 1).clamp(0, 40)), icon: const Icon(Icons.remove), style: IconButton.styleFrom(backgroundColor: const Color(0xFF001B44).withAlpha(20), foregroundColor: const Color(0xFF001B44))),
            const SizedBox(width: 24),
            Text('$_passengerCount', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const SizedBox(width: 24),
            IconButton.filled(onPressed: () => _confirmPassengerChange((_passengerCount + 1).clamp(0, 40)), icon: const Icon(Icons.add), style: IconButton.styleFrom(backgroundColor: const Color(0xFF001B44).withAlpha(20), foregroundColor: const Color(0xFF001B44))),
          ]),
          const SizedBox(height: 4),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _passengerCount / 40, minHeight: 6, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(Color(0xFFFED000)))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _endTrip, icon: const Icon(Icons.stop_circle, size: 18), label: const Text('Finalizar viaje'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        ]))),
      ]),
    );
  }
}
