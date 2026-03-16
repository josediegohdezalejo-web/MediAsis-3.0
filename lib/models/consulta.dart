import 'dart:convert';

/// Modelo de datos para representar una consulta médica en MediAsis.
/// Contiene información completa del episodio de atención médica.
class Consulta {
  final String? id;
  final String pacienteId;
  final String? historiaClinicaId;
  final DateTime fechaConsulta;
  final String motivoConsulta;
  final String? sintomas;
  final String? antecedentes;
  final String? exploracionFisica;
  final String? diagnostico;
  final String? diagnosticoCIE10;
  final String? tratamiento;
  final String? medicamentos;
  final String? indicaciones;
  final String? pronostico;
  final String? notas;
  final String? proximaCita;
  final String estado; // 'Pendiente', 'En curso', 'Completada', 'Cancelada'
  final String? medico;
  final String? especialidad;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consulta({
    this.id,
    required this.pacienteId,
    this.historiaClinicaId,
    DateTime? fechaConsulta,
    required this.motivoConsulta,
    this.sintomas,
    this.antecedentes,
    this.exploracionFisica,
    this.diagnostico,
    this.diagnosticoCIE10,
    this.tratamiento,
    this.medicamentos,
    this.indicaciones,
    this.pronostico,
    this.notas,
    this.proximaCita,
    this.estado = 'Pendiente',
    this.medico,
    this.especialidad,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : fechaConsulta = fechaConsulta ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Verifica si la consulta es para hoy
  bool get esHoy {
    final now = DateTime.now();
    return fechaConsulta.year == now.year &&
        fechaConsulta.month == now.month &&
        fechaConsulta.day == now.day;
  }

  /// Verifica si la consulta está pendiente
  bool get estaPendiente => estado == 'Pendiente';

  /// Verifica si la consulta está completada
  bool get estaCompletada => estado == 'Completada';

  /// Obtiene la fecha formateada
  String get fechaFormateada {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fechaConsulta.day} ${meses[fechaConsulta.month - 1]} ${fechaConsulta.year}';
  }

  /// Obtiene la hora formateada
  String get horaFormateada {
    final hour = fechaConsulta.hour.toString().padLeft(2, '0');
    final minute = fechaConsulta.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Convierte el modelo a un mapa para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paciente_id': pacienteId,
      'historia_clinica_id': historiaClinicaId,
      'fecha_consulta': fechaConsulta.toIso8601String(),
      'motivo_consulta': motivoConsulta,
      'sintomas': sintomas,
      'antecedentes': antecedentes,
      'exploracion_fisica': exploracionFisica,
      'diagnostico': diagnostico,
      'diagnostico_cie10': diagnosticoCIE10,
      'tratamiento': tratamiento,
      'medicamentos': medicamentos,
      'indicaciones': indicaciones,
      'pronostico': pronostico,
      'notas': notas,
      'proxima_cita': proximaCita,
      'estado': estado,
      'medico': medico,
      'especialidad': especialidad,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una instancia de Consulta desde un mapa de SQLite
  factory Consulta.fromMap(Map<String, dynamic> map) {
    return Consulta(
      id: map['id']?.toString(),
      pacienteId: map['paciente_id']?.toString() ?? '',
      historiaClinicaId: map['historia_clinica_id']?.toString(),
      fechaConsulta: DateTime.parse(map['fecha_consulta']),
      motivoConsulta: map['motivo_consulta'] ?? '',
      sintomas: map['sintomas'],
      antecedentes: map['antecedentes'],
      exploracionFisica: map['exploracion_fisica'],
      diagnostico: map['diagnostico'],
      diagnosticoCIE10: map['diagnostico_cie10'],
      tratamiento: map['tratamiento'],
      medicamentos: map['medicamentos'],
      indicaciones: map['indicaciones'],
      pronostico: map['pronostico'],
      notas: map['notas'],
      proximaCita: map['proxima_cita'],
      estado: map['estado'] ?? 'Pendiente',
      medico: map['medico'],
      especialidad: map['especialidad'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Convierte el modelo a JSON
  String toJson() => jsonEncode(toMap());

  /// Crea una instancia desde JSON
  factory Consulta.fromJson(String source) =>
      Consulta.fromMap(jsonDecode(source));

  /// Crea una copia de la consulta con campos actualizados
  Consulta copyWith({
    String? id,
    String? pacienteId,
    String? historiaClinicaId,
    DateTime? fechaConsulta,
    String? motivoConsulta,
    String? sintomas,
    String? antecedentes,
    String? exploracionFisica,
    String? diagnostico,
    String? diagnosticoCIE10,
    String? tratamiento,
    String? medicamentos,
    String? indicaciones,
    String? pronostico,
    String? notas,
    String? proximaCita,
    String? estado,
    String? medico,
    String? especialidad,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Consulta(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      historiaClinicaId: historiaClinicaId ?? this.historiaClinicaId,
      fechaConsulta: fechaConsulta ?? this.fechaConsulta,
      motivoConsulta: motivoConsulta ?? this.motivoConsulta,
      sintomas: sintomas ?? this.sintomas,
      antecedentes: antecedentes ?? this.antecedentes,
      exploracionFisica: exploracionFisica ?? this.exploracionFisica,
      diagnostico: diagnostico ?? this.diagnostico,
      diagnosticoCIE10: diagnosticoCIE10 ?? this.diagnosticoCIE10,
      tratamiento: tratamiento ?? this.tratamiento,
      medicamentos: medicamentos ?? this.medicamentos,
      indicaciones: indicaciones ?? this.indicaciones,
      pronostico: pronostico ?? this.pronostico,
      notas: notas ?? this.notas,
      proximaCita: proximaCita ?? this.proximaCita,
      estado: estado ?? this.estado,
      medico: medico ?? this.medico,
      especialidad: especialidad ?? this.especialidad,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Consulta(id: $id, pacienteId: $pacienteId, fecha: $fechaFormateada, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Consulta && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
