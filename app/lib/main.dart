import 'package:flutter/material.dart';
import 'screens/historial_screen.dart';

void main() {
  runApp(const ComposteraApp());
}

class ComposteraApp extends StatelessWidget {
  const ComposteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compostera Doméstica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Verde orgánico / compostaje
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F6),
      ),
      // Rol 2: Visualización de pantalla de historial con fl_chart y mock data.
      // Cuando Rol 1 integre autenticación y barra de navegación,
      // puede enlazar HistorialScreen() en su gestor de rutas / bottom bar.
      home: const HistorialScreen(),
    );
  }
}
