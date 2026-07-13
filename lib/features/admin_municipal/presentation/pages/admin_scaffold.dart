import 'package:flutter/material.dart';
import 'municipal_overview_page.dart';
import 'admin_incidents.dart';
import 'admin_analytics.dart';
import 'cooperativas_table.dart';
import 'premium_table.dart';

class AdminScaffold extends StatefulWidget {
  final int initialIndex;
  const AdminScaffold({super.key, this.initialIndex = 0});
  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();

  static const titles = ['Overview', 'Incidentes', 'Analítica', 'Cooperativas', 'Premium'];
  static const icons = [Icons.dashboard, Icons.warning_amber, Icons.analytics, Icons.business, Icons.workspace_premium];
}

class _AdminScaffoldState extends State<AdminScaffold> {
  late int _index = widget.initialIndex;

  static final _pages = [
    const MunicipalOverviewPage(), const AdminIncidents(), const AdminAnalytics(),
    const CooperativasTable(), const PremiumTable(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    if (isWide) {
      return Scaffold(body: Row(children: [
        _Rail(selected: _index, onChanged: (i) => setState(() => _index = i)),
        const VerticalDivider(width: 1),
        Expanded(child: _pages[_index]),
      ]));
    }
    return Scaffold(
      appBar: AppBar(title: Text(AdminScaffold.titles[_index]), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      drawer: _Drawer(selected: _index, onChanged: (i) { setState(() => _index = i); Navigator.pop(context); }),
      body: _pages[_index],
    );
  }
}

class _Rail extends StatelessWidget {
  final int selected; final ValueChanged<int> onChanged;
  const _Rail({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 240, child: Container(color: const Color(0xFFF8F9FA), child: Column(children: [
      const Padding(padding: EdgeInsets.all(20), child: Row(children: [
        Icon(Icons.account_balance, color: Color(0xFF001B44), size: 28), SizedBox(width: 8),
        Text('BUSSU Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      ])),
      const Divider(height: 1), const SizedBox(height: 16),
      ...List.generate(AdminScaffold.titles.length, (i) => _NavItem(
        icon: AdminScaffold.icons[i], title: AdminScaffold.titles[i],
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
        Icon(Icons.account_balance, color: Color(0xFF001B44), size: 28), SizedBox(width: 8),
        Text('BUSSU Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      ])),
      const Divider(),
      ...List.generate(AdminScaffold.titles.length, (i) => _NavItem(
        icon: AdminScaffold.icons[i], title: AdminScaffold.titles[i],
        selected: i == selected, onTap: () => onChanged(i),
      )),
    ])));
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon; final String title; final bool selected; final VoidCallback onTap;
  const _NavItem({required this.icon, required this.title, required this.selected, required this.onTap});
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
