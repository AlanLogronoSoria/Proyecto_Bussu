-- =============================================================================
-- Andes Mobility: Datos de prueba (seed)
-- =============================================================================

-- Cooperativas de prueba
insert into cooperativas (id, name, ruc, status) values
  ('c0000000-0000-0000-0000-000000000001', 'TransLima Express', '20100000001', 'active'),
  ('c0000000-0000-0000-0000-000000000002', 'Metropolitano Norte', '20100000002', 'active'),
  ('c0000000-0000-0000-0000-000000000003', 'BusPerú Sur', '20100000003', 'active')
on conflict (id) do nothing;

-- Rutas de prueba (con polyline WKT simulada)
insert into routes (id, cooperativa_id, name, polyline, color) values
  ('r0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001',
   'Ruta A - Centro Histórico',
   st_geogfromtext('LINESTRING(-77.0428 -12.0464, -77.0360 -12.050, -77.0300 -12.052)'),
   '#001B44'),
  ('r0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001',
   'Ruta B - Miraflores',
   st_geogfromtext('LINESTRING(-77.0300 -12.120, -77.0350 -12.115, -77.0400 -12.110)'),
   '#FED000'),
  ('r0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000002',
   'Ruta C - San Isidro',
   st_geogfromtext('LINESTRING(-77.0330 -12.097, -77.0300 -12.095, -77.0270 -12.093)'),
   '#1B5E20')
on conflict (id) do nothing;

-- Buses de prueba
insert into buses (id, plate, cooperativa_id, route_id, capacity, hardware_device_id) values
  ('b0000000-0000-0000-0000-000000000001', 'ABC-123', 'c0000000-0000-0000-0000-000000000001',
   'r0000000-0000-0000-0000-000000000001', 40, 'esp32-device-001'),
  ('b0000000-0000-0000-0000-000000000002', 'ABC-124', 'c0000000-0000-0000-0000-000000000001',
   'r0000000-0000-0000-0000-000000000001', 45, 'esp32-device-002'),
  ('b0000000-0000-0000-0000-000000000003', 'ABC-125', 'c0000000-0000-0000-0000-000000000001',
   'r0000000-0000-0000-0000-000000000002', 40, 'esp32-device-003'),
  ('b0000000-0000-0000-0000-000000000004', 'DEF-456', 'c0000000-0000-0000-0000-000000000002',
   'r0000000-0000-0000-0000-000000000003', 50, 'esp32-device-004'),
  ('b0000000-0000-0000-0000-000000000005', 'DEF-457', 'c0000000-0000-0000-0000-000000000002',
   'r0000000-0000-0000-0000-000000000003', 50, 'esp32-device-005')
on conflict (id) do nothing;

-- Paradas de prueba
insert into stops (id, route_id, name, location, order_index, distance_along_route) values
  ('s0000000-0000-0000-0000-000000000001', 'r0000000-0000-0000-0000-000000000001',
   'Plaza de Armas',
   st_geogfromtext('POINT(-77.0428 -12.0464)'), 1, 0),
  ('s0000000-0000-0000-0000-000000000002', 'r0000000-0000-0000-0000-000000000001',
   'Jirón de la Unión',
   st_geogfromtext('POINT(-77.0360 -12.0500)'), 2, 800),
  ('s0000000-0000-0000-0000-000000000003', 'r0000000-0000-0000-0000-000000000001',
   'Parque Universitario',
   st_geogfromtext('POINT(-77.0300 -12.0520)'), 3, 1500),
  ('s0000000-0000-0000-0000-000000000004', 'r0000000-0000-0000-0000-000000000002',
   'Parque Kennedy',
   st_geogfromtext('POINT(-77.0300 -12.1200)'), 1, 0),
  ('s0000000-0000-0000-0000-000000000005', 'r0000000-0000-0000-0000-000000000002',
   'Larcomar',
   st_geogfromtext('POINT(-77.0400 -12.1100)'), 2, 1500)
on conflict (id) do nothing;

-- Posiciones iniciales de buses (simuladas)
insert into bus_live_position (bus_id, location, speed_kmh, heading, passenger_count) values
  ('b0000000-0000-0000-0000-000000000001',
   st_geogfromtext('POINT(-77.039 -12.047)'), 32, 90, 15),
  ('b0000000-0000-0000-0000-000000000002',
   st_geogfromtext('POINT(-77.033 -12.051)'), 28, 90, 22),
  ('b0000000-0000-0000-0000-000000000004',
   st_geogfromtext('POINT(-77.031 -12.096)'), 45, 270, 30)
on conflict (bus_id) do update set
  location = excluded.location,
  speed_kmh = excluded.speed_kmh,
  heading = excluded.heading,
  passenger_count = excluded.passenger_count,
  updated_at = now();

-- Alertas de prueba
insert into system_alerts (id, scope, severity, title, description, route_id) values
  ('a0000000-0000-0000-0000-000000000001', 'route', 'medium',
   'Desvío temporal en Ruta A',
   'La Ruta A tiene un desvío por obras municipales en Jr. de la Unión.',
   'r0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002', 'system', 'low',
   'Mantenimiento programado',
   'El sistema estará en mantenimiento el domingo de 2:00 a 4:00 AM.',
   null),
  ('a0000000-0000-0000-0000-000000000003', 'route', 'high',
   'Bloqueo en Ruta C',
   'Manifestación bloqueando la vía en Av. Camino Real.',
    'r0000000-0000-0000-0000-000000000003')
on conflict (id) do nothing;

-- Perfiles de prueba (requiere que los auth.users existan previamente)
-- Crear usuarios via Supabase Auth API con estos UUIDs:
--   usuario:   u0000000-0000-0000-0000-000000000001
--   conductor: u0000000-0000-0000-0000-000000000002
--   coop_admin: u0000000-0000-0000-0000-000000000003
--   municipal:  u0000000-0000-0000-0000-000000000004
insert into profiles (id, role, full_name, email, cooperativa_id) values
  ('u0000000-0000-0000-0000-000000000001', 'usuario', 'Ana Usuario', 'usuario@bussu.app', null),
  ('u0000000-0000-0000-0000-000000000002', 'conductor', 'Carlos Conductor', 'conductor@bussu.app', 'c0000000-0000-0000-0000-000000000001'),
  ('u0000000-0000-0000-0000-000000000003', 'cooperativa_admin', 'Maria Cooperativa', 'coop@bussu.app', 'c0000000-0000-0000-0000-000000000001'),
  ('u0000000-0000-0000-0000-000000000004', 'municipal_admin', 'Pedro Municipal', 'admin@bussu.app', null)
on conflict (id) do nothing;

insert into drivers (id, cooperativa_id, license_number, assigned_bus_id) values
  ('u0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'Q-12345678', 'b0000000-0000-0000-0000-000000000001')
on conflict (id) do nothing;

insert into trips (id, bus_id, route_id, driver_id, started_at, ended_at, status) values
  ('t0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'r0000000-0000-0000-0000-000000000001', 'u0000000-0000-0000-0000-000000000002', now() - interval '2 hours', now() - interval '1 hour', 'completed'),
  ('t0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'r0000000-0000-0000-0000-000000000001', 'u0000000-0000-0000-0000-000000000002', now() - interval '30 minutes', null, 'active')
on conflict (id) do nothing;

insert into user_stop_presence (user_id, stop_id) values
  ('u0000000-0000-0000-0000-000000000001', 's0000000-0000-0000-0000-000000000001')
on conflict do nothing;

insert into device_registry (device_id, bus_id, status) values
  ('esp32-device-001', 'b0000000-0000-0000-0000-000000000001', 'online'),
  ('esp32-device-002', 'b0000000-0000-0000-0000-000000000002', 'online'),
  ('esp32-device-003', 'b0000000-0000-0000-0000-000000000003', 'online'),
  ('esp32-device-004', 'b0000000-0000-0000-0000-000000000004', 'online'),
  ('esp32-device-005', 'b0000000-0000-0000-0000-000000000005', 'online')
on conflict (device_id) do nothing;

insert into bridge_health (instance_id, status, last_heartbeat) values
  ('bridge-local', 'healthy', now())
on conflict (instance_id) do nothing;
