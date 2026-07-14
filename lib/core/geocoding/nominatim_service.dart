import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const int _maxRetries = 2;
  static const Duration _cacheTtl = Duration(minutes: 60);

  final http.Client _client;
  final Map<String, _CachedResult> _cache = {};

  NominatimService({http.Client? client}) : _client = client ?? http.Client();

  Future<NominatimResult> search({
    required String query,
    String? country,
    String? city,
    int limit = 5,
  }) async {
    final cacheKey = 'search:$query:$country:$city:$limit';
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) return cached.result as NominatimResult;

    final params = <String, String>{
      'q': query,
      'format': 'json',
      'addressdetails': '1',
      'limit': limit.toString(),
      'accept-language': 'es',
    };
    if (country != null) params['country'] = country;
    if (city != null) params['city'] = city;

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);
    final data = await _getWithRetry(uri);

    final results = (data as List<dynamic>).map((j) => NominatimPlace.fromJson(j as Map<String, dynamic>)).toList();
    final result = NominatimResult(places: results, query: query);
    _cache[cacheKey] = _CachedResult(result);
    return result;
  }

  Future<NominatimPlace?> searchAddress(String address) async {
    final result = await search(query: address, limit: 1);
    return result.places.isNotEmpty ? result.places.first : null;
  }

  Future<NominatimResult> searchStreet(String street, {String? city, String? country}) async {
    return search(query: street, city: city, country: country);
  }

  Future<NominatimResult> searchUniversity(String name, {String? city}) async {
    return search(query: '$name universidad', city: city);
  }

  Future<NominatimResult> searchNeighborhood(String name, {String? city}) async {
    return search(query: '$name barrio', city: city);
  }

  Future<NominatimPlace?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final key = 'reverse:${lat.toStringAsFixed(5)}:${lng.toStringAsFixed(5)}';
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) return cached.result as NominatimPlace?;

    final params = <String, String>{
      'lat': lat.toString(),
      'lon': lng.toString(),
      'format': 'json',
      'addressdetails': '1',
      'accept-language': 'es',
    };

    final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: params);
    final data = await _getWithRetry(uri);

    if (data is Map<String, dynamic>) {
      final place = NominatimPlace.fromJson(data);
      _cache[key] = _CachedResult(place);
      return place;
    }
    return null;
  }

  Future<LatLng?> forwardGeocode(String address) async {
    final key = 'forward:$address';
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) return cached.result as LatLng?;

    final place = await searchAddress(address);
    if (place != null) {
      final latLng = LatLng(place.lat, place.lng);
      _cache[key] = _CachedResult(latLng);
      return latLng;
    }
    return null;
  }

  Future<dynamic> _getWithRetry(Uri uri) async {
    Exception? lastError;
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _client
            .get(uri, headers: {'User-Agent': 'BUSSU-App/1.0'})
            .timeout(_defaultTimeout);

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 429) {
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        } else {
          throw NominatimException('HTTP ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }
    throw NominatimException('Failed after $_maxRetries retries: $lastError');
  }

  void clearCache() => _cache.clear();
  void dispose() => _client.close();
}

class NominatimResult {
  final List<NominatimPlace> places;
  final String query;
  const NominatimResult({required this.places, required this.query});
}

class NominatimPlace {
  final double lat;
  final double lng;
  final String displayName;
  final String? street;
  final String? city;
  final String? district;
  final String? country;
  final String? postcode;
  final String? type;

  const NominatimPlace({
    required this.lat,
    required this.lng,
    required this.displayName,
    this.street,
    this.city,
    this.district,
    this.country,
    this.postcode,
    this.type,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    return NominatimPlace(
      lat: double.parse(json['lat'] as String),
      lng: double.parse(json['lon'] as String),
      displayName: json['display_name'] as String? ?? '',
      street: address['road'] as String? ?? address['pedestrian'] as String?,
      city: address['city'] as String? ?? address['town'] as String? ?? address['municipality'] as String?,
      district: address['suburb'] as String? ?? address['neighbourhood'] as String?,
      country: address['country'] as String?,
      postcode: address['postcode'] as String?,
      type: json['type'] as String?,
    );
  }

  String get shortAddress {
    final parts = <String>[];
    if (street != null) parts.add(street!);
    if (city != null) parts.add(city!);
    if (country != null) parts.add(country!);
    return parts.isNotEmpty ? parts.join(', ') : displayName;
  }
}

class _CachedResult {
  final dynamic result;
  final DateTime cachedAt;
  _CachedResult(this.result) : cachedAt = DateTime.now();
  bool get isExpired => DateTime.now().difference(cachedAt) > NominatimService._cacheTtl;
}

class NominatimException implements Exception {
  final String message;
  NominatimException(this.message);
  @override
  String toString() => 'NominatimException: $message';
}
