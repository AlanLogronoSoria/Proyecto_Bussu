import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class OrsService {
  static const String _baseUrl = 'https://api.openrouteservice.org/v2';

  final String apiKey;
  final http.Client _client;
  final Map<String, _CachedRoute> _cache = {};

  OrsService({required this.apiKey, http.Client? client}) : _client = client ?? http.Client();

  Future<OrsRouteResult> getDirections({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String profile = 'driving-car',
  }) async {
    final cacheKey = _makeKey(startLat, startLng, endLat, endLng, profile);
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) return cached.result;

    final url = Uri.parse('$_baseUrl/directions/$profile/geojson');
    final body = jsonEncode({
      'coordinates': [
        [startLng, startLat],
        [endLng, endLat],
      ],
    });

    try {
      final response = await _client.post(
        url,
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = _parseResponse(data);
        _cache[cacheKey] = _CachedRoute(result);
        return result;
      } else {
        throw OrsException('ORS error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is OrsException) rethrow;
      throw OrsException('ORS request failed: $e');
    }
  }

  OrsRouteResult _parseResponse(Map<String, dynamic> data) {
    final features = data['features'] as List<dynamic>? ?? [];
    if (features.isEmpty) throw OrsException('No route found');

    final feature = features[0] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    final polyline = coordinates.map((c) {
      final coord = c as List<dynamic>;
      return [coord[1] as double, coord[0] as double];
    }).toList();

    final properties = feature['properties'] as Map<String, dynamic>? ?? {};
    final summary = properties['summary'] as Map<String, dynamic>? ?? {};

    return OrsRouteResult(
      polyline: polyline,
      distanceMeters: (summary['distance'] as num?)?.toDouble() ?? 0,
      durationSeconds: (summary['duration'] as num?)?.toDouble() ?? 0,
    );
  }

  String _makeKey(double slat, double slng, double elat, double elng, String profile) {
    return '${slat.toStringAsFixed(4)},${slng.toStringAsFixed(4)}-${elat.toStringAsFixed(4)},${elng.toStringAsFixed(4)}-$profile';
  }

  void dispose() => _client.close();
}

class OrsRouteResult {
  final List<List<double>> polyline;
  final double distanceMeters;
  final double durationSeconds;

  const OrsRouteResult({
    required this.polyline,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class _CachedRoute {
  final OrsRouteResult result;
  final DateTime cachedAt;
  static const _maxAge = Duration(minutes: 30);

  _CachedRoute(this.result) : cachedAt = DateTime.now();
  bool get isExpired => DateTime.now().difference(cachedAt) > _maxAge;
}

class OrsException implements Exception {
  final String message;
  OrsException(this.message);
  @override
  String toString() => 'OrsException: $message';
}
