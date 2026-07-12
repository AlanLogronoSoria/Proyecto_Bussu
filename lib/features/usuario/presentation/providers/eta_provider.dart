import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/route_entity.dart';
import '../../domain/repositories/eta_repository.dart';

/// Provider del repositorio ETA.
final etaRepositoryProvider = Provider<EtaRepository>((_) {
  throw UnimplementedError('Registra en injection_container');
});

/// Provider de la ruta seleccionada.
final selectedRouteIdProvider = StateProvider.autoDispose<String?>((ref) => null);

/// Rutas disponibles.
final availableRoutesProvider =
    FutureProvider<List<RouteEntity>>((ref) async {
  final repo = ref.watch(etaRepositoryProvider);
  final result = await repo.getAvailableRoutes();
  return result.fold(
    (_) => [],
    (routes) => routes,
  );
});

/// ETA de un bus a las paradas de su ruta.
final etaStreamProvider = StreamProvider.family<
    Map<String, Duration>, ({String busId, String routeId})>((ref, params) {
  final repo = ref.watch(etaRepositoryProvider);
  return repo.watchEtas(
    busId: params.busId,
    routeId: params.routeId,
  ).where((either) => either.isRight()).map((either) => either.fold(
        (_) => <String, Duration>{},
        (etas) => etas,
      ));
});

/// Ruta con sus buses activos.
final routeWithBusesProvider =
    FutureProvider.family<RouteWithBuses?, String>((ref, routeId) async {
  final repo = ref.watch(etaRepositoryProvider);
  final result = await repo.getRouteWithBuses(routeId);
  return result.fold(
    (_) => null,
    (data) => data,
  );
});
