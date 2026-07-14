import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PolylineService {
  final double strokeWidth;
  final Color defaultColor;

  const PolylineService({this.strokeWidth = 4, this.defaultColor = const Color(0xFF001B44)});

  Polyline createRoutePolyline({
    required String id,
    required List<LatLng> points,
    Color? color,
    double? width,
  }) {
    return Polyline(
      points: points,
      color: color ?? defaultColor,
      strokeWidth: width ?? strokeWidth,
    );
  }

  Polyline createFavoriteRoutePolyline({
    required String id,
    required List<LatLng> points,
  }) {
    return Polyline(
      points: points,
      color: Colors.amber.shade700,
      strokeWidth: 3,
    );
  }

  List<LatLng> fromDoubleList(List<List<double>> polyline) {
    return polyline.map((p) => LatLng(p[0], p[1])).toList();
  }
}
