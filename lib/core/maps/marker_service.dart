import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MarkerService {
  final double defaultSize;
  final Color defaultColor;

  const MarkerService({this.defaultSize = 40, this.defaultColor = Colors.blue});

  Marker createBusMarker({
    required String id,
    required LatLng point,
    double heading = 0,
    double occupancyPct = 0,
    void Function()? onTap,
  }) {
    final color = _occupancyColor(occupancyPct);
    return Marker(
      point: point,
      width: defaultSize,
      height: defaultSize,
      child: GestureDetector(
        onTap: onTap,
        child: Transform.rotate(
          angle: heading * (3.14159 / 180),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Icon(Icons.directions_bus, color: color, size: defaultSize * 0.6),
          ),
        ),
      ),
    );
  }

  Marker createStopMarker({
    required String id,
    required LatLng point,
    required String name,
    int orderIndex = 0,
    void Function()? onTap,
  }) {
    return Marker(
      point: point,
      width: 36,
      height: 36,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Center(
            child: Text('$orderIndex', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Marker createRequestMarker({
    required String id,
    required LatLng point,
    required String title,
    String? subtitle,
  }) {
    return Marker(
      point: point,
      width: 40,
      height: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(4), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)]),
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.location_on, color: Colors.green, size: 30),
        ],
      ),
    );
  }

  Color _occupancyColor(double pct) {
    if (pct < 40) return Colors.green;
    if (pct < 75) return Colors.orange;
    return Colors.red;
  }
}
