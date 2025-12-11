// Tests básicos para la aplicación MisTickets
//
// Para ejecutar los tests: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:mis_tickets_app/main.dart';

void main() {
  testWidgets('App inicializa correctamente', (WidgetTester tester) async {
    // Verificar que la app se crea sin errores
    await tester.pumpWidget(const AplicacionMisTickets());

    // Verificar que muestra el texto de MisTickets
    expect(find.text('MisTickets'), findsWidgets);
  });
}
