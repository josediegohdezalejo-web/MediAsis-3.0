import 'dart:convert';
import 'evolucion.dart';

/// Modelo de datos para representar una historia clínica en MediAsis.
/// Es el expediente médico completo del paciente.
class HistoriaClinica {
  final String? id;
  final String pacienteId;
  final String numeroExpediente;
  final DateTime fechaApertura;
  final String? antecedentesHeredofamiliares;
  final String? antecedentesPersonales;
  final String? antecedentesQuirurgicos;
  final String? antecedentesAlergicos;
  final String? antecedentesTraumaticos;
  final String? antecedentesTransfusionales;
  final String? antecedentesGinecobstetricos; // Para pacientes femeninos
  final String? habitos; // Tabaco, alcohol, drogas, ejercicio, etc.
  final String? inmunizaciones;
  final String? medicamentosActuales;
  final String? notasGenerales;
  final List<Evolucion>? evoluciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  HistoriaClinica({
    this.id,
    required this.pacienteId,
    required this.numeroExpediente,
    DateTime? fechaApertura,
    this.antecedentesHeredofamiliares,
    this.antecedentesPersonales,
    this.antecedentesQuirurgicos,
    this.antecedentesAlergicos,
    this.antecedentesTraumaticos,
    this.antecedentesTransfusionales,
    this.antecedentesGinecobstetricos,
    this.habitos,
    this.inmunizaciones,
    this.medicamentosActuales,
    this.notasGenerales,
    this.evoluciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : fechaApertura = fechaApertura ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Obtiene la fecha de apertura formateada
  String get fechaAperturaFormateada {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${fechaApertura.day} de ${meses[fechaApertura.month - 1]} del ${fechaApertura.year}';
  }

  /// Cuenta las evoluciones
  int get cantidadEvoluciones => evoluciones?.length ?? 0;

  /// Convierte el modelo a un mapa para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paciente_id': pacienteId,
      'numero_expediente': numeroExpediente,
      'fecha_apertura': fechaApertura.toIso8601String(),
      'antecedentes_heredofamiliares': antecedentesHeredofamiliares,
      'antecedentes_personales': antecedentesPersonales,
      'antecedentes_quirurgicos': antecedentesQuirurgicos,
      'antecedentes_alergicos': antecedentesAlergicos,
      'antecedentes_traumaticos': antecedentesTraumaticos,
      'antecedentes_transfusionales': antecedentesTransfusionales,
      'antecedentes_ginecobstetricos': antecedentesGinecobstetricos,
      'habitos': habitos,
      'inmunizaciones': inmunizaciones,
      'medicamentos_actuales': medicamentosActuales,
      'notas_generales': notasGenerales,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una instancia de HistoriaClinica desde un mapa de SQLite
  factory HistoriaClinica.fromMap(Map<String, dynamic> map, {List<Evolucion>? evoluciones}) {
    return HistoriaClinica(
      id: map['id']?.toString(),
      pacienteId: map['paciente_id']?.toString() ?? '',
      numeroExpediente: map['numero_expediente'] ?? '',
      fechaApertura: DateTime.parse(map['fecha_apertura']),
      antecedentesHeredofamiliares: map['antecedentes_heredofamiliares'],
      antecedentesPersonales: map['antecedentes_personales'],
      antecedentesQuirurgicos: map['antecedentes_quirurgicos'],
      antecedentesAlergicos: map['antecedentes_alergicos'],
      antecedentesTraumaticos: map['antecedentes_traumaticos'],
      antecedentesTransfusionales: map['antecedentes_transfusionales'],
      antecedentesGinecobstetricos: map['antecedentes_ginecobstetricos'],
      habitos: map['habitos'],
      inmunizaciones: map['inmunizaciones'],
      medicamentosActuales: map['medicamentos_actuales'],
      notasGenerales: map['notas_generales'],
      evoluciones: evoluciones,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Convierte el modelo a JSON
  String toJson() => jsonEncode(toMap());

  /// Crea una instancia desde JSON
  factory HistoriaClinica.fromJson(String source) =>
      HistoriaClinica.fromMap(jsonDecode(source));

  /// Crea una copia de la historia clínica con campos actualizados
  HistoriaClinica copyWith({
    String? id,
    String? pacienteId,
    String? numeroExpediente,
    DateTime? fechaApertura,
    String? antecedentesHeredofamiliares,
    String? antecedentesPersonales,
    String? antecedentesQuirurgicos,
    String? antecedentesAlergicos,
    String? antecedentesTraumaticos,
    String? antecedentesTransfusionales,
    String? antecedentesGinecobstetricos,
    String? habitos,
    String? inmunizaciones,
    String? medicamentosActuales,
    String? notasGenerales,
    List<Evolucion>? evoluciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistoriaClinica(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      numeroExpediente: numeroExpediente ?? this.numeroExpediente,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      antecedentesHeredofamiliares: antecedentesHeredofamiliares ?? this.antecedentesHeredofamiliares,
      antecedentesPersonales: antecedentesPersonales ?? this.antecedentesPersonales,
      antecedentesQuirurgicos: antecedentesQuirurgicos ?? this.antecedentesQuirurgicos,
      antecedentesAlergicos: antecedentesAlergicos ?? this.antecedentesAlergicos,
      antecedentesTraumaticos: antecedentesTraumaticos ?? this.antecedentesTraumaticos,
      antecedentesTransfusionales: antecedentesTransfusionales ?? this.antecedentesTransfusionales,
      antecedentesGinecobstetricos: antecedentesGinecobstetricos ?? this.antecedentesGinecobstetricos,
      habitos: habitos ?? this.habitos,
      inmunizaciones: inmunizaciones ?? this.inmunizaciones,
      medicamentosActuales: medicamentosActuales ?? this.medicamentosActuales,
      notasGenerales: notasGenerales ?? this.notasGenerales,
      evoluciones: evoluciones ?? this.evoluciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'HistoriaClinica(id: $id, numeroExpediente: $numeroExpediente, pacienteId: $pacienteId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoriaClinica && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
