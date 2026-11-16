import { z } from 'zod';

export const esquemaAccion = z
  .object({
    dispositivo: z.string().min(3).max(40),
    tipo: z.enum(['volteo', 'riego', 'material_seco', 'material_verde']),
    momento: z.string().datetime(),
  })
  .strict();

export type Accion = z.infer<typeof esquemaAccion>;

export const esquemaFiltroAcciones = z.object({
  dispositivo: z.string().min(3).max(40),
  desde: z.string().date().optional(),
  hasta: z.string().date().optional(),
});

export type FiltroAcciones = z.infer<typeof esquemaFiltroAcciones>;
