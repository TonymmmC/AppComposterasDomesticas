import { Lectura, FiltroHistorial } from '../validaciones/lectura';
import { evaluarLectura, Evaluacion } from '../reglas/estados';

interface LecturaGuardada extends Lectura {
  evaluacion: Evaluacion;
}

// Almacen en memoria. Sustituye a Firestore mientras no hay persistencia real.
// Se pierde al reiniciar el servidor, es intencional en esta etapa.
const lecturas: LecturaGuardada[] = [];

export function guardarLectura(lectura: Lectura): Evaluacion {
  const evaluacion = evaluarLectura(lectura.temperatura, lectura.humedad);
  lecturas.push({ ...lectura, evaluacion });
  return evaluacion;
}

export interface LecturaHistorial {
  temperatura: number;
  humedad: number;
  momento: string;
}

export function listarLecturas(filtro: FiltroHistorial): LecturaHistorial[] {
  const desde = filtro.desde ? new Date(`${filtro.desde}T00:00:00.000Z`).getTime() : -Infinity;
  const hasta = filtro.hasta ? new Date(`${filtro.hasta}T23:59:59.999Z`).getTime() : Infinity;

  return lecturas
    .filter((lectura) => {
      if (lectura.dispositivo !== filtro.dispositivo) return false;
      const momento = new Date(lectura.momento).getTime();
      return momento >= desde && momento <= hasta;
    })
    .sort((a, b) => new Date(a.momento).getTime() - new Date(b.momento).getTime())
    .map((lectura) => ({
      temperatura: lectura.temperatura,
      humedad: lectura.humedad,
      momento: lectura.momento,
    }));
}
