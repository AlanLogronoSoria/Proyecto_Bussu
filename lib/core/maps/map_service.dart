import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'marker_service.dart';
import 'polyline_service.dart';

class MapService {
  MarkerService get markerService => const MarkerService();
  PolylineService get polylineService => const PolylineService();

  MapController? controller;

  void moveTo(LatLng center, double zoom) {
    controller?.move(center, zoom);
  }

  void fitBounds(LatLngBounds bounds, {EdgeInsets padding = const EdgeInsets.all(50)}) {
    controller?.fitCamera(CameraFit.bounds(bounds: bounds, padding: padding));
  }
}
