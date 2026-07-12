import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/favorite_entity.dart';
import '../providers/eta_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.star_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16), const Text('No tienes favoritos'),
                const SizedBox(height: 8),
                Text('Marca rutas y paradas como favoritas', style: TextStyle(color: Colors.grey[600])),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16), itemCount: favorites.length,
            prototypeItem: const ListTile(leading: Icon(Icons.star), title: Text(' ')),
            itemBuilder: (_, i) {
              final fav = favorites[i];
              return Card(child: ListTile(
                leading: Icon(fav.type == FavoriteType.route ? Icons.route : Icons.place, color: AppTheme.primary),
                title: Text(fav.name),
                subtitle: Text(fav.type == FavoriteType.route ? 'Ruta' : 'Parada'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (fav.type == FavoriteType.route) {
                    ref.read(selectedRouteIdProvider.notifier).state = fav.itemId;
                    Navigator.of(context).pushNamed('/usuario/map');
                  }
                },
              ));
            },
          );
        },
      ),
    );
  }
}
