import express, { NextFunction, Request, Response } from 'express';
import { routerLecturas } from './rutas/lecturas';

export function crearApp() {
  const app = express();
  app.use(express.json());

  app.get('/salud', (_req, res) => {
    res.json({ estado: 'ok' });
  });

  app.use('/api/lecturas', routerLecturas);

  // Ruta no encontrada.
  app.use((_req, res) => {
    res.status(404).json({ error: 'ruta_no_encontrada' });
  });

  // Errores de parseo (JSON malformado) y cualquier otro, siempre en JSON.
  app.use((error: Error, _req: Request, res: Response, _next: NextFunction) => {
    const esJsonInvalido = error instanceof SyntaxError && 'body' in error;
    res.status(esJsonInvalido ? 400 : 500).json({
      error: esJsonInvalido ? 'json_malformado' : 'error_interno',
    });
  });

  return app;
}
