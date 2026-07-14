import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/maps/marker_service.dart';

class MarkerManager {
  final MarkerService _markerService;
  final MarkerCache _cache;

  MarkerManager({MarkerService? markerService})
      : _markerService = markerService ?? const MarkerService(),
        _cache = MarkerCache();

  List<Marker> buildBusMarkers(Map<String, MarkerState> busStates) {
    final markers = <Marker>[];
    for (final entry in busStates.entries) {
      final busId = entry.key;
      final state = entry.value;
      final cached = _cache.get(busId);
      if (cached != null && _cache.isFresh(busId, state.position, state.heading)) {
        markers.add(cached);
        continue;
      }
      final marker = _markerService.createBusMarker(
        id: busId,
        point: state.position,
        heading: state.heading,
        occupancyPct: state.occupancyPct,
      );
      _cache.put(busId, marker, state.position, state.heading);
      markers.add(marker);
    }
    return markers;
  }

  void removeBus(String busId) => _cache.remove(busId);
  void clear() => _cache.clear();
}

class MarkerState {
  final LatLng position;
  final double heading;
  final double occupancyPct;
  const MarkerState({required this.position, this.heading = 0, this.occupancyPct = 0});
}

class MarkerCache {
  final Map<String, _CachedMarker> _cache = {};
  static const double _positionThreshold = 0.00005;
  static const double _headingThreshold = 5.0;

  Marker? get(String busId) => _cache[busId]?.marker;

  bool isFresh(String busId, LatLng newPos, double newHeading) {
    final cached = _cache[busId];
    if (cached == null) return false;
    final dlat = (cached.lat - newPos.latitude).abs();
    final dlng = (cached.lng - newPos.longitude).abs();
    final dh = (cached.heading - newHeading).abs();
    return dlat < _positionThreshold && dlng < _positionThreshold && dh < _headingThreshold;
  }

  void put(String busId, Marker marker, LatLng pos, double heading) {
    _cache[busId] = _CachedMarker(marker: marker, lat: pos.latitude, lng: pos.longitude, heading: heading);
  }

  void remove(String busId) => _cache.remove(busId);
  void clear() => _cache.clear();
}

class _CachedMarker {
  final Marker marker;
  final double lat;
  final double lng;
  final double heading;
  _CachedMarker({required this.marker, required this.lat, required this.lng, required this.heading});
}
