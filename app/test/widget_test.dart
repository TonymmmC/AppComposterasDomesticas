import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:compostera/main.dart';

void main() {
  testWidgets('la aplicacion abre en la pantalla de inicio de sesion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AplicacionCompostera());

    expect(find.text('Mi compostera'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
  });
}
