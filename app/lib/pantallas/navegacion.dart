import 'package:flutter/material.dart';

import '../screens/historial_screen.dart';
import 'pantalla_acciones.dart';
import 'pantalla_hardware_3d.dart';
import 'pantalla_inicio.dart';

/// Barra inferior con las cuatro secciones de la aplicación:
/// 1. Inicio (Telemetría en tiempo real y estado)
/// 2. Historial (Gráficos interactivos de temperatura y humedad)
/// 3. Acciones (Bitácora de intervenciones del usuario)
/// 4. Hardware 3D (Simulación y gemelo digital del nodo IoT ESP32)
class Navegacion extends StatefulWidget {
  const Navegacion({super.key});

  @override
  State<Navegacion> createState() => _NavegacionState();
}

class _NavegacionState extends State<Navegacion> {
  int _seleccionada = 0;

  static const _pantallas = <Widget>[
    PantallaInicio(),
    HistorialScreen(),
    PantallaAcciones(),
    PantallaHardware3D(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_seleccionada],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seleccionada,
        onDestinationSelected: (indice) =>
            setState(() => _seleccionada = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Acciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_in_ar_outlined),
            selectedIcon: Icon(Icons.view_in_ar),
            label: 'Hardware 3D',
          ),
        ],
      ),
    );
  }
}
