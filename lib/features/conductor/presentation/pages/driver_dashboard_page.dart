import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/trip_provider.dart';

class DriverDashboardPage extends ConsumerStatefulWidget {
  const DriverDashboardPage({super.key});
  @override
  ConsumerState<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends ConsumerState<DriverDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final activeTrip = ref.watch(activeTripProvider);
    final trip = activeTrip.valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Dashboard', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          const CircleAvatar(radius: 28, backgroundColor: Color(0xFF001B44), child: Icon(Icons.person, color: Colors.white, size: 28)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Buenos días, ${user?.fullName ?? "Conductor"}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFED000).withAlpha(40), borderRadius: BorderRadius.circular(8)), child: Text('Bus ${trip?.busId ?? "ABC-123"}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter'))),
          ]),
        ]),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [
          Icon(trip != null ? Icons.directions_bus : Icons.local_parking, size: 48, color: trip != null ? const Color(0xFF001B44) : Colors.grey),
          const SizedBox(height: 12),
          Text(trip != null ? 'Viaje en curso' : 'Sin viaje iniciado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: trip != null ? const Color(0xFF001B44) : const Color(0xFF434750), fontFamily: 'Inter')),
          if (trip != null) ...[
            const SizedBox(height: 4),
            Text(trip.routeId, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
          ],
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: trip != null ? const Color(0xFFBA1A1A) : const Color(0xFF001B44), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(trip != null ? 'Finalizar viaje' : 'Iniciar viaje', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
          )),
        ])),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(14)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _SummaryItem(value: '3', label: 'Viajes hoy', color: const Color(0xFFFED000)),
          Container(width: 1, height: 40, color: Colors.white24),
          _SummaryItem(value: '67', label: 'Pasajeros', color: Colors.white),
        ])),
        const SizedBox(height: 16),
        const Text('Accesos rápidos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 8),
        _QuickCard(icon: Icons.people_outline, title: 'Ocupación', subtitle: 'Conteo de pasajeros', onTap: () {}),
        _QuickCard(icon: Icons.add_location, title: 'Solicitar parada', subtitle: 'Proponer nueva parada', onTap: () {}),
        _QuickCard(icon: Icons.warning_amber, title: 'Reportar incidente', subtitle: 'Emergencia o novedad', onTap: () {}),
      ]),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value, label; final Color color;
  const _SummaryItem({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color, fontFamily: 'Inter')),
    Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70, fontFamily: 'Inter')),
  ]);
}

class _QuickCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _QuickCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: ListTile(leading: Icon(icon, color: const Color(0xFF001B44)), title: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF001B44), fontFamily: 'Inter')), subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: onTap));
  }
}
