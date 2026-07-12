import 'package:flutter/material.dart';
import 'coop_fleet_dashboard.dart';
import 'coop_drivers.dart';
import 'coop_stops.dart';
import 'coop_reports.dart';
import 'coop_chat_inbox.dart';

class CoopScaffold extends StatefulWidget {
  final int initialIndex;
  const CoopScaffold({super.key, this.initialIndex = 0});
  @override
  State<CoopScaffold> createState() => _CoopScaffoldState();

  static const _titles = ['Dashboard', 'Conductores', 'Paradas', 'Reportes', 'Chat'];
  static const _icons = [Icons.dashboard, Icons.people, Icons.place, Icons.assessment, Icons.chat];
}

class _CoopScaffoldState extends State<CoopScaffold> {
  late int _index = widget.initialIndex;

  static final _pages = [
    const CoopFleetDashboard(), const CoopDrivers(), const CoopStops(),
    const CoopReports(), const CoopChatInbox(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    if (isWide) {
      return Scaffold(body: Row(children: [
        _Sidebar(selected: _index, onChanged: (i) => setState(() => _index = i)),
        const VerticalDivider(width: 1),
        Expanded(child: _pages[_index]),
      ]));
    }
    return Scaffold(
      appBar: AppBar(title: Text(CoopScaffold._titles[_index], style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      drawer: _Drawer(selected: _index, onChanged: (i) { setState(() => _index = i); Navigator.pop(context); }),
      body: _pages[_index],
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selected; final ValueChanged<int> onChanged;
  const _Sidebar({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 240, child: Container(color: const Color(0xFFF8F9FA), child: Column(children: [
      const Padding(padding: EdgeInsets.all(20), child: Row(children: [
        Icon(Icons.directions_bus, color: Color(0xFF001B44), size: 28), SizedBox(width: 8),
        Text('BUSSU Coop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      ])),
      const Divider(height: 1), const SizedBox(height: 16),
      ...List.generate(CoopScaffold._titles.length, (i) => _NavTile(
        icon: CoopScaffold._icons[i], title: CoopScaffold._titles[i],
        selected: i == selected, onTap: () => onChanged(i),
      )),
    ])));
  }
}

class _Drawer extends StatelessWidget {
  final int selected; final ValueChanged<int> onChanged;
  const _Drawer({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Drawer(child: SafeArea(child: Column(children: [
      const Padding(padding: EdgeInsets.all(20), child: Row(children: [
        Icon(Icons.directions_bus, color: Color(0xFF001B44), size: 28), SizedBox(width: 8),
        Text('BUSSU Coop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      ])),
      const Divider(),
      ...List.generate(CoopScaffold._titles.length, (i) => _NavTile(
        icon: CoopScaffold._icons[i], title: CoopScaffold._titles[i],
        selected: i == selected, onTap: () => onChanged(i),
      )),
    ])));
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon; final String title; final bool selected; final VoidCallback onTap;
  const _NavTile({required this.icon, required this.title, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: Material(
      color: selected ? const Color(0xFFFED000).withAlpha(30) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
        Icon(icon, color: selected ? const Color(0xFF001B44) : const Color(0xFF434750), size: 22), const SizedBox(width: 12),
        Text(title, style: TextStyle(fontSize: 15, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? const Color(0xFF001B44) : const Color(0xFF434750), fontFamily: 'Inter')),
      ]))),
    ));
  }
}
