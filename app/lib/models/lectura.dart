class Lectura {
  final String dispositivo;
  final double temperatura;
  final double humedad;
  final DateTime momento; // Almacenado en UTC según el contrato

  const Lectura({
    required this.dispositivo,
    required this.temperatura,
    required this.humedad,
    required this.momento,
  });

  /// Crea una lectura a partir del JSON especificado en contrato-datos.md
  factory Lectura.fromJson(Map<String, dynamic> json) {
    return Lectura(
      dispositivo: json['dispositivo'] as String? ?? 'compostera-01',
      temperatura: (json['temperatura'] as num).toDouble(),
      humedad: (json['humedad'] as num).toDouble(),
      momento: DateTime.parse(json['momento'] as String),
    );
  }

  /// Serializa la lectura respetando el contrato
  Map<String, dynamic> toJson() {
    return {
      'dispositivo': dispositivo,
      'temperatura': temperatura,
      'humedad': humedad,
      'momento': momento.toUtc().toIso8601String(),
    };
  }

  /// Convierte la fecha UTC a hora local (por defecto del dispositivo / La Paz UTC-4)
  DateTime get momentoLocal => momento.toLocal();

  /// Estado estimado según los rangos del contrato para renderizado visual
  String get estado {
    if (humedad < 40.0) return 'humedad_baja';
    if (humedad > 60.0) return 'humedad_alta';
    if (temperatura < 20.0) return 'temperatura_baja';
    if (temperatura > 65.0) return 'temperatura_alta';
    return 'optimo';
  }

  /// Severidad visual: 'ok', 'advertencia', 'critico'
  String get severidad {
    if (temperatura > 65.0) return 'critico';
    if (humedad < 40.0 || humedad > 60.0 || temperatura < 20.0) {
      return 'advertencia';
    }
    return 'ok';
  }

  /// Etiqueta legible para mostrar en la interfaz
  String get estadoLegible {
    switch (estado) {
      case 'optimo':
        return 'Óptimo';
      case 'humedad_baja':
        return 'Humedad Baja';
      case 'humedad_alta':
        return 'Humedad Alta';
      case 'temperatura_baja':
        return 'Temp. Baja';
      case 'temperatura_alta':
        return 'Temp. Crítica';
      default:
        return 'Desconocido';
    }
  }
}
