import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

/// Provider para la gestión del estado de historias clínicas en MediAsis.
/// Maneja todas las operaciones CRUD y mantiene el estado sincronizado.
class HistoriasProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<HistoriaClinica> _historias = [];
  HistoriaClinica? _historiaSeleccionada;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<HistoriaClinica> get historias => _historias;
  HistoriaClinica? get historiaSeleccionada => _historiaSeleccionada;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga todas las historias clínicas desde la base de datos
  Future<void> loadHistorias() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _historias = await _dbHelper.getAllHistoriasClinicas();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene la historia clínica de un paciente
  Future<HistoriaClinica?> getHistoriaByPaciente(int pacienteId) async {
    return await _dbHelper.getHistoriaClinicaByPaciente(pacienteId);
  }

  /// Verifica si un paciente tiene historia clínica
  Future<bool> pacienteTieneHistoria(int pacienteId) async {
    return await _dbHelper.pacienteTieneHistoriaClinica(pacienteId);
  }

  /// Selecciona una historia clínica
  void seleccionarHistoria(HistoriaClinica? historia) {
    _historiaSeleccionada = historia;
    notifyListeners();
  }

  /// Agrega una nueva historia clínica
  Future<bool> addHistoria(HistoriaClinica historia) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Verificar si el paciente ya tiene historia
      final yaTiene = await _dbHelper.pacienteTieneHistoriaClinica(
        int.parse(historia.pacienteId),
      );
      if (yaTiene) {
        _error = 'El paciente ya tiene una historia clínica registrada';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final id = await _dbHelper.insertHistoriaClinica(historia);
      final nuevaHistoria = historia.copyWith(id: id.toString());
      _historias.insert(0, nuevaHistoria);
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

  /// Actualiza una historia clínica existente
  Future<bool> updateHistoria(HistoriaClinica historia) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.updateHistoriaClinica(historia);
      final index = _historias.indexWhere((h) => h.id == historia.id);
      if (index != -1) {
        _historias[index] = historia;
      }
      
      if (_historiaSeleccionada?.id == historia.id) {
        _historiaSeleccionada = historia;
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

  /// Elimina una historia clínica
  Future<bool> deleteHistoria(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.deleteHistoriaClinica(id);
      _historias.removeWhere((h) => h.id == id.toString());
      
      if (_historiaSeleccionada?.id == id.toString()) {
        _historiaSeleccionada = null;
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

  // ==================== GESTIÓN DE EVOLUCIONES ====================

  /// Agrega una evolución a una historia clínica
  Future<bool> addEvolucion(Evolucion evolucion) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _dbHelper.insertEvolucion(evolucion);
      final nuevaEvolucion = evolucion.copyWith(id: id.toString());
      
      // Actualizar la historia seleccionada
      if (_historiaSeleccionada?.id == evolucion.historiaClinicaId) {
        final evolucionesActualizadas = [
          nuevaEvolucion,
          ...?_historiaSeleccionada?.evoluciones,
        ];
        _historiaSeleccionada = _historiaSeleccionada?.copyWith(
          evoluciones: evolucionesActualizadas,
        );
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

  /// Actualiza una evolución
  Future<bool> updateEvolucion(Evolucion evolucion) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.updateEvolucion(evolucion);
      
      // Actualizar la historia seleccionada
      if (_historiaSeleccionada?.id == evolucion.historiaClinicaId) {
        final evolucionesActualizadas = _historiaSeleccionada?.evoluciones?.map((e) {
          return e.id == evolucion.id ? evolucion : e;
        }).toList();
        
        _historiaSeleccionada = _historiaSeleccionada?.copyWith(
          evoluciones: evolucionesActualizadas,
        );
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

  /// Elimina una evolución
  Future<bool> deleteEvolucion(int evolucionId, String historiaClinicaId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.deleteEvolucion(evolucionId);
      
      // Actualizar la historia seleccionada
      if (_historiaSeleccionada?.id == historiaClinicaId) {
        final evolucionesActualizadas = _historiaSeleccionada?.evoluciones
            ?.where((e) => e.id != evolucionId.toString())
            .toList();
        
        _historiaSeleccionada = _historiaSeleccionada?.copyWith(
          evoluciones: evolucionesActualizadas,
        );
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

  /// Obtiene las evoluciones de una historia clínica
  Future<List<Evolucion>> getEvoluciones(int historiaClinicaId) async {
    return await _dbHelper.getEvolucionesByHistoriaClinica(historiaClinicaId);
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
