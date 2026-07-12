# Release Checklist — Andes Mobility

## Pre-Release

- [ ] `flutter analyze` — 0 errors
- [ ] `dart analyze lib/` — 0 errors
- [ ] `flutter test` — all passing
- [ ] Environment variables configured:
  - [ ] `SUPABASE_URL`
  - [ ] `SUPABASE_ANON_KEY`
  - [ ] `MQTT_BROKER_HOST`
  - [ ] `MQTT_BROKER_PORT`
  - [ ] `IOT_HMAC_SECRET` (not 'changeme')
  - [ ] `GOOGLE_MAPS_API_KEY`
  - [ ] `ENABLE_MOCK_AUTH=false`
  - [ ] `IS_PRODUCTION=true`
- [ ] Supabase migrations applied (`supabase db push`)
- [ ] RLS policies verified on all tables
- [ ] Edge Functions deployed (`supabase functions deploy`)
- [ ] Storage buckets created (avatars, documents)
- [ ] Realtime enabled on: bus_live_position, bus_stop_events, system_alerts, chat_messages, trips, ota_commands, bridge_health

## Build

- [ ] Android: `flutter build appbundle --release --dart-define=IS_PRODUCTION=true`
- [ ] iOS: `flutter build ios --release --dart-define=IS_PRODUCTION=true`
- [ ] Android signing key configured in `android/key.properties`
- [ ] iOS provisioning profile valid

## Security

- [ ] Certificate pinning fingerprints updated in `certificate_pinner.dart`
- [ ] `IOT_HMAC_SECRET` set to strong random value
- [ ] `SUPABASE_WEBHOOK_SECRET` configured for push notifications
- [ ] FCM service account configured in Supabase secrets
- [ ] `ENABLE_MOCK_AUTH=false` verified
- [ ] No debug logs in release build (`flutter run --release`)

## Deploy

- [ ] GitHub Actions CI passing on main branch
- [ ] Android AAB uploaded to Google Play Console
- [ ] iOS IPA uploaded to App Store Connect
- [ ] Supabase migrations applied to production project
- [ ] Edge Functions deployed to production
- [ ] MQTT Bridge deployed (Fly.io / Railway / Docker)
- [ ] Database backups configured

## Post-Release

- [ ] Verify login flow on production app
- [ ] Verify realtime bus tracking
- [ ] Verify ETA calculations
- [ ] Verify push notifications
- [ ] Monitor Sentry/Crashlytics for errors
- [ ] Tag release: `git tag v1.0.0 && git push --tags`
