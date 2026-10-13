import '../modelos/estado.dart';
import '../modelos/lectura.dart';

/// Datos falsos para ver las pantallas mientras el backend no existe.
/// Se reemplazan por las respuestas de la API cuando este lista.
class DatosEjemplo {
  static Lectura get lectura => Lectura(
    dispositivo: 'compostera-01',
    temperatura: 38.4,
    humedad: 41.0,
    momento: DateTime.now().subtract(const Duration(minutes: 12)),
  );

  static const Estado estado = Estado(
    codigo: 'humedad_baja',
    titulo: 'Humedad baja',
    recomendacion: 'Regar la mezcla hasta humedecerla, sin encharcar.',
    severidad: Severidad.advertencia,
  );
}
