import 'package:flutter/material.dart';
import 'map_page.dart';
import 'routes_page.dart';
import 'tickets_page.dart';
import 'alerts_page.dart';
import '../../../../shared/presentation/pages/unified_profile_page.dart';

class UScaffold extends StatefulWidget {
  final int initialIndex;
  const UScaffold({super.key, this.initialIndex = 0});
  @override
  State<UScaffold> createState() => _UScaffoldState();
}

class _UScaffoldState extends State<UScaffold> {
  late int _index = widget.initialIndex;

  static const _pages = [MapPage(), RoutesPage(), TicketsPage(), AlertsPage(), UnifiedProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: const Color(0xFFFED000),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map, color: Color(0xFF001B44)), label: 'Live'),
          NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route, color: Color(0xFF001B44)), label: 'Routes'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number, color: Color(0xFF001B44)), label: 'Tickets'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications, color: Color(0xFF001B44)), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person, color: Color(0xFF001B44)), label: 'Profile'),
        ],
      ),
    );
  }

  void switchTo(int index) => setState(() => _index = index);
  void showRouteOnMap(String routeId) => setState(() => _index = 0);
}
