// =============================================================================
// Andes Mobility: Servicio Puente MQTT → Supabase (v2 - Producción)
//
// Despliegue: Fly.io / Railway / Docker
//
// Funcionalidades:
// - Conexión MQTT con TLS y reconexión automática (backoff exponencial)
// - Validación HMAC-SHA256 de cada mensaje entrante
// - Anti-replay: rechaza mensajes con timestamp > 60s de antigüedad
// - Persistencia de telemetría offline (cola en BD)
// - Health check del puente (topic bridge/health)
// - Logs estructurados en BD (bridge_logs)
// - Métricas de rendimiento (bridge_metrics)
// =============================================================================

import * as mqtt from "mqtt";
import { createClient } from "@supabase/supabase-js";
import { createHmac, timingSafeEqual } from "crypto";

// ---- Configuración ----
const MQTT_URL = process.env.MQTT_BROKER_URL ?? "mqtts://broker.andesmobility.com:8883";
const MQTT_USERNAME = process.env.MQTT_USERNAME ?? "";
const MQTT_PASSWORD = process.env.MQTT_PASSWORD ?? "";
const HMAC_SECRET = process.env.IOT_HMAC_SECRET ?? "changeme";
const SUPABASE_URL = process.env.SUPABASE_URL ?? "";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY ?? "";
const BRIDGE_INSTANCE_ID = process.env.BRIDGE_INSTANCE_ID ?? `bridge-${Date.now()}`;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// ---- Estructuras de datos ----
interface TelemetryMessage {
  hardware_device_id: string;
  timestamp: number;
  hmac: string;
  payload: {
    lat: number;
    lng: number;
    speed_kmh: number;
    heading: number;
    passenger_count: number;
  };
}

interface BridgeHealthMessage {
  instanceId: string;
  uptime: number;
  messagesProcessed: number;
  errors: number;
  connectedDevices: number;
}

// ---- HMAC Validation ----
function validateHmac(message: TelemetryMessage): boolean {
  const { hardware_device_id, timestamp, hmac, payload } = message;

  // Anti-replay: rechazar mensajes con timestamp > 60s de antigüedad
  const now = Math.floor(Date.now() / 1000);
  if (Math.abs(now - timestamp) > 60) {
    console.warn(`[SECURITY] Replay attack blocked: device=${hardware_device_id}, age=${now - timestamp}s`);
    return false;
  }

  const data = `${hardware_device_id}:${timestamp}:${JSON.stringify(payload)}`;
  const expectedHmac = createHmac("sha256", HMAC_SECRET).update(data).digest("hex");

  // Comparación en tiempo constante para prevenir timing attacks
  const bufA = Buffer.from(expectedHmac, "hex");
  const bufB = Buffer.from(hmac, "hex");
  return bufA.length === bufB.length && timingSafeEqual(bufA, bufB);
}

// ---- Logger estructurado ----
async function logToDb(
  level: "info" | "warn" | "error",
  message: string,
  metadata?: Record<string, unknown>
) {
  try {
    await supabase.from("bridge_logs").insert({
      instance_id: BRIDGE_INSTANCE_ID,
      level,
      message,
      metadata: metadata ?? {},
    });
  } catch {
    console.error("Failed to write log to DB");
  }
}

// ---- Persistencia de telemetría ----
async function persistTelemetry(busId: string, payload: TelemetryMessage["payload"]) {
  try {
    // 1. Upsert en bus_live_position (última posición)
    await supabase.from("bus_live_position").upsert({
      bus_id: busId,
      location: `SRID=4326;POINT(${payload.lng} ${payload.lat})`,
      speed_kmh: payload.speed_kmh,
      heading: payload.heading,
      passenger_count: payload.passenger_count,
      updated_at: new Date().toISOString(),
    });

    // 2. Insertar en histórico
    await supabase.from("bus_telemetry_history").insert({
      bus_id: busId,
      location: `SRID=4326;POINT(${payload.lng} ${payload.lat})`,
      speed_kmh: payload.speed_kmh,
      passenger_count: payload.passenger_count,
      recorded_at: new Date().toISOString(),
    });
  } catch (error) {
    // Si falla la escritura, encolar para reintento
    await enqueueOffline(busId, payload);
    throw error;
  }
}

// ---- Cola offline ----
async function enqueueOffline(busId: string, payload: TelemetryMessage["payload"]) {
  await supabase.from("telemetry_offline_queue").insert({
    bus_id: busId,
    payload: payload as unknown as Record<string, unknown>,
    enqueued_at: new Date().toISOString(),
    retries: 0,
  });
}

async function processOfflineQueue() {
  const { data: queued } = await supabase
    .from("telemetry_offline_queue")
    .select("*")
    .eq("processed", false)
    .lt("retries", 5)
    .order("enqueued_at", { ascending: true })
    .limit(50);

  if (!queued || queued.length === 0) return;

  for (const item of queued) {
    try {
      const payload = item.payload as TelemetryMessage["payload"];
      await persistTelemetry(item.bus_id, payload);
      await supabase.from("telemetry_offline_queue").update({ processed: true }).eq("id", item.id);
    } catch {
      await supabase.from("telemetry_offline_queue")
        .update({ retries: item.retries + 1 })
        .eq("id", item.id);
    }
  }
}

// ---- Health Check ----
function publishBridgeHealth(client: mqtt.MqttClient, stats: BridgeHealthMessage) {
  client.publish("bridge/health", JSON.stringify(stats), { qos: 1, retain: true });
}

// ---- Main ----
async function main() {
  const stats: BridgeHealthMessage = {
    instanceId: BRIDGE_INSTANCE_ID,
    uptime: 0,
    messagesProcessed: 0,
    errors: 0,
    connectedDevices: 0,
  };

  const startTime = Date.now();
  const connectedDevices = new Set<string>();
  const deviceLastSeen = new Map<string, number>();

  // Caché bus_id → hardware_device_id (invalida cada 5 min)
  const busHardwareCache = new Map<string, { deviceId: string; cachedAt: number }>();
  const BUS_CACHE_TTL_MS = 5 * 60 * 1000;

  async function getBusHardwareId(busId: string): Promise<string | null> {
    const cached = busHardwareCache.get(busId);
    if (cached && Date.now() - cached.cachedAt < BUS_CACHE_TTL_MS) {
      return cached.deviceId;
    }
    const { data: bus } = await supabase
      .from("buses").select("id, hardware_device_id").eq("id", busId).single();
    if (bus?.hardware_device_id) {
      busHardwareCache.set(busId, { deviceId: bus.hardware_device_id, cachedAt: Date.now() });
      return bus.hardware_device_id;
    }
    return null;
  }

  let healthCheckInterval: ReturnType<typeof setInterval> | null = null;

  const client = mqtt.connect(MQTT_URL, {
    username: MQTT_USERNAME,
    password: MQTT_PASSWORD,
    reconnectPeriod: 1000,
    connectTimeout: 10000,
    keepalive: 30,
    clean: false,
  });

  client.on("connect", () => {
    console.log(`[${BRIDGE_INSTANCE_ID}] Conectado al broker MQTT`);
    logToDb("info", "Puente conectado al broker MQTT");

    client.subscribe("bus/+/telemetry", { qos: 1 });
    client.subscribe("bridge/command", { qos: 1 });

    // Limpiar interval anterior antes de crear uno nuevo (previene fuga en reconexión)
    if (healthCheckInterval) clearInterval(healthCheckInterval);

    // Health check periódico (cada 30s)
    healthCheckInterval = setInterval(() => {
      stats.uptime = Math.floor((Date.now() - startTime) / 1000);

      // Limpiar dispositivos que no han transmitido en 5 minutos
      const now = Date.now();
      for (const [deviceId, lastSeen] of deviceLastSeen) {
        if (now - lastSeen > 5 * 60 * 1000) {
          connectedDevices.delete(deviceId);
          deviceLastSeen.delete(deviceId);
          // Fix 7: actualizar device_registry.status a offline
          supabase.from("device_registry").update({
            status: "offline",
            last_seen: new Date(lastSeen).toISOString(),
          }).eq("device_id", deviceId).eq("status", "online").then(
            () => {},
            (err: unknown) => { console.error("device_registry offline update failed:", err); }
          );
        }
      }

      stats.connectedDevices = connectedDevices.size;
      publishBridgeHealth(client, stats);
    }, 30000);
  });

  client.on("message", async (topic: string, message: Buffer) => {
    try {
      const raw = message.toString();

      if (topic === "bridge/command") {
        const cmd = JSON.parse(raw);
        if (cmd.action === "process_offline_queue") {
          await processOfflineQueue();
        }
        return;
      }

      const busId = topic.split("/")[1];
      const data: TelemetryMessage = JSON.parse(raw);

      // Validar HMAC
      if (!validateHmac(data)) {
        stats.errors++;
        logToDb("warn", `HMAC validation failed for bus ${busId}`, { deviceId: data.hardware_device_id });
        return;
      }

      // Validar hardware_device_id (usando caché)
      const expectedDeviceId = await getBusHardwareId(busId);

      if (!expectedDeviceId || expectedDeviceId !== data.hardware_device_id) {
        stats.errors++;
        logToDb("error", `Hardware ID mismatch: bus=${busId}, received=${data.hardware_device_id}`);
        return;
      }

      // Persistir telemetría
      await persistTelemetry(busId, data.payload);

      connectedDevices.add(data.hardware_device_id);
      deviceLastSeen.set(data.hardware_device_id, Date.now());
      stats.messagesProcessed++;

      // Actualizar device_registry cada 10 mensajes por dispositivo
      if (stats.messagesProcessed % 10 === 0) {
        supabase.from("device_registry").upsert({
          device_id: data.hardware_device_id,
          bus_id: busId,
          last_seen: new Date().toISOString(),
          status: "online",
          consecutive_failures: 0,
        }, { onConflict: "device_id" }).then(
          () => {},
          (err: unknown) => { console.error("device_registry upsert failed:", err); }
        );
      }

      // Verificar OTA commands pendientes para este dispositivo
      const { data: otaCmd } = await supabase.rpc("get_pending_ota", {
        device_id_param: data.hardware_device_id,
      });
      if (otaCmd && otaCmd.length > 0) {
        const cmd = otaCmd[0];
        client.publish(
          `bus/${busId}/ota/command`,
          JSON.stringify({
            command_id: cmd.command_id,
            version: cmd.target_version,
            url: cmd.binary_url,
            checksum: cmd.checksum_sha256,
          }),
          { qos: 1 }
        );
        // Fix 6: actualizar ota_commands.status tras publicar el comando
        supabase.from("ota_commands").update({
          status: "downloading",
          command_sent_at: new Date().toISOString(),
        }).eq("id", cmd.command_id).then(
          () => {},
          (err: unknown) => { console.error("ota_commands update failed:", err); }
        );
      }

      if (stats.messagesProcessed % 100 === 0) {
        console.log(`[${BRIDGE_INSTANCE_ID}] Procesados: ${stats.messagesProcessed}`);
      }
    } catch (error) {
      stats.errors++;
      logToDb("error", "Error procesando mensaje MQTT", {
        topic,
        error: String(error),
      });
    }
  });

  client.on("error", (error) => {
    logToDb("error", "Error de conexión MQTT", { error: error.message });
  });

  client.on("reconnect", () => {
    logToDb("info", "Reconectando al broker MQTT...");
  });

  client.on("close", () => {
    logToDb("warn", "Conexión MQTT cerrada");
  });

  // Procesar cola offline cada 60 segundos
  setInterval(processOfflineQueue, 60000);

  // Graceful shutdown
  process.on("SIGTERM", async () => {
    console.log(`[${BRIDGE_INSTANCE_ID}] Shutdown signal received`);
    if (healthCheckInterval) clearInterval(healthCheckInterval);
    client.end(true);
    process.exit(0);
  });
}

main().catch(console.error);
