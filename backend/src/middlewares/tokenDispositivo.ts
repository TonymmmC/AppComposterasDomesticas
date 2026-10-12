import { Request, Response, NextFunction } from 'express';
import { TOKEN_DISPOSITIVO } from '../config';

// Cabecera obligatoria del contrato: Authorization: Bearer <token del dispositivo>.
// Hoy el token es un valor de entorno. Cuando llegue Firebase Auth se verifica
// el token real en este mismo punto.
export function exigirTokenDispositivo(req: Request, res: Response, next: NextFunction): void {
  const cabecera = req.header('authorization') ?? '';
  const [tipo, token] = cabecera.split(' ');

  if (tipo !== 'Bearer' || !token) {
    res.status(401).json({ error: 'token_ausente' });
    return;
  }

  if (!TOKEN_DISPOSITIVO || token !== TOKEN_DISPOSITIVO) {
    res.status(401).json({ error: 'token_invalido' });
    return;
  }

  next();
}
