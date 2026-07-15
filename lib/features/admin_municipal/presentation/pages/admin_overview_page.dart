import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_roles.dart';
import '../../../../shared/domain/entities/stop_entity.dart';
import '../../../../shared/presentation/widgets/live_map_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/system_alerts_provider.dart';
import '../../domain/entities/cooperativa_status.dart';
import '../../domain/entities/municipal_overview.dart';

class AdminOverviewPage extends ConsumerStatefulWidget {
  const AdminOverviewPage({super.key});
  @override
  ConsumerState<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends ConsumerState<AdminOverviewPage> {
  late final TextEditingController _nombre, _ruc, _buses, _correo, _password;
  bool _estado = true;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(); _ruc = TextEditingController();
    _buses = TextEditingController(); _correo = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _nombre.dispose(); _ruc.dispose(); _buses.dispose();
    _correo.dispose(); _password.dispose();
    super.dispose();
  }

  void _openCreate() {
    _nombre.clear(); _ruc.clear(); _buses.clear(); _correo.clear(); _password.clear();
    _estado = true;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setDlg) => AlertDialog(
      title: const Text('Nueva Cooperativa', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(_nombre, 'Nombre'), const SizedBox(height: 10),
        _field(_ruc, 'RUC'), const SizedBox(height: 10),
        _field(_buses, 'Número de buses', keyboardType: TextInputType.number), const SizedBox(height: 10),
        _field(_correo, 'Correo', keyboardType: TextInputType.emailAddress), const SizedBox(height: 10),
        _field(_password, 'Contraseña BUSSU', obscure: true),
        const SizedBox(height: 12),
        SwitchListTile(title: const Text('Activo', style: TextStyle(fontFamily: 'Inter')), value: _estado, onChanged: (v) => setDlg(() => _estado = v), dense: true, contentPadding: EdgeInsets.zero, activeColor: const Color(0xFF001B44)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          final fn = _nombre.text.trim();
          final email = _correo.text.trim();
          if (fn.isEmpty || email.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre y correo son requeridos'), backgroundColor: Color(0xFFBA1A1A)));
            return;
          }
          ref.read(authNotifierProvider.notifier).register(email: email, password: _password.text.trim(), confirmPassword: _password.text.trim(), fullName: fn, role: UserRole.cooperativaAdmin);
          Navigator.pop(context);
          ref.invalidate(cooperativasStatusProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cooperativa registrada — usuario Auth + Profile creados'), backgroundColor: Color(0xFF001B44)));
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white), child: const Text('Registrar')),
      ],
    )));
  }

  void _openEdit(CooperativaStatus c) {
    _nombre.text = c.name; _ruc.text = c.ruc ?? '';
    _buses.text = '${c.totalBuses}'; _estado = c.activeBuses > 0;
    _correo.clear(); _password.clear();
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setDlg) => AlertDialog(
      title: const Text('Editar Cooperativa', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(_nombre, 'Nombre'), const SizedBox(height: 10),
        _field(_ruc, 'RUC'), const SizedBox(height: 10),
        _field(_buses, 'Número de buses', keyboardType: TextInputType.number), const SizedBox(height: 10),
        SwitchListTile(title: const Text('Activo', style: TextStyle(fontFamily: 'Inter')), value: _estado, onChanged: (v) => setDlg(() => _estado = v), dense: true, contentPadding: EdgeInsets.zero, activeColor: const Color(0xFF001B44)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          if (_nombre.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre requerido'), backgroundColor: Color(0xFFBA1A1A))); return; }
          Navigator.pop(context);
          ref.invalidate(cooperativasStatusProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cooperativa actualizada'), backgroundColor: Color(0xFF001B44)));
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001B44), foregroundColor: Colors.white), child: const Text('Guardar')),
      ],
    )));
  }

  void _confirmDelete(CooperativaStatus c) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Eliminar Cooperativa', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      content: Text('¿Eliminar "${c.name}" permanentemente? Esta acción no se puede deshacer.', style: const TextStyle(fontFamily: 'Inter')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
          ref.invalidate(cooperativasStatusProvider);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${c.name} eliminada'), backgroundColor: const Color(0xFFBA1A1A)));
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white), child: const Text('Eliminar')),
      ],
    ));
  }

  Widget _field(TextEditingController ctrl, String label, {TextInputType? keyboardType, bool obscure = false}) {
    return TextField(controller: ctrl, obscureText: obscure, keyboardType: keyboardType, decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontFamily: 'Inter'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF001B44))), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)));
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(municipalOverviewProvider);
    final coopStatus = ref.watch(cooperativasStatusProvider);
    final premiumSubs = ref.watch(premiumSubscriptionsProvider);

    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Overview Municipal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
      const SizedBox(height: 16),
      overview.when(loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))), error: (_, __) => const SizedBox.shrink(), data: (o) => _buildMetrics(o)),
      const SizedBox(height: 16),
      _buildQuickLinks(context),
      const SizedBox(height: 20),
      _buildMapCard(),
      const SizedBox(height: 20),
      _buildCooperativasCrud(coopStatus),
      const SizedBox(height: 20),
      _buildPremiumCrud(premiumSubs),
      const SizedBox(height: 20),
      _buildIncidentSummary(),
      const SizedBox(height: 20),
      _buildAllStopsCard(coopStatus),
    ]);
  }

  Widget _buildMetrics(MunicipalOverview o) => Column(children: [
    Row(children: [
      _metricCard(Icons.business, '${o.totalCooperativas}', 'Cooperativas', const Color(0xFF001B44)),
      const SizedBox(width: 10),
      _metricCard(Icons.directions_bus, '${o.totalBuses}', 'Buses Totales', const Color(0xFF001B44)),
    ]),
    const SizedBox(height: 10),
    Row(children: [
      _metricCard(Icons.people, '${o.totalDrivers}', 'Conductores', const Color(0xFF001B44)),
      const SizedBox(width: 10),
      _metricCard(Icons.warning_amber, '${o.activeAlerts}', 'Incidentes', const Color(0xFFBA1A1A)),
    ]),
  ]);

  Widget _metricCard(IconData icon, String value, String label, Color color) => Expanded(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(children: [Icon(icon, color: color, size: 32), const SizedBox(height: 8), Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color, fontFamily: 'Inter')), Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))])));

  Widget _buildQuickLinks(BuildContext ctx) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Gestión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
    const SizedBox(height: 12),
    _linkTile(Icons.workspace_premium, 'Premium', 'Administrar suscripciones', () => Navigator.pushNamed(ctx, '/admin/premium')),
    _linkTile(Icons.group, 'Usuarios', 'Gestionar roles y permisos', () => Navigator.pushNamed(ctx, '/admin/users')),
  ]));

  Widget _linkTile(IconData icon, String title, String sub, VoidCallback onTap) => Padding(padding: const EdgeInsets.only(bottom: 4), child: ListTile(leading: Icon(icon, color: const Color(0xFF001B44)), title: Text(title, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))), subtitle: Text(sub, style: const TextStyle(fontSize: 12, fontFamily: 'Inter', color: Color(0xFF434750))), trailing: const Icon(Icons.chevron_right, color: Color(0xFF434750)), onTap: onTap, dense: true, contentPadding: EdgeInsets.zero));

  Widget _buildMapCard() {
    const mockStops = [StopEntity(id: 'a1', name: 'Plaza de Armas', latitude: -12.0464, longitude: -77.0428, orderIndex: 1), StopEntity(id: 'a2', name: 'Jr. de la Union', latitude: -12.0452, longitude: -77.0410, orderIndex: 2)];
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), clipBehavior: Clip.antiAlias, height: 200, child: Stack(children: [LiveMapWidget(initialCenter: const LatLng(-12.0464, -77.0428), initialZoom: 13, stops: mockStops), Positioned(top: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.map, size: 16, color: Color(0xFF001B44)), SizedBox(width: 6), Text('Visualización general', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))])))]));
  }

  Widget _buildCooperativasCrud(AsyncValue<List> coopStatus) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Cooperativas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), TextButton.icon(onPressed: _openCreate, icon: const Icon(Icons.add, size: 18), label: const Text('Nueva', style: TextStyle(fontFamily: 'Inter')), style: TextButton.styleFrom(foregroundColor: const Color(0xFF001B44)))]),
      const SizedBox(height: 8),
      coopStatus.when(loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))), error: (_, __) => const Text('Error'), data: (List list) {
        final coops = list.cast<CooperativaStatus>();
        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columnSpacing: 16, columns: const [
          DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('RUC', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Buses', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Correo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        ], rows: coops.map((c) => DataRow(cells: [
          DataCell(Text(c.name, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44)))),
          DataCell(Text(c.ruc ?? '', style: const TextStyle(fontFamily: 'Inter'))),
          DataCell(Text('${c.activeBuses}/${c.totalBuses}', style: const TextStyle(fontFamily: 'Inter'))),
          DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: (c.activeBuses > 0 ? Colors.green : Colors.grey).withAlpha(20), borderRadius: BorderRadius.circular(6)), child: Text(c.activeBuses > 0 ? 'Activo' : 'Inactivo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: c.activeBuses > 0 ? Colors.green.shade700 : const Color(0xFF434750))))),
          DataCell(const Text('—', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF434750)))),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF434750)), onPressed: () => _openEdit(c), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
            IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)), onPressed: () => _confirmDelete(c), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
          ])),
        ])).toList()));
      }),
    ]));
  }

  Widget _buildPremiumCrud(AsyncValue<List<Map<String, dynamic>>> premiumSubs) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.workspace_premium, color: Color(0xFFFED000), size: 20), SizedBox(width: 8), Text('Administración Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter'))]),
      const SizedBox(height: 12),
      premiumSubs.when(loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))), error: (_, __) => const Text('Error'), data: (subs) {
        if (subs.isEmpty) return const Text('Sin suscripciones', style: TextStyle(color: Color(0xFF434750), fontFamily: 'Inter'));
        final rows = subs.map((s) {
          final profile = s['profiles'] as Map<String, dynamic>? ?? {};
          final name = profile['full_name'] as String? ?? '';
          final email = profile['email'] as String? ?? '';
          final status = s['status'] as String? ?? 'active';
          final createdAt = s['created_at'] as String?;
          final expiresAt = s['expires_at'] as String?;
          final id = s['id'] as String? ?? '';
          return DataRow(cells: [
            DataCell(Text(name.isNotEmpty ? name : 'Usuario', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44)))),
            DataCell(Text(email, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF001B44)))),
            DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(
              color: status == 'active' ? Colors.green.withAlpha(20) : status == 'suspended' ? const Color(0xFFBA1A1A).withAlpha(20) : Colors.orange.withAlpha(30),
              borderRadius: BorderRadius.circular(6)),
              child: Text(status == 'active' ? 'Activo' : status == 'suspended' ? 'Suspendido' : 'Expirado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Inter', color: status == 'active' ? Colors.green.shade700 : status == 'suspended' ? const Color(0xFFBA1A1A) : Colors.orange.shade800)))),
            DataCell(Text(createdAt != null ? _fmtDate(createdAt) : '—', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF434750)))),
            DataCell(Text(expiresAt != null ? _fmtDate(expiresAt) : '—', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF434750)))),
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              if (status == 'active') IconButton(icon: const Icon(Icons.pause_circle_outline, size: 18, color: Color(0xFFBA1A1A)), onPressed: () { ref.read(networkMonitorRepositoryProvider).updateSubscriptionStatus(id, 'suspended'); ref.invalidate(premiumSubscriptionsProvider); }, constraints: const BoxConstraints(), padding: EdgeInsets.zero, tooltip: 'Desactivar'),
              if (status != 'active') IconButton(icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.green), onPressed: () { ref.read(networkMonitorRepositoryProvider).updateSubscriptionStatus(id, 'active'); ref.invalidate(premiumSubscriptionsProvider); }, constraints: const BoxConstraints(), padding: EdgeInsets.zero, tooltip: 'Activar'),
              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)), onPressed: () { ref.read(networkMonitorRepositoryProvider).updateSubscriptionStatus(id, 'cancelled'); ref.invalidate(premiumSubscriptionsProvider); }, constraints: const BoxConstraints(), padding: EdgeInsets.zero, tooltip: 'Eliminar'),
            ])),
          ]);
        }).toList();
        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columnSpacing: 12, columns: const [
          DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Correo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Inicio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Expira', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        ], rows: rows));
      }),
    ]));
  }

  String _fmtDate(String iso) { try { final d = DateTime.parse(iso); return '${d.day}/${d.month}/${d.year}'; } catch (_) { return iso; } }

  Widget _buildIncidentSummary() {
    const incidents = [
      {'title': 'Frenado brusco ABC-123', 'route': 'Ruta A', 'status': 'Pendiente', 'severity': 'high'},
      {'title': 'Motor recalentado DEF-456', 'route': 'Ruta C', 'status': 'En revisión', 'severity': 'medium'},
      {'title': 'Puerta no cierra ABC-124', 'route': 'Ruta B', 'status': 'Resuelto', 'severity': 'low'},
    ];
    Color sevColor(String s) => s == 'high' ? const Color(0xFFBA1A1A) : s == 'medium' ? const Color(0xFFFED000) : Colors.blue;
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Últimos Incidentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), Text('${incidents.length} activos', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))]),
      const SizedBox(height: 12),
      ...incidents.map((inc) {
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
          Container(width: 4, height: 36, decoration: BoxDecoration(color: sevColor(inc['severity']!), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(inc['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), _incidentStatusRow(inc)])),
        ]));
      }),
    ]));
  }

  Widget _incidentStatusRow(Map<String, String> inc) {
    Color bg; Color fg;
    if (inc['status'] == 'Pendiente') { bg = const Color(0xFFBA1A1A).withAlpha(20); fg = const Color(0xFFBA1A1A); }
    else if (inc['status'] == 'En revisión') { bg = const Color(0xFFFED000).withAlpha(40); fg = const Color(0xFF001B44); }
    else { bg = Colors.green.withAlpha(20); fg = Colors.green.shade700; }
    return Row(children: [
      Text(inc['route']!, style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
      const SizedBox(width: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)), child: Text(inc['status']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: fg))),
    ]);
  }

  Widget _buildAllStopsCard(AsyncValue<List> coopStatus) {
    const allStops = [
      {'name': 'Plaza de Armas', 'coop': 'TransLima', 'route': 'Ruta A', 'lat': '-12.0464', 'lng': '-77.0428'},
      {'name': 'Jr. de la Union', 'coop': 'TransLima', 'route': 'Ruta A', 'lat': '-12.0452', 'lng': '-77.0410'},
      {'name': 'Parque Kennedy', 'coop': 'Metropolitano', 'route': 'Ruta B', 'lat': '-12.0480', 'lng': '-77.0340'},
      {'name': 'Larcomar', 'coop': 'Metropolitano', 'route': 'Ruta B', 'lat': '-12.0490', 'lng': '-77.0350'},
    ];
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Todas las Paradas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Spacer(), Text('${allStops.length} paradas', style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))]),
      const SizedBox(height: 12),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columnSpacing: 16, columns: const [
        DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Cooperativa', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Ruta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataColumn(label: Text('Coordenadas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
      ], rows: allStops.map((s) => DataRow(cells: [
        DataCell(Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter', color: Color(0xFF001B44)))),
        DataCell(Text(s['coop']!, style: const TextStyle(fontFamily: 'Inter'))),
        DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF001B44).withAlpha(20), borderRadius: BorderRadius.circular(4)), child: Text(s['route']!, style: const TextStyle(fontSize: 12, fontFamily: 'Inter', color: Color(0xFF001B44))))),
        DataCell(Text('${s['lat']}, ${s['lng']}', style: const TextStyle(fontSize: 11, fontFamily: 'Inter', color: Color(0xFF434750)))),
      ])).toList())),
    ]));
  }
}
