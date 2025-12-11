import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_client.dart';

/// Repositorio de autenticación para MisTickets
///
/// Maneja todas las operaciones relacionadas con la autenticación de usuarios:
/// - Inicio de sesión con email y contraseña
/// - Registro de nuevos usuarios
/// - Cierre de sesión
/// - Obtención del usuario actual
/// - Verificación del estado de autenticación
///
/// Utiliza Supabase Auth como backend de autenticación.
class RepositorioAuth {
  /// Cliente de Supabase
  final SupabaseClient _cliente;

  /// Constructor que recibe el cliente de Supabase
  ///
  /// Por defecto usa el cliente global de ServicioSupabase.
  /// Se puede inyectar un cliente personalizado para testing.
  RepositorioAuth({SupabaseClient? cliente})
      : _cliente = cliente ?? ServicioSupabase.obtenerCliente();

  /// Inicia sesión con email y contraseña
  ///
  /// Parámetros:
  /// - [email]: Correo electrónico del usuario (debe ser @uthermosillo.edu.mx)
  /// - [password]: Contraseña del usuario
  ///
  /// Retorna:
  /// - [AuthResponse] con información de sesión y usuario
  ///
  /// Lanza:
  /// - [AuthException] si las credenciales son incorrectas
  /// - [Exception] para otros errores
  Future<AuthResponse> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final respuesta = await _cliente.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      return respuesta;
    } on AuthException catch (e) {
      // Errores específicos de autenticación
      throw AuthException(e.message);
    } catch (e) {
      // Otros errores (red, etc.)
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  /// Registra un nuevo usuario con email y contraseña
  ///
  /// Parámetros:
  /// - [email]: Correo electrónico del usuario (debe ser @uthermosillo.edu.mx)
  /// - [password]: Contraseña del usuario (mínimo 6 caracteres)
  /// - [metadata]: Datos adicionales del usuario (nombre, matrícula, etc.)
  ///
  /// Retorna:
  /// - [AuthResponse] con información de sesión y usuario
  ///
  /// Lanza:
  /// - [AuthException] si el email ya está registrado o no cumple requisitos
  /// - [Exception] para otros errores
  ///
  /// NOTA: Dependiendo de la configuración de Supabase, puede requerir
  /// confirmación de email antes de permitir el inicio de sesión.
  Future<AuthResponse> registrarse({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final respuesta = await _cliente.auth.signUp(
        email: email.trim(),
        password: password,
        data: metadata,
      );

      return respuesta;
    } on AuthException catch (e) {
      // Errores específicos de autenticación
      throw AuthException(e.message);
    } catch (e) {
      // Otros errores (red, etc.)
      throw Exception('Error al registrarse: ${e.toString()}');
    }
  }

  /// Cierra la sesión del usuario actual
  ///
  /// Limpia todos los tokens de sesión y refresco.
  ///
  /// Lanza:
  /// - [Exception] si hay un error al cerrar sesión
  Future<void> cerrarSesion() async {
    try {
      await _cliente.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Obtiene el usuario actualmente autenticado
  ///
  /// Retorna:
  /// - [User] si hay un usuario autenticado
  /// - `null` si no hay sesión activa
  User? obtenerUsuarioActual() {
    return _cliente.auth.currentUser;
  }

  /// Verifica si hay un usuario autenticado
  ///
  /// Retorna:
  /// - `true` si existe una sesión activa
  /// - `false` si no hay usuario autenticado
  bool estaAutenticado() {
    return _cliente.auth.currentUser != null;
  }

  /// Obtiene la sesión actual
  ///
  /// Retorna:
  /// - [Session] si hay una sesión activa
  /// - `null` si no hay sesión
  Session? obtenerSesionActual() {
    return _cliente.auth.currentSession;
  }

  /// Stream que notifica cambios en el estado de autenticación
  ///
  /// Útil para:
  /// - Actualizar UI cuando el usuario inicia/cierra sesión
  /// - Redirigir automáticamente cuando cambia el estado de auth
  /// - Sincronizar estado en múltiples pantallas
  ///
  /// Ejemplo:
  /// ```dart
  /// repositorioAuth.cambiosDeAutenticacion().listen((event) {
  ///   if (event == AuthChangeEvent.signedIn) {
  ///     // Usuario inició sesión
  ///   } else if (event == AuthChangeEvent.signedOut) {
  ///     // Usuario cerró sesión
  ///   }
  /// });
  /// ```
  Stream<AuthState> cambiosDeAutenticacion() {
    return _cliente.auth.onAuthStateChange;
  }
}
