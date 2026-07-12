import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/eta_provider.dart';

class RoutesPage extends ConsumerWidget {
  const RoutesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(availableRoutesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Routes', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _SearchSection(),
        const SizedBox(height: 16),
        _RecentRoutesSection(),
        const SizedBox(height: 16),
        _SuggestedSection(routes: routesAsync.valueOrNull ?? []),
      ]),
    );
  }
}

class _SearchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, 2))]),
        child: TextField(
          decoration: InputDecoration(hintText: '¿A dónde vas?', hintStyle: const TextStyle(color: Color(0xFF434750), fontSize: 14, fontFamily: 'Inter'),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF001B44)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
            filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      )),
      const SizedBox(width: 12),
      Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFED000), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.directions, color: Color(0xFF001B44))),
    ]);
  }
}

class _RecentRoutesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': 'Ruta A - Centro Histórico', 'freq': '5', 'eta': '8', 'color': '#001B44'},
      {'name': 'Ruta B - Miraflores', 'freq': '8', 'eta': '15', 'color': '#FED000'},
      {'name': 'Ruta C - San Isidro', 'freq': '10', 'eta': '22', 'color': '#1B5E20'},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Rutas recientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
      ...items.map((r) => _RecentCard(name: r['name']!, freq: r['freq']!, eta: r['eta']!, color: r['color']!)),
    ]);
  }
}

class _RecentCard extends StatelessWidget {
  final String name, freq, eta, color;
  const _RecentCard({required this.name, required this.freq, required this.eta, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, 2))]),
      child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Container(width: 4, height: 40, decoration: BoxDecoration(color: Color(int.parse('FF${color.replaceAll('#', '')}', radix: 16)), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.schedule, size: 14, color: Color(0xFF434750)),
            const SizedBox(width: 4),
            Text('Cada $freq min', style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
          ]),
        ])),
        Text('$eta min', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      ])),
    );
  }
}

class _SuggestedSection extends StatelessWidget {
  final List<dynamic> routes;
  const _SuggestedSection({required this.routes});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Sugeridas para ti', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
      Wrap(spacing: 12, runSpacing: 12, children: [
        _SuggestionCard(title: 'Ruta A - Centro', desc: 'Más rápida a tu destino habitual', eta: '8 min', badge: 'Más rápida'),
        _SuggestionCard(title: 'Ruta B - Miraflores', desc: 'Conexión directa sin transbordo', eta: '15 min', badge: 'En vivo ahora'),
      ]),
    ]);
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title, desc, eta, badge;
  const _SuggestionCard({required this.title, required this.desc, required this.eta, required this.badge});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 240,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, 2))]),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.route, color: Color(0xFF001B44), size: 24),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFED000), borderRadius: BorderRadius.circular(8)), child: Text(badge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
          ]),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
          const SizedBox(height: 12),
          Row(children: [
            Text(eta, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const Spacer(),
            const Text('Ver ruta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF001B44)),
          ]),
        ]),
      ),
    );
  }
}
