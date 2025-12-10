/// Modelo de datos para representar un Ticket/Recibo en la aplicación
///
/// Esta clase maneja la conversión entre los datos JSON de Supabase
/// y los objetos Dart utilizados en la aplicación.
///
/// Campos:
/// - [id]: Identificador único del ticket (UUID)
/// - [monto]: Cantidad monetaria del ticket
/// - [categoria]: Categoría del gasto (ej: "Alimentos", "Transporte")
/// - [fecha]: Fecha y hora en que se realizó el gasto
/// - [urlFoto]: URL de la imagen del ticket en Supabase Storage (opcional)
/// - [userId]: ID del usuario propietario del ticket
/// - [createdAt]: Fecha de creación del registro
/// - [updatedAt]: Fecha de última actualización del registro
class TicketModel {
  /// Identificador único del ticket
  final String id;

  /// Monto del ticket (cantidad de dinero gastada)
  final double monto;

  /// Categoría del gasto
  /// Ejemplos: "Alimentos", "Transporte", "Educación", "Entretenimiento"
  final String categoria;

  /// Fecha y hora en que se realizó el gasto
  final DateTime fecha;

  /// URL de la foto del ticket almacenada en Supabase Storage
  /// Puede ser null si el usuario no subió foto
  final String? urlFoto;

  /// ID del usuario propietario del ticket (UUID)
  final String userId;

  /// Marca de tiempo de creación del registro
  final DateTime createdAt;

  /// Marca de tiempo de última actualización del registro
  final DateTime updatedAt;

  /// Constructor principal del modelo
  const TicketModel({
    required this.id,
    required this.monto,
    required this.categoria,
    required this.fecha,
    this.urlFoto,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una instancia de [TicketModel] desde un Map JSON
  ///
  /// Este método se utiliza para convertir los datos recibidos de Supabase
  /// (en formato JSON/Map) a un objeto Dart tipado.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final json = {'id': '123', 'monto': 150.50, ...};
  /// final ticket = TicketModel.fromJson(json);
  /// ```
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      monto: (json['monto'] as num).toDouble(),
      categoria: json['categoria'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      urlFoto: json['url_foto'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte esta instancia de [TicketModel] a un Map JSON
  ///
  /// Este método se utiliza para convertir un objeto Dart a formato JSON/Map
  /// antes de enviarlo a Supabase para guardar o actualizar.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final ticket = TicketModel(...);
  /// final json = ticket.toJson();
  /// await supabase.from('tickets').insert(json);
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monto': monto,
      'categoria': categoria,
      'fecha': fecha.toIso8601String(),
      'url_foto': urlFoto,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia de este [TicketModel] con algunos campos modificados
  ///
  /// Útil para actualizar tickets existentes manteniendo la inmutabilidad.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final ticketActualizado = ticketOriginal.copyWith(
  ///   monto: 200.00,
  ///   categoria: "Transporte",
  /// );
  /// ```
  TicketModel copyWith({
    String? id,
    double? monto,
    String? categoria,
    DateTime? fecha,
    String? urlFoto,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      categoria: categoria ?? this.categoria,
      fecha: fecha ?? this.fecha,
      urlFoto: urlFoto ?? this.urlFoto,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Representación en String del ticket para debugging
  @override
  String toString() {
    return 'TicketModel(id: $id, monto: $monto, categoria: $categoria, '
        'fecha: $fecha, urlFoto: $urlFoto, userId: $userId, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  /// Compara dos instancias de [TicketModel] para determinar igualdad
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TicketModel &&
        other.id == id &&
        other.monto == monto &&
        other.categoria == categoria &&
        other.fecha == fecha &&
        other.urlFoto == urlFoto &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  /// Genera un código hash para este [TicketModel]
  @override
  int get hashCode {
    return id.hashCode ^
        monto.hashCode ^
        categoria.hashCode ^
        fecha.hashCode ^
        (urlFoto?.hashCode ?? 0) ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
