import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/route_entity.dart';
import '../../domain/entities/stop_entity.dart';
import 'bus_marker_animator.dart';

/// Widget reutilizable de mapa en vivo con buses y paradas.
///
/// Recibe flujos de datos para posiciones de buses y rutas,
/// y renderiza el mapa de Google Maps con animaciones suaves.
class LiveMapWidget extends StatefulWidget {
  /// Posición inicial del mapa.
  final CameraPosition initialPosition;

  /// Buses activos con sus posiciones.
  final Map<String, BusPosition> buses;

  /// Ruta actual a mostrar.
  final RouteEntity? activeRoute;

  /// Paradas a mostrar en el mapa.
  final List<StopEntity> stops;

  /// Callback al seleccionar una parada.
  final void Function(StopEntity)? onStopTapped;

  /// Callback al seleccionar un bus.
  final void Function(String busId)? onBusTapped;

  /// Polilíneas adicionales (rutas favoritas, etc.).
  final List<Polyline> extraPolylines;

  /// Marcadores adicionales.
  final List<Marker> extraMarkers;

  /// Callback al tocar el mapa.
  final void Function(LatLng)? onMapTapped;

  const LiveMapWidget({
    super.key,
    required this.initialPosition,
    this.buses = const {},
    this.activeRoute,
    this.stops = const [],
    this.onStopTapped,
    this.onBusTapped,
    this.extraPolylines = const [],
    this.extraMarkers = const [],
    this.onMapTapped,
  });

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

/// Datos de posición de un bus en el mapa.
class BusPosition {
  final LatLng position;
  final double heading;
  final double occupancyPct;

  const BusPosition({
    required this.position,
    this.heading = 0,
    this.occupancyPct = 0,
  });
}

class _LiveMapWidgetState extends State<LiveMapWidget>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  final BusMarkerAnimator _animator = BusMarkerAnimator();
  late final AnimationController _animationController;
  Timer? _updateTimer;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animator.animationDuration,
    )..addListener(_onAnimationTick);

    _updateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshBusPositions(),
    );
  }

  @override
  void didUpdateWidget(LiveMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.buses != widget.buses) {
      _refreshBusPositions();
    }
  }

  void _refreshBusPositions() {
    for (final entry in widget.buses.entries) {
      _animator.updateBusPosition(
        entry.key,
        entry.value.position,
        entry.value.heading,
        occupancyPct: entry.value.occupancyPct,
      );
    }

    _animationController.forward(from: 0);
  }

  void _onAnimationTick() {
    _animator.tick(_animationController.value);
    _updateMarkers();
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    for (final busId in _animator.activeBusIds) {
      markers.add(_animator.createMarker(busId));
    }

    for (final stop in widget.stops) {
      markers.add(
        Marker(
          markerId: MarkerId('stop_${stop.id}'),
          position: LatLng(stop.latitude, stop.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: 'Parada ${stop.orderIndex}',
          ),
          onTap: () => widget.onStopTapped?.call(stop),
        ),
      );
    }

    setState(() {
      _markers
        ..clear()
        ..addAll(markers);
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _animationController.dispose();
    _mapController?.dispose();
    _animator.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final polylines = <Polyline>{};

    if (widget.activeRoute != null &&
        widget.activeRoute!.polyline.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: PolylineId(widget.activeRoute!.id),
          points: widget.activeRoute!.polyline
              .map((p) => LatLng(p[0], p[1]))
              .toList(),
          color: const Color(0xFF001B44),
          width: 4,
        ),
      );
    }

    polylines.addAll(widget.extraPolylines);

    return GoogleMap(
      initialCameraPosition: widget.initialPosition,
      markers: {..._markers, ...widget.extraMarkers},
      polylines: polylines,
      onMapCreated: (controller) {
        _mapController = controller;
        _refreshBusPositions();
      },
      onTap: widget.onMapTapped,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
    );
  }
}
