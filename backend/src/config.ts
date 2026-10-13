import 'dotenv/config';

export const PUERTO = Number(process.env.PORT ?? 3000);

export const TOKEN_DISPOSITIVO = process.env.TOKEN_DISPOSITIVO ?? '';
