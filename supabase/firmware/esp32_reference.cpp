// =============================================================================
// Andes Mobility: Firmware ESP32 — Estructura de referencia
//
// Este documento define la arquitectura del firmware que corre en cada
// ESP32 instalado en los buses y paradas.
//
// Plataforma: ESP32 (ESP-IDF o Arduino framework)
// Sensores: GPS NEO-6M, IR/ToF VL53L0X, Acelerómetro MPU6050
// Conectividad: WiFi/LTE, MQTT sobre TLS
// =============================================================================

// ---- Estructura de archivos del firmware ----
//
// esp32_firmware/
// ├── main.cpp                    # Entry point, WiFi, tareas FreeRTOS
// ├── mqtt_client.cpp/.h          # Cliente MQTT con TLS, reconexión
// ├── gps_reader.cpp/.h           # Lectura GPS NEO-6M via UART
// ├── passenger_counter.cpp/.h    # Sensores IR/ToF para conteo
// ├── hmac_signer.cpp/.h          # Firma HMAC-SHA256 de mensajes
// ├── config.h                    # Configuración (pines, IDs, secrets)
// ├── telemetry_publisher.cpp/.h  # Publicador de telemetría cada 5s
// └── offline_buffer.cpp/.h       # Buffer circular para modo offline

// =============================================================================
// main.cpp — Punto de entrada
// =============================================================================
/*
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <mbedtls/md.h>
#include "config.h"
#include "gps_reader.h"
#include "passenger_counter.h"
#include "hmac_signer.h"
#include "telemetry_publisher.h"
#include "offline_buffer.h"

// Handles de tareas FreeRTOS
TaskHandle_t gpsTaskHandle;
TaskHandle_t mqttTaskHandle;
TaskHandle_t telemetryTaskHandle;

WiFiClientSecure wifiClient;
PubSubClient mqttClient(wifiClient);

unsigned long lastTelemetryTime = 0;
const int TELEMETRY_INTERVAL_MS = 5000;  // 5 segundos

void setup() {
  Serial.begin(115200);

  // 1. Conectar WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  // 2. Configurar MQTT con TLS
  wifiClient.setCACert(CA_CERT);
  mqttClient.setServer(MQTT_BROKER_HOST, MQTT_BROKER_PORT);
  mqttClient.setCallback(mqttCallback);
  mqttClient.setKeepAlive(30);

  // 3. Inicializar sensores
  gps_init(GPS_RX_PIN, GPS_TX_PIN, 9600);
  passenger_counter_init(IR_SDA_PIN, IR_SCL_PIN);

  // 4. Conectar MQTT
  mqttConnect();

  // 5. Crear tareas FreeRTOS
  xTaskCreatePinnedToCore(gpsTask, "GPS", 4096, NULL, 1, &gpsTaskHandle, 0);
  xTaskCreatePinnedToCore(telemetryTask, "Telemetry", 4096, NULL, 2,
                          &telemetryTaskHandle, 1);

  Serial.println("ESP32 Andes Mobility iniciado");
}

void loop() {
  if (!mqttClient.connected()) {
    mqttConnect();
  }
  mqttClient.loop();
  delay(10);
}

void mqttConnect() {
  // Reconexión con backoff exponencial
  static int retryCount = 0;
  while (!mqttClient.connected()) {
    String clientId = "ESP32_" + String(HARDWARE_DEVICE_ID);
    if (mqttClient.connect(clientId.c_str(), MQTT_USERNAME, MQTT_PASSWORD,
                           "bus/" HARDWARE_DEVICE_ID "/status", 0, true,
                           "offline")) {
      mqttClient.subscribe("bus/" HARDWARE_DEVICE_ID "/command", 1);
      mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/status", "online", true);
      retryCount = 0;

      // Vaciar buffer offline al reconectar
      processOfflineBuffer();
    } else {
      int delay_ms = min(1000 * pow(2, retryCount), 120000);
      retryCount++;
      delay(delay_ms);
    }
  }
}

// =============================================================================
// telemetry_publisher.cpp — Publicador de telemetría
// =============================================================================
/*
void telemetryTask(void *parameter) {
  for (;;) {
    if (millis() - lastTelemetryTime >= TELEMETRY_INTERVAL_MS) {
      lastTelemetryTime = millis();
      publishTelemetry();
    }
    vTaskDelay(100 / portTICK_PERIOD_MS);
  }
}

void publishTelemetry() {
  GpsData gps = gps_read();
  int passengers = passenger_counter_read();

  if (gps.valid) {
    StaticJsonDocument<256> doc;
    doc["lat"] = gps.latitude;
    doc["lng"] = gps.longitude;
    doc["speed_kmh"] = gps.speed_kmh;
    doc["heading"] = gps.heading;
    doc["passenger_count"] = passengers;

    String payload;
    serializeJson(doc, payload);

    unsigned long ts = gps.timestamp;  // Unix timestamp
    String hmac = signHmac(HARDWARE_DEVICE_ID, ts, payload);

    StaticJsonDocument<512> msg;
    msg["hardware_device_id"] = HARDWARE_DEVICE_ID;
    msg["timestamp"] = ts;
    msg["hmac"] = hmac;
    msg["payload"] = serialized(payload);

    String topic = "bus/" + String(BUS_ID) + "/telemetry";
    String msgStr;
    serializeJson(msg, msgStr);

    if (!mqttClient.publish(topic.c_str(), msgStr.c_str())) {
      // Si falla el envío, almacenar en buffer offline
      storeOffline(msgStr);
    }
  } else {
    Serial.println("GPS sin señal");
  }
}
*/

// =============================================================================
// hmac_signer.cpp — Firma HMAC-SHA256
// =============================================================================
/*
#include <mbedtls/md.h>

String signHmac(const char* deviceId, unsigned long timestamp,
                const String& payload) {
  String data = String(deviceId) + ":" + String(timestamp) + ":" + payload;

  byte hmacResult[32];
  mbedtls_md_context_t ctx;
  mbedtls_md_type_t md_type = MBEDTLS_MD_SHA256;

  mbedtls_md_init(&ctx);
  mbedtls_md_setup(&ctx, mbedtls_md_info_from_type(md_type), 1);
  mbedtls_md_hmac_starts(&ctx, (const unsigned char*)HMAC_SECRET,
                          strlen(HMAC_SECRET));
  mbedtls_md_hmac_update(&ctx, (const unsigned char*)data.c_str(),
                          data.length());
  mbedtls_md_hmac_finish(&ctx, hmacResult);
  mbedtls_md_free(&ctx);

  String hmacHex = "";
  for (int i = 0; i < 32; i++) {
    char hex[3];
    sprintf(hex, "%02x", hmacResult[i]);
    hmacHex += hex;
  }
  return hmacHex;
}
*/

// =============================================================================
// offline_buffer.cpp — Buffer circular para modo offline
// =============================================================================
/*
#define BUFFER_SIZE 100

struct OfflineMessage {
  String topic;
  String payload;
  unsigned long timestamp;
};

OfflineMessage offlineBuffer[BUFFER_SIZE];
int bufferHead = 0;
int bufferTail = 0;
int bufferCount = 0;

void storeOffline(const String& payload) {
  if (bufferCount < BUFFER_SIZE) {
    offlineBuffer[bufferTail].topic =
        "bus/" + String(BUS_ID) + "/telemetry";
    offlineBuffer[bufferTail].payload = payload;
    offlineBuffer[bufferTail].timestamp = millis();
    bufferTail = (bufferTail + 1) % BUFFER_SIZE;
    bufferCount++;
  } else {
    // Buffer lleno: descartar el mensaje más antiguo
    bufferHead = (bufferHead + 1) % BUFFER_SIZE;
    bufferCount--;
    storeOffline(payload);
  }
}

void processOfflineBuffer() {
  while (bufferCount > 0) {
    OfflineMessage msg = offlineBuffer[bufferHead];
    if (mqttClient.publish(msg.topic.c_str(), msg.payload.c_str())) {
      bufferHead = (bufferHead + 1) % BUFFER_SIZE;
      bufferCount--;
    } else {
      break;  // Si falla, reintentar en el próximo ciclo
    }
  }
}
*/

// =============================================================================
// config.h — Configuración por dispositivo
// =============================================================================
/*
#ifndef CONFIG_H
#define CONFIG_H

// WiFi
#define WIFI_SSID "AndesMobility-IoT"
#define WIFI_PASSWORD "changeme-wifi-password"

// MQTT Broker
#define MQTT_BROKER_HOST "broker.andesmobility.com"
#define MQTT_BROKER_PORT 8883
#define MQTT_USERNAME "esp32-client"
#define MQTT_PASSWORD "changeme-mqtt-password"

// Identidad del dispositivo (única por ESP32)
#define HARDWARE_DEVICE_ID "esp32-device-001"
#define BUS_ID "b0000000-0000-0000-0000-000000000001"

// Seguridad
#define HMAC_SECRET "changeme-hmac-secret"
#define CA_CERT "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----"

// Pines del ESP32
#define GPS_RX_PIN 16
#define GPS_TX_PIN 17
#define IR_SDA_PIN 21
#define IR_SCL_PIN 22

#endif
*/

// =============================================================================
// passenger_counter.cpp — Contador de pasajeros IR/ToF
// =============================================================================
/*
// Sensor VL53L0X (ToF) o barrera infrarroja para conteo
// Lógica: dos sensores en secuencia determinan dirección (entrada/salida)

int passengerCount = 0;
bool sensorA_prev = false;
bool sensorB_prev = false;

void passenger_counter_init(int sda, int scl) {
  // Inicializar I2C y sensores
  Wire.begin(sda, scl);
}

int passenger_counter_read() {
  // Leer sensores y determinar conteo
  bool sensorA = digitalRead(IR_SENSOR_A_PIN);
  bool sensorB = digitalRead(IR_SENSOR_B_PIN);

  // Entrada: A → B
  if (sensorA && !sensorA_prev && sensorB && sensorB_prev) {
    passengerCount++;
  }
  // Salida: B → A
  if (sensorB && !sensorB_prev && sensorA && sensorA_prev) {
    passengerCount = max(0, passengerCount - 1);
  }

  sensorA_prev = sensorA;
  sensorB_prev = sensorB;
  return passengerCount;
}
*/

// =============================================================================
// ota_updater.cpp — Actualización Over-The-Air (OTA)
// =============================================================================
/*
#include <Update.h>
#include <HTTPClient.h>
#include <mbedtls/md.h>

// Variables globales para OTA
bool otaInProgress = false;
String otaCurrentVersion = "1.0.0";
unsigned long otaLastProgressTime = 0;

// Task: verificar comandos OTA pendientes
void otaTask(void *parameter) {
  for (;;) {
    if (!otaInProgress) {
      // El comando OTA se recibe via MQTT en mqttCallback()
      // Topic: bus/HARDWARE_DEVICE_ID/ota/command
      // Payload: { command_id, version, url, checksum }
    }
    vTaskDelay(1000 / portTICK_PERIOD_MS);
  }
}

// Callback MQTT para topic OTA
void handleOtaCommand(const String& payload) {
  if (otaInProgress) {
    mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
      "{\"status\":\"busy\",\"message\":\"OTA already in progress\"}");
    return;
  }

  StaticJsonDocument<512> doc;
  deserializeJson(doc, payload);

  const char* commandId = doc["command_id"];
  const char* version = doc["version"];
  const char* url = doc["url"];
  const char* expectedChecksum = doc["checksum"];

  mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
    "{\"command_id\":\"" + String(commandId) + "\",\"status\":\"downloading\"}");

  otaInProgress = true;
  otaLastProgressTime = millis();

  HTTPClient http;
  http.begin(url);
  http.setTimeout(300);  // 5 minutos

  int httpCode = http.GET();
  if (httpCode != HTTP_CODE_OK) {
    mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
      "{\"command_id\":\"" + String(commandId) +
      "\",\"status\":\"failed\",\"error\":\"HTTP " + String(httpCode) + "\"}");
    otaInProgress = false;
    http.end();
    return;
  }

  int contentLength = http.getSize();

  // Leer el firmware descargado completo antes de flashear
  // para poder verificar el checksum SHA-256
  size_t totalRead = 0;
  uint8_t* firmwareBuffer = (uint8_t*)malloc(contentLength);
  if (!firmwareBuffer) {
    mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
      "{\"command_id\":\"" + String(commandId) +
      "\",\"status\":\"failed\",\"error\":\"No memory for buffer\"}");
    otaInProgress = false;
    http.end();
    return;
  }

  WiFiClient* stream = http.getStreamPtr();
  while (totalRead < contentLength && stream->connected()) {
    size_t available = stream->available();
    if (available > 0) {
      size_t toRead = min(available, contentLength - totalRead);
      stream->readBytes(firmwareBuffer + totalRead, toRead);
      totalRead += toRead;
    }
    yield();
  }

  http.end();

  if (totalRead != contentLength) {
    free(firmwareBuffer);
    mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
      "{\"command_id\":\"" + String(commandId) +
      "\",\"status\":\"failed\",\"error\":\"Download incomplete\"}");
    otaInProgress = false;
    return;
  }

  // Calcular SHA-256 del firmware descargado
  byte computedHash[32];
  mbedtls_md_context_t mdCtx;
  mbedtls_md_init(&mdCtx);
  mbedtls_md_setup(&mdCtx, mbedtls_md_info_from_type(MBEDTLS_MD_SHA256), 0);
  mbedtls_md_starts(&mdCtx);
  mbedtls_md_update(&mdCtx, firmwareBuffer, contentLength);
  mbedtls_md_finish(&mdCtx, computedHash);
  mbedtls_md_free(&mdCtx);

  // Convertir hash a hex string
  char computedHex[65];
  for (int i = 0; i < 32; i++) {
    sprintf(computedHex + (i * 2), "%02x", computedHash[i]);
  }
  computedHex[64] = '\0';

  // Comparar contra el checksum esperado (recibido via MQTT)
  if (strcmp(computedHex, expectedChecksum) != 0) {
    free(firmwareBuffer);
    mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
      "{\"command_id\":\"" + String(commandId) +
      "\",\"status\":\"failed\",\"error\":\"Checksum mismatch\"}");
    otaInProgress = false;
    return;
  }

  // Checksum válido: flashear el firmware
  mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
    "{\"command_id\":\"" + String(commandId) + "\",\"status\":\"installing\"}");

  if (!Update.begin(contentLength)) {
    free(firmwareBuffer);
    mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
      "{\"command_id\":\"" + String(commandId) +
      "\",\"status\":\"failed\",\"error\":\"Not enough space\"}");
    otaInProgress = false;
    return;
  }

  size_t written = Update.writeStream(
    (const uint8_t*)firmwareBuffer, contentLength
  );
  free(firmwareBuffer);

  if (written != contentLength || !Update.end()) {
    mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
      "{\"command_id\":\"" + String(commandId) +
      "\",\"status\":\"failed\",\"error\":\"Flash write failed\"}");
    otaInProgress = false;
    return;
  }

  mqttClient.publish("bus/" HARDWARE_DEVICE_ID "/ota/status",
    "{\"command_id\":\"" + String(commandId) +
    "\",\"status\":\"completed\",\"version\":\"" + String(version) + "\"}");

  otaInProgress = false;

  // Reiniciar para aplicar el nuevo firmware
  delay(2000);
  ESP.restart();
}
*/

// =============================================================================
// watchdog.cpp — Watchdog Timer
// =============================================================================
/*
#include <esp_task_wdt.h>

// Watchdog: reinicia el ESP32 si se cuelga por más de 60 segundos
// Se configura en setup() y se alimenta en el loop principal y tareas críticas

#define WDT_TIMEOUT_SEC 60

TaskHandle_t watchdogTaskHandle;

// Task dedicada para alimentar el watchdog
void watchdogTask(void *parameter) {
  for (;;) {
    // Verificar que las tareas críticas están vivas
    unsigned long now = millis();

    // Si la tarea de GPS no ha producido datos en 30s, reiniciar
    if (now - lastGpsReadTime > 30000) {
      ESP.restart();
    }

    // Si MQTT no se ha reconectado en 5 minutos, reiniciar
    if (now - lastMqttConnectTime > 300000 && !mqttClient.connected()) {
      ESP.restart();
    }

    // Alimentar el watchdog del ESP32
    esp_task_wdt_reset();

    vTaskDelay(1000 / portTICK_PERIOD_MS);
  }
}

// En setup():
// esp_task_wdt_init(WDT_TIMEOUT_SEC, true);  // true = panic on timeout
// esp_task_wdt_add(NULL);                     // añadir loop() actual
// xTaskCreate(watchdogTask, "Watchdog", 2048, NULL, 1, &watchdogTaskHandle);

// Variables de timestamp para el watchdog:
// unsigned long lastGpsReadTime = 0;
// unsigned long lastMqttConnectTime = 0;

// Actualizar en:
// - gps_read(): lastGpsReadTime = millis();
// - mqttConnect() al conectar: lastMqttConnectTime = millis();
*/

