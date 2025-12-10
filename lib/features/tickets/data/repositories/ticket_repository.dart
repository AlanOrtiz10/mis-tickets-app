import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_client.dart';
import '../../domain/entities/ticket.dart';

/// Repositorio de Tickets para MisTickets
///
/// Maneja todas las operaciones CRUD relacionadas con tickets:
/// - Obtener lista de tickets del usuario
/// - Crear nuevo ticket (subir imagen y guardar registro)
/// - Eliminar ticket (futuro)
/// - Actualizar ticket (futuro)
class RepositorioTicket {
  final SupabaseClient _cliente;

  /// Nombre del bucket de Supabase Storage donde se guardan las imágenes
  static const String bucketTickets = 'tickets-images';

  /// Constructor que recibe el cliente de Supabase
  ///
  /// Por defecto usa el cliente global de ServicioSupabase.
  /// Se puede inyectar un cliente personalizado para testing.
  RepositorioTicket({SupabaseClient? cliente})
      : _cliente = cliente ?? ServicioSupabase.obtenerCliente();

  /// Obtiene todos los tickets del usuario actual
  ///
  /// Retorna:
  /// - Lista de [Ticket] ordenados por fecha de creación (más recientes primero)
  ///
  /// Lanza:
  /// - [Exception] si hay error al consultar la base de datos
  /// - [Exception] si no hay usuario autenticado
  Future<List<Ticket>> obtenerTickets() async {
    try {
      // Verificar que hay un usuario autenticado
      final usuario = _cliente.auth.currentUser;
      if (usuario == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Consultar tickets del usuario actual
      final response = await _cliente
          .from('tickets')
          .select()
          .eq('user_id', usuario.id)
          .order('created_at', ascending: false);

      // Convertir la respuesta a lista de Tickets
      final tickets = (response as List)
          .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
          .toList();

      return tickets;
    } catch (e) {
      throw Exception('Error al obtener tickets: ${e.toString()}');
    }
  }

  /// Crea un nuevo ticket subiendo la imagen y guardando el registro
  ///
  /// Parámetros:
  /// - [imagenFile]: Archivo de imagen capturado (desde cámara o galería)
  /// - [monto]: Monto del ticket en pesos
  /// - [categoria]: Categoría del gasto
  /// - [fechaTicket]: Fecha del ticket/gasto
  ///
  /// Proceso:
  /// 1. Sube la imagen a Supabase Storage (bucket 'tickets-images')
  /// 2. Obtiene la URL pública de la imagen
  /// 3. Inserta el registro en la tabla 'tickets'
  ///
  /// Retorna:
  /// - El [Ticket] creado con todos sus datos
  ///
  /// Lanza:
  /// - [Exception] si no hay usuario autenticado
  /// - [Exception] si falla la subida de la imagen
  /// - [Exception] si falla la inserción en la base de datos
  Future<Ticket> crearTicket({
    required File imagenFile,
    required double monto,
    required String categoria,
    required DateTime fechaTicket,
  }) async {
    try {
      // Verificar que hay un usuario autenticado
      final usuario = _cliente.auth.currentUser;
      if (usuario == null) {
        throw Exception('No hay usuario autenticado');
      }

      // 1. Generar nombre único para la imagen usando timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imagenFile.path.split('.').last;
      final nombreArchivo = '${usuario.id}/$timestamp.$extension';

      // 2. Subir imagen a Supabase Storage
      final rutaStorage = await _cliente.storage
          .from(bucketTickets)
          .upload(nombreArchivo, imagenFile);

      // 3. Obtener URL pública de la imagen
      final imagenUrl = _cliente.storage
          .from(bucketTickets)
          .getPublicUrl(nombreArchivo);

      // 4. Insertar registro en la tabla tickets
      final ticketData = {
        'user_id': usuario.id,
        'monto': monto,
        'categoria': categoria,
        'imagen_url': imagenUrl,
        'fecha_ticket': fechaTicket.toIso8601String().split('T')[0], // Solo fecha (YYYY-MM-DD)
      };

      final response = await _cliente
          .from('tickets')
          .insert(ticketData)
          .select()
          .single();

      // 5. Convertir la respuesta a objeto Ticket
      final ticket = Ticket.fromJson(response as Map<String, dynamic>);

      return ticket;
    } on StorageException catch (e) {
      throw Exception('Error al subir imagen: ${e.message}');
    } catch (e) {
      throw Exception('Error al crear ticket: ${e.toString()}');
    }
  }

  /// Elimina un ticket (imagen y registro)
  ///
  /// Parámetros:
  /// - [ticketId]: ID del ticket a eliminar
  ///
  /// Proceso:
  /// 1. Obtiene el ticket para saber la ruta de la imagen
  /// 2. Elimina la imagen de Supabase Storage
  /// 3. Elimina el registro de la base de datos
  ///
  /// Lanza:
  /// - [Exception] si hay error al eliminar
  Future<void> eliminarTicket(String ticketId) async {
    try {
      // Obtener el ticket para saber la URL de la imagen
      final response = await _cliente
          .from('tickets')
          .select()
          .eq('id', ticketId)
          .single();

      final ticket = Ticket.fromJson(response as Map<String, dynamic>);

      // Extraer el path de la imagen desde la URL
      // URL: https://[project].supabase.co/storage/v1/object/public/tickets-images/[user_id]/[timestamp].jpg
      final imagenUrl = ticket.imagenUrl;
      final rutaImagen = imagenUrl.split('$bucketTickets/').last;

      // Eliminar imagen de Storage
      await _cliente.storage.from(bucketTickets).remove([rutaImagen]);

      // Eliminar registro de la base de datos
      await _cliente.from('tickets').delete().eq('id', ticketId);
    } catch (e) {
      throw Exception('Error al eliminar ticket: ${e.toString()}');
    }
  }

  /// Obtiene la suma total de todos los tickets del usuario
  ///
  /// Retorna:
  /// - El total en pesos de todos los tickets
  Future<double> obtenerTotalGastos() async {
    try {
      final tickets = await obtenerTickets();
      return tickets.fold<double>(0.0, (sum, ticket) => sum + ticket.monto);
    } catch (e) {
      throw Exception('Error al calcular total de gastos: ${e.toString()}');
    }
  }

  /// Obtiene tickets filtrados por categoría
  ///
  /// Parámetros:
  /// - [categoria]: Categoría a filtrar
  ///
  /// Retorna:
  /// - Lista de tickets de esa categoría
  Future<List<Ticket>> obtenerTicketsPorCategoria(String categoria) async {
    try {
      final usuario = _cliente.auth.currentUser;
      if (usuario == null) {
        throw Exception('No hay usuario autenticado');
      }

      final response = await _cliente
          .from('tickets')
          .select()
          .eq('user_id', usuario.id)
          .eq('categoria', categoria)
          .order('created_at', ascending: false);

      final tickets = (response as List)
          .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
          .toList();

      return tickets;
    } catch (e) {
      throw Exception('Error al obtener tickets por categoría: ${e.toString()}');
    }
  }
}
