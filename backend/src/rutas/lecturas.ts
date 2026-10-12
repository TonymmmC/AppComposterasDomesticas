import { Router } from 'express';
import { esquemaLectura } from '../validaciones/lectura';
import { guardarLectura } from '../servicios/lecturas';
import { exigirTokenDispositivo } from '../middlewares/tokenDispositivo';

export const routerLecturas = Router();

// POST /api/lecturas — recibe la lectura del nodo, la valida, evalua el estado
// y responde 201 con { estado, recomendacion, severidad }.
routerLecturas.post('/', exigirTokenDispositivo, (req, res) => {
  const resultado = esquemaLectura.safeParse(req.body);
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

  const evaluacion = guardarLectura(resultado.data);
  res.status(201).json(evaluacion);
});
