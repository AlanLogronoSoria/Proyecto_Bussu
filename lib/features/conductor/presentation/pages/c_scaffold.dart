import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'active_trip_page.dart';
import 'stop_request_page.dart';
import 'conductor_chat_page.dart';
import '../../../../shared/presentation/pages/unified_profile_page.dart';
import 'driver_dashboard_page.dart';
import '../providers/trip_provider.dart';

class CScaffold extends ConsumerStatefulWidget {
  const CScaffold({super.key});
  @override
  ConsumerState<CScaffold> createState() => _CScaffoldState();
}

class _CScaffoldState extends ConsumerState<CScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final hasActive = ref.watch(hasActiveTripProvider);
    ref.listen(hasActiveTripProvider, (_, next) {
      if (next == true) setState(() => _index = 0);
    });

    return Scaffold(
      body: IndexedStack(index: _index, children: [
        hasActive ? const ActiveTripPage() : const DriverDashboardPage(),
        const StopRequestPage(),
        const ConductorChatPage(),
        const UnifiedProfilePage(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: const Color(0xFFFED000),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.navigation_outlined), selectedIcon: Icon(Icons.navigation, color: Color(0xFF001B44)), label: 'Viaje'),
          NavigationDestination(icon: Icon(Icons.add_location_outlined), selectedIcon: Icon(Icons.add_location, color: Color(0xFF001B44)), label: 'Paradas'),
          NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat, color: Color(0xFF001B44)), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person, color: Color(0xFF001B44)), label: 'Profile'),
        ],
      ),
    );
  }
}
