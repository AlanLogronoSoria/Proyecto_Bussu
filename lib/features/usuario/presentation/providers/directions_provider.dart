import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/entities/directions_entity.dart';
import '../../../../shared/domain/repositories/directions_repository.dart';
import '../../data/datasources/directions_remote_datasource.dart';
import '../../data/repositories/directions_repository_impl.dart';
import '../../domain/usecases/get_directions_usecase.dart';
import '../../../../core/navigation/ors_service.dart';

final orsServiceProvider = Provider<OrsService>((_) {
  return OrsService(apiKey: const String.fromEnvironment('ORS_API_KEY', defaultValue: ''));
});

final directionsRemoteDataSourceProvider = Provider<DirectionsRemoteDataSource>((ref) {
  return DirectionsRemoteDataSourceImpl(ref.watch(orsServiceProvider));
});

final directionsRepositoryProvider = Provider<DirectionsRepository>((ref) {
  return DirectionsRepositoryImpl(ref.watch(directionsRemoteDataSourceProvider));
});

final getDirectionsUseCaseProvider = Provider<GetDirectionsUseCase>((ref) {
  return GetDirectionsUseCase(ref.watch(directionsRepositoryProvider));
});

final directionsProvider = FutureProvider.family<DirectionsEntity?, ({double slat, double slng, double elat, double elng})>((ref, params) async {
  final useCase = ref.watch(getDirectionsUseCaseProvider);
  final result = await useCase.execute(
    startLat: params.slat, startLng: params.slng,
    endLat: params.elat, endLng: params.elng,
  );
  return result.fold((_) => null, (d) => d);
});
