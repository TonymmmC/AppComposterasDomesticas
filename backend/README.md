# Backend

API REST en Node.js con TypeScript. Recibe las lecturas del nodo, evalua el estado, guarda en
Firestore y dispara las notificaciones push.

## Responsable

Alex Rodrigo Ergueta Arce.

## Estructura

| Carpeta | Contenido |
|---|---|
| `src/rutas/` | Endpoints. Validan el cuerpo antes de llamar al servicio |
| `src/servicios/` | Logica de negocio. No sabe que existe HTTP |
| `src/reglas/` | Rangos agronomicos y motor de recomendaciones |
| `src/validaciones/` | Schemas Zod. Fuente de verdad de los tipos de entrada |

## Puesta en marcha

Requiere Node.js LTS (>= 20). Desde `backend/`:

```bash
npm install
copy .env.example .env
npm run dev
```

El servidor queda en `http://localhost:3000`. El token de ejemplo vive en
`.env` (`TOKEN_DISPOSITIVO`). En produccion lo verifica Firebase Auth.

## Probar los endpoints

Lectura valida (responde 201 con el estado evaluado):

```bash
curl -i -X POST http://localhost:3000/api/lecturas `
  -H "Authorization: Bearer compostera-token-local" `
  -H "Content-Type: application/json" `
  -d '{"dispositivo":"compostera-01","temperatura":42.5,"humedad":55.0,"momento":"2026-10-11T18:30:00Z"}'
```

Cuerpo invalido (400), sin token o token incorrecto (401):

```bash
curl -i -X POST http://localhost:3000/api/lecturas `
  -H "Content-Type: application/json" `
  -d '{"dispositivo":"x","temperatura":500,"humedad":-1,"momento":"ayer"}'
```

Historial por dispositivo y rango de fechas (UTC):

```bash
curl "http://localhost:3000/api/lecturas?dispositivo=compostera-01&desde=2026-10-01&hasta=2026-10-31"
```

Salud del servicio:

```bash
curl http://localhost:3000/salud
```

Hoy la persistencia es en memoria: al reiniciar el servidor el historial se
vacia. Firestore entra en la siguiente iteracion.

## Pruebas

```bash
npm test
```

Corre las pruebas del motor de reglas y de la validacion con el runner nativo
de Node (`node --test` + tsx).

## Tareas del sprint 1

1. Proyecto Express con TypeScript y Zod.
2. `POST /api/lecturas` con validacion del cuerpo y del token del dispositivo.
3. Motor de reglas segun la tabla de estados de `documentacion/contrato-datos.md`.
4. Escritura en Firestore.
5. `GET /api/lecturas` con filtro por dispositivo y rango de fechas.

El contrato de datos no se cambia sin acuerdo del equipo.
