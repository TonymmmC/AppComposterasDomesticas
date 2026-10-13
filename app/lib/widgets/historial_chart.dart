import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lectura.dart';

enum MetricaSeleccionada { todas, temperatura, humedad }

class HistorialChart extends StatelessWidget {
  final List<Lectura> lecturas;
  final MetricaSeleccionada metrica;

  const HistorialChart({
    super.key,
    required this.lecturas,
    this.metrica = MetricaSeleccionada.todas,
  });

  @override
  Widget build(BuildContext context) {
    if (lecturas.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(
          child: Text('No hay lecturas registradas para graficar.'),
        ),
      );
    }

    final tempSpots = <FlSpot>[];
    final humSpots = <FlSpot>[];

    for (int i = 0; i < lecturas.length; i++) {
      final x = i.toDouble();
      tempSpots.add(FlSpot(x, lecturas[i].temperatura));
      humSpots.add(FlSpot(x, lecturas[i].humedad));
    }

    final lineBars = <LineChartBarData>[];

    // Línea de Temperatura (°C) - Naranja/Ámbar
    if (metrica == MetricaSeleccionada.todas ||
        metrica == MetricaSeleccionada.temperatura) {
      lineBars.add(
        LineChartBarData(
          spots: tempSpots,
          isCurved: true,
          color: const Color(0xFFE65100), // Ámbar/Naranja cálido
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 3.5,
              color: Colors.white,
              strokeWidth: 2.5,
              strokeColor: const Color(0xFFE65100),
            ),
          ),
          belowBarData: BarAreaData(
            show: metrica == MetricaSeleccionada.temperatura,
            color: const Color(0xFFE65100).withValues(alpha: 0.15),
          ),
        ),
      );
    }

    // Línea de Humedad (%) - Azul turquesa
    if (metrica == MetricaSeleccionada.todas ||
        metrica == MetricaSeleccionada.humedad) {
      lineBars.add(
        LineChartBarData(
          spots: humSpots,
          isCurved: true,
          color: const Color(0xFF0277BD), // Azul/Cyan profundo
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 3.5,
              color: Colors.white,
              strokeWidth: 2.5,
              strokeColor: const Color(0xFF0277BD),
            ),
          ),
          belowBarData: BarAreaData(
            show: metrica == MetricaSeleccionada.humedad,
            color: const Color(0xFF0277BD).withValues(alpha: 0.15),
          ),
        ),
      );
    }

    // Cálculo dinámico de escala Y
    double minY = 10;
    double maxY = 80;
    if (metrica == MetricaSeleccionada.temperatura) {
      final temps = lecturas.map((l) => l.temperatura);
      minY = (temps.reduce((a, b) => a < b ? a : b) - 5).clamp(0, 100);
      maxY = (temps.reduce((a, b) => a > b ? a : b) + 5).clamp(0, 100);
    } else if (metrica == MetricaSeleccionada.humedad) {
      final hums = lecturas.map((l) => l.humedad);
      minY = (hums.reduce((a, b) => a < b ? a : b) - 5).clamp(0, 100);
      maxY = (hums.reduce((a, b) => a > b ? a : b) + 5).clamp(0, 100);
    }

    return AspectRatio(
      aspectRatio: 1.6,
      child: Padding(
        padding: const EdgeInsets.only(right: 18, left: 6, top: 18, bottom: 8),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (lecturas.length - 1).toDouble(),
            minY: minY.floorToDouble(),
            maxY: maxY.ceilToDouble(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 15,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: (lecturas.length / 4).ceilToDouble().clamp(1, 10),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= lecturas.length) {
                      return const SizedBox.shrink();
                    }
                    final fechaLocal = lecturas[index].momentoLocal;
                    final formatoHora = DateFormat('HH:mm');
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        formatoHora.format(fechaLocal),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 15,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => Colors.blueGrey.shade900,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.x.toInt();
                    if (index < 0 || index >= lecturas.length) return null;
                    final lectura = lecturas[index];
                    final hora = DateFormat('HH:mm - dd/MM')
                        .format(lectura.momentoLocal);

                    final esTemp = spot.bar.color == const Color(0xFFE65100);
                    final etiqueta = esTemp
                        ? 'Temp: ${spot.y.toStringAsFixed(1)} °C'
                        : 'Hum: ${spot.y.toStringAsFixed(1)} %';
                    final colorTexto = esTemp
                        ? const Color(0xFFFFB74D)
                        : const Color(0xFF4FC3F7);

                    return LineTooltipItem(
                      '$etiqueta\n($hora)',
                      TextStyle(
                        color: colorTexto,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: lineBars,
          ),
        ),
      ),
    );
  }
}
