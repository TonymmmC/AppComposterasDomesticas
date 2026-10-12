import { Lectura } from '../validaciones/lectura';
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
