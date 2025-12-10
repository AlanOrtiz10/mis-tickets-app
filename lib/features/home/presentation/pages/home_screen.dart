import 'package:flutter/material.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_screen.dart';

/// Pantalla principal de MisTickets
///
/// Esta es la pantalla que se muestra después de un inicio de sesión exitoso.
/// Aquí el usuario podrá:
/// - Ver sus tickets/gastos
/// - Agregar nuevos tickets
/// - Ver estadísticas
/// - Acceder a su perfil
///
/// Por ahora, es una versión básica que muestra:
/// - Mensaje de bienvenida con el email del usuario
/// - Botón para cerrar sesión
class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  final RepositorioAuth _repositorioAuth = RepositorioAuth();
  bool _cargando = false;

  /// Maneja el cierre de sesión del usuario
  Future<void> _cerrarSesion() async {
    setState(() {
      _cargando = true;
    });

    try {
      await _repositorioAuth.cerrarSesion();

      if (mounted) {
        // Navegar al login y eliminar todas las rutas anteriores
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PantallaLogin()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _repositorioAuth.obtenerUsuarioActual();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'MisTickets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cargando ? null : _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de bienvenida
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Mensaje de bienvenida
              const Text(
                '¡Bienvenido a MisTickets!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Email del usuario
              if (usuario != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF1E3A8A),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          usuario.email ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),

              // Mensaje temporal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue[200]!,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.construction,
                      color: Color(0xFF1E3A8A),
                      size: 40,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Funcionalidades próximamente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aquí podrás gestionar tus tickets y gastos universitarios',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Botón de cerrar sesión
              ElevatedButton.icon(
                onPressed: _cargando ? null : _cerrarSesion,
                icon: _cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(_cargando ? 'Cerrando sesión...' : 'Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
