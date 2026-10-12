import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_lecturas.dart';
import '../models/lectura.dart';
import '../widgets/historial_chart.dart';

enum FiltroPeriodo { ultimas24h, ultimos3dias, todos }

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  // Lista de lecturas cargadas (Mock según contrato de datos)
  late List<Lectura> _todasLasLecturas;
  FiltroPeriodo _filtroPeriodo = FiltroPeriodo.todos;
  MetricaSeleccionada _metricaSeleccionada = MetricaSeleccionada.todas;

  @override
  void initState() {
    super.initState();
    _todasLasLecturas = getLecturasMock();
  }

  List<Lectura> get _lecturasFiltradas {
    if (_todasLasLecturas.isEmpty) return [];
    final ultimaFecha = _todasLasLecturas.last.momento;

    switch (_filtroPeriodo) {
      case FiltroPeriodo.ultimas24h:
        final limite = ultimaFecha.subtract(const Duration(hours: 24));
        return _todasLasLecturas
            .where((l) => l.momento.isAfter(limite))
            .toList();
      case FiltroPeriodo.ultimos3dias:
        final limite = ultimaFecha.subtract(const Duration(days: 3));
        return _todasLasLecturas
            .where((l) => l.momento.isAfter(limite))
            .toList();
      case FiltroPeriodo.todos:
        return _todasLasLecturas;
    }
  }

  Lectura? get _ultimaLectura =>
      _todasLasLecturas.isNotEmpty ? _todasLasLecturas.last : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lecturasParaGrafico = _lecturasFiltradas;
    // Para la lista de historial, mostramos de la más reciente a la más antigua
    final lecturasParaLista = lecturasParaGrafico.reversed.toList();
    final ultima = _ultimaLectura;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Compostera',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
            Text(
              'Dispositivo: ${ultima?.dispositivo ?? "compostera-01"}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: 'Refrescar datos (Simulado)',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _todasLasLecturas = getLecturasMock();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lecturas actualizadas (Mock)'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selector de periodo (Filtros rápidos)
            _buildSelectorPeriodo(),
            const SizedBox(height: 14),

            // 2. Tarjetas de última medición (KPIs)
            if (ultima != null) _buildResumenMetricas(ultima),
            const SizedBox(height: 16),

            // 3. Card del Gráfico con fl_chart
            _buildCardGrafico(lecturasParaGrafico),
            const SizedBox(height: 20),

            // 4. Lista de lecturas individuales
            _buildSeccionListaLecturas(lecturasParaLista),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorPeriodo() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChipFiltro('Todas las lecturas', FiltroPeriodo.todos),
          const SizedBox(width: 8),
          _buildChipFiltro('Últimas 24 horas', FiltroPeriodo.ultimas24h),
          const SizedBox(width: 8),
          _buildChipFiltro('Últimos 3 días', FiltroPeriodo.ultimos3dias),
        ],
      ),
    );
  }

  Widget _buildChipFiltro(String label, FiltroPeriodo periodo) {
    final seleccionado = _filtroPeriodo == periodo;
    return ChoiceChip(
      label: Text(label),
      selected: seleccionado,
      selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: seleccionado ? const Color(0xFF1B5E20) : Colors.black87,
        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        fontSize: 12.5,
      ),
      side: BorderSide(
        color: seleccionado ? const Color(0xFF2E7D32) : Colors.grey.shade300,
      ),
      onSelected: (_) {
        setState(() {
          _filtroPeriodo = periodo;
        });
      },
    );
  }

  Widget _buildResumenMetricas(Lectura ultima) {
    return Row(
      children: [
        // Tarjeta Temperatura
        Expanded(
          child: _buildMetricCard(
            titulo: 'Temperatura',
            valor: '${ultima.temperatura.toStringAsFixed(1)} °C',
            icono: Icons.thermostat_rounded,
            colorIcono: const Color(0xFFE65100),
            fondoIcono: const Color(0xFFFFF3E0),
            subtitulo: 'Rango: 20 a 65 °C',
          ),
        ),
        const SizedBox(width: 12),
        // Tarjeta Humedad
        Expanded(
          child: _buildMetricCard(
            titulo: 'Humedad',
            valor: '${ultima.humedad.toStringAsFixed(1)} %',
            icono: Icons.water_drop_rounded,
            colorIcono: const Color(0xFF0277BD),
            fondoIcono: const Color(0xFFE1F5FE),
            subtitulo: 'Rango: 40 a 60 %',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color colorIcono,
    required Color fondoIcono,
    required String subtitulo,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: fondoIcono,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: colorIcono, size: 20),
              ),
              const Spacer(),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            style: TextStyle(
              fontSize: 10.5,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrafico(List<Lectura> lecturas) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la tarjeta y selector de métrica
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Comportamiento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // Segmented selector para Temperatura / Humedad / Ambas
              SegmentedButton<MetricaSeleccionada>(
                segments: const [
                  ButtonSegment(
                    value: MetricaSeleccionada.todas,
                    label: Text('Ambas', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: MetricaSeleccionada.temperatura,
                    label: Text('Temp', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: MetricaSeleccionada.humedad,
                    label: Text('Hum', style: TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {_metricaSeleccionada},
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onSelectionChanged: (nuevaSeleccion) {
                  setState(() {
                    _metricaSeleccionada = nuevaSeleccion.first;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Leyenda de colores
          Row(
            children: [
              if (_metricaSeleccionada == MetricaSeleccionada.todas ||
                  _metricaSeleccionada == MetricaSeleccionada.temperatura) ...[
                _buildIndicadorLeyenda(
                  color: const Color(0xFFE65100),
                  texto: 'Temperatura (°C)',
                ),
                const SizedBox(width: 16),
              ],
              if (_metricaSeleccionada == MetricaSeleccionada.todas ||
                  _metricaSeleccionada == MetricaSeleccionada.humedad) ...[
                _buildIndicadorLeyenda(
                  color: const Color(0xFF0277BD),
                  texto: 'Humedad (%)',
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Gráfico interactivo
          HistorialChart(
            lecturas: lecturas,
            metrica: _metricaSeleccionada,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicadorLeyenda({required Color color, required String texto}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionListaLecturas(List<Lectura> lecturas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lecturas Registradas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${lecturas.length} mediciones',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lecturas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = lecturas[index];
            final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
            final fechaStr = formatoFecha.format(item.momentoLocal);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Icono indicador de severidad
                  _buildBadgeSeveridad(item.severidad),
                  const SizedBox(width: 12),
                  // Fecha y hora local
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fechaStr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Estado: ${item.estadoLegible}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Valores numéricos
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.temperatura.toStringAsFixed(1)} °C',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      Text(
                        '${item.humedad.toStringAsFixed(1)} %',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0277BD),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBadgeSeveridad(String severidad) {
    Color bg;
    Color fg;
    IconData icon;

    switch (severidad) {
      case 'critico':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        icon = Icons.error_outline;
        break;
      case 'advertencia':
        bg = Colors.amber.shade100;
        fg = Colors.orange.shade900;
        icon = Icons.warning_amber_rounded;
        break;
      case 'ok':
      default:
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: fg, size: 18),
    );
  }
}
