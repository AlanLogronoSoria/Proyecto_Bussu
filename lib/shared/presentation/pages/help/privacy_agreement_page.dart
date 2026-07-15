import 'package:flutter/material.dart';

class PrivacyAgreementPage extends StatelessWidget {
  const PrivacyAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Contrato de Confidencialidad', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _introCard(),
        const SizedBox(height: 28),
        _privacyPolicySection(),
        const SizedBox(height: 28),
        _dataTreatmentSection(),
        const SizedBox(height: 28),
        _gpsSection(),
        const SizedBox(height: 28),
        _personalInfoSection(),
        const SizedBox(height: 28),
        _termsSection(),
        const SizedBox(height: 28),
        _contactSection(),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _introCard() {
    return _card(children: [
      const Row(children: [Icon(Icons.shield_outlined, color: Color(0xFF001B44), size: 28), SizedBox(width: 12), Text('BUSSU', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF001B44), fontFamily: 'Inter'))]),
      const SizedBox(height: 12),
      const Text('Contrato de Confidencialidad y Privacidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF434750), fontFamily: 'Inter')),
      const SizedBox(height: 8),
      const Text('Fecha de vigencia: Julio 2026', style: TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
      const SizedBox(height: 12),
      const Text('Al utilizar BUSSU, aceptas los términos descritos en este documento. Este contrato establece cómo recopilamos, usamos, almacenamos y protegemos tu información personal y datos de ubicación.', style: TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter', height: 1.5)),
    ]);
  }

  Widget _privacyPolicySection() {
    return _section('Política de Privacidad', [
      _item('BUSSU cumple con la Ley de Protección de Datos Personales del Perú (Ley N° 29733) y su reglamento.', ''),
      _item('Esta política aplica a todos los usuarios registrados en la plataforma BUSSU sin excepción.', ''),
      _item('Los datos personales se recolectan únicamente con el consentimiento explícito del usuario durante el proceso de registro.', ''),
      _item('El usuario tiene derecho a ejercer sus derechos ARCO (Acceso, Rectificación, Cancelación y Oposición) en cualquier momento.', ''),
      _item('Para ejercer tus derechos ARCO, envía un correo a soporte@bussu.pe con el asunto "Derechos ARCO" y tu solicitud será procesada en un plazo máximo de 15 días hábiles.', ''),
      _item('BUSSU no vende, alquila, cede ni comercializa datos personales de usuarios a terceros bajo ninguna circunstancia.', ''),
      _item('En caso de brecha de seguridad que comprometa datos personales, notificaremos a los usuarios afectados en un plazo máximo de 72 horas desde la detección del incidente.', ''),
      _item('Realizamos auditorías internas de seguridad cada 6 meses para garantizar la integridad de nuestros sistemas de protección de datos.', ''),
    ]);
  }

  Widget _dataTreatmentSection() {
    return _section('Tratamiento de Datos', [
      _item('Datos recolectados:', 'Nombre completo, correo electrónico, rol en el sistema, información de perfil, preferencias de rutas favoritas y ubicación geográfica cuando el usuario lo autoriza explícitamente.'),
      _item('Finalidad del tratamiento:', 'Proveer el servicio de visualización de rutas y buses en tiempo real, calcular tiempos estimados de llegada (ETA), gestionar tickets digitales, y enviar notificaciones relevantes al usuario.'),
      _item('Base legal:', 'Consentimiento informado otorgado durante el registro, y ejecución del contrato de servicio entre BUSSU y el usuario.'),
      _item('Almacenamiento:', 'Los datos se almacenan en servidores seguros con cifrado AES-256. Supabase proporciona Row Level Security (RLS) garantizando que cada usuario acceda exclusivamente a sus propios datos.'),
      _item('Transferencia internacional:', 'Los servidores de Supabase pueden estar ubicados fuera del Perú. Al aceptar este contrato, consientes la transferencia internacional de tus datos bajo las mismas garantías de seguridad.'),
      _item('Plazo de conservación:', 'Los datos se conservan mientras la cuenta esté activa. Al eliminar tu cuenta, tus datos personales se eliminan en un plazo de 30 días. Los datos anonimizados de uso pueden conservarse con fines estadísticos.'),
      _item('Eliminación de datos:', 'Puedes solicitar la eliminación completa de tus datos en cualquier momento escribiendo a soporte@bussu.pe.'),
    ]);
  }

  Widget _gpsSection() {
    return _section('Uso del GPS y Ubicación', [
      _item('BUSSU solicita acceso a la ubicación del dispositivo exclusivamente para:', 'Centrar el mapa en tu posición actual al presionar "Mi Ubicación", mostrar paradas y buses cercanos a tu ubicación, y calcular distancias hacia las paradas.'),
      _item('La ubicación solo se transmite al servidor cuando el usuario presiona activamente el botón "Mi Ubicación" en el mapa.', ''),
      _item('BUSSU NO rastrea tu ubicación en segundo plano. No hay seguimiento continuo ni monitoreo pasivo de tu posición.', ''),
      _item('Los datos de ubicación enviados al servidor se descartan inmediatamente después de procesar la solicitud. No se almacenan coordenadas históricas de los pasajeros.', ''),
      _item('Puedes revocar el permiso de ubicación en cualquier momento desde los ajustes de tu dispositivo. La funcionalidad del mapa seguirá disponible sin tu ubicación.', ''),
      _item('Para conductores, la ubicación se publica durante el viaje activo exclusivamente para actualizar la posición del bus en el mapa de los pasajeros. Al finalizar el viaje, la publicación se detiene.', ''),
    ]);
  }

  Widget _personalInfoSection() {
    return _section('Uso de Información Personal', [
      _item('Tu nombre y correo son visibles únicamente para los administradores de tu cooperativa y el administrador municipal.', ''),
      _item('Los pasajeros no pueden ver información personal de otros pasajeros.', ''),
      _item('Los conductores tienen acceso a su propio perfil y a los datos operativos del bus que conducen.', ''),
      _item('Las cooperativas pueden ver los datos de sus conductores registrados, pero no de los pasajeros.', ''),
      _item('El administrador municipal tiene acceso a datos agregados y anonimizados para fines de gestión y reportes.', ''),
      _item('Toda consulta a la base de datos está protegida por Row Level Security (RLS) de Supabase, garantizando el principio de mínimo privilegio.', ''),
    ]);
  }

  Widget _termsSection() {
    return _section('Condiciones de Uso', [
      _item('Aceptación:', 'Al registrarte y usar BUSSU, aceptas de forma expresa y sin reservas todas las condiciones establecidas en este contrato.'),
      _item('Uso adecuado:', 'Te comprometes a usar BUSSU exclusivamente para los fines previstos: consulta de rutas, visualización de transporte público, gestión de tickets y comunicación con los actores del sistema.'),
      _item('Prohibiciones:', 'Está prohibido el uso de BUSSU para actividades ilícitas, extracción no autorizada de datos, ingeniería inversa, o cualquier acción que comprometa la seguridad del sistema.'),
      _item('Responsabilidad:', 'BUSSU se esfuerza por ofrecer datos precisos de ubicación y tiempos, pero no garantiza exactitud absoluta debido a factores externos como tráfico, condiciones climáticas y disponibilidad de GPS.'),
      _item('Modificaciones:', 'BUSSU se reserva el derecho de modificar estas condiciones. Los cambios serán notificados a través de la aplicación con al menos 15 días de anticipación.'),
      _item('Suspensión:', 'BUSSU puede suspender o cancelar cuentas que violen estas condiciones, previa notificación al usuario afectado.'),
    ]);
  }

  Widget _contactSection() {
    return _card(children: [
      const Text('Contacto para Asuntos Legales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 14),
      _contactRow(Icons.email_outlined, 'soporte@bussu.pe'),
      const SizedBox(height: 8),
      _contactRow(Icons.phone_outlined, '+51 1 555-0123'),
      const SizedBox(height: 8),
      _contactRow(Icons.location_on_outlined, 'Av. Arequipa 1200, Lima, Perú'),
      const SizedBox(height: 16),
      Text('BUSSU © 2026 — Todos los derechos reservados', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontFamily: 'Inter')),
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

  Widget _item(String title, String? description) {
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 8, right: 12), decoration: BoxDecoration(color: const Color(0xFF001B44), shape: BoxShape.circle)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter', height: 1.4)),
        ],
      ])),
    ]));
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 18, color: const Color(0xFF001B44)), const SizedBox(width: 12), Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter'))]);
  }
}
