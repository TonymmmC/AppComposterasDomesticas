import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { esquemaLectura, esquemaFiltroHistorial } from './lectura';

const lecturaValida = {
  dispositivo: 'compostera-01',
  temperatura: 42.5,
  humedad: 55.0,
  momento: '2026-10-11T18:30:00Z',
};

describe('esquemaLectura', () => {
  it('acepta una lectura valida', () => {
    const r = esquemaLectura.safeParse(lecturaValida);
    assert.equal(r.success, true);
  });

  it('acepta los limites de los rangos', () => {
    const r = esquemaLectura.safeParse({
      ...lecturaValida,
      dispositivo: 'abc',
      temperatura: -10,
      humedad: 100,
    });
    assert.equal(r.success, true);

    const r2 = esquemaLectura.safeParse({
      ...lecturaValida,
      dispositivo: 'a'.repeat(40),
      temperatura: 90,
      humedad: 0,
    });
    assert.equal(r2.success, true);
  });

  it('rechaza un dispositivo demasiado corto o largo', () => {
    assert.equal(esquemaLectura.safeParse({ ...lecturaValida, dispositivo: 'ab' }).success, false);
    assert.equal(esquemaLectura.safeParse({ ...lecturaValida, dispositivo: 'a'.repeat(41) }).success, false);
  });

  it('rechaza temperaturas fuera de -10 a 90', () => {
    assert.equal(esquemaLectura.safeParse({ ...lecturaValida, temperatura: -10.1 }).success, false);
    assert.equal(esquemaLectura.safeParse({ ...lecturaValida, temperatura: 90.1 }).success, false);
  });

  it('rechaza humedad fuera de 0 a 100', () => {
    assert.equal(esquemaLectura.safeParse({ ...lecturaValida, humedad: -1 }).success, false);
    assert.equal(esquemaLectura.safeParse({ ...lecturaValida, humedad: 100.1 }).success, false);
  });

  it('rechaza un momento sin Z final', () => {
    assert.equal(
      esquemaLectura.safeParse({ ...lecturaValida, momento: '2026-10-11T18:30:00-04:00' }).success,
      false,
    );
    assert.equal(esquemaLectura.safeParse({ ...lecturaValida, momento: '2026-10-11' }).success, false);
  });

  it('rechaza campos desconocidos', () => {
    assert.equal(esquemaLectura.safeParse({ ...lecturaValida, extra: 'no' }).success, false);
  });

  it('rechaza numeros como string', () => {
    assert.equal(esquemaLectura.safeParse({ ...lecturaValida, temperatura: '42.5' }).success, false);
  });
});

describe('esquemaFiltroHistorial', () => {
  it('exige el dispositivo', () => {
    assert.equal(esquemaFiltroHistorial.safeParse({ desde: '2026-10-01' }).success, false);
  });

  it('acepta solo el dispositivo', () => {
    assert.equal(esquemaFiltroHistorial.safeParse({ dispositivo: 'compostera-01' }).success, true);
  });

  it('acepta el rango de fechas en formato YYYY-MM-DD', () => {
    const r = esquemaFiltroHistorial.safeParse({
      dispositivo: 'compostera-01',
      desde: '2026-10-01',
      hasta: '2026-10-11',
    });
    assert.equal(r.success, true);
  });

  it('rechaza fechas con formato incorrecto', () => {
    assert.equal(
      esquemaFiltroHistorial.safeParse({ dispositivo: 'compostera-01', desde: '2026-10-01T10:00:00Z' }).success,
      false,
    );
  });
});