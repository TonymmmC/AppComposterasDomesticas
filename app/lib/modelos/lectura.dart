/// Una medicion enviada por el nodo de sensado.
/// El formato coincide con documentacion/contrato-datos.md.
class Lectura {
  final String dispositivo;
  final double temperatura;
  final double humedad;
  final DateTime momento;

  const Lectura({
    required this.dispositivo,
    required this.temperatura,
    required this.humedad,
    required this.momento,
  });

  factory Lectura.desdeJson(Map<String, Object?> json) {
    return Lectura(
      dispositivo: json['dispositivo']! as String,
      temperatura: (json['temperatura']! as num).toDouble(),
      humedad: (json['humedad']! as num).toDouble(),
      momento: DateTime.parse(json['momento']! as String).toLocal(),
    );
  }

  /// El redondeo es decision de presentacion. El valor guardado no se toca.
  String get temperaturaTexto => temperatura.toStringAsFixed(1);

  String get humedadTexto => humedad.toStringAsFixed(0);

  /// Cuanto paso desde la medicion, en texto corto para la pantalla.
  String get antiguedad {
    final minutos = DateTime.now().difference(momento).inMinutes;
    if (minutos < 1) return 'hace instantes';
    if (minutos < 60) return 'hace $minutos min';
    final horas = minutos ~/ 60;
    if (horas < 24) return 'hace $horas h';
    return 'hace ${horas ~/ 24} d';
  }
}
