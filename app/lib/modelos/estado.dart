import 'package:flutter/material.dart';

import '../tema.dart';

/// Gravedad del estado. La decide el backend, la app solo la pinta.
enum Severidad { ok, advertencia, critico }

/// Estado de la compostera con su recomendacion.
/// Los codigos son los de documentacion/contrato-datos.md.
class Estado {
  final String codigo;
  final String titulo;
  final String recomendacion;
  final Severidad severidad;

  const Estado({
    required this.codigo,
    required this.titulo,
    required this.recomendacion,
    required this.severidad,
  });

  Color get color {
    switch (severidad) {
      case Severidad.ok:
        return Tema.verde;
      case Severidad.advertencia:
        return Tema.ambar;
      case Severidad.critico:
        return Tema.rojo;
    }
  }

  IconData get icono {
    switch (severidad) {
      case Severidad.ok:
        return Icons.check_circle_outline;
      case Severidad.advertencia:
        return Icons.warning_amber_outlined;
      case Severidad.critico:
        return Icons.error_outline;
    }
  }
}
