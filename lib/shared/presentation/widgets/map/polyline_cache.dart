import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/maps/polyline_service.dart';

class PolylineCache {
  final PolylineService _service;
  final Map<String, Polyline> _cache = {};

  PolylineCache({PolylineService? service})
      : _service = service ?? const PolylineService();

  Polyline getOrCreateRoute(String id, List<List<double>> polylineData) {
    if (_cache.containsKey(id)) return _cache[id]!;
    final polyline = _service.createRoutePolyline(
      id: id,
      points: _service.fromDoubleList(polylineData),
    );
    _cache[id] = polyline;
    return polyline;
  }

  Polyline getOrCreateFavorite(String id, List<List<double>> polylineData) {
    final key = 'fav_$id';
    if (_cache.containsKey(key)) return _cache[key]!;
    final polyline = _service.createFavoriteRoutePolyline(
      id: id,
      points: _service.fromDoubleList(polylineData),
    );
    _cache[key] = polyline;
    return polyline;
  }

  Polyline? get(String id) => _cache[id];
  void put(String id, Polyline p) => _cache[id] = p;
  void remove(String id) => _cache.remove(id);
  void clear() => _cache.clear();
}
