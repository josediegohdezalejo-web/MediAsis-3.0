import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

/// Helper para la gestión de la base de datos SQLite en MediAsis.
/// Implementa el patrón Singleton para asegurar una única instancia de la BD.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Nombre de la base de datos
  static const String _databaseName = 'mediasis.db';

  /// Versión de la base de datos
  static const int _databaseVersion = 1;

  /// Nombres de las tablas
  static const String tablePacientes = 'pacientes';
  static const String tableConsultas = 'consultas';
  static const String tableHistoriasClinicas = 'historias_clinicas';
  static const String tableEvoluciones = 'evoluciones';

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas de la base de datos
  Future<void> _onCreate(Database db, int version) async {
    // Tabla de pacientes
    await db.execute('''
      CREATE TABLE $tablePacientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellido_paterno TEXT NOT NULL,
        apellido_materno TEXT NOT NULL,
        fecha_nacimiento TEXT NOT NULL,
        genero TEXT NOT NULL,
        curp TEXT UNIQUE NOT NULL,
        telefono TEXT NOT NULL,
        email TEXT,
        direccion TEXT NOT NULL,
        contacto_emergencia TEXT,
        telefono_emergencia TEXT,
        alergias TEXT,
        tipo_sanguineo TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de historias clínicas
    await db.execute('''
      CREATE TABLE $tableHistoriasClinicas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        numero_expediente TEXT UNIQUE NOT NULL,
        fecha_apertura TEXT NOT NULL,
        antecedentes_heredofamiliares TEXT,
        antecedentes_personales TEXT,
        antecedentes_quirurgicos TEXT,
        antecedentes_alergicos TEXT,
        antecedentes_traumaticos TEXT,
        antecedentes_transfusionales TEXT,
        antecedentes_ginecobstetricos TEXT,
        habitos TEXT,
        inmunizaciones TEXT,
        medicamentos_actuales TEXT,
        notas_generales TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (paciente_id) REFERENCES $tablePacientes (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de consultas
    await db.execute('''
      CREATE TABLE $tableConsultas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        historia_clinica_id INTEGER,
        fecha_consulta TEXT NOT NULL,
        motivo_consulta TEXT NOT NULL,
        sintomas TEXT,
        antecedentes TEXT,
        exploracion_fisica TEXT,
        diagnostico TEXT,
        diagnostico_cie10 TEXT,
        tratamiento TEXT,
        medicamentos TEXT,
        indicaciones TEXT,
        pronostico TEXT,
        notas TEXT,
        proxima_cita TEXT,
        estado TEXT NOT NULL DEFAULT 'Pendiente',
        medico TEXT,
        especialidad TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (paciente_id) REFERENCES $tablePacientes (id) ON DELETE CASCADE,
        FOREIGN KEY (historia_clinica_id) REFERENCES $tableHistoriasClinicas (id) ON DELETE SET NULL
      )
    ''');

    // Tabla de evoluciones
    await db.execute('''
      CREATE TABLE $tableEvoluciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        historia_clinica_id INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'evolucion',
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        diagnostico TEXT,
        tratamiento TEXT,
        medico TEXT,
        firma TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (historia_clinica_id) REFERENCES $tableHistoriasClinicas (id) ON DELETE CASCADE
      )
    ''');

    // Índices para mejorar el rendimiento
    await db.execute('CREATE INDEX idx_pacientes_curp ON $tablePacientes (curp)');
    await db.execute('CREATE INDEX idx_consultas_paciente ON $tableConsultas (paciente_id)');
    await db.execute('CREATE INDEX idx_consultas_fecha ON $tableConsultas (fecha_consulta)');
    await db.execute('CREATE INDEX idx_consultas_estado ON $tableConsultas (estado)');
    await db.execute('CREATE INDEX idx_historias_paciente ON $tableHistoriasClinicas (paciente_id)');
    await db.execute('CREATE INDEX idx_evoluciones_historia ON $tableEvoluciones (historia_clinica_id)');
  }

  /// Maneja las migraciones de la base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Aquí se implementarían las migraciones futuras
    // Por ejemplo:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE $tablePacientes ADD COLUMN nuevo_campo TEXT');
    // }
  }

  // ==================== OPERACIONES CRUD PARA PACIENTES ====================

  /// Inserta un nuevo paciente
  Future<int> insertPaciente(Paciente paciente) async {
    final db = await database;
    return await db.insert(tablePacientes, paciente.toMap());
  }

  /// Obtiene un paciente por su ID
  Future<Paciente?> getPacienteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePacientes,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Paciente.fromMap(maps.first);
  }

  /// Obtiene un paciente por su CURP
  Future<Paciente?> getPacienteByCurp(String curp) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePacientes,
      where: 'curp = ?',
      whereArgs: [curp.toUpperCase()],
    );
    if (maps.isEmpty) return null;
    return Paciente.fromMap(maps.first);
  }

  /// Obtiene todos los pacientes
  Future<List<Paciente>> getAllPacientes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePacientes,
      orderBy: 'apellido_paterno, apellido_materno, nombre',
    );
    return maps.map((map) => Paciente.fromMap(map)).toList();
  }

  /// Busca pacientes por nombre o CURP
  Future<List<Paciente>> searchPacientes(String query) async {
    final db = await database;
    final String searchQuery = '%${query.toLowerCase()}%';
    final List<Map<String, dynamic>> maps = await db.query(
      tablePacientes,
      where: '''
        LOWER(nombre) LIKE ? OR 
        LOWER(apellido_paterno) LIKE ? OR 
        LOWER(apellido_materno) LIKE ? OR 
        LOWER(curp) LIKE ?
      ''',
      whereArgs: [searchQuery, searchQuery, searchQuery, searchQuery],
      orderBy: 'apellido_paterno, apellido_materno, nombre',
    );
    return maps.map((map) => Paciente.fromMap(map)).toList();
  }

  /// Actualiza un paciente
  Future<int> updatePaciente(Paciente paciente) async {
    final db = await database;
    return await db.update(
      tablePacientes,
      paciente.toMap(),
      where: 'id = ?',
      whereArgs: [paciente.id],
    );
  }

  /// Elimina un paciente
  Future<int> deletePaciente(int id) async {
    final db = await database;
    return await db.delete(
      tablePacientes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== OPERACIONES CRUD PARA CONSULTAS ====================

  /// Inserta una nueva consulta
  Future<int> insertConsulta(Consulta consulta) async {
    final db = await database;
    return await db.insert(tableConsultas, consulta.toMap());
  }

  /// Obtiene una consulta por su ID
  Future<Consulta?> getConsultaById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableConsultas,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Consulta.fromMap(maps.first);
  }

  /// Obtiene todas las consultas de un paciente
  Future<List<Consulta>> getConsultasByPaciente(int pacienteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableConsultas,
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'fecha_consulta DESC',
    );
    return maps.map((map) => Consulta.fromMap(map)).toList();
  }

  /// Obtiene las consultas de hoy
  Future<List<Consulta>> getConsultasHoy() async {
    final db = await database;
    final now = DateTime.now();
    final inicioDia = DateTime(now.year, now.month, now.day);
    final finDia = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      tableConsultas,
      where: 'fecha_consulta >= ? AND fecha_consulta <= ?',
      whereArgs: [inicioDia.toIso8601String(), finDia.toIso8601String()],
      orderBy: 'fecha_consulta ASC',
    );
    return maps.map((map) => Consulta.fromMap(map)).toList();
  }

  /// Obtiene las consultas pendientes
  Future<List<Consulta>> getConsultasPendientes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableConsultas,
      where: 'estado = ?',
      whereArgs: ['Pendiente'],
      orderBy: 'fecha_consulta ASC',
    );
    return maps.map((map) => Consulta.fromMap(map)).toList();
  }

  /// Obtiene todas las consultas
  Future<List<Consulta>> getAllConsultas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableConsultas,
      orderBy: 'fecha_consulta DESC',
    );
    return maps.map((map) => Consulta.fromMap(map)).toList();
  }

  /// Actualiza una consulta
  Future<int> updateConsulta(Consulta consulta) async {
    final db = await database;
    return await db.update(
      tableConsultas,
      consulta.toMap(),
      where: 'id = ?',
      whereArgs: [consulta.id],
    );
  }

  /// Elimina una consulta
  Future<int> deleteConsulta(int id) async {
    final db = await database;
    return await db.delete(
      tableConsultas,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== OPERACIONES CRUD PARA HISTORIAS CLÍNICAS ====================

  /// Inserta una nueva historia clínica
  Future<int> insertHistoriaClinica(HistoriaClinica historia) async {
    final db = await database;
    return await db.insert(tableHistoriasClinicas, historia.toMap());
  }

  /// Obtiene una historia clínica por su ID
  Future<HistoriaClinica?> getHistoriaClinicaById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHistoriasClinicas,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    
    // Cargar evoluciones
    final evoluciones = await getEvolucionesByHistoriaClinica(id);
    return HistoriaClinica.fromMap(maps.first, evoluciones: evoluciones);
  }

  /// Obtiene la historia clínica de un paciente
  Future<HistoriaClinica?> getHistoriaClinicaByPaciente(int pacienteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHistoriasClinicas,
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
    );
    if (maps.isEmpty) return null;
    
    final historiaId = int.parse(maps.first['id'].toString());
    final evoluciones = await getEvolucionesByHistoriaClinica(historiaId);
    return HistoriaClinica.fromMap(maps.first, evoluciones: evoluciones);
  }

  /// Obtiene todas las historias clínicas
  Future<List<HistoriaClinica>> getAllHistoriasClinicas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHistoriasClinicas,
      orderBy: 'fecha_apertura DESC',
    );
    
    List<HistoriaClinica> historias = [];
    for (var map in maps) {
      final historiaId = int.parse(map['id'].toString());
      final evoluciones = await getEvolucionesByHistoriaClinica(historiaId);
      historias.add(HistoriaClinica.fromMap(map, evoluciones: evoluciones));
    }
    return historias;
  }

  /// Actualiza una historia clínica
  Future<int> updateHistoriaClinica(HistoriaClinica historia) async {
    final db = await database;
    return await db.update(
      tableHistoriasClinicas,
      historia.toMap(),
      where: 'id = ?',
      whereArgs: [historia.id],
    );
  }

  /// Elimina una historia clínica
  Future<int> deleteHistoriaClinica(int id) async {
    final db = await database;
    return await db.delete(
      tableHistoriasClinicas,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Verifica si un paciente tiene historia clínica
  Future<bool> pacienteTieneHistoriaClinica(int pacienteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHistoriasClinicas,
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
    );
    return maps.isNotEmpty;
  }

  // ==================== OPERACIONES CRUD PARA EVOLUCIONES ====================

  /// Inserta una nueva evolución
  Future<int> insertEvolucion(Evolucion evolucion) async {
    final db = await database;
    return await db.insert(tableEvoluciones, evolucion.toMap());
  }

  /// Obtiene una evolución por su ID
  Future<Evolucion?> getEvolucionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableEvoluciones,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Evolucion.fromMap(maps.first);
  }

  /// Obtiene todas las evoluciones de una historia clínica
  Future<List<Evolucion>> getEvolucionesByHistoriaClinica(int historiaClinicaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableEvoluciones,
      where: 'historia_clinica_id = ?',
      whereArgs: [historiaClinicaId],
      orderBy: 'fecha DESC',
    );
    return maps.map((map) => Evolucion.fromMap(map)).toList();
  }

  /// Actualiza una evolución
  Future<int> updateEvolucion(Evolucion evolucion) async {
    final db = await database;
    return await db.update(
      tableEvoluciones,
      evolucion.toMap(),
      where: 'id = ?',
      whereArgs: [evolucion.id],
    );
  }

  /// Elimina una evolución
  Future<int> deleteEvolucion(int id) async {
    final db = await database;
    return await db.delete(
      tableEvoluciones,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== OPERACIONES COMPUESTAS ====================

  /// Genera un número de expediente único
  Future<String> generarNumeroExpediente() async {
    final db = await database;
    final now = DateTime.now();
    final year = now.year.toString();
    
    // Obtener el último número de expediente del año
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT numero_expediente FROM $tableHistoriasClinicas 
      WHERE numero_expediente LIKE ? 
      ORDER BY id DESC LIMIT 1
    ''', ['EXP-$year%']);

    if (result.isEmpty) {
      return 'EXP-$year-0001';
    }

    final ultimoExpediente = result.first['numero_expediente'] as String;
    final partes = ultimoExpediente.split('-');
    if (partes.length >= 3) {
      final ultimoNumero = int.tryParse(partes.last) ?? 0;
      final nuevoNumero = (ultimoNumero + 1).toString().padLeft(4, '0');
      return 'EXP-$year-$nuevoNumero';
    }

    return 'EXP-$year-0001';
  }

  /// Crea una consulta y automáticamente crea historia clínica si no existe
  Future<int> crearConsultaConHistoriaAutomatica({
    required Consulta consulta,
    required Paciente paciente,
  }) async {
    int historiaClinicaId;

    // Verificar si el paciente ya tiene historia clínica
    final historiaExistente = await getHistoriaClinicaByPaciente(int.parse(paciente.id!));

    if (historiaExistente != null) {
      historiaClinicaId = int.parse(historiaExistente.id!);
    } else {
      // Crear nueva historia clínica
      final numeroExpediente = await generarNumeroExpediente();
      final nuevaHistoria = HistoriaClinica(
        pacienteId: paciente.id!,
        numeroExpediente: numeroExpediente,
      );
      historiaClinicaId = await insertHistoriaClinica(nuevaHistoria);
    }

    // Crear la consulta con el ID de historia clínica
    final consultaConHistoria = consulta.copyWith(
      historiaClinicaId: historiaClinicaId.toString(),
    );

    return await insertConsulta(consultaConHistoria);
  }

  /// Obtiene estadísticas generales
  Future<Map<String, int>> getEstadisticas() async {
    final db = await database;

    final totalPacientes = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tablePacientes'),
    ) ?? 0;

    final totalConsultas = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableConsultas'),
    ) ?? 0;

    final consultasHoy = Sqflite.firstIntValue(
      await db.rawQuery('''
        SELECT COUNT(*) FROM $tableConsultas 
        WHERE date(fecha_consulta) = date('now')
      '''),
    ) ?? 0;

    final consultasPendientes = Sqflite.firstIntValue(
      await db.rawQuery('''
        SELECT COUNT(*) FROM $tableConsultas 
        WHERE estado = 'Pendiente'
      '''),
    ) ?? 0;

    final totalHistorias = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableHistoriasClinicas'),
    ) ?? 0;

    return {
      'totalPacientes': totalPacientes,
      'totalConsultas': totalConsultas,
      'consultasHoy': consultasHoy,
      'consultasPendientes': consultasPendientes,
      'totalHistorias': totalHistorias,
    };
  }

  /// Cierra la conexión a la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
