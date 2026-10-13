export type Severidad = 'ok' | 'advertencia' | 'critico';

export type Estado =
  | 'optimo'
  | 'humedad_baja'
  | 'humedad_alta'
  | 'temperatura_baja'
  | 'temperatura_alta'
  | 'sin_datos';

export interface Evaluacion {
  estado: Estado;
  recomendacion: string;
  severidad: Severidad;
}

// Rangos agronomicos. Viven en un solo lugar del backend, nunca repetidos en
// la app. Ver documentacion/contrato-datos.md y documentacion/decisiones.md.
export const RANGOS = {
  humedadMin: 40,
  humedadMax: 60,
  temperaturaMin: 20,
  temperaturaMax: 65,
} as const;

// Sin lecturas en las ultimas 6 horas se reporta sin_datos.
export const HORAS_SIN_DATOS = 6;

const RESPUESTAS: Record<Estado, { recomendacion: string; severidad: Severidad }> = {
  optimo: {
    recomendacion: 'Mantener el compost en las condiciones actuales',
    severidad: 'ok',
  },
  humedad_baja: {
    recomendacion: 'Regar la mezcla hasta humedecerla sin encharcar',
    severidad: 'advertencia',
  },
  humedad_alta: {
    recomendacion: 'Agregar material seco y voltear para airear la mezcla',
    severidad: 'advertencia',
  },
  temperatura_baja: {
    recomendacion: 'Acercar la compostera al sol y sumar material verde',
    severidad: 'advertencia',
  },
  temperatura_alta: {
    recomendacion: 'Voltear la mezcla y agregar material seco para bajar la temperatura',
    severidad: 'critico',
  },
  sin_datos: {
    recomendacion: 'Verificar el nodo de sensado, no hay lecturas recientes',
    severidad: 'advertencia',
  },
};

function evaluacion(estado: Estado): Evaluacion {
  return { estado, ...RESPUESTAS[estado] };
}

// Orden de precedencia segun la tabla del contrato: primero humedad, luego
// temperatura. Un solo estado por lectura.
export function evaluarLectura(temperatura: number, humedad: number): Evaluacion {
  if (humedad < RANGOS.humedadMin) return evaluacion('humedad_baja');
  if (humedad > RANGOS.humedadMax) return evaluacion('humedad_alta');
  if (temperatura < RANGOS.temperaturaMin) return evaluacion('temperatura_baja');
  if (temperatura > RANGOS.temperaturaMax) return evaluacion('temperatura_alta');
  return evaluacion('optimo');
}

export function evaluarSinDatos(momentoUltimaLectura: Date, ahora: Date = new Date()): Evaluacion | null {
  const horas = (ahora.getTime() - momentoUltimaLectura.getTime()) / 3_600_000;
  return horas > HORAS_SIN_DATOS ? evaluacion('sin_datos') : null;
}
