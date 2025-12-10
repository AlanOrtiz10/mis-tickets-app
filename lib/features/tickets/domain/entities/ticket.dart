/// Entidad Ticket que representa un ticket/gasto en MisTickets
///
/// Esta clase representa un ticket escaneado/fotografiado por el usuario.
/// Contiene información sobre el monto, categoría y la imagen del ticket.
class Ticket {
  /// ID único del ticket (UUID generado por Supabase)
  final String id;

  /// ID del usuario propietario del ticket
  final String userId;

  /// Monto del ticket en pesos
  final double monto;

  /// Categoría del gasto (Alimentos, Transporte, Servicios, etc.)
  final String categoria;

  /// URL pública de la imagen del ticket en Supabase Storage
  final String imagenUrl;

  /// Fecha de creación del ticket
  final DateTime fechaCreacion;

  /// Constructor
  const Ticket({
    required this.id,
    required this.userId,
    required this.monto,
    required this.categoria,
    required this.imagenUrl,
    required this.fechaCreacion,
  });

  /// Crea un Ticket desde un Map (típicamente de JSON o Supabase)
  ///
  /// Ejemplo de data de Supabase:
  /// ```json
  /// {
  ///   "id": "uuid-here",
  ///   "user_id": "uuid-user",
  ///   "monto": 150.50,
  ///   "categoria": "Alimentos",
  ///   "imagen_url": "https://...",
  ///   "created_at": "2024-01-15T10:30:00Z"
  /// }
  /// ```
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      monto: (json['monto'] as num).toDouble(),
      categoria: json['categoria'] as String,
      imagenUrl: json['imagen_url'] as String,
      fechaCreacion: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte el Ticket a Map (para enviar a Supabase)
  ///
  /// NOTA: No incluye 'id' ni 'created_at' porque Supabase los genera automáticamente
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'monto': monto,
      'categoria': categoria,
      'imagen_url': imagenUrl,
    };
  }

  /// Crea una copia del Ticket con algunos campos modificados
  Ticket copyWith({
    String? id,
    String? userId,
    double? monto,
    String? categoria,
    String? imagenUrl,
    DateTime? fechaCreacion,
  }) {
    return Ticket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monto: monto ?? this.monto,
      categoria: categoria ?? this.categoria,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'Ticket(id: $id, monto: $monto, categoria: $categoria, fecha: $fechaCreacion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ticket && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
