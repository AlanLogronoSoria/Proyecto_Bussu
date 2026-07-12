import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/bus_entity.dart';
import '../../domain/repositories/bus_tracking_repository.dart';
import '../../domain/usecases/watch_bus_position_usecase.dart';

/// Provider del repositorio de tracking.
final busTrackingRepositoryProvider = Provider<BusTrackingRepository>((_) {
  throw UnimplementedError('Registra en injection_container');
});

/// Provider del caso de uso de watch position.
final watchBusPositionUseCaseProvider =
    Provider<WatchBusPositionUseCase>((ref) {
  return WatchBusPositionUseCase(ref.watch(busTrackingRepositoryProvider));
});

/// Stream de posición de un bus específico.
final busPositionProvider =
    StreamProvider.family<Either<Failure, BusEntity>, String>((ref, busId) {
  final useCase = ref.watch(watchBusPositionUseCaseProvider);
  return useCase.execute(busId);
});

/// Stream de buses activos en una ruta.
final routeBusesProvider = StreamProvider.family<
    Either<Failure, List<BusEntity>>, String>((ref, routeId) {
  final repo = ref.watch(busTrackingRepositoryProvider);
  return repo.watchRouteBuses(routeId);
});

/// Provider del bus seleccionado por el usuario.
final selectedBusIdProvider = StateProvider.autoDispose<String?>((ref) => null);
