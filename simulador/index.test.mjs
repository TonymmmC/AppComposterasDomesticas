import assert from 'node:assert/strict';
import { once } from 'node:events';
import { createServer } from 'node:http';
import test from 'node:test';
import {
  buildReading,
  INTERVAL_MS,
  loadConfig,
  sendReading,
} from './index.mjs';

test('construye la lectura con el formato exacto del contrato', () => {
  const reading = buildReading('compostera-01', new Date('2026-10-11T18:30:00.000Z'));

  assert.deepEqual(Object.keys(reading), [
    'dispositivo',
    'temperatura',
    'humedad',
    'momento',
  ]);
  assert.deepEqual(reading, {
    dispositivo: 'compostera-01',
    temperatura: 42.5,
    humedad: 55,
    momento: '2026-10-11T18:30:00.000Z',
  });
  assert.equal(INTERVAL_MS, 10_000);
});

test('configura el endpoint, token e identificador del dispositivo', () => {
  assert.deepEqual(
    loadConfig({
      SIMULADOR_URL: 'https://localhost/api/lecturas',
      TOKEN_DISPOSITIVO: 'token-de-prueba',
      DISPOSITIVO_ID: 'compostera-02',
    }),
    {
      url: 'https://localhost/api/lecturas',
      token: 'token-de-prueba',
      deviceId: 'compostera-02',
    },
  );
  assert.throws(
    () => loadConfig({}),
    /Falta configurar TOKEN_DISPOSITIVO/,
  );
});

test('envía POST con JSON y autorización Bearer al endpoint', async (t) => {
  let requestBody;
  let authorization;
  let contentType;
  const server = createServer((request, response) => {
    requestBody = '';
    authorization = request.headers.authorization;
    contentType = request.headers['content-type'];
    request.on('data', (chunk) => {
      requestBody += chunk;
    });
    request.on('end', () => {
      response.writeHead(201, { 'Content-Type': 'application/json' });
      response.end('{"estado":"optimo"}');
    });
  });

  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  t.after(() => new Promise((resolve, reject) => {
    server.close((error) => (error ? reject(error) : resolve()));
  }));

  const address = server.address();
  const result = await sendReading({
    url: `http://127.0.0.1:${address.port}/api/lecturas`,
    token: 'token-de-prueba',
    deviceId: 'compostera-01',
    now: new Date('2026-10-11T18:30:00.000Z'),
  });

  assert.equal(result.status, 201);
  assert.deepEqual(JSON.parse(requestBody), result.reading);
  assert.equal(authorization, 'Bearer token-de-prueba');
  assert.equal(contentType, 'application/json');
});

test('reporta el cuerpo de respuesta cuando el backend rechaza la lectura', async () => {
  await assert.rejects(
    sendReading({
      url: 'http://localhost/api/lecturas',
      token: 'token-de-prueba',
      deviceId: 'compostera-01',
      fetchImpl: async () => new Response('token inválido', { status: 401 }),
    }),
    /HTTP 401: token inválido/,
  );
});
