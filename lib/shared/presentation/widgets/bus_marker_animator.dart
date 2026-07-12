import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Posición animada de un bus en el mapa.
///
/// Interpola la posición del marcador entre dos actualizaciones
/// consecutivas para suavizar el movimiento visual.
class BusMarkerAnimator {
  BusMarkerAnimator({
    this.animationDuration = const Duration(seconds: 4),
  });

  /// Duración de la animación de interpolación.
  final Duration animationDuration;

  final Map<String, _AnimatedBus> _buses = {};

  /// Agrega o actualiza la posición de un bus.
  ///
  /// Si ya existe, inicia la animación desde la posición actual
  /// hacia la nueva [position].
  void updateBusPosition(
    String busId,
    LatLng position,
    double heading, {
    double? occupancyPct,
  }) {
    if (_buses.containsKey(busId)) {
      final bus = _buses[busId]!;
      bus.targetPosition = position;
      bus.heading = heading;
      bus.occupancyPct = occupancyPct ?? bus.occupancyPct;
    } else {
      _buses[busId] = _AnimatedBus(
        position: position,
        heading: heading,
        occupancyPct: occupancyPct ?? 0,
      );
    }
  }

  /// Obtiene la posición interpolada actual de un bus.
  ///
  /// Retorna `null` si el bus no existe.
  LatLng? getBusPosition(String busId) {
    return _buses[busId]?.position;
  }

  /// Obtiene el heading actual de un bus.
  double getBusHeading(String busId) {
    return _buses[busId]?.heading ?? 0;
  }

  /// Obtiene el porcentaje de ocupación de un bus.
  double getBusOccupancy(String busId) {
    return _buses[busId]?.occupancyPct ?? 0;
  }

  /// Lista de IDs de buses activos.
  Iterable<String> get activeBusIds => _buses.keys;

  /// Elimina un bus del animador (cuando deja de transmitir).
  void removeBus(String busId) {
    _buses.remove(busId);
  }

  /// Elimina todos los buses.
  void clear() {
    _buses.clear();
  }

  /// Tick de animación. Debe llamarse desde un [Ticker] o [AnimationController].
  ///
  /// [progress] debe estar entre 0.0 y 1.0.
  void tick(double progress) {
    for (final bus in _buses.values) {
      if (bus.targetPosition != null) {
        final t = Curves.easeInOut.transform(progress);
        bus.currentPosition = LatLng(
          bus.currentPosition.latitude +
              (bus.targetPosition!.latitude - bus.currentPosition.latitude) * t,
          bus.currentPosition.longitude +
              (bus.targetPosition!.longitude - bus.currentPosition.longitude) *
                  t,
        );
      }
    }
  }

  /// Marca el frame de animación como completado.
  /// El target se convierte en la posición actual.
  void commitFrame() {
    for (final bus in _buses.values) {
      if (bus.targetPosition != null) {
        bus.currentPosition = bus.targetPosition!;
        bus.targetPosition = null;
      }
    }
  }

  /// Crea un marcador de Google Maps para un bus.
  Marker createMarker(String busId) {
    final bus = _buses[busId];
    if (bus == null) {
      return Marker(markerId: MarkerId(busId));
    }

    final occupancy = bus.occupancyPct;
    final hue = _occupancyColor(occupancy);

    return Marker(
      markerId: MarkerId(busId),
      position: bus.position,
      rotation: bus.heading,
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: 'Bus $busId',
        snippet: '${occupancy.round()}% ocupado',
      ),
      onTap: () {
        // Callback manejado por el widget
      },
    );
  }

  double _occupancyColor(double pct) {
    if (pct < 40) return BitmapDescriptor.hueGreen;
    if (pct < 75) return BitmapDescriptor.hueYellow;
    return BitmapDescriptor.hueRed;
  }
}

class _AnimatedBus {
  LatLng currentPosition;
  LatLng? targetPosition;
  double heading;
  double occupancyPct;

  _AnimatedBus({
    required LatLng position,
    required this.heading,
    required this.occupancyPct,
  })  : currentPosition = position,
        targetPosition = null;

  LatLng get position => currentPosition;
}
