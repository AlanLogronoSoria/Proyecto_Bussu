-- =============================================================================
-- Andes Mobility: Webhooks y Storage
-- =============================================================================

-- 9. WEBHOOKS (Database Webhooks)
-- =============================================================================
-- Configurar desde el Dashboard de Supabase:
-- Database → Webhooks → Create Webhook
--
-- Webhook 1: Notificación de llegada a parada
--   Name: bus_arrival_push
--   Table: bus_stop_events
--   Events: Insert
--   URL: https://[PROJECT_REF].supabase.co/functions/v1/send-push-notification
--   HTTP Method: POST
--   Headers: Authorization: Bearer [SUPABASE_SERVICE_ROLE_KEY]
--
-- Webhook 2: Alerta de nuevo viaje iniciado
--   Name: trip_started_notify
--   Table: trips
--   Events: Insert
--   Filter: status = 'active'
--   URL: https://[PROJECT_REF].supabase.co/functions/v1/send-push-notification
--   HTTP Method: POST

-- 10. STORAGE BUCKETS
-- =============================================================================

-- Crear buckets (ejecutar en SQL Editor)
-- Nota: Supabase no soporta CREATE BUCKET via SQL directo en todos los entornos.
-- Usar el Dashboard o la API de Management.

-- Bucket: avatars (imágenes de perfil)
--   Name: avatars
--   Public: false
--   File size limit: 5MB
--   Allowed MIME types: image/png, image/jpeg, image/webp

-- Bucket: documents (documentos legales, RUC, licencias)
--   Name: documents
--   Public: false
--   File size limit: 10MB
--   Allowed MIME types: application/pdf, image/png, image/jpeg

-- 10.1 Políticas RLS para Storage

-- Avatars: lectura pública
-- create policy "Avatars públicos"
-- on storage.objects for select
-- using (bucket_id = 'avatars');

-- Avatars: usuario sube su propio avatar
-- create policy "Usuario sube su avatar"
-- on storage.objects for insert
-- with check (
--   bucket_id = 'avatars'
--   and (storage.foldername(name))[1] = auth.uid()::text
-- );

-- Documents: solo admins
-- create policy "Admins ven documentos"
-- on storage.objects for select
-- using (
--   bucket_id = 'documents'
--   and auth_user_role() in ('cooperativa_admin', 'municipal_admin')
-- );

-- =============================================================================
-- 11. ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =============================================================================

-- Búsqueda rápida de viajes por conductor
create index if not exists idx_trips_driver_status
  on trips(driver_id, status);

-- Búsqueda rápida de viajes por ruta
create index if not exists idx_trips_route
  on trips(route_id);

-- Búsqueda de mensajes de chat por conversación
create index if not exists idx_chat_messages_conversation
  on chat_messages(conversation_id, sent_at desc);

-- Búsqueda de alertas activas
create index if not exists idx_system_alerts_unresolved
  on system_alerts(scope, severity) where resolved_at is null;

-- Búsqueda de suscripciones por usuario
create index if not exists idx_premium_user
  on premium_subscriptions(user_id, status);

-- Búsqueda de solicitudes de parada pendientes
create index if not exists idx_stop_requests_pending
  on stop_requests(status) where status = 'pending';

-- =============================================================================
-- 12. POSTGIS: CONSULTAS ESPACIALES ÚTILES
-- =============================================================================

-- 12.1 Buses dentro de un radio (ej: 500m de un punto)
-- select b.id, b.plate, st_distance(blp.location, st_geogfromtext('POINT(-77.0428 -12.0464)')) as distancia
-- from bus_live_position blp
-- join buses b on b.id = blp.bus_id
-- where st_dwithin(blp.location, st_geogfromtext('POINT(-77.0428 -12.0464)'), 500)
-- order by distancia;

-- 12.2 Paradas más cercanas a una coordenada (KNN - K Nearest Neighbors)
-- select s.id, s.name, st_distance(s.location, st_geogfromtext('POINT(-77.0428 -12.0464)')) as distancia
-- from stops s
-- order by s.location <-> st_geogfromtext('POINT(-77.0428 -12.0464)')
-- limit 5;

-- 12.3 Longitud de una ruta en metros
-- select id, name, st_length(polyline) as longitud_metros
-- from routes;

-- 12.4 Progreso de un bus sobre la polyline de su ruta
-- select
--   b.id as bus_id,
--   st_linelocatepoint(r.polyline, blp.location) * st_length(r.polyline) as progreso_metros
-- from bus_live_position blp
-- join buses b on b.id = blp.bus_id
-- join routes r on r.id = b.route_id;
