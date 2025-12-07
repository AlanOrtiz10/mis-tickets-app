import 'package:flutter/material.dart';

/// Pantalla de inicio de sesión para MisTickets
///
/// Esta pantalla permite a los usuarios autenticarse usando su
/// correo institucional y contraseña de la Universidad.
///
/// Funcionalidades:
/// - Campo de correo electrónico institucional
/// - Campo de contraseña con opción de mostrar/ocultar
/// - Validación de campos antes de enviar
/// - Botón de ingreso que conectará con Supabase Auth
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  // Controladores para los campos de texto
  final TextEditingController _controladorCorreo = TextEditingController();
  final TextEditingController _controladorContrasena = TextEditingController();

  // Llave global para el formulario (validación)
  final GlobalKey<FormState> _llaveFormulario = GlobalKey<FormState>();

  // Estado para mostrar/ocultar contraseña
  bool _ocultarContrasena = true;

  // Estado de carga durante autenticación
  bool _cargando = false;

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  /// Valida y procesa el inicio de sesión
  Future<void> _iniciarSesion() async {
    // Validar que los campos cumplan con las reglas
    if (!_llaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      // TODO: Implementar autenticación con Supabase
      // await supabase.auth.signInWithPassword(
      //   email: _controladorCorreo.text.trim(),
      //   password: _controladorContrasena.text,
      // );

      // Simulación temporal
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // TODO: Navegar a la pantalla principal después de login exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: $error'),
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
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Azul institucional
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _llaveFormulario,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo o icono de la aplicación
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      size: 80,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título
                  const Text(
                    'MisTickets',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtítulo
                  const Text(
                    'Gestiona tus gastos fácilmente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Campo de Correo Institucional
                  TextFormField(
                    controller: _controladorCorreo,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Correo Institucional',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'ejemplo@uthermosillo.edu.mx',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Por favor ingresa tu correo institucional';
                      }
                      // Validación básica de formato de email
                      if (!valor.contains('@') || !valor.contains('.')) {
                        return 'Por favor ingresa un correo válido';
                      }
                      // Validación de dominio institucional
                      if (!valor.endsWith('@uthermosillo.edu.mx')) {
                        return 'Usa tu correo institucional (@uthermosillo.edu.mx)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo de Contraseña
                  TextFormField(
                    controller: _controladorContrasena,
                    obscureText: _ocultarContrasena,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'Ingresa tu contraseña',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarContrasena
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _ocultarContrasena = !_ocultarContrasena;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      if (valor.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón de Ingresar
                  ElevatedButton(
                    onPressed: _cargando ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1E3A8A),
                              ),
                            ),
                          )
                        : const Text(
                            'Ingresar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Enlace de recuperación de contraseña (futuro)
                  TextButton(
                    onPressed: () {
                      // TODO: Implementar recuperación de contraseña
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función próximamente disponible'),
                        ),
                      );
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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
