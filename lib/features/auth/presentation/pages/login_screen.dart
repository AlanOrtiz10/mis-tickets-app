import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../home/presentation/pages/home_screen.dart';

/// Pantalla de inicio de sesión y registro para MisTickets
///
/// Esta pantalla permite a los usuarios:
/// - Autenticarse usando su correo institucional y contraseña
/// - Registrarse como nuevos usuarios
/// - Cambiar entre modo login y registro
///
/// Funcionalidades:
/// - Campo de correo electrónico institucional
/// - Campo de contraseña con opción de mostrar/ocultar
/// - Validación de campos antes de enviar
/// - Integración con Supabase Auth
/// - Navegación a pantalla principal tras autenticación exitosa
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

  // Repositorio de autenticación
  final RepositorioAuth _repositorioAuth = RepositorioAuth();

  // Estado para mostrar/ocultar contraseña
  bool _ocultarContrasena = true;

  // Estado de carga durante autenticación
  bool _cargando = false;

  // Estado para alternar entre Login y Registro
  bool _modoRegistro = false;

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
      // Iniciar sesión con Supabase
      await _repositorioAuth.iniciarSesion(
        email: _controladorCorreo.text.trim(),
        password: _controladorContrasena.text,
      );

      if (mounted) {
        // Navegar a la pantalla principal y eliminar todas las rutas anteriores
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PantallaHome()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      // Errores de autenticación de Supabase
      if (mounted) {
        String mensaje = 'Error al iniciar sesión';

        // Mensajes más amigables para errores comunes
        if (e.message.contains('Invalid login credentials')) {
          mensaje = 'Credenciales incorrectas. Verifica tu email y contraseña.';
        } else if (e.message.contains('Email not confirmed')) {
          mensaje = 'Por favor confirma tu email antes de iniciar sesión.';
        } else {
          mensaje = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (error) {
      // Otros errores (red, etc.)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  /// Valida y procesa el registro de un nuevo usuario
  Future<void> _registrarse() async {
    // Validar que los campos cumplan con las reglas
    if (!_llaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      // Registrar usuario en Supabase
      final respuesta = await _repositorioAuth.registrarse(
        email: _controladorCorreo.text.trim(),
        password: _controladorContrasena.text,
      );

      if (mounted) {
        // Verificar si se requiere confirmación de email
        if (respuesta.user != null && respuesta.session == null) {
          // Supabase requiere confirmación de email
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registro exitoso. Por favor confirma tu email para iniciar sesión.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 6),
            ),
          );
          // Cambiar a modo login
          setState(() {
            _modoRegistro = false;
          });
        } else {
          // Registro exitoso con sesión automática
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const PantallaHome()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      // Errores de autenticación de Supabase
      if (mounted) {
        String mensaje = 'Error al registrarse';

        // Mensajes más amigables para errores comunes
        if (e.message.contains('already registered')) {
          mensaje = 'Este email ya está registrado. Intenta iniciar sesión.';
        } else if (e.message.contains('Password should be')) {
          mensaje = 'La contraseña debe tener al menos 6 caracteres.';
        } else {
          mensaje = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (error) {
      // Otros errores (red, etc.)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  /// Alterna entre modo login y registro
  void _alternarModo() {
    setState(() {
      _modoRegistro = !_modoRegistro;
    });
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

                  // Subtítulo dinámico según el modo
                  Text(
                    _modoRegistro
                        ? 'Crea tu cuenta institucional'
                        : 'Gestiona tus gastos fácilmente',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Campo de Correo Electrónico
                  TextFormField(
                    controller: _controladorCorreo,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'ejemplo@correo.com',
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
                        return 'Por favor ingresa tu correo electrónico';
                      }
                      // Validación básica de formato de email
                      if (!valor.contains('@') || !valor.contains('.')) {
                        return 'Por favor ingresa un correo válido';
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

                  // Botón de Ingresar/Registrarse
                  ElevatedButton(
                    onPressed: _cargando
                        ? null
                        : (_modoRegistro ? _registrarse : _iniciarSesion),
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
                        : Text(
                            _modoRegistro ? 'Registrarse' : 'Ingresar',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Botón para alternar entre Login y Registro
                  TextButton(
                    onPressed: _cargando ? null : _alternarModo,
                    child: Text(
                      _modoRegistro
                          ? '¿Ya tienes cuenta? Inicia sesión'
                          : '¿No tienes cuenta? Regístrate',
                      style: const TextStyle(
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
