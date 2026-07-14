import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapControllerService {
  final MapController mapController;

  MapControllerService() : mapController = MapController();

  void animateTo(LatLng center, double zoom) {
    mapController.move(center, zoom);
  }

  void fitBounds(LatLngBounds bounds, {EdgeInsets padding = const EdgeInsets.all(50)}) {
    mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: padding));
  }
}
