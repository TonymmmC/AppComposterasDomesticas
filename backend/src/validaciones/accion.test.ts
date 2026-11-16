import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { esquemaAccion, esquemaFiltroAcciones } from './accion';

describe('esquemaAccion', () => {
  const valida = {
    dispositivo: 'compostera-01',
    tipo: 'volteo' as const,
    momento: '2026-10-12T16:00:00.000Z',
  };

  it('acepta una accion valida', () => {
    const res = esquemaAccion.safeParse(valida);
    assert.equal(res.success, true);
  });

  it('acepta todos los tipos permitidos', () => {
    for (const tipo of ['volteo', 'riego', 'material_seco', 'material_verde'] as const) {
      const res = esquemaAccion.safeParse({ ...valida, tipo });
      assert.equal(res.success, true);
    }
  });

  it('rechaza un tipo desconocido', () => {
    const res = esquemaAccion.safeParse({ ...valida, tipo: 'otro' });
    assert.equal(res.success, false);
  });

  it('rechaza un momento sin formato ISO', () => {
    const res = esquemaAccion.safeParse({ ...valida, momento: 'ayer' });
    assert.equal(res.success, false);
  });
});

describe('esquemaFiltroAcciones', () => {
  it('exige el dispositivo', () => {
    assert.equal(esquemaFiltroAcciones.safeParse({}).success, false);
    assert.equal(esquemaFiltroAcciones.safeParse({ dispositivo: 'c-01' }).success, true);
  });
});

