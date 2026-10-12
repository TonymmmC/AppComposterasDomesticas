# Simulador del nodo de sensado

Emite lecturas al backend mientras no hay hardware. Envia exactamente el formato que enviara el
ESP32, descrito en `documentacion/contrato-datos.md`.

## Ejecucion

Requiere Node.js 18 o posterior. No necesita instalar dependencias.

Configura el token que espera el backend y, si corresponde, cambia la URL o el identificador:

```powershell
$env:TOKEN_DISPOSITIVO = "tu-token"
$env:SIMULADOR_URL = "http://localhost:3000/api/lecturas"
$env:DISPOSITIVO_ID = "compostera-01"
npm start
```

`SIMULADOR_URL` y `DISPOSITIVO_ID` son opcionales; esos son sus valores por defecto.
`TOKEN_DISPOSITIVO` es obligatorio. El simulador manda la primera lectura al iniciar y luego
espera 10 segundos entre envios. Usa `Authorization: Bearer <token>` y el cuerpo exacto de
`documentacion/contrato-datos.md`. Los valores simulados son 42.5 °C y 55 %; cada lectura
incluye el momento actual en UTC.

Ejecuta las pruebas del contrato y del envio HTTP con:

```powershell
npm test
```

## Por que existe

Sin esto, el backend y la app quedan bloqueados esperando el hardware. Cuando llegue el ESP32,
solo cambia quien emite: el backend y la app no se modifican.

## Alcance

El simulador envía lecturas periódicas y permite configurar el endpoint, el dispositivo y su
token. Las curvas realistas y los modos para forzar estados quedan fuera de esta tarea.
