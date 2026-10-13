import { z } from 'zod';

// Fuente de verdad de los tipos de entrada. Refleja la tabla de reglas de
// documentacion/contrato-datos.md. Cambiar esto es decision de equipo.
export const esquemaLectura = z
  .object({
    dispositivo: z.string().min(3).max(40),
    temperatura: z.number().min(-10).max(90),
    humedad: z.number().min(0).max(100),
    momento: z.string().datetime(),
  })
  .strict();

export type Lectura = z.infer<typeof esquemaLectura>;

// Parametros del historial: GET /api/lecturas?dispositivo=&desde=&hasta=
export const esquemaFiltroHistorial = z.object({
  dispositivo: z.string().min(3).max(40),
  desde: z.string().date().optional(),
  hasta: z.string().date().optional(),
});

export type FiltroHistorial = z.infer<typeof esquemaFiltroHistorial>;
