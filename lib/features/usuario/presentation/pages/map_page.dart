import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../../../../shared/domain/entities/route_entity.dart';
import '../../../../shared/presentation/widgets/live_map_widget.dart';
import '../../domain/repositories/eta_repository.dart';
import '../providers/eta_provider.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(availableRoutesProvider);
    final selectedRouteId = ref.watch(selectedRouteIdProvider);
    final routeWithBuses = ref.watch(routeWithBusesProvider(selectedRouteId ?? ''));

    return Scaffold(
      body: Stack(
        children: [
          LiveMapWidget(
            initialPosition: const CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 14),
            buses: _extractBusPositions(routeWithBuses.valueOrNull),
            activeRoute: routeWithBuses.valueOrNull?.route,
            stops: routeWithBuses.valueOrNull?.route.stops ?? [],
          ),
          Positioned(top: 56, left: 16, right: 16, child: _SearchBar()),
          Positioned(bottom: 0, left: 0, right: 0, child: _BusBottomSheet(routeWithBuses: routeWithBuses.valueOrNull)),
        ],
      ),
    );
  }

  Map<String, BusPosition> _extractBusPositions(RouteWithBuses? r) {
    if (r == null) return {};
    final buses = <String, BusPosition>{};
    for (final BusEntity bus in r.activeBuses) {
      if (bus.latitude != null && bus.longitude != null) {
        buses[bus.id] = BusPosition(
          position: LatLng(bus.latitude!, bus.longitude!),
          heading: bus.heading ?? 0,
          occupancyPct: bus.occupancyPct,
        );
      }
    }
    return buses;
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 12, offset: Offset(0, 4))]),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar destino o ruta...',
          hintStyle: const TextStyle(color: Color(0xFF434750), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF001B44)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _BusBottomSheet extends StatelessWidget {
  final dynamic routeWithBuses;
  const _BusBottomSheet({this.routeWithBuses});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 16, offset: Offset(0, -4))]),
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFED000), borderRadius: BorderRadius.circular(12)), child: const Text('En Ruta', style: TextStyle(color: Color(0xFF001B44), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
          const Spacer(),
          const Icon(Icons.directions_bus, color: Color(0xFF001B44), size: 28),
          const SizedBox(width: 8),
          const Text('ABC-123', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        ]),
        const SizedBox(height: 8),
        const Text('Ruta A - Centro Histórico', style: TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
        const SizedBox(height: 16),
        const Text('12 min', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter', height: 1)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Ocupación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.45, minHeight: 8, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(Color(0xFFFED000)))),
            const SizedBox(height: 4),
            const Text('45% Ocupado · 18/40', style: TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
          ])),
        ]),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.place_outlined, size: 18), label: const Text('Ver paradas'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF001B44), side: const BorderSide(color: Color(0xFF001B44)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)))),
      ]),
    );
  }
}
