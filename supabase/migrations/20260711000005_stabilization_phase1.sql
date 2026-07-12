-- =============================================================================
-- Andes Mobility: Fase 1 de Estabilización — Correcciones Críticas
--
-- C01: RLS policies para tablas sin cobertura
-- C02: Corregir device_registry policy (usaba using(true))
-- C07: Agregar SET search_path = '' a SECURITY DEFINER functions
-- C08: Validar role en handle_new_user() trigger
-- =============================================================================

-- =============================================================================
-- C07: Agregar SET search_path = '' a funciones SECURITY DEFINER
-- Esto previene ataques de search-path injection.
-- =============================================================================

create or replace function auth_user_role()
returns user_role
set search_path = ''
language sql stable security definer as $$
  select coalesce(
    (select role from profiles where id = auth.uid()),
    'usuario'::user_role
  );
$$;

create or replace function auth_user_cooperativa()
returns uuid
set search_path = ''
language sql stable security definer as $$
  select cooperativa_id from profiles where id = auth.uid();
$$;

-- =============================================================================
-- C08: Validar role en handle_new_user() para evitar crash del trigger
-- por valores inválidos en raw_user_meta_data.role
-- =============================================================================

create or replace function handle_new_user()
returns trigger
set search_path = ''
language plpgsql security definer as $$
declare
  raw_role text;
  valid_role user_role;
begin
  raw_role := new.raw_user_meta_data->>'role';

  -- Validar role antes de castear: si es inválido, usar 'usuario'
  valid_role := case raw_role
    when 'usuario' then 'usuario'::user_role
    when 'conductor' then 'conductor'::user_role
    when 'cooperativa_admin' then 'cooperativa_admin'::user_role
    when 'municipal_admin' then 'municipal_admin'::user_role
    else 'usuario'::user_role
  end;

  insert into profiles (id, role, full_name, email)
  values (
    new.id,
    valid_role,
    coalesce(
      trim(new.raw_user_meta_data->>'full_name'),
      trim(new.raw_user_meta_data->>'fullName'),
      trim(new.email)
    ),
    new.email
  );
  return new;
end;
$$;

-- =============================================================================
-- C01: RLS policies para las 4 tablas sin cobertura
-- =============================================================================

-- bus_telemetry_history: admins y conductors ven el histórico de sus buses
create policy "Admins ven historial de telemetría"
  on bus_telemetry_history for select
  using (auth_user_role() in ('cooperativa_admin', 'municipal_admin'));

create policy "Conductor ve historial de su bus asignado"
  on bus_telemetry_history for select
  using (
    exists (
      select 1 from drivers d
      join buses b on b.id = d.assigned_bus_id
      where d.id = auth.uid()
        and b.id = bus_telemetry_history.bus_id
    )
  );

-- bus_stop_events: admins y participantes del trip
create policy "Admins ven eventos de parada"
  on bus_stop_events for select
  using (auth_user_role() in ('cooperativa_admin', 'municipal_admin'));

create policy "Conductor ve eventos de su viaje"
  on bus_stop_events for select
  using (
    exists (
      select 1 from trips t
      where t.id = bus_stop_events.trip_id
        and t.driver_id = auth.uid()
    )
  );

-- stop_requests: conductor ve sus solicitudes, admin coop las gestiona
create policy "Conductor ve sus solicitudes de parada"
  on stop_requests for select
  using (driver_id = auth.uid());

create policy "Admin cooperativa gestiona solicitudes de parada"
  on stop_requests for all
  using (
    exists (
      select 1 from drivers d
      where d.id = stop_requests.driver_id
        and d.cooperativa_id = auth_user_cooperativa()
    )
    or auth_user_role() = 'municipal_admin'
  );

-- chat_conversations: participantes ven y gestionan
create policy "Participantes ven conversaciones"
  on chat_conversations for select
  using (
    driver_id = auth.uid()
    or cooperativa_id = auth_user_cooperativa()
    or auth_user_role() = 'municipal_admin'
  );

create policy "Participantes gestionan conversaciones"
  on chat_conversations for all
  using (
    driver_id = auth.uid()
    or cooperativa_id = auth_user_cooperativa()
  );

-- =============================================================================
-- C02: Corregir device_registry policy — using(true) exponía datos
-- a TODOS los usuarios autenticados. Ahora solo service_role.
-- =============================================================================

-- Eliminar la política insegura existente y la de admins si ya fue creada
drop policy if exists "Service role gestiona device registry" on device_registry;
drop policy if exists "Admins ven device registry" on device_registry;

-- Recrear con restricción correcta
create policy "Service role gestiona device registry"
  on device_registry for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

-- Agregar políticas para admins (solo SELECT)
create policy "Admins ven device registry"
  on device_registry for select
  using (auth_user_role() in ('cooperativa_admin', 'municipal_admin'));

-- =============================================================================
-- C01 (continuación): Políticas faltantes para premium_subscriptions y trips
-- =============================================================================

-- premium_subscriptions: INSERT y UPDATE
create policy "Sistema crea suscripciones"
  on premium_subscriptions for insert
  with check (auth.role() = 'service_role' or auth_user_role() = 'municipal_admin');

create policy "Municipal gestiona suscripciones"
  on premium_subscriptions for update
  using (auth_user_role() = 'municipal_admin');

-- trips: INSERT y UPDATE
create policy "Conductor inicia viaje"
  on trips for insert
  with check (driver_id = auth.uid());

create policy "Conductor actualiza su viaje"
  on trips for update
  using (driver_id = auth.uid());

create policy "Admin coop gestiona viajes de su flota"
  on trips for update
  using (auth_user_role() = 'cooperativa_admin');

-- =============================================================================
-- C01 (continuación): Políticas adicionales para chat_messages y user_stop_presence
-- =============================================================================

-- chat_messages: UPDATE y DELETE
create policy "Sender edita su mensaje"
  on chat_messages for update
  using (sender_id = auth.uid());

create policy "Admin municipal elimina mensajes"
  on chat_messages for delete
  using (auth_user_role() = 'municipal_admin');

-- user_stop_presence: UPDATE y DELETE
create policy "Usuario elimina su presencia"
  on user_stop_presence for delete
  using (user_id = auth.uid());

create policy "Admins gestionan presencia"
  on user_stop_presence for update
  using (auth_user_role() in ('cooperativa_admin', 'municipal_admin'));
