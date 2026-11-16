import 'dart:async';
import 'package:flutter/material.dart';

import '../modelos/estado.dart';
import '../models/lectura.dart';
import '../services/api_service.dart';
import '../tema.dart';
import '../utils/url_helper.dart';

/// Pantalla principal: Dashboard integrado con telemetría en tiempo real,
/// simulación del hardware IoT (ESP32) y bitácora de intervenciones.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
    with SingleTickerProviderStateMixin {
  bool _cargando = false;
  Lectura? _lectura;
  Timer? _timerPeriodico;
  late AnimationController _animWifi;

  @override
  void initState() {
    super.initState();
    _animWifi = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _cargarDatos();
    // Actualizar datos automáticamente cada 10 segundos (sincronizado con el hardware)
    _timerPeriodico = Timer.periodic(const Duration(seconds: 10), (_) => _cargarDatosSilencioso());
  }

  @override
  void dispose() {
    _timerPeriodico?.cancel();
    _animWifi.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final lectura = await ApiService.obtenerUltimaLectura();
    if (mounted) {
      setState(() {
        _lectura = lectura;
        _cargando = false;
      });
    }
  }

  Future<void> _cargarDatosSilencioso() async {
    final lectura = await ApiService.obtenerUltimaLectura();
    if (mounted) {
      setState(() => _lectura = lectura);
    }
  }

  Estado _evaluarEstado(Lectura lectura) {
    if (lectura.humedad < 45.0) {
      return const Estado(
        codigo: 'humedad_baja',
        titulo: 'Humedad baja',
        recomendacion: 'Regar la mezcla hasta humedecerla sin encharcar.',
        severidad: Severidad.advertencia,
      );
    }
    if (lectura.humedad > 60.0) {
      return const Estado(
        codigo: 'humedad_alta',
        titulo: 'Humedad alta',
        recomendacion: 'Agregar material seco y voltear para airear la mezcla.',
        severidad: Severidad.advertencia,
      );
    }
    if (lectura.temperatura < 20.0) {
      return const Estado(
        codigo: 'temperatura_baja',
        titulo: 'Temperatura baja',
        recomendacion: 'Acercar la compostera al sol y sumar material verde.',
        severidad: Severidad.advertencia,
      );
    }
    if (lectura.temperatura > 65.0) {
      return const Estado(
        codigo: 'temperatura_alta',
        titulo: 'Temperatura crítica',
        recomendacion: 'Voltear la mezcla y agregar material seco para bajar la temperatura.',
        severidad: Severidad.critico,
      );
    }

    return const Estado(
      codigo: 'optimo',
      titulo: 'Estado óptimo',
      recomendacion: 'Mantener el compost en las condiciones actuales.',
      severidad: Severidad.ok,
    );
  }

  Future<void> _ejecutarAccion(String tipo, String nombre) async {
    final exito = await ApiService.registrarAccion(
      dispositivo: 'compostera-01',
      tipo: tipo,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exito
            ? '✔ Acción "$nombre" registrada exitosamente'
            : '⚠ Acción guardada localmente'),
        backgroundColor: exito ? Tema.verde : Tema.ambar,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _abrirSimulador3D() {
    abrirUrl('http://localhost:3000/3d');
  }

  @override
  Widget build(BuildContext context) {
    final lectura = _lectura ??
        Lectura(
          dispositivo: 'compostera-01',
          temperatura: 48.5,
          humedad: 52.0,
          momento: DateTime.now().toUtc(),
        );

    final estado = _evaluarEstado(lectura);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi compostera'),
        actions: [
          IconButton(
            onPressed: _abrirSimulador3D,
            icon: const Icon(Icons.view_in_ar),
            tooltip: 'Ver Simulación 3D en pantalla completa',
          ),
          IconButton(
            onPressed: _cargarDatos,
            icon: _cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refrescar mediciones',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Tarjeta de Estado y Recomendación Agronómica
            _TarjetaEstado(estado: estado),
            const SizedBox(height: 16),

            // 2. Medidores de Temperatura y Humedad
            Row(
              children: [
                Expanded(
                  child: _TarjetaMedicion(
                    icono: Icons.thermostat,
                    titulo: 'Temperatura',
                    valor: lectura.temperaturaTexto,
                    unidad: '°C',
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
            const SizedBox(height: 16),

            // 3. SECCIÓN DESTACADA: GEMELO DIGITAL Y SIMULACIÓN 3D DEL HARDWARE
            _TarjetaHardware3DIntegrada(
              lectura: lectura,
              animWifi: _animWifi,
              onAbrir3D: _abrirSimulador3D,
            ),
            const SizedBox(height: 16),

            // 4. Última lectura registrada
            _UltimaLectura(lectura: lectura),
            const SizedBox(height: 24),

            // 5. Registro rápido de acciones de mantenimiento
            const Text(
              'Registrar intervención rápida',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Toca una acción para registrar el mantenimiento en la bitácora:',
              style: TextStyle(fontSize: 12.5, color: Tema.gris),
            ),
            const SizedBox(height: 12),
            _Acciones(onAccion: _ejecutarAccion),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENTE: GEMELO DIGITAL DEL HARDWARE INTEGRADO EN EL DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
class _TarjetaHardware3DIntegrada extends StatelessWidget {
  const _TarjetaHardware3DIntegrada({
    required this.lectura,
    required this.animWifi,
    required this.onAbrir3D,
  });

  final Lectura lectura;
  final AnimationController animWifi;
  final VoidCallback onAbrir3D;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF090D16), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera del Hardware
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Tema.verde.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.memory, color: Color(0xFF86EFAC), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'HARDWARE IoT (ESP32)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Emisión cada 10s',
                        style: TextStyle(color: Color(0xFF86EFAC), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Esquema visual esquemático del nodo (Compostera + Sonda + ESP32 + DHT22)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF0B1120),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compostera con mezcla termófila (Izquierda)
                  Positioned(
                    left: 18,
                    top: 24,
                    bottom: 24,
                    width: 110,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF451A03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF854D0E), width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.compost, color: Color(0xFFF59E0B), size: 30),
                          const SizedBox(height: 4),
                          const Text(
                            'Compostera',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${lectura.temperatura.toStringAsFixed(1)} °C',
                              style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sonda de humedad de sustrato clavada
                  Positioned(
                    left: 110,
                    top: 50,
                    child: Container(
                      width: 28,
                      height: 75,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFF0284C7), width: 2),
                      ),
                      child: const Center(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text('Sonda v1.2', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),

                  // Cableado flexible intermedio
                  Positioned(
                    left: 140,
                    right: 145,
                    top: 90,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFFF59E0B)]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Microcontrolador ESP32 (Derecha)
                  Positioned(
                    right: 18,
                    top: 24,
                    bottom: 24,
                    width: 125,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14532D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'ESP32 Node',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              AnimatedBuilder(
                                animation: animWifi,
                                builder: (_, __) => Icon(
                                  Icons.wifi,
                                  color: animWifi.value > 0.5 ? const Color(0xFF86EFAC) : Colors.white24,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Text(
                              'Xtensa 2.4GHz\nDeep-Sleep',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 8.5),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.device_thermostat, size: 11, color: Color(0xFF0284C7)),
                                SizedBox(width: 3),
                                Text('DHT22', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 9.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón destacado para abrir la simulación 3D en pantalla completa
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
            child: FilledButton.icon(
              onPressed: onAbrir3D,
              style: FilledButton.styleFrom(
                backgroundColor: Tema.verde,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.view_in_ar, size: 20),
              label: const Text(
                'Abrir Simulación 3D Interactiva (Three.js WebGL)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENTES AUXILIARES
// ─────────────────────────────────────────────────────────────────────────────
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
  const _Acciones({required this.onAccion});

  final void Function(String tipo, String nombre) onAccion;

  @override
  Widget build(BuildContext context) {
    final acciones = <Map<String, dynamic>>[
      {'tipo': 'volteo', 'nombre': 'Volteo', 'icono': Icons.autorenew},
      {'tipo': 'riego', 'nombre': 'Riego', 'icono': Icons.water_drop},
      {'tipo': 'material_seco', 'nombre': 'Material seco', 'icono': Icons.grass},
      {'tipo': 'material_verde', 'nombre': 'Material verde', 'icono': Icons.eco},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: acciones
          .map(
            (accion) => ActionChip(
              avatar: Icon(accion['icono'] as IconData, size: 18, color: Tema.verde),
              label: Text(accion['nombre'] as String),
              onPressed: () => onAccion(
                accion['tipo'] as String,
                accion['nombre'] as String,
              ),
            ),
          )
          .toList(),
    );
  }
}
