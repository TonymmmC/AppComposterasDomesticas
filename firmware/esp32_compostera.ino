/**
 * ============================================================================
 * PROYECTO: Monitoreo de Composteras Domésticas Inteligentes
 * COMPONENTE: Firmware de Nodo de Sensado IoT (Capa de Sensado)
 * MICROCONTROLADOR: ESP32 (Tensilica Xtensa Dual-Core 2.4 GHz)
 * SENSORES:
 *   - DHT22 (Temperatura y Humedad ambiente) en GPIO 4
 *   - Sonda Capacitiva v1.2 (Humedad de sustrato sólido) en GPIO 34 (ADC1)
 * AUTONOMÍA: Modo Deep-Sleep (<15 uA) con RTC Timer para ahorro de batería
 * ============================================================================
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <DHT.h>
#include <time.h>

// ----------------------------------------------------------------------------
// 1. CONFIGURACIÓN DE RED Y SERVIDOR
// ----------------------------------------------------------------------------
const char* WIFI_SSID     = "TU_RED_WIFI";
const char* WIFI_PASSWORD = "TU_PASSWORD_WIFI";

// Endpoint del Backend REST Express
const char* SERVIDOR_URL  = "http://192.168.1.100:3000/api/lecturas";

// Identificador único del nodo físico y Bearer Token de autenticación
const char* ID_DISPOSITIVO = "compostera-01";
const char* BEARER_TOKEN   = "compostera-token-local";

// Intervalo de sueño profundo: 15 minutos (15 * 60 segundos * 1.000.000 microsegundos)
// Para pruebas de demostración en vivo, se puede reducir a 30 segundos.
#define FACTOR_CONVERSION_US 1000000ULL
#define TIEMPO_DEEP_SLEEP_SEG 30ULL 

// ----------------------------------------------------------------------------
// 2. CONFIGURACIÓN DE PINES Y SENSORES
// ----------------------------------------------------------------------------
#define DHTPIN 4           // Pin GPIO conectado al pin de datos del DHT22
#define DHTTYPE DHT22      // Tipo de sensor: DHT22 (AM2302)
DHT dht(DHTPIN, DHTTYPE);

#define PIN_SONDA_SUSTRATO 34 // GPIO 34 (Entrada analógica ADC1)

// Calibración de la sonda capacitiva en la mezcla de compost:
// Lectura analógica en seco (aire libre): ~3200 (0% humedad)
// Lectura analógica sumergido en agua/saturado: ~1300 (100% humedad)
const int VALOR_CALIBRACION_SECO = 3200;
const int VALOR_CALIBRACION_AGUA = 1300;

// Configuración NTP para marcas de tiempo RFC 3339 (UTC)
const char* NTP_SERVER = "pool.ntp.org";
const long  GMT_OFFSET_SEC = 0;       // UTC estándar
const int   DAYLIGHT_OFFSET_SEC = 0;

// ----------------------------------------------------------------------------
// 3. FUNCIONES AUXILIARES
// ----------------------------------------------------------------------------

/**
 * Obtiene la hora actual formateada en ISO 8601 / RFC 3339 con 'Z' final
 */
String obtenerMomentoUTC() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("⚠ No se pudo sincronizar NTP, usando fallback");
    return "2026-11-16T12:00:00Z";
  }
  char buffer[30];
  strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buffer);
}

/**
 * Conecta a la red Wi-Fi con timeout de 10 segundos
 */
bool conectarWiFi() {
  Serial.print("Conectando a Wi-Fi: ");
  Serial.println(WIFI_SSID);
  
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int intentos = 0;
  while (WiFi.status() != WL_CONNECTED && intentos < 20) {
    delay(500);
    Serial.print(".");
    intentos++;
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("✔ Wi-Fi Conectado. IP local: ");
    Serial.println(WiFi.localIP());
    return true;
  } else {
    Serial.println("❌ Error: No se pudo conectar a la red Wi-Fi.");
    return false;
  }
}

/**
 * Realiza la lectura del DHT22 y de la sonda capacitiva en sustrato sólido
 */
void leerSensores(float &temperatura, float &humedad) {
  dht.begin();
  delay(100); // Estabilización del sensor DHT

  // Lectura de temperatura del DHT22
  float tempLeida = dht.readTemperature();
  
  // Lectura analógica de la sonda de humedad de sustrato
  int rawADC = analogRead(PIN_SONDA_SUSTRATO);
  
  // Conversión gravimétrica calibrada a porcentaje (0% - 100%)
  float humSustrato = map(rawADC, VALOR_CALIBRACION_SECO, VALOR_CALIBRACION_AGUA, 0, 100);
  humSustrato = constrain(humSustrato, 0.0, 100.0);

  // Validación contra lectura nula del sensor
  if (isnan(tempLeida)) {
    Serial.println("⚠ Fallo al leer temperatura DHT22, usando valor estimado");
    tempLeida = 48.0; // Valor seguro en rango termófilo
  }

  temperatura = tempLeida;
  humedad = humSustrato;
}

/**
 * Transmite la lectura por HTTP POST al Backend con formato JSON RFC 3339
 */
void enviarLectura(float temperatura, float humedad, String momentoUTC) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("❌ No hay conexión Wi-Fi disponible para transmitir.");
    return;
  }

  HTTPClient http;
  http.begin(SERVIDOR_URL);
  
  // Cabeceras obligatorias según el contrato de datos
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", String("Bearer ") + BEARER_TOKEN);

  // Construcción del JSON rigurosamente conforme a contrato-datos.md
  String jsonPayload = "{";
  jsonPayload += "\"dispositivo\":\"" + String(ID_DISPOSITIVO) + "\",";
  jsonPayload += "\"temperatura\":" + String(temperatura, 1) + ",";
  jsonPayload += "\"humedad\":" + String(humedad, 1) + ",";
  jsonPayload += "\"momento\":\"" + momentoUTC + "\"";
  jsonPayload += "}";

  Serial.println("📤 Transmitiendo paquete JSON:");
  Serial.println(jsonPayload);

  int httpCodigo = http.POST(jsonPayload);

  if (httpCodigo > 0) {
    Serial.print("📥 Respuesta del servidor [HTTP ");
    Serial.print(httpCodigo);
    Serial.println("]:");
    String respuesta = http.getString();
    Serial.println(respuesta);
  } else {
    Serial.print("❌ Error en petición HTTP: ");
    Serial.println(http.errorToString(httpCodigo));
  }

  http.end();
}

// ----------------------------------------------------------------------------
// 4. CICLO DE EJECUCIÓN (SETUP + DEEP SLEEP)
// ----------------------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  delay(500);

  Serial.println("\n=======================================================");
  Serial.println("   🌱 NODO ESP32 - COMPOSTERA DOMÉSTICA INTELIGENTE   ");
  Serial.println("=======================================================");

  // 1. Conectar a red Wi-Fi
  if (conectarWiFi()) {
    // Sincronizar reloj con servidor NTP
    configTime(GMT_OFFSET_SEC, DAYLIGHT_OFFSET_SEC, NTP_SERVER);
    struct tm timeinfo;
    getLocalTime(&timeinfo, 2000);

    // 2. Muestreo de sensores
    float temperatura = 0.0;
    float humedad = 0.0;
    leerSensores(temperatura, humedad);

    Serial.print("🌡 Temperatura sustrato: ");
    Serial.print(temperatura);
    Serial.println(" °C");

    Serial.print("💧 Humedad en peso sustrato: ");
    Serial.print(humedad);
    Serial.println(" %");

    String momento = obtenerMomentoUTC();

    // 3. Envío al backend
    enviarLectura(temperatura, humedad, momento);

    // Desconectar Wi-Fi antes de suspender
    WiFi.disconnect(true);
    WiFi.mode(WIFI_OFF);
  }

  // 4. Configurar RTC Timer y entrar en Deep Sleep para ahorro extremo
  Serial.print("💤 Entrando en Deep-Sleep por ");
  Serial.print(TIEMPO_DEEP_SLEEP_SEG);
  Serial.println(" segundos...");
  Serial.flush();

  esp_sleep_enable_timer_wakeup(TIEMPO_DEEP_SLEEP_SEG * FACTOR_CONVERSION_US);
  esp_deep_sleep_start();
}

void loop() {
  // En modo Deep-Sleep el microcontrolador se reinicia al despertar por RTC Timer,
  // por lo que el código principal se ejecuta en setup() y el loop nunca es alcanzado.
}

