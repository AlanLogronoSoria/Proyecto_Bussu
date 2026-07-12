import 'package:flutter/material.dart';

class AdminAnalytics extends StatelessWidget {
  const AdminAnalytics({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 16),
        Row(children: [
          _FilterChip(label: 'Todas', selected: true), const SizedBox(width: 8),
          _FilterChip(label: 'TransLima', selected: false), const SizedBox(width: 8),
          _FilterChip(label: 'Metropolitano', selected: false), const SizedBox(width: 8),
          _FilterChip(label: 'BusPeru', selected: false),
        ]),
        const SizedBox(height: 20),
        _ChartCard(title: 'Puntualidad de la red (ultimas 4 semanas)', child: _PunctualityChart()),
        const SizedBox(height: 20),
        _ChartCard(title: 'Cobertura de rutas activas por cooperativa', child: _CoverageChart()),
        const SizedBox(height: 20),
        _ChartCard(title: 'Incidentes reportados por cooperativa', child: _IncidentsChart()),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool selected;
  const _FilterChip({required this.label, required this.selected});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: selected ? const Color(0xFF001B44) : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? const Color(0xFF001B44) : const Color(0xFFE0E0E0))), child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : const Color(0xFF434750), fontFamily: 'Inter')));
  }
}

class _ChartCard extends StatelessWidget {
  final String title; final Widget child;
  const _ChartCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 16), child,
    ]));
  }
}

class _PunctualityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weeks = ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'];
    final values = [0.78, 0.82, 0.75, 0.88];
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(values.length, (i) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Column(children: [
        Text('${(values[i] * 100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF001B44))),
        const SizedBox(height: 4),
        Container(height: values[i] * 160, decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(4))),
      ]))))),
      const SizedBox(height: 8),
      Row(children: weeks.map((w) => Expanded(child: Text(w, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF434750))))).toList()),
    ]);
  }
}

class _CoverageChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [{'name': 'TransLima', 'value': 0.92}, {'name': 'Metropolitano', 'value': 0.78}, {'name': 'BusPeru', 'value': 0.85}, {'name': 'Rutas Unidas', 'value': 0.45}, {'name': 'TransAndes', 'value': 0.68}];
    return Column(children: items.map((i) {
      final name = i['name'] as String;
      final val = i['value'] as double;
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
        SizedBox(width: 100, child: Text(name, style: const TextStyle(fontSize: 13, color: Color(0xFF001B44), fontFamily: 'Inter'))),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: val, minHeight: 20, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(Color(0xFFFED000))))),
        const SizedBox(width: 12),
        SizedBox(width: 40, child: Text('${(val * 100).round()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
      ]));
    }).toList());
  }
}

class _IncidentsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [{'name': 'TransLima', 'value': 3}, {'name': 'Metropolitano', 'value': 1}, {'name': 'BusPeru', 'value': 5}, {'name': 'Rutas Unidas', 'value': 0}, {'name': 'TransAndes', 'value': 2}];
    const maxVal = 5.0;
    return Column(children: items.map((i) {
      final name = i['name'] as String;
      final v = i['value'] as int;
      return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
        SizedBox(width: 100, child: Text(name, style: const TextStyle(fontSize: 13, color: Color(0xFF001B44), fontFamily: 'Inter'))),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: v / maxVal, minHeight: 20, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(v > 3 ? const Color(0xFFBA1A1A) : const Color(0xFF001B44))))),
        const SizedBox(width: 12),
        SizedBox(width: 30, child: Text('$v', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
      ]));
    }).toList());
  }
}
