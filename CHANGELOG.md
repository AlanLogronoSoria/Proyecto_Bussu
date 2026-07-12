# Andes Mobility

## [1.0.0] - 2026-07-11

### Added
- Sistema de autenticación completo (login, registro, recuperación, logout)
- Mock authentication para desarrollo sin backend
- Módulo Usuario: mapa en vivo, ETA, rutas, favoritos, historial, perfil, alertas, tickets, premium
- Módulo Conductor: dashboard, viaje activo, estado del bus, ocupación, solicitud de paradas, historial
- Módulo Cooperativa: fleet dashboard, CRUD conductores/buses/paradas/rutas, reportes, analytics
- Módulo Admin Municipal: dashboard general, CRUD cooperativas, premium, usuarios, alertas, reportes
- Sistema ETA con PostGIS: st_linelocatepoint, EMA smoothing, fallback histórico de velocidad
- Integración IoT completa: MQTT bridge con HMAC, OTA, watchdog, device registry
- Backend Supabase: 21 tablas, RLS completo, 4 Edge Functions, 8 RPCs
- Security: certificate pinning, secure storage, rate limiter, output sanitizer, secure logger
- CI/CD: GitHub Actions con analyze, test, coverage, build Android/iOS, deploy Supabase

### Security
- HMAC-SHA256 validation en MQTT bridge con anti-replay (60s)
- RLS policies en 17 tablas con SECURITY DEFINER guards
- JWT validation en Edge Functions con webhook signature verification
- Certificate pinning para Supabase y MQTT broker
- Secure storage (Keychain/EncryptedSharedPreferences) para tokens
