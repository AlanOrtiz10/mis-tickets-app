import 'package:flutter/material.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'core/services/supabase_client.dart';
import 'core/config/supabase_config.dart';

/// Punto de entrada principal de la aplicación MisTickets
///
/// Este método inicializa los servicios necesarios antes de ejecutar la app:
/// - Supabase: Backend para autenticación y base de datos
/// - Widgets Flutter: Binding necesario para operaciones asíncronas
Future<void> main() async {
  // Asegura que los widgets de Flutter estén inicializados antes de operaciones asíncronas
  // Requerido cuando se llaman métodos async en main() antes de runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar cliente de Supabase con las credenciales configuradas
  // Las credenciales se obtienen de lib/core/config/supabase_config.dart
  // Ver ese archivo para instrucciones de cómo obtener tus propias credenciales
  await ServicioSupabase.inicializar(
    urlSupabase: SupabaseConfig.urlSupabase,
    claveAnonima: SupabaseConfig.claveAnonima,
  );

  // Ejecutar la aplicación
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
