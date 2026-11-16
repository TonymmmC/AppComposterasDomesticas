import { Router } from 'express';
import { esquemaAccion, esquemaFiltroAcciones } from '../validaciones/accion';
import { guardarAccion, listarAcciones } from '../servicios/acciones';

export const routerAcciones = Router();

// POST /api/acciones — bitácora de mantenimiento (volteo, riego, etc.)
routerAcciones.post('/', (req, res) => {
  const resultado = esquemaAccion.safeParse(req.body);
  if (!resultado.success) {
    res.status(400).json({
      error: 'cuerpo_invalido',
      detalles: resultado.error.issues.map((issue) => ({
        campo: issue.path.join('.'),
        mensaje: issue.message,
      })),
    });
    return;
  }

  const guardada = guardarAccion(resultado.data);
  res.status(201).json({ estado: 'ok', accion: guardada });
});

// GET /api/acciones?dispositivo=&desde=&hasta=
routerAcciones.get('/', (req, res) => {
  const resultado = esquemaFiltroAcciones.safeParse(req.query);
  if (!resultado.success) {
    res.status(400).json({
      error: 'filtro_invalido',
      detalles: resultado.error.issues.map((issue) => ({
        campo: issue.path.join('.'),
        mensaje: issue.message,
      })),
    });
    return;
  }

  res.json({ acciones: listarAcciones(resultado.data) });
});
