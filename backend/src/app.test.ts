import { before, beforeEach, describe, it } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import type { Express } from 'express';

const TOKEN = 'compostera-token-local';

const lecturaValida = {
  dispositivo: 'compostera-01',
  temperatura: 42.5,
  humedad: 55.0,
  momento: '2026-10-11T18:30:00Z',
};

describe('endpoints /api/lecturas', () => {
  let app: Express;
  let vaciarLecturas: () => void;

  before(async () => {
    // El token se lee al cargar config. Se define antes del import dinamico
    // para que las pruebas no dependan del .env local.
    process.env.TOKEN_DISPOSITIVO = TOKEN;
    const { crearApp } = await import('./app');
    ({ vaciarLecturas } = await import('./servicios/lecturas'));
    app = crearApp();
  });

  beforeEach(() => {
    vaciarLecturas();
  });

  describe('POST /api/lecturas', () => {
    it('responde 201 con el estado evaluado', async () => {
      const res = await request(app)
        .post('/api/lecturas')
        .set('Authorization', `Bearer ${TOKEN}`)
        .send(lecturaValida);

      assert.equal(res.status, 201);
      assert.deepEqual(res.body, {
        estado: 'optimo',
        recomendacion: 'Mantener el compost en las condiciones actuales',
        severidad: 'ok',
      });
    });

    it('responde 201 y guarda la lectura para el historial', async () => {
      await request(app)
        .post('/api/lecturas')
        .set('Authorization', `Bearer ${TOKEN}`)
        .send(lecturaValida)
        .expect(201);

      const res = await request(app).get('/api/lecturas?dispositivo=compostera-01').expect(200);
      assert.equal(res.body.lecturas.length, 1);
      assert.deepEqual(res.body.lecturas[0], {
        temperatura: 42.5,
        humedad: 55,
        momento: '2026-10-11T18:30:00Z',
      });
    });

    it('rechaza un cuerpo invalido con 400 y detalle por campo', async () => {
      const res = await request(app)
        .post('/api/lecturas')
        .set('Authorization', `Bearer ${TOKEN}`)
        .send({ dispositivo: 'x', temperatura: 500, humedad: -1, momento: 'ayer' });

      assert.equal(res.status, 400);
      assert.equal(res.body.error, 'cuerpo_invalido');
      assert.ok(res.body.detalles.length >= 4);
    });

    it('responde 401 sin token', async () => {
      const res = await request(app).post('/api/lecturas').send(lecturaValida);
      assert.equal(res.status, 401);
      assert.equal(res.body.error, 'token_ausente');
    });

    it('responde 401 con token incorrecto', async () => {
      const res = await request(app)
        .post('/api/lecturas')
        .set('Authorization', 'Bearer incorrecto')
        .send(lecturaValida);
      assert.equal(res.status, 401);
      assert.equal(res.body.error, 'token_invalido');
    });

    it('responde 400 json_malformado con JSON invalido', async () => {
      const res = await request(app)
        .post('/api/lecturas')
        .set('Authorization', `Bearer ${TOKEN}`)
        .set('Content-Type', 'application/json')
        .send('{malformado');

      assert.equal(res.status, 400);
      assert.equal(res.body.error, 'json_malformado');
    });
  });

  describe('GET /api/lecturas', () => {
    it('filtra por dispositivo y rango de fechas', async () => {
      await request(app).post('/api/lecturas').set('Authorization', `Bearer ${TOKEN}`).send(lecturaValida).expect(201);
      await request(app)
        .post('/api/lecturas')
        .set('Authorization', `Bearer ${TOKEN}`)
        .send({ ...lecturaValida, temperatura: 46.0, momento: '2026-10-11T19:00:00Z' })
        .expect(201);

      const dentro = await request(app)
        .get('/api/lecturas?dispositivo=compostera-01&desde=2026-10-11&hasta=2026-10-11')
        .expect(200);
      assert.equal(dentro.body.lecturas.length, 2);
      assert.deepEqual(dentro.body.lecturas[0], {
        temperatura: 42.5,
        humedad: 55,
        momento: '2026-10-11T18:30:00Z',
      });

      const fuera = await request(app)
        .get('/api/lecturas?dispositivo=compostera-01&desde=2026-10-12')
        .expect(200);
      assert.deepEqual(fuera.body.lecturas, []);
    });

    it('rechaza la peticion sin dispositivo con 400', async () => {
      const res = await request(app).get('/api/lecturas').expect(400);
      assert.equal(res.body.error, 'filtro_invalido');
    });
  });

  describe('otros', () => {
    it('responde 200 en /salud', async () => {
      const res = await request(app).get('/salud').expect(200);
      assert.deepEqual(res.body, { estado: 'ok' });
    });

    it('responde 404 en una ruta inexistente', async () => {
      const res = await request(app).get('/no-existe').expect(404);
      assert.equal(res.body.error, 'ruta_no_encontrada');
    });
  });
});