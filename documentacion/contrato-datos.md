# Contrato de datos

Lo que se envían las capas entre sí. Es el único acuerdo que permite a cuatro personas avanzar
en paralelo sin esperarse.

**Cambiarlo es decisión de equipo.** Toca las tres capas a la vez.

## Lectura del nodo de sensado

El simulador de hoy y el ESP32 de mañana envían exactamente esto. Cuando llegue el hardware, el
backend y la app no se modifican.

`POST /api/lecturas`

```json
{
  "dispositivo": "compostera-01",
  "temperatura": 42.5,
  "humedad": 55.0,
  "momento": "2026-10-11T18:30:00Z"
}
```

| Campo | Tipo | Regla |
|---|---|---|
| `dispositivo` | string | Identificador del nodo. Entre 3 y 40 caracteres |
| `temperatura` | number | Grados Celsius. Entre -10 y 90 |
| `humedad` | number | Porcentaje. Entre 0 y 100 |
| `momento` | string | ISO 8601 en UTC, con la Z final |

Cabecera obligatoria: `Authorization: Bearer <token del dispositivo>`.

Respuesta 201 con el estado evaluado:

```json
{
  "estado": "humedad_baja",
  "recomendacion": "Regar la mezcla hasta humedecerla sin encharcar",
  "severidad": "advertencia"
}
```

## Estados posibles

Los calcula el backend, nunca la app. La app solo muestra lo que recibe.

| Estado | Condición | Severidad |
|---|---|---|
| `optimo` | Humedad 45 a 60 %, temperatura 20 a 65 °C | `ok` |
| `humedad_baja` | Humedad menor a 45 % | `advertencia` |
| `humedad_alta` | Humedad mayor a 60 % | `advertencia` |
| `temperatura_baja` | Menor a 20 °C | `advertencia` |
| `temperatura_alta` | Mayor a 65 °C | `critico` |
| `sin_datos` | Sin lecturas en las últimas 6 horas | `advertencia` |

El rango de humedad sale del manual de compostaje de la FAO (Román, Martínez y Pantoja, 2013):
por debajo del 45 % la actividad microbiana disminuye, y por encima del 60 % el agua satura los
poros e impide la oxigenación. No cambiar estos valores sin una fuente que lo respalde, porque
el documento académico los cita.

Los umbrales viven en un solo archivo del backend, no repetidos en la app.

## Historial

`GET /api/lecturas?dispositivo=compostera-01&desde=2026-10-01&hasta=2026-10-11`

```json
{
  "lecturas": [
    { "temperatura": 42.5, "humedad": 55.0, "momento": "2026-10-11T18:30:00Z" }
  ]
}
```

## Acción del usuario

`POST /api/acciones`

```json
{
  "dispositivo": "compostera-01",
  "tipo": "volteo",
  "momento": "2026-10-11T19:00:00Z"
}
```

Tipos válidos: `volteo`, `riego`, `material_seco`, `material_verde`.

## Reglas que valen para todo el contrato

- Los tiempos viajan en UTC. La conversión a `America/La_Paz` es de la app.
- Los números viajan sin redondear. El redondeo a un decimal es de la interfaz.
- Temperatura siempre en grados Celsius, humedad siempre en porcentaje. Una sola unidad en todo
  el sistema.
- El backend valida todo cuerpo recibido antes de escribir. Un dato malo guardado contamina el
  historial y los gráficos para siempre.
