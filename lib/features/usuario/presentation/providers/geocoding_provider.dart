import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/geocoding/nominatim_service.dart';
import '../../../../shared/domain/entities/geocoding_entity.dart';
import '../../../../shared/domain/repositories/geocoding_repository.dart';
import '../../data/datasources/geocoding_remote_datasource.dart';
import '../../data/repositories/geocoding_repository_impl.dart';
import '../../domain/usecases/reverse_geocode_usecase.dart';
import '../../domain/usecases/search_places_usecase.dart';

final nominatimServiceProvider = Provider<NominatimService>((_) => NominatimService());

final geocodingRemoteDataSourceProvider = Provider<GeocodingRemoteDataSource>((ref) {
  return GeocodingRemoteDataSourceImpl(ref.watch(nominatimServiceProvider));
});

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepositoryImpl(ref.watch(geocodingRemoteDataSourceProvider));
});

final reverseGeocodeUseCaseProvider = Provider<ReverseGeocodeUseCase>((ref) {
  return ReverseGeocodeUseCase(ref.watch(geocodingRepositoryProvider));
});

final searchPlacesUseCaseProvider = Provider<SearchPlacesUseCase>((ref) {
  return SearchPlacesUseCase(ref.watch(geocodingRepositoryProvider));
});

final reverseGeocodeProvider = FutureProvider.family<GeocodingEntity?, ({double lat, double lng})>((ref, params) async {
  final uc = ref.watch(reverseGeocodeUseCaseProvider);
  final result = await uc.execute(lat: params.lat, lng: params.lng);
  return result.fold((_) => null, (p) => p);
});

final searchPlacesProvider = FutureProvider.family<GeocodingResultEntity?, String>((ref, query) async {
  if (query.trim().isEmpty) return null;
  final uc = ref.watch(searchPlacesUseCaseProvider);
  final result = await uc.execute(query: query);
  return result.fold((_) => null, (r) => r);
});

final addressLookupProvider = FutureProvider.family<String?, ({double lat, double lng})>((ref, params) async {
  final uc = ref.watch(reverseGeocodeUseCaseProvider);
  final result = await uc.execute(lat: params.lat, lng: params.lng);
  return result.fold((_) => null, (p) => p?.shortAddress);
});
