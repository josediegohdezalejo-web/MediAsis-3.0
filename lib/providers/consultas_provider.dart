import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

/// Provider para la gestión del estado de consultas médicas en MediAsis.
/// Maneja todas las operaciones CRUD y mantiene el estado sincronizado.
class ConsultasProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Consulta> _consultas = [];
  List<Consulta> _consultasHoy = [];
  List<Consulta> _consultasPendientes = [];
  Consulta? _consultaSeleccionada;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Consulta> get consultas => _consultas;
  List<Consulta> get consultasHoy => _consultasHoy;
  List<Consulta> get consultasPendientes => _consultasPendientes;
  Consulta? get consultaSeleccionada => _consultaSeleccionada;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga todas las consultas desde la base de datos
  Future<void> loadConsultas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _consultas = await _dbHelper.getAllConsultas();
      _consultasHoy = await _dbHelper.getConsultasHoy();
      _consultasPendientes = await _dbHelper.getConsultasPendientes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga las consultas de hoy
  Future<void> loadConsultasHoy() async {
    try {
      _consultasHoy = await _dbHelper.getConsultasHoy();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Carga las consultas pendientes
  Future<void> loadConsultasPendientes() async {
    try {
      _consultasPendientes = await _dbHelper.getConsultasPendientes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Obtiene las consultas de un paciente específico
  Future<List<Consulta>> getConsultasByPaciente(int pacienteId) async {
    return await _dbHelper.getConsultasByPaciente(pacienteId);
  }

  /// Selecciona una consulta
  void seleccionarConsulta(Consulta? consulta) {
    _consultaSeleccionada = consulta;
    notifyListeners();
  }

  /// Agrega una nueva consulta
  Future<bool> addConsulta(Consulta consulta) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _dbHelper.insertConsulta(consulta);
      final nuevaConsulta = consulta.copyWith(id: id.toString());
      _consultas.insert(0, nuevaConsulta);
      
      // Actualizar listas específicas
      if (nuevaConsulta.esHoy) {
        _consultasHoy.add(nuevaConsulta);
      }
      if (nuevaConsulta.estaPendiente) {
        _consultasPendientes.add(nuevaConsulta);
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

  /// Crea una consulta con creación automática de historia clínica
  Future<bool> crearConsultaConHistoriaAutomatica({
    required Consulta consulta,
    required Paciente paciente,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _dbHelper.crearConsultaConHistoriaAutomatica(
        consulta: consulta,
        paciente: paciente,
      );
      
      // Recargar datos
      await loadConsultas();
      
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

  /// Actualiza una consulta existente
  Future<bool> updateConsulta(Consulta consulta) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.updateConsulta(consulta);
      final index = _consultas.indexWhere((c) => c.id == consulta.id);
      if (index != -1) {
        _consultas[index] = consulta;
      }
      
      // Actualizar listas específicas
      _consultasHoy = await _dbHelper.getConsultasHoy();
      _consultasPendientes = await _dbHelper.getConsultasPendientes();
      
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

  /// Actualiza el estado de una consulta
  Future<bool> actualizarEstadoConsulta(int consultaId, String nuevoEstado) async {
    try {
      final consulta = await _dbHelper.getConsultaById(consultaId);
      if (consulta == null) return false;

      final consultaActualizada = consulta.copyWith(estado: nuevoEstado);
      await _dbHelper.updateConsulta(consultaActualizada);
      
      // Actualizar listas
      await loadConsultas();
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Elimina una consulta
  Future<bool> deleteConsulta(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.deleteConsulta(id);
      _consultas.removeWhere((c) => c.id == id.toString());
      _consultasHoy.removeWhere((c) => c.id == id.toString());
      _consultasPendientes.removeWhere((c) => c.id == id.toString());
      
      if (_consultaSeleccionada?.id == id.toString()) {
        _consultaSeleccionada = null;
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
