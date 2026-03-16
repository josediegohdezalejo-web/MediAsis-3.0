import 'dart:convert';

/// Modelo de datos para representar un paciente en el sistema MediAsis.
/// Contiene toda la información demográfica y personal del paciente.
class Paciente {
  final String? id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final DateTime fechaNacimiento;
  final String genero; // 'Masculino', 'Femenino', 'Otro'
  final String curp;
  final String telefono;
  final String? email;
  final String direccion;
  final String? contactoEmergencia;
  final String? telefonoEmergencia;
  final String? alergias;
  final String? tipoSanguineo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Paciente({
    this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.fechaNacimiento,
    required this.genero,
    required this.curp,
    required this.telefono,
    this.email,
    required this.direccion,
    this.contactoEmergencia,
    this.telefonoEmergencia,
    this.alergias,
    this.tipoSanguineo,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Nombre completo del paciente
  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';

  /// Calcula la edad del paciente basándose en su fecha de nacimiento
  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month ||
        (now.month == fechaNacimiento.month &&
            now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  /// Convierte el modelo a un mapa para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'genero': genero,
      'curp': curp,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'contacto_emergencia': contactoEmergencia,
      'telefono_emergencia': telefonoEmergencia,
      'alergias': alergias,
      'tipo_sanguineo': tipoSanguineo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una instancia de Paciente desde un mapa de SQLite
  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id']?.toString(),
      nombre: map['nombre'] ?? '',
      apellidoPaterno: map['apellido_paterno'] ?? '',
      apellidoMaterno: map['apellido_materno'] ?? '',
      fechaNacimiento: DateTime.parse(map['fecha_nacimiento']),
      genero: map['genero'] ?? 'Otro',
      curp: map['curp'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'],
      direccion: map['direccion'] ?? '',
      contactoEmergencia: map['contacto_emergencia'],
      telefonoEmergencia: map['telefono_emergencia'],
      alergias: map['alergias'],
      tipoSanguineo: map['tipo_sanguineo'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Convierte el modelo a JSON
  String toJson() => jsonEncode(toMap());

  /// Crea una instancia desde JSON
  factory Paciente.fromJson(String source) =>
      Paciente.fromMap(jsonDecode(source));

  /// Crea una copia del paciente con campos actualizados
  Paciente copyWith({
    String? id,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    DateTime? fechaNacimiento,
    String? genero,
    String? curp,
    String? telefono,
    String? email,
    String? direccion,
    String? contactoEmergencia,
    String? telefonoEmergencia,
    String? alergias,
    String? tipoSanguineo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Paciente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      genero: genero ?? this.genero,
      curp: curp ?? this.curp,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      contactoEmergencia: contactoEmergencia ?? this.contactoEmergencia,
      telefonoEmergencia: telefonoEmergencia ?? this.telefonoEmergencia,
      alergias: alergias ?? this.alergias,
      tipoSanguineo: tipoSanguineo ?? this.tipoSanguineo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Paciente(id: $id, nombreCompleto: $nombreCompleto, curp: $curp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Paciente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
