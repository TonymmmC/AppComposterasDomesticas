# Backend

API REST en Node.js con TypeScript. Recibe las lecturas del nodo, evalua el estado, guarda en
Firestore y dispara las notificaciones push.

## Responsable

Pendiente de asignacion.

## Estructura

| Carpeta | Contenido |
|---|---|
| `src/rutas/` | Endpoints. Validan el cuerpo antes de llamar al servicio |
| `src/servicios/` | Logica de negocio. No sabe que existe HTTP |
| `src/reglas/` | Rangos agronomicos y motor de recomendaciones |
| `src/validaciones/` | Schemas Zod. Fuente de verdad de los tipos de entrada |

## Tareas del sprint 1

1. Proyecto Express con TypeScript y Zod.
2. `POST /api/lecturas` con validacion del cuerpo y del token del dispositivo.
3. Motor de reglas segun la tabla de estados de `documentacion/contrato-datos.md`.
4. Escritura en Firestore.
5. `GET /api/lecturas` con filtro por dispositivo y rango de fechas.

El contrato de datos no se cambia sin acuerdo del equipo.
