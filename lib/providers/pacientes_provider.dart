import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

/// Provider para la gestión del estado de pacientes en MediAsis.
/// Maneja todas las operaciones CRUD y mantiene el estado sincronizado.
class PacientesProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Paciente> _pacientes = [];
  Paciente? _pacienteSeleccionado;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Paciente> get pacientes => _pacientes;
  Paciente? get pacienteSeleccionado => _pacienteSeleccionado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga todos los pacientes desde la base de datos
  Future<void> loadPacientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pacientes = await _dbHelper.getAllPacientes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca pacientes por nombre o CURP
  Future<List<Paciente>> searchPacientes(String query) async {
    if (query.isEmpty) {
      return _pacientes;
    }
    return await _dbHelper.searchPacientes(query);
  }

  /// Obtiene un paciente por su ID
  Future<Paciente?> getPacienteById(int id) async {
    return await _dbHelper.getPacienteById(id);
  }

  /// Obtiene un paciente por su CURP
  Future<Paciente?> getPacienteByCurp(String curp) async {
    return await _dbHelper.getPacienteByCurp(curp);
  }

  /// Selecciona un paciente
  void seleccionarPaciente(Paciente? paciente) {
    _pacienteSeleccionado = paciente;
    notifyListeners();
  }

  /// Agrega un nuevo paciente
  Future<bool> addPaciente(Paciente paciente) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Verificar si ya existe un paciente con el mismo CURP
      final existente = await _dbHelper.getPacienteByCurp(paciente.curp);
      if (existente != null) {
        _error = 'Ya existe un paciente con el CURP ${paciente.curp}';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final id = await _dbHelper.insertPaciente(paciente);
      final nuevoPaciente = paciente.copyWith(id: id.toString());
      _pacientes.add(nuevoPaciente);
      _pacientes.sort((a, b) => 
        '${a.apellidoPaterno} ${a.apellidoMaterno} ${a.nombre}'
        .compareTo('${b.apellidoPaterno} ${b.apellidoMaterno} ${b.nombre}'));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualiza un paciente existente
  Future<bool> updatePaciente(Paciente paciente) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.updatePaciente(paciente);
      final index = _pacientes.indexWhere((p) => p.id == paciente.id);
      if (index != -1) {
        _pacientes[index] = paciente;
        _pacientes.sort((a, b) => 
          '${a.apellidoPaterno} ${a.apellidoMaterno} ${a.nombre}'
          .compareTo('${b.apellidoPaterno} ${b.apellidoMaterno} ${b.nombre}'));
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina un paciente
  Future<bool> deletePaciente(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.deletePaciente(id);
      _pacientes.removeWhere((p) => p.id == id.toString());
      if (_pacienteSeleccionado?.id == id.toString()) {
        _pacienteSeleccionado = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
