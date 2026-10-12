# Simulador del nodo de sensado

Emite lecturas al backend mientras no hay hardware. Envia exactamente el formato que enviara el
ESP32, descrito en `documentacion/contrato-datos.md`.

## Responsable

Pendiente de asignacion.

## Por que existe

Sin esto, el backend y la app quedan bloqueados esperando el hardware. Cuando llegue el ESP32,
solo cambia quien emite: el backend y la app no se modifican.

## Tareas del sprint 1

1. Script que envia una lectura al endpoint cada N segundos.
2. Curva realista: la temperatura sube en fase termofila y baja despues, la humedad baja con el
   tiempo y sube al regar.
3. Modos de prueba para forzar cada estado: humedad baja, temperatura alta, sin datos.
4. Token de dispositivo configurable por variable de entorno.
