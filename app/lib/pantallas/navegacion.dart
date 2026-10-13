import 'package:flutter/material.dart';

import '../tema.dart';
import '../screens/historial_screen.dart';
import 'pantalla_inicio.dart';

/// Barra inferior con las tres secciones de la aplicacion.
/// Historial y Acciones los construye el rol 2, en feature/app-historial.
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
    _EnConstruccion(titulo: 'Acciones'),
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
        ],
      ),
    );
  }
}

class _EnConstruccion extends StatelessWidget {
  const _EnConstruccion({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: const Center(
        child: Text('En construcción', style: TextStyle(color: Tema.gris)),
      ),
    );
  }
}
