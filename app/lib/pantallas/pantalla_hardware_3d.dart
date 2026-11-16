import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/lectura.dart';
import '../services/api_service.dart';
import '../tema.dart';

// En Web, podemos usar dart:html para abrir el enlace directamente si aplica
// Para mantener compatibilidad universal móvil y web, usamos navegación estándar o enlaces

class PantallaHardware3D extends StatefulWidget {
  const PantallaHardware3D({super.key});

  @override
  State<PantallaHardware3D> createState() => _PantallaHardware3DState();
}

class _PantallaHardware3DState extends State<PantallaHardware3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Lectura? _lectura;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _cargarLectura();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _cargarLectura());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _cargarLectura() async {
    final lectura = await ApiService.obtenerUltimaLectura();
    if (mounted) {
      setState(() => _lectura = lectura);
    }
  }

  void _abrirGemelo3D() {
    // Mostrar diálogo o instruir al usuario para abrir la simulación Three.js WebGL
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.view_in_ar, color: Tema.verde),
            SizedBox(width: 8),
            Text('Simulador 3D WebGL'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El gemelo digital 3D interactivo con Three.js se encuentra corriendo en el servidor local:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            SelectableText(
              'http://localhost:3000/3d',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0284C7),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '💡 Puedes abrir esa dirección en otra pestaña de tu navegador para interactuar con la cámara orbital en 360°, mover el mouse y ver los sensores en tiempo real.',
              style: TextStyle(fontSize: 12.5, color: Tema.gris),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hardware & Simulación 3D'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Abrir 3D en navegador',
            onPressed: _abrirGemelo3D,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner de acceso a la simulación 3D interactiva WebGL
          Card(
            color: const Color(0xFF0F172A),
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
                          color: Tema.verde.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.view_in_ar, color: Color(0xFF86EFAC), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GEMELO DIGITAL 3D (WEBGL)',
                              style: TextStyle(
                                color: Color(0xFF86EFAC),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'Simulación interactiva Three.js con cámara orbital 360°',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _abrirGemelo3D,
                    style: FilledButton.styleFrom(
                      backgroundColor: Tema.verde,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.travel_explore, size: 18),
                    label: const Text('Ver Simulación 3D en Pantalla Completa'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Esquema visual del hardware simulado en tiempo real
          const Text(
            'Esquema del Nodo IoT en Operación',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                // Representación de la Compostera (Lado izquierdo)
                Positioned(
                  left: 20,
                  top: 30,
                  bottom: 30,
                  width: 130,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF451A03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF8B5A2B), width: 3),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.compost, color: Color(0xFFF59E0B), size: 36),
                        const SizedBox(height: 6),
                        const Text(
                          'Cámara\nCompostera',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${lectura.temperatura.toStringAsFixed(1)} °C',
                            style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sonda clavada en el compost
                Positioned(
                  left: 125,
                  top: 70,
                  child: Container(
                    width: 35,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF0284C7), width: 2),
                    ),
                    child: const Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text('Sonda v1.2', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),

                // Cables que van al microcontrolador
                Positioned(
                  left: 160,
                  top: 110,
                  right: 170,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFFF59E0B)]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Microcontrolador ESP32 (Lado derecho)
                Positioned(
                  right: 20,
                  top: 30,
                  bottom: 30,
                  width: 140,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14532D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                          blurRadius: 12,
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
                              'ESP32',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            // Indicador de Wi-Fi animado
                            AnimatedBuilder(
                              animation: _animController,
                              builder: (_, __) => Icon(
                                Icons.wifi,
                                color: _animController.value > 0.5 ? const Color(0xFF86EFAC) : Colors.white30,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        // Microchip Tensilica
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Center(
                            child: Text(
                              'Tensilica Xtensa\n2.4 GHz Deep-Sleep',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 9.5),
                            ),
                          ),
                        ),
                        // Sensor DHT22 adyacente
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.device_thermostat, size: 14, color: Color(0xFF0284C7)),
                              SizedBox(width: 4),
                              Text('DHT22', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
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
          const SizedBox(height: 24),

          // Desglose de Presupuesto del Kit Piloto (Bs. 350)
          const Text(
            'Ficha Técnica y Presupuesto del Kit Piloto',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Presupuesto máximo asignado: Bs. 350,00 por unidad física.',
            style: TextStyle(fontSize: 13, color: Tema.gris),
          ),
          const SizedBox(height: 12),

          Card(
            child: DataTable(
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text('Componente', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Función', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('ESP32 NodeMCU')),
                  DataCell(Text('MCU + Wi-Fi 2.4GHz')),
                  DataCell(Text('Bs. 85')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Sensor DHT22')),
                  DataCell(Text('Temp/Hum ambiente')),
                  DataCell(Text('Bs. 45')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Sonda Capacitiva v1.2')),
                  DataCell(Text('Humedad sustrato sólido')),
                  DataCell(Text('Bs. 35')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Batería Li-Ion + TP4056')),
                  DataCell(Text('Alimentación autónoma')),
                  DataCell(Text('Bs. 60')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Carcasa IP65 + Pasacables')),
                  DataCell(Text('Sellado intemperie')),
                  DataCell(Text('Bs. 45')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Jumpers y misceláneos')),
                  DataCell(Text('Conexiones y soporte')),
                  DataCell(Text('Bs. 30')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Calibración gravimétrica')),
                  DataCell(Text('Ajuste matriz suelo')),
                  DataCell(Text('Bs. 50')),
                ]),
                DataRow(cells: [
                  DataCell(Text('TOTAL ESTIMADO', style: TextStyle(fontWeight: FontWeight.bold, color: Tema.verde))),
                  DataCell(Text('Kit Piloto Completo', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('Bs. 350,00', style: TextStyle(fontWeight: FontWeight.bold, color: Tema.verde))),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

