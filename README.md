# App Composteras Domésticas

Aplicación móvil para monitorear una compostera doméstica desde el celular. Mide humedad y
temperatura, muestra el historial y recomienda qué acción tomar según el estado del compost.

Proyecto de la materia Desarrollo de Aplicaciones Móviles. Universidad Privada Franz Tamayo,
Ingeniería de Sistemas. La Paz, Bolivia, 2026.

## Integrantes

- Jhorddy Danner Condori Mamani
- Alex Rodrigo Ergueta Arce
- Juan Gabriel Ibañez Copatiti
- Juan Luis Mayta Guzman

## Estructura

| Carpeta | Contenido |
|---|---|
| `app/` | Aplicación Flutter |
| `backend/` | API REST en Node.js, autenticación y motor de reglas |
| `simulador/` | Emisor de lecturas mientras no hay hardware |
| `firmware/` | Código del ESP32 (pendiente de hardware) |
| `documentacion/` | Contrato de datos y decisiones técnicas |
| `scripts/` | Utilidades locales |

## Arquitectura

```
Nodo de sensado  ->  Backend (API REST + reglas)  ->  Firestore
                              |
                              v
                       App Flutter  <-  Notificaciones push
```

El nodo de sensado es hoy un simulador. El ESP32 está pendiente de compra y enviará el mismo
formato de datos, descrito en `documentacion/contrato-datos.md`.

Las recomendaciones se calculan en el backend. La app las muestra, no las decide.

## Puesta en marcha

Después de clonar, cada integrante corre una vez:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup-local.ps1
```

Aplicación Flutter:

```bash
cd app
flutter pub get
flutter run
```

Backend:

```bash
cd backend
npm install
npm run dev
```

## Ramas

```
main        versiones que funcionan
develop     integración
feature/*   una rama por tarea
```

Nadie sube a `main` ni a `develop` directo. Todo entra por Pull Request con un revisor distinto
del autor.
