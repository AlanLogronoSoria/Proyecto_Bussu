import 'package:flutter/material.dart';

import '../../../core/constants/app_roles.dart';
import '../../../core/routing/role_guard.dart';

/// Scaffold consciente del rol del usuario.
///
/// Renderiza un [Scaffold] con un [NavigationBar] dinámico
/// cuyos destinos varían según el [UserRole] del usuario autenticado.
class RoleScaffold extends StatelessWidget {
  /// Título de la barra superior.
  final String title;

  /// Rol del usuario actual.
  final UserRole role;

  /// Índice de la pestaña seleccionada.
  final int currentIndex;

  /// Callback al cambiar de pestaña.
  final void Function(int)? onTabChanged;

  /// Cuerpo principal.
  final Widget body;

  /// Acciones en la AppBar.
  final List<Widget>? actions;

  /// Widget flotante.
  final Widget? floatingActionButton;

  const RoleScaffold({
    super.key,
    required this.title,
    required this.role,
    required this.currentIndex,
    this.onTabChanged,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabChanged,
        destinations: _destinationsForRole(role),
      ),
    );
  }

  List<NavigationDestination> _destinationsForRole(UserRole role) {
    switch (role) {
      case UserRole.usuario:
        return const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Rutas',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
        ];
      case UserRole.conductor:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bus_outlined),
            selectedIcon: Icon(Icons.directions_bus),
            label: 'Viaje',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Ocupación',
          ),
        ];
      case UserRole.cooperativaAdmin:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Flota',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Conductores',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Reportes',
          ),
        ];
      case UserRole.municipalAdmin:
        return const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Visión',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_outlined),
            selectedIcon: Icon(Icons.warning),
            label: 'Incidentes',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analíticas',
          ),
        ];
    }
  }
}
