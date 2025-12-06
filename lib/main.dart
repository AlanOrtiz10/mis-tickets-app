import 'package:flutter/material.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

/// Punto de entrada principal de la aplicación MisTickets
void main() {
  runApp(const AplicacionMisTickets());
}

/// Widget raíz de la aplicación MisTickets
class AplicacionMisTickets extends StatelessWidget {
  const AplicacionMisTickets({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MisTickets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PantallaSplash(),
    );
  }
}
