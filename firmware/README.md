# Firmware del nodo ESP32

Pendiente de hardware. El ESP32, el DHT22 y el sensor de humedad de suelo no estan comprados.

Mientras tanto, la fuente de datos del sistema es `simulador/`.

## Cuando llegue el hardware

El firmware debe emitir exactamente el mismo JSON que el simulador, descrito en
`documentacion/contrato-datos.md`. Nada del backend ni de la app cambia por eso.

1. Lectura del DHT22 (temperatura y humedad del aire).
2. Lectura del sensor de humedad de suelo, calibrado contra la mezcla real.
3. Conexion Wi-Fi y envio HTTPS al endpoint.
4. Ciclos de suspension para ahorrar energia (RNF-04).
