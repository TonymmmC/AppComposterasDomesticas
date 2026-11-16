import path from 'path';
import express, { NextFunction, Request, Response } from 'express';
import { routerLecturas } from './rutas/lecturas';
import { routerAcciones } from './rutas/acciones';

export function crearApp() {
  const app = express();
  app.use(express.json());

  // Soporte CORS para clientes Web, emuladores y dispositivos móviles
  app.use((_req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    if (_req.method === 'OPTIONS') {
      res.sendStatus(204);
      return;
    }
    next();
  });

  // Servir la Simulación 3D interactiva del Hardware por HTTP
  const webDir = path.resolve(__dirname, '../../simulador/web');
  app.use('/simulador', express.static(webDir));
  app.get('/3d', (_req, res) => {
    res.sendFile(path.join(webDir, 'index.html'));
  });

  app.get('/salud', (_req, res) => {
    res.json({ estado: 'ok' });
  });

  app.use('/api/lecturas', routerLecturas);
  app.use('/api/acciones', routerAcciones);

  // Si abren la raíz http://localhost:3000/, mostrar la simulación 3D
  app.get('/', (_req, res) => {
    res.sendFile(path.join(webDir, 'index.html'));
  });

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
