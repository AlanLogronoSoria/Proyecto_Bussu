import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Ayuda', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _section('¿Cómo usar BUSSU?', [
          '1. Selecciona una ruta en la pestaña "Routes".',
          '2. Toca una ruta para ver el recorrido completo en el mapa.',
          '3. Usa el botón de estrella para guardar tus rutas favoritas.',
          '4. En "Live" puedes ver los buses en tiempo real.',
          '5. Toca una parada en el mapa para ver su información.',
          '6. En "Tickets" gestionas tus boletos digitales.',
          '7. Activa las notificaciones para recibir alertas de tu ruta.',
        ]),
        const SizedBox(height: 24),
        _section('Preguntas Frecuentes', [
          '¿Cómo sé cuándo llega mi bus? — Selecciona tu ruta y verás el ETA estimado en el panel inferior del mapa Live.',
          '¿Puedo ver todas las paradas? — Sí, en el mapa Live presiona "Ver todas las paradas".',
          '¿Cómo reporto un problema? — Usa la opción "Reportar incidente" en tu perfil.',
          '¿Qué significa el color de los buses? — Verde: poca ocupación. Naranja: media. Rojo: alta.',
          '¿Funciona sin internet? — Necesitas conexión para ver posiciones en tiempo real. Las rutas guardadas se cachean.',
        ]),
        const SizedBox(height: 24),
        _section('Contacto', [
          'Email: soporte@bussu.pe',
          'Teléfono: +51 1 555-0123',
          'Horario: Lunes a Viernes 8:00 - 18:00',
          'Dirección: Av. Arequipa 1200, Lima, Perú',
        ]),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _section(String title, List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 12),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 7, right: 10), decoration: const BoxDecoration(color: Color(0xFF001B44), shape: BoxShape.circle)),
          Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter', height: 1.4))),
        ]),
      )),
    ]);
  }
}
