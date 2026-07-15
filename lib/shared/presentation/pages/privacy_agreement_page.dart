import 'package:flutter/material.dart';

class PrivacyAgreementPage extends StatelessWidget {
  const PrivacyAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Contrato de Confidencialidad', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _section('Tratamiento de Datos', [
          'BUSSU recopila únicamente los datos necesarios para brindar el servicio de transporte público.',
          'Tu nombre, correo electrónico y ubicación se almacenan de forma segura en servidores con cifrado AES-256.',
          'No compartimos tus datos personales con terceros sin tu consentimiento explícito.',
          'Puedes solicitar la eliminación de tus datos en cualquier momento escribiendo a soporte@bussu.pe.',
          'Los datos de ubicación se utilizan exclusivamente para mostrarte buses cercanos y calcular tiempos de llegada.',
        ]),
        const SizedBox(height: 24),
        _section('Uso de Ubicación', [
          'BUSSU solicita acceso a tu ubicación para centrar el mapa y mostrar las paradas y buses cercanos.',
          'La ubicación solo se envía al servidor cuando seleccionas activamente "Mi Ubicación" en el mapa.',
          'No rastreamos tu ubicación en segundo plano.',
          'Puedes desactivar el acceso a ubicación desde los ajustes de tu dispositivo en cualquier momento.',
          'Los datos de ubicación no se almacenan permanentemente; se descartan después de cada sesión.',
        ]),
        const SizedBox(height: 24),
        _section('Política de Privacidad', [
          'Fecha de vigencia: Julio 2026.',
          'Esta política aplica a todos los usuarios de la aplicación BUSSU.',
          'Nos comprometemos a cumplir con la Ley de Protección de Datos Personales (Ley N° 29733 del Perú).',
          'Implementamos medidas técnicas y organizativas para proteger tus datos contra accesos no autorizados.',
          'En caso de brecha de seguridad, notificaremos a los usuarios afectados en un plazo máximo de 72 horas.',
          'Para ejercer tus derechos ARCO (Acceso, Rectificación, Cancelación, Oposición), contáctanos a soporte@bussu.pe.',
        ]),
        const SizedBox(height: 24),
        _section('Información de Confidencialidad', [
          'Toda la información transmitida entre la aplicación y los servidores de BUSSU está cifrada mediante TLS 1.3.',
          'Los datos almacenados en Supabase utilizan Row Level Security (RLS) para garantizar que cada usuario solo acceda a su propia información.',
          'El personal de BUSSU con acceso a datos firma acuerdos de confidencialidad vinculantes.',
          'Realizamos auditorías de seguridad periódicas para garantizar la integridad de nuestros sistemas.',
          'BUSSU no vende, alquila ni comercializa datos de usuarios bajo ninguna circunstancia.',
        ]),
        const SizedBox(height: 40),
        Center(child: Text('BUSSU © 2026 — Todos los derechos reservados', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontFamily: 'Inter'))),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _section(String title, List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter'))]),
      const SizedBox(height: 12),
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('• ', style: TextStyle(fontSize: 14, color: Color(0xFF001B44), fontFamily: 'Inter')),
        Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter', height: 1.5))),
      ]))),
    ]);
  }
}
