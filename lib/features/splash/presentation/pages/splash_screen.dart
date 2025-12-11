import 'package:flutter/material.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../home/presentation/pages/home_screen.dart';

/// Pantalla de bienvenida que se muestra al iniciar la aplicación
///
/// Funcionalidades:
/// - Muestra el icono de MisTickets y un mensaje de carga
/// - Verifica si hay una sesión activa de usuario
/// - Redirige automáticamente a Home si hay sesión o a Login si no la hay
class PantallaSplash extends StatefulWidget {
  const PantallaSplash({super.key});

  @override
  State<PantallaSplash> createState() => _PantallaSplashState();
}

class _PantallaSplashState extends State<PantallaSplash> {
  final RepositorioAuth _repositorioAuth = RepositorioAuth();

  @override
  void initState() {
    super.initState();
    _verificarSesionYNavegar();
  }

  /// Verifica si hay una sesión activa y navega a la pantalla correspondiente
  Future<void> _verificarSesionYNavegar() async {
    // Esperar un mínimo de 2 segundos para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar si hay un usuario autenticado
    final estaAutenticado = _repositorioAuth.estaAutenticado();

    // Navegar a la pantalla correspondiente
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => estaAutenticado
            ? const PantallaHome()
            : const PantallaLogin(),
      ),
    );
  }

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
