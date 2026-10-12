import 'package:flutter_test/flutter_test.dart';
import 'package:compostera/main.dart';

void main() {
  testWidgets('Smoke test de la pantalla de Historial', (WidgetTester tester) async {
    // Construir la app y renderizar el primer frame.
    await tester.pumpWidget(const ComposteraApp());
    await tester.pumpAndSettle();

    // Verificar que el título de la pantalla de historial se muestra correctamente
    expect(find.text('Historial de Compostera'), findsOneWidget);
    expect(find.text('Comportamiento'), findsOneWidget);
  });
}
