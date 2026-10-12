import { pathToFileURL } from 'node:url';

export const INTERVAL_MS = 10_000;

export function buildReading(deviceId, now = new Date()) {
  return {
    dispositivo: deviceId,
    temperatura: 42.5,
    humedad: 55.0,
    momento: now.toISOString(),
  };
}

export function loadConfig(env = process.env) {
  const endpoint = env.SIMULADOR_URL ?? 'http://localhost:3000/api/lecturas';
  const token = env.TOKEN_DISPOSITIVO;
  const deviceId = env.DISPOSITIVO_ID ?? 'compostera-01';
  const url = new URL(endpoint);

  if (url.protocol !== 'http:' && url.protocol !== 'https:') {
    throw new Error('SIMULADOR_URL debe usar HTTP o HTTPS.');
  }
  if (!token) {
    throw new Error('Falta configurar TOKEN_DISPOSITIVO.');
  }
  if (deviceId.length < 3 || deviceId.length > 40) {
    throw new Error('DISPOSITIVO_ID debe tener entre 3 y 40 caracteres.');
  }

  return { url: url.toString(), token, deviceId };
}

export async function sendReading({
  url,
  token,
  deviceId,
  fetchImpl = fetch,
  now = new Date(),
}) {
  const reading = buildReading(deviceId, now);
  const response = await fetchImpl(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(reading),
  });
  const responseBody = await response.text();

  if (!response.ok) {
    throw new Error(
      `El backend respondió HTTP ${response.status}${responseBody ? `: ${responseBody}` : '.'}`,
    );
  }

  return { reading, status: response.status, responseBody };
}

export async function runSimulator(config, {
  fetchImpl = fetch,
  log = console.log,
  reportError = console.error,
  sleep = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds)),
} = {}) {
  while (true) {
    try {
      const result = await sendReading({ ...config, fetchImpl });
      log(`Lectura enviada (${result.status}): ${JSON.stringify(result.reading)}`);
    } catch (error) {
      reportError(`No se pudo enviar la lectura: ${error.message}`);
    }

    await sleep(INTERVAL_MS);
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    await runSimulator(loadConfig());
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
