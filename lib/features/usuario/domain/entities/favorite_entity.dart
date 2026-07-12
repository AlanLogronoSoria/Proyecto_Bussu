import '../../../../core/constants/app_roles.dart';

/// Ruta o parada marcada como favorita por el usuario.
class FavoriteEntity {
  final String id;
  final String userId;
  final String itemId;
  final FavoriteType type;
  final String name;
  final DateTime createdAt;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.name,
    required this.createdAt,
  });

  FavoriteEntity copyWith({
    String? id,
    String? userId,
    String? itemId,
    FavoriteType? type,
    String? name,
    DateTime? createdAt,
  }) {
    return FavoriteEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum FavoriteType { route, stop }
