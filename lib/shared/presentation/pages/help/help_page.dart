import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Ayuda', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _introSection(),
        const SizedBox(height: 28),
        _howItWorksSection(),
        const SizedBox(height: 28),
        _mapSection(),
        const SizedBox(height: 28),
        _routesSection(),
        const SizedBox(height: 28),
        _premiumSection(),
        const SizedBox(height: 28),
        _faqSection(),
        const SizedBox(height: 28),
        _contactSection(),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _introSection() {
    return _card(children: [
      const Text('BUSSU', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 8),
      const Text('Sistema Inteligente de Transporte Público', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF434750), fontFamily: 'Inter')),
      const SizedBox(height: 16),
      const Text('BUSSU es la plataforma integral que conecta pasajeros, conductores, cooperativas y autoridades municipales en un solo ecosistema. Utilizando tecnología GPS, mapas OpenStreetMap e inteligencia en tiempo real, BUSSU transforma la experiencia del transporte público.', style: TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter', height: 1.5)),
    ]);
  }

  Widget _howItWorksSection() {
    return _section('¿Cómo funciona BUSSU?', [
      _step('1', 'Explora rutas', 'Selecciona tu ruta en la pestaña Routes. Puedes buscar por nombre, ver todas las paradas y marcar tus rutas favoritas con la estrella.'),
      _step('2', 'Visualiza en el mapa', 'En la pestaña Live verás el recorrido completo: polyline de la ruta, paradas numeradas y buses en tiempo real con colores según ocupación (verde = baja, naranja = media, roja = alta).'),
      _step('3', 'Consulta tiempos', 'Toca cualquier parada en el mapa para ver su información detallada. El ETA estimado te indica cuánto falta para que llegue tu bus.'),
      _step('4', 'Gestiona tickets', 'Si eres usuario Premium, en la pestaña Tickets puedes gestionar tus boletos digitales y ver tu historial de viajes.'),
      _step('5', 'Recibe alertas', 'Activa las notificaciones en tu perfil para recibir alertas sobre tu ruta, incidentes y cambios en el servicio.'),
    ]);
  }

  Widget _mapSection() {
    return _section('Uso del Mapa', [
      _bullet('Acerca y aleja con gestos de pellizco (pinch).'),
      _bullet('Rota el mapa con dos dedos para orientarte.'),
      _bullet('Toca el botón "Mi Ubicación" (ícono azul) para centrar el mapa en tu posición actual.'),
      _bullet('Usa el botón "Ver todas las paradas" para mostrar/ocultar marcadores de paradas.'),
      _bullet('Los buses se muestran como íconos de autobús animados con movimiento suave.'),
      _bullet('Las rutas favoritas aparecen como líneas amarillas punteadas en el mapa.'),
      _bullet('Toca cualquier marcador para ver información detallada.'),
    ]);
  }

  Widget _routesSection() {
    return _section('Uso de Rutas', [
      _bullet('Busca rutas por nombre en la barra de búsqueda.'),
      _bullet('Toca la estrella junto a una ruta para marcarla como favorita.'),
      _bullet('Al seleccionar una ruta, el mapa se centra automáticamente en el recorrido.'),
      _bullet('Verás la polyline completa, paradas numeradas y el punto de inicio/fin.'),
      _bullet('Las rutas favoritas se sincronizan con tu cuenta y persisten entre sesiones.'),
      _bullet('El panel inferior muestra distancia total, número de paradas y coordenadas de inicio/fin.'),
    ]);
  }

  Widget _premiumSection() {
    return _section('Premium', [
      _bullet('Accede a la gestión de tickets y boletería digital.'),
      _bullet('Visualiza tu historial completo de viajes.'),
      _bullet('Recibe notificaciones prioritarias sobre tu ruta.'),
      _bullet('Sin anuncios ni limitaciones de uso del mapa.'),
      _bullet('Para activar Premium, contacta a tu cooperativa o al administrador municipal.'),
    ]);
  }

  Widget _faqSection() {
    return _section('Preguntas Frecuentes', [
      _faqItem('¿Cómo sé cuándo llega mi bus?', 'Selecciona tu ruta en Routes y cambia a la pestaña Live. Verás la posición de los buses en tiempo real y el ETA estimado.'),
      _faqItem('¿Qué significa el color de los buses?', 'Verde: poca ocupación (< 40%). Naranja: ocupación media (40-75%). Rojo: alta ocupación (> 75%).'),
      _faqItem('¿Puedo ver todas las paradas de una ruta?', 'Sí. En el mapa Live presiona "Ver todas las paradas" para mostrar los marcadores de todas las rutas disponibles.'),
      _faqItem('¿Cómo reporto un problema?', 'Dependiendo de tu rol: pasajeros usan Alertas, conductores usan el botón de incidente en el mapa, cooperativas y admin usan Reportar incidente en el perfil.'),
      _faqItem('¿Funciona sin internet?', 'Necesitas conexión para ver posiciones en tiempo real. Las rutas y paradas se cachean para acceso offline limitado.'),
      _faqItem('¿Cómo agrego una nueva parada?', 'Los conductores pueden solicitar paradas tocando el mapa durante un viaje activo. Las cooperativas pueden crearlas desde la pestaña Paradas.'),
      _faqItem('¿Mis datos están seguros?', 'Sí. BUSSU cumple con la Ley de Protección de Datos Personales del Perú (Ley N° 29733). Consulta el Contrato de Confidencialidad en tu perfil.'),
    ]);
  }

  Widget _contactSection() {
    return _card(children: [
      const Text('Contacto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 16),
      _contactRow(Icons.email_outlined, 'soporte@bussu.pe'),
      const SizedBox(height: 10),
      _contactRow(Icons.phone_outlined, '+51 1 555-0123'),
      const SizedBox(height: 10),
      _contactRow(Icons.access_time, 'Lunes a Viernes 8:00 - 18:00'),
      const SizedBox(height: 10),
      _contactRow(Icons.location_on_outlined, 'Av. Arequipa 1200, Lima, Perú'),
    ]);
  }

  Widget _card({required List<Widget> children}) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 12)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }

  Widget _section(String title, List<Widget> items) {
    return _card(children: [
      Row(children: [Container(width: 4, height: 22, decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')))]),
      const SizedBox(height: 16),
      ...items,
    ]);
  }

  Widget _step(String number, String title, String description) {
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter')))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 2),
        Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter', height: 1.4)),
      ])),
    ]));
  }

  Widget _bullet(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 7, right: 12), decoration: const BoxDecoration(color: Color(0xFF001B44), shape: BoxShape.circle)),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter', height: 1.4))),
    ]));
  }

  Widget _faqItem(String question, String answer) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 4),
      Text(answer, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter', height: 1.4)),
    ]));
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 18, color: const Color(0xFF001B44)), const SizedBox(width: 12), Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter'))]);
  }
}
