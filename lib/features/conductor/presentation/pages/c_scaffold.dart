import 'package:flutter/material.dart';
import 'driver_dashboard_page.dart';
import 'active_trip_page.dart';
import 'stop_request_page.dart';
import 'conductor_chat_page.dart';

class CScaffold extends StatefulWidget {
  final int initialIndex;
  const CScaffold({super.key, this.initialIndex = 0});
  @override
  State<CScaffold> createState() => _CScaffoldState();
}

class _CScaffoldState extends State<CScaffold> {
  late int _index = widget.initialIndex;
  static final _pages = [const DriverDashboardPage(), const ActiveTripPage(), const StopRequestPage(), const ConductorChatPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: const Color(0xFFFED000),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: Color(0xFF001B44)), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.navigation_outlined), selectedIcon: Icon(Icons.navigation, color: Color(0xFF001B44)), label: 'Viaje'),
          NavigationDestination(icon: Icon(Icons.add_location_outlined), selectedIcon: Icon(Icons.add_location, color: Color(0xFF001B44)), label: 'Paradas'),
          NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat, color: Color(0xFF001B44)), label: 'Chat'),
        ],
      ),
    );
  }
}
