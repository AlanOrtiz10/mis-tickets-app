import 'package:flutter/material.dart';

/// Pantalla de bienvenida que se muestra al iniciar la aplicación
/// Muestra el icono de MisTickets y un mensaje de carga
class PantallaSplash extends StatelessWidget {
  const PantallaSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Azul oscuro profesional
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de ticket con animación implícita
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.confirmation_number_rounded,
                size: 100,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 40),
            // Texto de carga
            const Text(
              'Cargando MisTickets...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            // Indicador de progreso
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
