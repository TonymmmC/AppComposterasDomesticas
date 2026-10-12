# Decisiones técnicas

Formato: problema, opciones consideradas, decisión, razón. Se agrega una entrada cada vez que
se toma una decisión de arquitectura, no al final del proyecto.

## 2026-10-11 — Base de datos: Firebase

**Problema.** El perfil de proyecto dejó abierta la elección entre PostgreSQL y Firebase.

**Opciones.** PostgreSQL con Prisma en el backend; Firebase (Firestore, Auth, Cloud Messaging);
híbrido con PostgreSQL para el historial y Firebase solo para notificaciones.

**Decisión.** Firebase.

**Razón.** Tres requerimientos funcionales se resuelven con servicios ya existentes en lugar de
construirlos: RF-01 con Firebase Auth, RF-05 con Cloud Messaging y RF-02 con las lecturas en
tiempo real de Firestore. Son ocho semanas de ejecución y cuatro integrantes sin experiencia
previa en el stack. El híbrido obliga a mantener dos servicios y dos modelos de datos, costo que
no se justifica en este alcance.

## 2026-10-11 — Un solo repositorio para las tres piezas

**Problema.** El proyecto tiene app móvil, backend y firmware. Podían ir en repositorios
separados.

**Opciones.** Tres repositorios; un monorepo con una carpeta por pieza; solo la app en el
repositorio.

**Decisión.** Monorepo con `app/`, `backend/`, `firmware/` y `simulador/`.

**Razón.** Un clon por integrante, una sola historia de commits y una sola entrega al docente.
Tres repositorios triplican la coordinación entre cuatro personas sin beneficio técnico en este
tamaño.

## 2026-10-11 — Sin machine learning

**Problema.** El perfil de proyecto prometía un modelo de aprendizaje que sugiriera acciones a
partir de los patrones de lectura.

**Opciones.** Implementar un modelo simple; dejar la promesa y resolverla si sobra tiempo;
quitar la promesa y resolver con reglas.

**Decisión.** Motor de reglas sobre rangos documentados. Se elimina la mención de machine
learning del documento.

**Razón.** Un modelo necesita historial real de composteras, que no existe. Las reglas
agronómicas (humedad entre 40 y 60 por ciento, fases mesófila y termófila) resuelven el problema
del usuario con fundamento citable. Afirmar en el documento una capacidad que el código no tiene
es indefendible ante el docente.

## 2026-10-11 — Nodo de sensado simulado

**Problema.** No hay hardware. El ESP32 y los sensores están pendientes de compra, sin fecha.

**Opciones.** Esperar el hardware; simular las lecturas dentro de la app; un simulador
independiente que use el mismo contrato de datos que usará el ESP32.

**Decisión.** Simulador independiente en `simulador/`, que envía al mismo endpoint y con el
mismo formato que enviará el nodo físico.

**Razón.** Desbloquea el backend y la app desde el primer día. Cuando llegue el hardware, solo
cambia quién emite: ni el backend ni la app se modifican. Simular dentro de la app en cambio
dejaría el backend sin probar y obligaría a reescribir el flujo después.

El documento declara el nodo como simulado. No se presenta como hardware instalado.

## 2026-10-11 — El motor de reglas corre en el backend

**Problema.** Las recomendaciones podían calcularse en el teléfono o en el servidor.

**Opciones.** En la app, con los umbrales en código Dart; en el backend, con la app mostrando el
resultado.

**Decisión.** En el backend.

**Razón.** Los umbrales se corrigen en un solo lugar y sin publicar una versión nueva del APK.
Si la lógica viviera en el cliente, cada versión instalada recomendaría distinto. Además las
notificaciones push se disparan del lado del servidor, donde ya se evalúa la lectura.
