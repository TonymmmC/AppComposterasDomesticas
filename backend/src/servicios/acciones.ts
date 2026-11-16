import { Accion, FiltroAcciones } from '../validaciones/accion';

const acciones: Accion[] = [];

export function guardarAccion(accion: Accion): Accion {
  acciones.push(accion);
  return accion;
}

export function listarAcciones(filtro: FiltroAcciones): Accion[] {
  const desde = filtro.desde ? new Date(`${filtro.desde}T00:00:00.000Z`).getTime() : -Infinity;
  const hasta = filtro.hasta ? new Date(`${filtro.hasta}T23:59:59.999Z`).getTime() : Infinity;

  return acciones
    .filter((accion) => {
      if (accion.dispositivo !== filtro.dispositivo) return false;
      const momento = new Date(accion.momento).getTime();
      return momento >= desde && momento <= hasta;
    })
    .sort((a, b) => new Date(a.momento).getTime() - new Date(b.momento).getTime());
}

export function vaciarAcciones(): void {
  acciones.length = 0;
}
