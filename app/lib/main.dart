import 'package:flutter/material.dart';

import 'pantallas/pantalla_login.dart';
import 'tema.dart';

void main() {
  runApp(const AplicacionCompostera());
}

class AplicacionCompostera extends StatelessWidget {
  const AplicacionCompostera({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi compostera',
      debugShowCheckedModeBanner: false,
      theme: Tema.claro(),
      home: const PantallaLogin(),
    );
  }
}
