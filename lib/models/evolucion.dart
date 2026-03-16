import 'dart:convert';

/// Tipo de entrada en la evolución médica
enum TipoEvolucion {
  evolucion,     // Evolución clínica del paciente
  comentario,    // Comentario médico o nota
  procedimiento, // Procedimiento realizado
  interconsulta, // Interconsulta solicitada
}

/// Modelo de datos para representar una evolución o comentario médico
/// dentro de una historia clínica en MediAsis.
class Evolucion {
  final String? id;
  final String historiaClinicaId;
  final DateTime fecha;
  final TipoEvolucion tipo;
  final String titulo;
  final String descripcion;
  final String? diagnostico;
  final String? tratamiento;
  final String? medico;
  final String? firma; // Firma digital o hash de verificación
  final DateTime createdAt;
  final DateTime updatedAt;

  Evolucion({
    this.id,
    required this.historiaClinicaId,
    DateTime? fecha,
    this.tipo = TipoEvolucion.evolucion,
    required this.titulo,
    required this.descripcion,
    this.diagnostico,
    this.tratamiento,
    this.medico,
    this.firma,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : fecha = fecha ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Obtiene la fecha formateada
  String get fechaFormateada {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  /// Obtiene la hora formateada
  String get horaFormateada {
    final hour = fecha.hour.toString().padLeft(2, '0');
    final minute = fecha.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Obtiene el nombre del tipo de evolución
  String get tipoNombre {
    switch (tipo) {
      case TipoEvolucion.evolucion:
        return 'Evolución';
      case TipoEvolucion.comentario:
        return 'Comentario';
      case TipoEvolucion.procedimiento:
        return 'Procedimiento';
      case TipoEvolucion.interconsulta:
        return 'Interconsulta';
    }
  }

  /// Convierte el tipo a string para almacenamiento
  String _tipoToString(TipoEvolucion tipo) {
    switch (tipo) {
      case TipoEvolucion.evolucion:
        return 'evolucion';
      case TipoEvolucion.comentario:
        return 'comentario';
      case TipoEvolucion.procedimiento:
        return 'procedimiento';
      case TipoEvolucion.interconsulta:
        return 'interconsulta';
    }
  }

  /// Convierte string a TipoEvolucion
  static TipoEvolucion _stringToTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'comentario':
        return TipoEvolucion.comentario;
      case 'procedimiento':
        return TipoEvolucion.procedimiento;
      case 'interconsulta':
        return TipoEvolucion.interconsulta;
      default:
        return TipoEvolucion.evolucion;
    }
  }

  /// Convierte el modelo a un mapa para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'historia_clinica_id': historiaClinicaId,
      'fecha': fecha.toIso8601String(),
      'tipo': _tipoToString(tipo),
      'titulo': titulo,
      'descripcion': descripcion,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'medico': medico,
      'firma': firma,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una instancia de Evolucion desde un mapa de SQLite
  factory Evolucion.fromMap(Map<String, dynamic> map) {
    return Evolucion(
      id: map['id']?.toString(),
      historiaClinicaId: map['historia_clinica_id']?.toString() ?? '',
      fecha: DateTime.parse(map['fecha']),
      tipo: _stringToTipo(map['tipo'] ?? 'evolucion'),
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      diagnostico: map['diagnostico'],
      tratamiento: map['tratamiento'],
      medico: map['medico'],
      firma: map['firma'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Convierte el modelo a JSON
  String toJson() => jsonEncode(toMap());

  /// Crea una instancia desde JSON
  factory Evolucion.fromJson(String source) =>
      Evolucion.fromMap(jsonDecode(source));

  /// Crea una copia de la evolución con campos actualizados
  Evolucion copyWith({
    String? id,
    String? historiaClinicaId,
    DateTime? fecha,
    TipoEvolucion? tipo,
    String? titulo,
    String? descripcion,
    String? diagnostico,
    String? tratamiento,
    String? medico,
    String? firma,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Evolucion(
      id: id ?? this.id,
      historiaClinicaId: historiaClinicaId ?? this.historiaClinicaId,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      diagnostico: diagnostico ?? this.diagnostico,
      tratamiento: tratamiento ?? this.tratamiento,
      medico: medico ?? this.medico,
      firma: firma ?? this.firma,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Evolucion(id: $id, tipo: $tipoNombre, titulo: $titulo, fecha: $fechaFormateada)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Evolucion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
