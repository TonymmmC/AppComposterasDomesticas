import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { evaluarLectura, evaluarSinDatos } from './estados';

describe('evaluarLectura', () => {
  it('clasifica como optimo dentro de los rangos', () => {
    assert.equal(evaluarLectura(20, 40).estado, 'optimo');
    assert.equal(evaluarLectura(65, 60).estado, 'optimo');
    assert.equal(evaluarLectura(42.5, 55).estado, 'optimo');
  });

  it('clasifica humedad_baja por debajo de 40', () => {
    const r = evaluarLectura(42.5, 39.9);
    assert.equal(r.estado, 'humedad_baja');
    assert.equal(r.severidad, 'advertencia');
  });

  it('clasifica humedad_alta por encima de 60', () => {
    const r = evaluarLectura(42.5, 60.1);
    assert.equal(r.estado, 'humedad_alta');
    assert.equal(r.severidad, 'advertencia');
  });

  it('clasifica temperatura_baja por debajo de 20', () => {
    const r = evaluarLectura(19.9, 55);
    assert.equal(r.estado, 'temperatura_baja');
    assert.equal(r.severidad, 'advertencia');
  });

  it('clasifica temperatura_alta por encima de 65 como critico', () => {
    const r = evaluarLectura(65.1, 55);
    assert.equal(r.estado, 'temperatura_alta');
    assert.equal(r.severidad, 'critico');
  });

  it('da precedencia a la humedad sobre la temperatura', () => {
    // Temperatura alta pero humedad baja: gana humedad_baja.
    assert.equal(evaluarLectura(70, 30).estado, 'humedad_baja');
    assert.equal(evaluarLectura(70, 80).estado, 'humedad_alta');
  });

  it('siempre incluye una recomendacion', () => {
    for (const temp of [19.9, 20, 65, 65.1, 70]) {
      for (const humedad of [30, 40, 60, 61, 80]) {
        const r = evaluarLectura(temp, humedad);
        assert.ok(r.recomendacion.length > 0, `sin recomendacion para ${temp}/${humedad}`);
      }
    }
  });
});

describe('evaluarSinDatos', () => {
  const ahora = new Date('2026-10-12T12:00:00Z');

  it('es null con menos de 6 horas', () => {
    const reciente = new Date('2026-10-12T08:00:00Z');
    assert.equal(evaluarSinDatos(reciente, ahora), null);
  });

  it('es sin_datos al superar las 6 horas', () => {
    const viejo = new Date('2026-10-12T05:00:00Z');
    const r = evaluarSinDatos(viejo, ahora);
    assert.equal(r?.estado, 'sin_datos');
    assert.equal(r?.severidad, 'advertencia');
  });
});