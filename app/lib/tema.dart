import 'package:flutter/material.dart';

/// Paleta y estilos de la aplicacion. Un solo lugar para los colores,
/// para que ninguna pantalla defina tonos sueltos.
class Tema {
  static const Color verde = Color(0xFF2E7D32);
  static const Color verdeSuave = Color(0xFFE8F5E9);
  static const Color ambar = Color(0xFFF9A825);
  static const Color rojo = Color(0xFFC62828);
  static const Color gris = Color(0xFF5F6368);
  static const Color borde = Color(0xFFE0E0E0);

  static ThemeData claro() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: verde),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borde),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
