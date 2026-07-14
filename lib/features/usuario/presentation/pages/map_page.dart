import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../../../../shared/domain/entities/route_entity.dart';
import '../../../../shared/domain/entities/stop_entity.dart';
import '../../../../shared/presentation/widgets/live_map_widget.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/eta_repository.dart';
import '../providers/eta_provider.dart';
import '../providers/favorites_provider.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  bool _showStops = false;

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(availableRoutesProvider);
    final selectedRouteId = ref.watch(selectedRouteIdProvider);
    final routeWithBuses = ref.watch(routeWithBusesProvider(selectedRouteId ?? ''));
    final favoritesAsync = ref.watch(favoritesProvider);

    final allRoutes = routesAsync.valueOrNull ?? [];
    final favoriteIds = favoritesAsync.valueOrNull?.where((f) => f.type == FavoriteType.route).map((f) => f.itemId).toSet() ?? {};
    final stops = routeWithBuses.valueOrNull?.route.stops ?? [];
    final buses = _extractBusPositions(routeWithBuses.valueOrNull);

    final favoritePolylines = allRoutes.where((r) => favoriteIds.contains(r.id)).map((r) => Polyline(
      polylineId: PolylineId('fav_${r.id}'),
      points: r.polyline.map((p) => LatLng(p[0], p[1])).toList(),
      color: Colors.yellow.shade700,
      width: 3,
      patterns: [PatternItem.dash(10), PatternItem.gap(5)],
    )).toList();

    final allStops = allRoutes.expand((r) => r.stops).toList();

    return Scaffold(
      body: Stack(children: [
        LiveMapWidget(
          initialPosition: const CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 14),
          buses: buses,
          activeRoute: routeWithBuses.valueOrNull?.route,
          stops: _showStops ? allStops : stops,
          extraPolylines: favoritePolylines,
        ),
        Positioned(top: 56, left: 16, right: 16, child: _buildSearchBar()),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomSheet(allStops, allRoutes)),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Row(children: [
      Expanded(child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 12, offset: Offset(0, 4))]),
        child: TextField(decoration: InputDecoration(hintText: 'Buscar destino o ruta...', hintStyle: const TextStyle(color: Color(0xFF434750), fontSize: 14), prefixIcon: const Icon(Icons.search, color: Color(0xFF001B44)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
      )),
    ]);
  }

  Widget _buildBottomSheet(List<StopEntity> allStops, List<RouteEntity> allRoutes) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final favRoutes = favoritesAsync.valueOrNull?.where((f) => f.type == FavoriteType.route).toList() ?? [];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 16, offset: Offset(0, -4))]),
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 12),
        if (favRoutes.isNotEmpty) ...[
          const Text('Rutas Favoritas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const SizedBox(height: 8),
          SizedBox(height: 50, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: favRoutes.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) {
            final fav = favRoutes[i];
            final selected = ref.watch(selectedRouteIdProvider) == fav.itemId;
            return GestureDetector(onTap: () => ref.read(selectedRouteIdProvider.notifier).state = fav.itemId, child: Chip(
              avatar: Icon(selected ? Icons.star : Icons.star_border, size: 16, color: selected ? const Color(0xFF001B44) : const Color(0xFFFED000)),
              label: Text(fav.name, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? Colors.white : const Color(0xFF001B44), fontFamily: 'Inter')),
              backgroundColor: selected ? const Color(0xFF001B44) : const Color(0xFFFED000).withAlpha(30),
            ));
          })),
          const SizedBox(height: 12),
        ],
        if (allStops.isNotEmpty)
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => setState(() => _showStops = !_showStops),
            icon: Icon(_showStops ? Icons.visibility_off : Icons.place_outlined, size: 18),
            label: Text(_showStops ? 'Ocultar paradas' : 'Ver todas las paradas (${allStops.length})'),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF001B44), side: const BorderSide(color: Color(0xFF001B44)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
          )),
      ]),
    );
  }

  Map<String, BusPosition> _extractBusPositions(RouteWithBuses? r) {
    if (r == null) return {};
    final buses = <String, BusPosition>{};
    for (final BusEntity bus in r.activeBuses) {
      if (bus.latitude != null && bus.longitude != null) {
        buses[bus.id] = BusPosition(position: LatLng(bus.latitude!, bus.longitude!), heading: bus.heading ?? 0, occupancyPct: bus.occupancyPct);
      }
    }
    return buses;
  }
}
