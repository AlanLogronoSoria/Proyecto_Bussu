import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/maps/marker_service.dart';

class BusMarkerAnimator {
  final MarkerService _markerService;

  static const double _minMoveMeters = 0.5;
  static const Duration _fastAnim = Duration(milliseconds: 400);
  static const Duration _mediumAnim = Duration(milliseconds: 700);
  static const Duration _slowAnim = Duration(milliseconds: 1000);

  final Map<String, _BusState> _states = {};
  final Map<String, _AnimSegment> _segments = {};
  int _frameCount = 0;

  BusMarkerAnimator(this._markerService);

  Duration get animationDuration {
    var total = 0.0;
    var count = 0;
    for (final s in _segments.values) { total += s.speedKmh; count++; }
    final avg = count > 0 ? total / count : 20;
    return avg > 40 ? _fastAnim : avg > 20 ? _mediumAnim : _slowAnim;
  }

  void updateBusPosition(String busId, LatLng pos, double heading, {double occupancyPct = 0, double speedKmh = 0}) {
    final cur = _states[busId];
    if (cur == null) {
      _states[busId] = _BusState(interpolatedPosition: pos, heading: heading, occupancyPct: occupancyPct);
      _segments[busId] = _AnimSegment(start: pos, end: pos, speedKmh: speedKmh);
      return;
    }
    final dist = _haversine(cur.interpolatedPosition, pos);
    if (dist < _minMoveMeters && speedKmh < 2) return;
    _segments[busId] = _AnimSegment(start: cur.interpolatedPosition, end: pos, speedKmh: speedKmh);
    _states[busId] = _BusState(interpolatedPosition: cur.interpolatedPosition, heading: heading, occupancyPct: occupancyPct);
  }

  void tick(double progress) {
    for (final entry in _states.entries) {
      final busId = entry.key;
      final seg = _segments[busId];
      if (seg == null) continue;
      final p = _ease(progress, seg.speedKmh);
      final lat = seg.start.latitude + (seg.end.latitude - seg.start.latitude) * p;
      final lng = seg.start.longitude + (seg.end.longitude - seg.start.longitude) * p;
      _states[busId] = _states[busId]!.copyWith(interpolatedPosition: LatLng(lat, lng));
    }
    _frameCount++;
  }

  double _ease(double t, double speed) {
    if (speed > 40) {
      final easeOut = 1 - (1 - t) * (1 - t) * (1 - t);
      return easeOut;
    }
    if (speed > 10) return t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2) * 0.5;
    return t * t;
  }

  Marker createMarker(String busId) {
    final s = _states[busId];
    if (s == null) return Marker(point: const LatLng(0, 0), child: const SizedBox.shrink());
    return _markerService.createBusMarker(id: busId, point: s.interpolatedPosition, heading: s.heading, occupancyPct: s.occupancyPct);
  }

  Iterable<String> get activeBusIds => _states.keys;
  bool get hasActiveBuses => _states.isNotEmpty;
  int get frameCount => _frameCount;

  void removeBus(String busId) { _states.remove(busId); _segments.remove(busId); }
  void clear() { _states.clear(); _segments.clear(); _frameCount = 0; }

  double _haversine(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dlat = (b.latitude - a.latitude) * 0.0174533;
    final dlng = (b.longitude - a.longitude) * 0.0174533;
    final aa = dlat * dlat / 4 + (a.latitude * 0.0174533).clamp(-1.0, 1.0).let((c) => c) * (b.latitude * 0.0174533).clamp(-1.0, 1.0).let((c) => c) * dlng * dlng / 4;
    return r * 2 * asinSafe(aa.clamp(0.0, 1.0));
  }

  double asinSafe(double x) {
    double s = x, t = x;
    for (int i = 3; i < 10; i += 2) { t *= x * x * (i - 2) / i; s += t; }
    return s;
  }
}

class _BusState {
  final LatLng interpolatedPosition;
  final double heading;
  final double occupancyPct;
  _BusState({required this.interpolatedPosition, this.heading = 0, this.occupancyPct = 0});
  _BusState copyWith({LatLng? interpolatedPosition, double? heading, double? occupancyPct}) {
    return _BusState(interpolatedPosition: interpolatedPosition ?? this.interpolatedPosition, heading: heading ?? this.heading, occupancyPct: occupancyPct ?? this.occupancyPct);
  }
}

class _AnimSegment {
  final LatLng start, end;
  final double speedKmh;
  _AnimSegment({required this.start, required this.end, required this.speedKmh});
}

extension _NumExt on num {
  double let(double Function(double) f) => f(toDouble());
}
