import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../tema.dart';

class PantallaAcciones extends StatefulWidget {
  const PantallaAcciones({super.key});

  @override
  State<PantallaAcciones> createState() => _PantallaAccionesState();
}

class _PantallaAccionesState extends State<PantallaAcciones> {
  bool _cargando = false;
  List<Map<String, dynamic>> _acciones = [];

  @override
  void initState() {
    super.initState();
    _cargarAcciones();
  }

  Future<void> _cargarAcciones() async {
    setState(() => _cargando = true);
    final acciones = await ApiService.obtenerAcciones();
    if (mounted) {
      setState(() {
        _acciones = acciones;
        _cargando = false;
      });
    }
  }

  Future<void> _registrar(String tipo, String nombre) async {
    final exito = await ApiService.registrarAccion(
      dispositivo: 'compostera-01',
      tipo: tipo,
    );

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✔ Acción "$nombre" registrada exitosamente'),
          backgroundColor: Tema.verde,
          duration: const Duration(seconds: 2),
        ),
      );
      _cargarAcciones();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No se pudo registrar la acción'),
          backgroundColor: Tema.rojo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora de Acciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarAcciones,
            tooltip: 'Actualizar bitácora',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarAcciones,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Registrar intervención manual',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mantén un registro de cada labor de mantenimiento para correlacionar con los cambios de temperatura y humedad.',
              style: TextStyle(fontSize: 13, color: Tema.gris),
            ),
            const SizedBox(height: 16),

            // Tarjetas de intervención
            _TarjetaAccionBoton(
              icono: Icons.autorenew,
              colorIcono: Tema.verde,
              titulo: 'Volteo de la mezcla',
              descripcion: 'Oxigena las bacterias aerobias y homogeniza la temperatura de la pila.',
              etiquetaBoton: 'Registrar volteo',
              onPressed: () => _registrar('volteo', 'Volteo de la mezcla'),
            ),
            const SizedBox(height: 12),

            _TarjetaAccionBoton(
              icono: Icons.water_drop,
              colorIcono: const Color(0xFF0284C7),
              titulo: 'Riego controlado',
              descripcion: 'Humedece el sustrato cuando la humedad desciende por debajo del 45%.',
              etiquetaBoton: 'Registrar riego',
              onPressed: () => _registrar('riego', 'Riego controlado'),
            ),
            const SizedBox(height: 12),

            _TarjetaAccionBoton(
              icono: Icons.grass,
              colorIcono: const Color(0xFFD97706),
              titulo: 'Agregar material seco (Marrón)',
              descripcion: 'Aporta carbono y absorbe el exceso de agua (hojas secas, cartón, paja).',
              etiquetaBoton: 'Registrar material seco',
              onPressed: () => _registrar('material_seco', 'Material seco'),
            ),
            const SizedBox(height: 12),

            _TarjetaAccionBoton(
              icono: Icons.eco,
              colorIcono: const Color(0xFF16A34A),
              titulo: 'Agregar material verde (Nitrógeno)',
              descripcion: 'Restos vegetales frescos de cocina o césped recién cortado.',
              etiquetaBoton: 'Registrar material verde',
              onPressed: () => _registrar('material_verde', 'Material verde'),
            ),

            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historial de intervenciones',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_cargando)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_acciones.isEmpty && !_cargando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No hay acciones registradas aún.',
                    style: TextStyle(color: Tema.gris),
                  ),
                ),
              )
            else
              ..._acciones.map((acc) {
                final tipo = acc['tipo'] as String? ?? 'accion';
                final momentoStr = acc['momento'] as String?;
                DateTime momento = DateTime.now();
                if (momentoStr != null) {
                  momento = DateTime.tryParse(momentoStr)?.toLocal() ?? DateTime.now();
                }

                final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(momento);
                
                IconData icono = Icons.check_circle_outline;
                Color colorIcono = Tema.verde;
                String nombreTipo = 'Acción registrada';

                switch (tipo) {
                  case 'volteo':
                    icono = Icons.autorenew;
                    colorIcono = Tema.verde;
                    nombreTipo = 'Volteo de la mezcla';
                    break;
                  case 'riego':
                    icono = Icons.water_drop;
                    colorIcono = const Color(0xFF0284C7);
                    nombreTipo = 'Riego controlado';
                    break;
                  case 'material_seco':
                    icono = Icons.grass;
                    colorIcono = const Color(0xFFD97706);
                    nombreTipo = 'Material seco agregado';
                    break;
                  case 'material_verde':
                    icono = Icons.eco;
                    colorIcono = const Color(0xFF16A34A);
                    nombreTipo = 'Material verde agregado';
                    break;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorIcono.withValues(alpha: 0.15),
                      child: Icon(icono, color: colorIcono, size: 22),
                    ),
                    title: Text(nombreTipo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(fechaFormateada, style: const TextStyle(fontSize: 12, color: Tema.gris)),
                    trailing: const Icon(Icons.check, size: 18, color: Tema.verde),
                  ),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAccionBoton extends StatelessWidget {
  const _TarjetaAccionBoton({
    required this.icono,
    required this.colorIcono,
    required this.titulo,
    required this.descripcion,
    required this.etiquetaBoton,
    required this.onPressed,
  });

  final IconData icono;
  final Color colorIcono;
  final String titulo;
  final String descripcion;
  final String etiquetaBoton;
  final VoidCallback onPressed;

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorIcono.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: colorIcono, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: const TextStyle(fontSize: 12.5, color: Tema.gris, height: 1.3),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 16),
                    const SizedBox(width: 4),
                    Text(etiquetaBoton),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

