import 'package:flutter/material.dart';

import '../datos/datos_ejemplo.dart';
import '../modelos/estado.dart';
import '../modelos/lectura.dart';
import '../tema.dart';

/// Pantalla principal: estado de la compostera, ultimas mediciones
/// y las acciones que el usuario puede registrar.
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final lectura = DatosEjemplo.lectura;
    const estado = DatosEjemplo.estado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi compostera'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TarjetaEstado(estado: estado),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TarjetaMedicion(
                  icono: Icons.thermostat,
                  titulo: 'Temperatura',
                  valor: lectura.temperaturaTexto,
                  unidad: 'C',
                  rango: 'Fase termófila: 45 a 65',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TarjetaMedicion(
                  icono: Icons.water_drop_outlined,
                  titulo: 'Humedad',
                  valor: lectura.humedadTexto,
                  unidad: '%',
                  rango: 'Rango adecuado: 45 a 60',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _UltimaLectura(lectura: lectura),
          const SizedBox(height: 24),
          const Text(
            'Registrar acción',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _Acciones(),
        ],
      ),
    );
  }
}

class _TarjetaEstado extends StatelessWidget {
  const _TarjetaEstado({required this.estado});

  final Estado estado;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(estado.icono, size: 44, color: estado.color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estado.titulo,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: estado.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    estado.recomendacion,
                    style: const TextStyle(color: Tema.gris, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaMedicion extends StatelessWidget {
  const _TarjetaMedicion({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.unidad,
    required this.rango,
  });

  final IconData icono;
  final String titulo;
  final String valor;
  final String unidad;
  final String rango;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 18, color: Tema.verde),
                const SizedBox(width: 6),
                Text(titulo, style: const TextStyle(color: Tema.gris)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(unidad, style: const TextStyle(color: Tema.gris)),
              ],
            ),
            const SizedBox(height: 6),
            Text(rango, style: const TextStyle(fontSize: 11, color: Tema.gris)),
          ],
        ),
      ),
    );
  }
}

class _UltimaLectura extends StatelessWidget {
  const _UltimaLectura({required this.lectura});

  final Lectura lectura;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.schedule, size: 14, color: Tema.gris),
        const SizedBox(width: 6),
        Text(
          'Última lectura ${lectura.antiguedad}',
          style: const TextStyle(fontSize: 12, color: Tema.gris),
        ),
      ],
    );
  }
}

class _Acciones extends StatelessWidget {
  const _Acciones();

  @override
  Widget build(BuildContext context) {
    const acciones = <String, IconData>{
      'Volteo': Icons.autorenew,
      'Riego': Icons.water_drop,
      'Material seco': Icons.grass,
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: acciones.entries
          .map(
            (accion) => ActionChip(
              avatar: Icon(accion.value, size: 18, color: Tema.verde),
              label: Text(accion.key),
              onPressed: () {},
            ),
          )
          .toList(),
    );
  }
}
