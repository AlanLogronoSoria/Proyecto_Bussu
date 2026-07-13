import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final premiumPlanProvider = StateProvider<String>((ref) => 'free');
final premiumLoadingProvider = StateProvider<bool>((ref) => false);
final premiumSuccessProvider = StateProvider<bool>((ref) => false);

class PremiumUpgradePage extends ConsumerWidget {
  const PremiumUpgradePage({super.key});

  void _upgrade(WidgetRef ref, String plan) {
    ref.read(premiumLoadingProvider.notifier).state = true;
    Future.delayed(const Duration(seconds: 1), () {
      ref.read(premiumLoadingProvider.notifier).state = false;
      ref.read(premiumPlanProvider.notifier).state = plan;
      ref.read(premiumSuccessProvider.notifier).state = true;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(premiumPlanProvider);
    final loading = ref.watch(premiumLoadingProvider);
    final success = ref.watch(premiumSuccessProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Upgrade', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Center(child: Icon(Icons.workspace_premium, size: 64, color: Color(0xFFFED000))),
        const SizedBox(height: 12),
        if (plan != 'free' && success) ...[
          const Center(child: Text('¡Ya eres Premium!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter'))),
          const SizedBox(height: 8),
          Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFED000), borderRadius: BorderRadius.circular(20)), child: const Text('Premium Member', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')))),
        ] else ...[
          const Text('Andes Premium', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
          const SizedBox(height: 4),
          const Text('La mejor experiencia de transporte', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
          const SizedBox(height: 24),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), padding: const EdgeInsets.all(20), child: const Column(children: [
            _Row(label: 'Ocupación exacta en tiempo real', free: '3 niveles', premium: '% exacto'),
            Divider(height: 24), _Row(label: 'Alertas de llegada', free: '5 min antes', premium: '10 min + push'),
            Divider(height: 24), _Row(label: 'Historial de viajes', free: '1 semana', premium: '90 días'),
            Divider(height: 24), _Row(label: 'Rutas favoritas', free: '3 rutas', premium: 'Ilimitadas'),
            Divider(height: 24), _Row(label: 'Soporte prioritario', free: 'Estándar', premium: '24/7'),
          ])),
          const SizedBox(height: 24),
          if (loading) const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
          if (!loading) ...[
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF001B44), width: 2), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Premium Mensual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
                Text('S/ 15.90', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
              ]),
              const SizedBox(height: 4),
              const Text('Facturación mensual. Cancela cuando quieras.', style: TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _upgrade(ref, 'premium_mensual'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFED000), foregroundColor: const Color(0xFF001B44), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')), child: const Text('Suscribirse ahora'))),
            ])),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Premium Anual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
                Text('S/ 129.90', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
              ]),
              const SizedBox(height: 4),
              const Text('Ahorra 32%. Facturación anual.', style: TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _upgrade(ref, 'premium_anual'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')), child: const Text('Suscribirse ahora'))),
            ])),
          ],
        ],
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, free, premium;
  const _Row({required this.label, required this.free, required this.premium});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter'))),
    Expanded(flex: 2, child: Text(free, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontFamily: 'Inter'))),
    Expanded(flex: 2, child: Text(premium, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))),
  ]);
}
