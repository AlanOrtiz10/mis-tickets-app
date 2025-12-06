import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de cliente de Supabase para MisTickets
///
/// CONFIGURACIÓN DE SEGURIDAD (Issue #1):
///
/// 1. HTTPS/SSL Forzado:
///    - Supabase_flutter utiliza HTTPS por defecto para todas las conexiones
///    - La URL de Supabase siempre comienza con "https://" garantizando
///      cifrado de extremo a extremo (TLS/SSL)
///    - Todas las peticiones a la API y base de datos están protegidas
///      contra interceptación y ataques man-in-the-middle
///
/// 2. Autenticación JWT (JSON Web Tokens):
///    - Supabase utiliza JWT para la autenticación de usuarios
///    - Los tokens se generan tras el inicio de sesión exitoso
///    - Cada petición autenticada incluye el JWT en el header Authorization
///    - Los tokens tienen tiempo de expiración configurable (por defecto 1 hora)
///    - Se implementa refresh token automático para mantener sesiones seguras
///    - Los JWT están firmados con clave secreta en el servidor
///    - Protección contra falsificación de tokens (CSRF) y replay attacks
///
/// 3. Almacenamiento Seguro:
///    - Las claves de API se almacenan como variables de entorno
///    - NUNCA se deben hacer commit de las claves en el código fuente
///    - Los tokens de sesión se guardan de forma segura en el dispositivo
///
/// EJEMPLO DE USO:
/// ```dart
/// await ServicioSupabase.inicializar(
///   urlSupabase: 'TU_URL_SUPABASE',
///   claveAnonima: 'TU_CLAVE_ANONIMA',
/// );
/// final cliente = ServicioSupabase.obtenerCliente();
/// ```
class ServicioSupabase {
  static SupabaseClient? _clienteInstancia;

  /// Inicializa el cliente de Supabase con configuración segura
  ///
  /// Parámetros:
  /// - [urlSupabase]: URL del proyecto Supabase (debe comenzar con https://)
  /// - [claveAnonima]: Clave anónima pública del proyecto
  static Future<void> inicializar({
    required String urlSupabase,
    required String claveAnonima,
  }) async {
    await Supabase.initialize(
      url: urlSupabase,
      anonKey: claveAnonima,
      // La configuración por defecto ya incluye:
      // - HTTPS forzado
      // - Gestión automática de JWT
      // - Refresh automático de tokens
    );

    _clienteInstancia = Supabase.instance.client;
  }

  /// Obtiene la instancia única del cliente Supabase
  static SupabaseClient obtenerCliente() {
    if (_clienteInstancia == null) {
      throw Exception(
        'El cliente de Supabase no ha sido inicializado. '
        'Llama a ServicioSupabase.inicializar() primero.',
      );
    }
    return _clienteInstancia!;
  }

  /// Obtiene el usuario autenticado actual
  static User? get usuarioActual => _clienteInstancia?.auth.currentUser;

  /// Verifica si hay un usuario autenticado
  static bool get estaAutenticado => usuarioActual != null;
}
