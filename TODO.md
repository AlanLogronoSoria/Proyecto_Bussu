# TODO — Configuración de entorno (no requiere cambios de código)

## Google Maps API Key
- Archivo: `android/app/src/main/AndroidManifest.xml:31`
- Acción: Reemplazar `YOUR_GOOGLE_MAPS_API_KEY` por una key real desde Google Cloud Console
- API requerida: Maps SDK for Android

## Certificate Pinning fingerprints
- Archivo: `lib/core/security/certificate_pinner.dart:17-23`
- Acción: Reemplazar `supabase_pin_placeholder` y `mqtt_broker_pin_placeholder` con fingerprints SHA-256 reales
  ```bash
  openssl s_client -connect your-project.supabase.co:443 2>/dev/null \
    | openssl x509 -noout -pubkey \
    | openssl pkey -pubin -outform der \
    | openssl dgst -sha256 -binary \
    | openssl base64
  ```

## Modo producción (desactivar mock auth + establecer credenciales)
- Acción: Ejecutar con `--dart-define` o configurar en CI/CD:
  ```bash
  flutter run --dart-define=ENABLE_MOCK_AUTH=false \
    --dart-define=IS_PRODUCTION=true \
    --dart-define=SUPABASE_URL=https://xxx.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=xxx \
    --dart-define=GOOGLE_MAPS_API_KEY=xxx \
    --dart-define=IOT_HMAC_SECRET=xxx \
    --dart-define=MQTT_BROKER_HOST=xxx \
    --dart-define=MQTT_BROKER_PORT=8883
  ```

## Firebase / FCM (Edge Functions)
- Archivo: `supabase/functions/send-push-notification/index.ts:31-50`
- Acción: Configurar secrets en Supabase Dashboard:
  - `FIREBASE_CLIENT_EMAIL` — email de la service account de Firebase
  - `FIREBASE_PRIVATE_KEY` — clave privada PKCS#8 de la service account
  - `FCM_PROJECT_ID` — ID del proyecto Firebase
  - `SUPABASE_WEBHOOK_SECRET` — string aleatorio para firma de webhooks

## MQTT Bridge (despliegue)
- Archivo: `supabase/functions/mqtt-bridge/index.ts`
- Acción: Desplegar en Fly.io / Railway / Docker con variables de entorno:
  - `MQTT_BROKER_URL`, `MQTT_USERNAME`, `MQTT_PASSWORD`
  - `IOT_HMAC_SECRET`
  - `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`
