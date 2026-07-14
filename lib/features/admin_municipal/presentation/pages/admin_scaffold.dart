import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_overview_page.dart';
import 'admin_drivers_page.dart';
import 'admin_reports_page.dart';
import 'admin_chat_page.dart';
import '../../../../shared/presentation/pages/unified_profile_page.dart';

class AdminScaffold extends ConsumerStatefulWidget {
  const AdminScaffold({super.key});
  @override
  ConsumerState<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends ConsumerState<AdminScaffold> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(index: _idx, children: const [
        AdminOverviewPage(),
        AdminDriversPage(),
        AdminReportsPage(),
        AdminChatPage(),
        UnifiedProfilePage(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        indicatorColor: const Color(0xFFFED000),
        height: 64,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: Color(0xFF001B44)), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people, color: Color(0xFF001B44)), label: 'Conductores'),
          NavigationDestination(icon: Icon(Icons.assessment_outlined), selectedIcon: Icon(Icons.assessment, color: Color(0xFF001B44)), label: 'Reportes'),
          NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat, color: Color(0xFF001B44)), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person, color: Color(0xFF001B44)), label: 'Profile'),
        ],
      ),
    );
  }
}
