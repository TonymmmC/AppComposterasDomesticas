import 'package:flutter/material.dart';

import '../tema.dart';
import 'navegacion.dart';

/// Inicio de sesion. Todavia no valida contra Firebase: solo comprueba
/// que los campos esten completos y entra a la aplicacion.
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _entrar() {
    if (!_formulario.currentState!.validate()) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const Navegacion()),
    );
  }

  String? _obligatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formulario,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.compost, size: 72, color: Tema.verde),
                  const SizedBox(height: 16),
                  const Text(
                    'Mi compostera',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Monitorea tu compost desde el celular',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Tema.gris),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _correo,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: _obligatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasena,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: _obligatorio,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _entrar,
                    child: const Text('Iniciar sesión'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Crear una cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
