# Guía de Presentación del Proyecto: Composteras Domésticas Inteligentes

> **Rol:** Arquitecto Senior de Software & IoT  
> **Objetivo:** Presentar ante docentes y evaluadores el prototipado funcional integral (Capa de Sensado 3D, Backend REST y Aplicación Móvil).

---

## 1. Estructura y Componentes del Sistema

### A. Capa de Sensado (Hardware IoT)
* **Microcontrolador:** ESP32 Tensilica Xtensa Dual-Core 2.4 GHz, con Wi-Fi 802.11 b/g/n integrado y modo **Deep-Sleep** (<15 µA) para autonomía energética mediante batería 18650 (RNF-04).
* **Sensores:**
  1. **DHT22:** Medición de temperatura y humedad relativa en la cámara de aire superior.
  2. **Sonda Capacitiva de Suelo v1.2:** Calibrada contra la matriz sólida de compost para medir el porcentaje de agua en peso (% humedad gravimétrica) sin corrosión galvánica.
* **Presupuesto del Kit Piloto Físico:** **Bs. 350,00** por unidad (con desglose detallado de microcontrolador, sensores, batería, cargador TP4056 y carcasa estanca IP65).
* **Firmware:** Implementado en C++/Arduino con sincronización horaria NTP (RFC 3339 UTC) y cabecera de autenticación `Authorization: Bearer <token>` ([firmware/esp32_compostera.ino](../firmware/esp32_compostera.ino)).

### B. Capa de Servicio (Backend REST & Reglas)
* **Stack:** Node.js, Express, TypeScript, Zod.
* **Endpoints:**
  * `POST /api/lecturas`: Ingesta de telemetría del nodo ESP32 protegida por Bearer Token.
  * `GET /api/lecturas`: Consulta y filtrado de histórico temporal para gráficos.
  * `POST /api/acciones`: Registro de intervenciones manuales (volteo, riego, material seco, material verde).
  * `GET /api/acciones`: Historial de intervenciones en la bitácora.
* **Motor de Recomendaciones Basado en Reglas Fijas:**
  * Fundamento agronómico según el **Manual de Compostaje de la FAO (Román et al., 2013)**.
  * Humedad óptima: **45 % a 60 %**.
  * Temperatura óptima (Fase termófila): **45 °C a 65 °C**.
  * Precedencia de estados: Evaluación de humedad primero (factor limitante de oxigenación), luego temperatura.

### C. Capa Cliente (Aplicación Móvil Flutter)
* **Framework:** Flutter (Dart) para Android 8.0+.
* **Pantallas funcionales:**
  * **Pantalla de Inicio:** Monitoreo en vivo de temperatura, humedad, indicador de estado agronómico, tiempo transcurrido y registro rápido de intervenciones.
  * **Pantalla de Historial:** Gráfico interactivo con `fl_chart`, visualización combinada de curvas térmicas/humedad, filtros temporales (24h, 3 días, todo) y lista de eventos con severidad.
  * **Pantalla de Acciones (Bitácora):** Registro de mantenimiento del usuario con confirmación SnackBar y línea de tiempo de intervenciones.

### D. Gemelo Digital / Prototipado 3D Interactivo
* **Tecnología:** WebGL / Three.js (renderizado acelerado por hardware a 60 fps).
* **Características:**
  * Modelado 3D de la compostera de madera con textura de sustrato orgánico y degradé térmico dinámico.
  * Modelado fotorrealista del ESP32 con antena Wi-Fi, microchip, pines GPIO y LED parpadeante.
  * Sensor DHT22 y sonda capacitiva sumergida en el abono.
  * Cableado jumper tridimensional con código de colores normalizado.
  * Ondas de radio Wi-Fi 3D animadas emitiendo en cada transmisión HTTP.
  * Dashboard HUD con telemetría en tiempo real, selector de escenarios de falla y terminal de inspección JSON.

---

## 2. Guion de Demostración en Vivo (Paso a Paso)

### Paso 1: Lanzar el Ecosistema
1. Ejecuta el archivo de un solo clic:
   ```cmd
   iniciar-demo.bat
   ```
2. Se abrirán simultáneamente:
   * La consola del **Backend REST** en el puerto 3000.
   * El **Simulador del Hardware ESP32** enviando paquetes JSON.
   * La **Simulación 3D Interactiva** en tu navegador Google Chrome o Edge.

### Paso 2: Explicar la Simulación 3D a los Evaluadores
* **Interacción 3D:** Mueve la cámara con el mouse (clic y arrastra para orbitar en 360°, rueda para zoom).
* **Mostrar los componentes etiquetados:** Señala el microcontrolador ESP32, el sensor DHT22, la sonda capacitiva sumergida y la caja compostera.
* **Prueba de escenarios con el selector interactivo:**
  1. Cambia a **"Forzar: Humedad Baja (<45%)"**: La telemetría cae a ~35%, el estado cambia a `HUMEDAD BAJA (Advertencia)` y la recomendación indica *"Regar la mezcla hasta humedecerla sin encharcar"*.
  2. Cambia a **"Forzar: Temp. Crítica (>65°C)"**: La temperatura sube a ~70°C, el compost se ilumina en rojo térmico, el estado pasa a `TEMPERATURA ALTA (Crítico)` y recomienda *"Voltear la mezcla y agregar material seco para bajar la temperatura"*.
  3. Muestra la terminal inferior: Observa los paquetes JSON con marcas de tiempo UTC RFC 3339 y la respuesta `HTTP 201 Created`.

### Paso 3: Demostrar la Aplicación Móvil
1. En la carpeta `app/`, ejecuta `flutter run`.
2. Inicia sesión (las credenciales de prueba vienen precargadas: `demo@compostera.bo`).
3. Observa en la **Pantalla de Inicio** cómo se reflejan las métricas de temperatura y humedad en tiempo real con las recomendaciones agronómicas.
4. Pasa a la pestaña **Historial** y muestra los gráficos interactivos de evolución temporal.
5. Ve a la pestaña **Acciones**, pulsa *"Registrar volteo"* y observa cómo se sincroniza y almacena en la bitácora del backend.

