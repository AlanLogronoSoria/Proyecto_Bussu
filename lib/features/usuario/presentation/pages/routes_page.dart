import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/entities/route_entity.dart';
import '../../domain/entities/favorite_entity.dart';
import '../providers/eta_provider.dart';
import '../providers/favorites_provider.dart';

class RoutesPage extends ConsumerWidget {
  const RoutesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(availableRoutesProvider);
    final favorites = ref.watch(favoritesProvider);
    final selectedRouteId = ref.watch(selectedRouteIdProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Routes', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _buildSearchBar(),
        const SizedBox(height: 20),
        _buildSection('Favoritos', favorites.valueOrNull ?? [], selectedRouteId, ref),
        const SizedBox(height: 20),
        _buildSection('Todas las rutas', routesAsync.valueOrNull ?? [], selectedRouteId, ref),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Row(children: [
      Expanded(child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, 2))]),
        child: TextField(
          decoration: InputDecoration(hintText: '¿A dónde vas?', hintStyle: const TextStyle(color: Color(0xFF434750), fontSize: 14, fontFamily: 'Inter'), prefixIcon: const Icon(Icons.search, color: Color(0xFF001B44)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      )),
      const SizedBox(width: 12),
      Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFED000), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.directions, color: Color(0xFF001B44))),
    ]);
  }

  Widget _buildSection(String title, List<dynamic> items, String? selectedRouteId, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 8),
      ...items.map((item) {
        final isFavorite = title == 'Favoritos';
        final name = isFavorite ? (item as FavoriteEntity).name : (item as RouteEntity).name;
        final id = isFavorite ? (item as FavoriteEntity).itemId : (item as RouteEntity).id;
        final color = isFavorite ? '#001B44' : (item as RouteEntity).color;
        final subtitle = isFavorite ? 'Favorito' : '${(item as RouteEntity).stops.length} paradas';
        final isSelected = selectedRouteId == id;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFFFED000).withAlpha(25) : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, 2))], border: isSelected ? Border.all(color: const Color(0xFFFED000), width: 1.5) : null),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ref.read(selectedRouteIdProvider.notifier).state = id;
            },
            child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
              Container(width: 4, height: 40, decoration: BoxDecoration(color: Color(int.parse('FF${color.replaceAll('#', '')}', radix: 16)), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
              ])),
              const Icon(Icons.chevron_right, color: Color(0xFF434750)),
            ])),
          ),
        );
      }),
    ]);
  }
}
