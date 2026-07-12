import 'package:flutter/material.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});
  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  bool _tripActive = false;
  final int _tripsToday = 3;
  final int _passengersToday = 67;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))),
        backgroundColor: const Color(0xFFF8F9FA), elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _Greeting(name: 'Carlos', plate: 'ABC-123'),
        const SizedBox(height: 16),
        _TripStatusCard(active: _tripActive, onToggle: () => setState(() => _tripActive = !_tripActive)),
        const SizedBox(height: 16),
        _DaySummary(trips: _tripsToday, passengers: _passengersToday),
        const SizedBox(height: 16),
        const Text('Accesos rápidos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 8),
        _QuickCard(icon: Icons.people_outline, title: 'Ocupación', subtitle: 'Ver conteo de pasajeros', onTap: () {}),
        _QuickCard(icon: Icons.add_location, title: 'Solicitar parada', subtitle: 'Proponer nueva parada', onTap: () {}),
        _QuickCard(icon: Icons.warning_amber, title: 'Reportar incidente', subtitle: 'Emergencia o novedad', onTap: () {}),
      ]),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String name, plate;
  const _Greeting({required this.name, required this.plate});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const CircleAvatar(radius: 28, backgroundColor: Color(0xFF001B44), child: Icon(Icons.person, color: Colors.white, size: 28)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Buenos días, $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 2),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFED000).withAlpha(40), borderRadius: BorderRadius.circular(8)), child: Text('Bus $plate', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF001B44), fontFamily: 'Inter'))),
      ]),
    ]);
  }
}

class _TripStatusCard extends StatelessWidget {
  final bool active;
  final VoidCallback onToggle;
  const _TripStatusCard({required this.active, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
      child: Column(children: [
        Icon(active ? Icons.directions_bus : Icons.local_parking, size: 48, color: active ? const Color(0xFF001B44) : Colors.grey),
        const SizedBox(height: 12),
        Text(active ? 'Viaje en curso' : 'Sin viaje iniciado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: active ? const Color(0xFF001B44) : const Color(0xFF434750), fontFamily: 'Inter')),
        if (active) ...[
          const SizedBox(height: 4),
          const Text('Ruta A - Centro Histórico', style: TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter')),
          const SizedBox(height: 4),
          const Text('Iniciado hace 32 min', style: TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
        ],
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
            backgroundColor: active ? const Color(0xFFBA1A1A) : const Color(0xFF001B44),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(active ? 'Finalizar viaje' : 'Iniciar viaje', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
        )),
      ]),
    );
  }
}

class _DaySummary extends StatelessWidget {
  final int trips, passengers;
  const _DaySummary({required this.trips, required this.passengers});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x33002F6C), blurRadius: 12, offset: Offset(0, 4))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _SummaryItem(value: '$trips', label: 'Viajes hoy', color: const Color(0xFFFED000)),
        Container(width: 1, height: 40, color: Colors.white24),
        _SummaryItem(value: '$passengers', label: 'Pasajeros', color: Colors.white),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]),
      child: ListTile(leading: Icon(icon, color: const Color(0xFF001B44)), title: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF001B44), fontFamily: 'Inter')), subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: onTap),
    );
  }
}
