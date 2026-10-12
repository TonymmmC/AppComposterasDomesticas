import '../models/lectura.dart';

/// Datos simulados (mock) que cumplen rigurosamente el formato JSON de contrato-datos.md
final List<Map<String, dynamic>> mockLecturasJson = [
  {
    'dispositivo': 'compostera-01',
    'temperatura': 42.5,
    'humedad': 55.0,
    'momento': '2026-10-12T16:00:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 43.1,
    'humedad': 54.2,
    'momento': '2026-10-12T14:30:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 44.0,
    'humedad': 52.8,
    'momento': '2026-10-12T13:00:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 45.3,
    'humedad': 51.5,
    'momento': '2026-10-12T11:30:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 46.0,
    'humedad': 50.0,
    'momento': '2026-10-12T10:00:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 44.8,
    'humedad': 48.2,
    'momento': '2026-10-12T08:30:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 43.2,
    'humedad': 47.0,
    'momento': '2026-10-12T07:00:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 41.0,
    'humedad': 45.5,
    'momento': '2026-10-12T05:30:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 39.5,
    'humedad': 43.0,
    'momento': '2026-10-12T04:00:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 38.2,
    'humedad': 38.5, // Advertencia: humedad baja (< 40%)
    'momento': '2026-10-12T02:30:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 36.4,
    'humedad': 37.0, // Advertencia: humedad baja
    'momento': '2026-10-12T01:00:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 35.0,
    'humedad': 35.5,
    'momento': '2026-10-11T23:30:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 33.5,
    'humedad': 58.0, // Previo a riego/aireación
    'momento': '2026-10-11T18:00:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 31.0,
    'humedad': 62.5, // Advertencia: humedad alta (> 60%)
    'momento': '2026-10-11T12:00:00Z',
  },
  {
    'dispositivo': 'compostera-01',
    'temperatura': 28.5,
    'humedad': 63.0,
    'momento': '2026-10-11T06:00:00Z',
  },
];

/// Lista instanciada de objetos Lectura ordenadas de más antigua a más reciente para el gráfico
List<Lectura> getLecturasMock() {
  return mockLecturasJson
      .map((json) => Lectura.fromJson(json))
      .toList()
    ..sort((a, b) => a.momento.compareTo(b.momento));
}
