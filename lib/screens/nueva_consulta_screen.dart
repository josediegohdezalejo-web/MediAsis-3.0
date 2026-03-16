import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../database/database_helper.dart';
import 'nuevo_paciente_dialog.dart';

/// Pantalla para crear una nueva consulta médica.
/// Incluye formulario completo y selección de paciente.
class NuevaConsultaScreen extends StatefulWidget {
  final Paciente? pacientePreseleccionado;
  
  const NuevaConsultaScreen({
    super.key,
    this.pacientePreseleccionado,
  });

  @override
  State<NuevaConsultaScreen> createState() => _NuevaConsultaScreenState();
}

class _NuevaConsultaScreenState extends State<NuevaConsultaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  
  // Controladores
  final _motivoController = TextEditingController();
  final _sintomasController = TextEditingController();
  final _antecedentesController = TextEditingController();
  final _exploracionController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _cie10Controller = TextEditingController();
  final _tratamientoController = TextEditingController();
  final _medicamentosController = TextEditingController();
  final _indicacionesController = TextEditingController();
  final _pronosticoController = TextEditingController();
  final _notasController = TextEditingController();
  final _medicoController = TextEditingController();
  final _especialidadController = TextEditingController();
  
  // Estado
  Paciente? _pacienteSeleccionado;
  DateTime _fechaConsulta = DateTime.now();
  TimeOfDay _horaConsulta = TimeOfDay.now();
  String _estado = 'Pendiente';
  bool _isLoading = false;
  bool _isSearchingPaciente = false;
  List<Paciente> _pacientesEncontrados = [];

  @override
  void initState() {
    super.initState();
    if (widget.pacientePreseleccionado != null) {
      _pacienteSeleccionado = widget.pacientePreseleccionado;
    }
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _sintomasController.dispose();
    _antecedentesController.dispose();
    _exploracionController.dispose();
    _diagnosticoController.dispose();
    _cie10Controller.dispose();
    _tratamientoController.dispose();
    _medicamentosController.dispose();
    _indicacionesController.dispose();
    _pronosticoController.dispose();
    _notasController.dispose();
    _medicoController.dispose();
    _especialidadController.dispose();
    super.dispose();
  }

  Future<void> _buscarPaciente(String query) async {
    if (query.isEmpty) {
      setState(() {
        _pacientesEncontrados = [];
        _isSearchingPaciente = false;
      });
      return;
    }

    setState(() => _isSearchingPaciente = true);
    
    final pacientes = await _dbHelper.searchPacientes(query);
    
    setState(() {
      _pacientesEncontrados = pacientes;
      _isSearchingPaciente = false;
    });
  }

  Future<void> _seleccionarFechaHora() async {
    // Seleccionar fecha
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaConsulta,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );
    
    if (fecha != null) {
      setState(() => _fechaConsulta = fecha);
    }

    // Seleccionar hora
    if (!mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaConsulta,
    );
    
    if (hora != null) {
      setState(() => _horaConsulta = hora);
    }
  }

  Future<void> _guardarConsulta() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_pacienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un paciente'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fechaHoraConsulta = DateTime(
        _fechaConsulta.year,
        _fechaConsulta.month,
        _fechaConsulta.day,
        _horaConsulta.hour,
        _horaConsulta.minute,
      );

      final consulta = Consulta(
        pacienteId: _pacienteSeleccionado!.id!,
        fechaConsulta: fechaHoraConsulta,
        motivoConsulta: _motivoController.text.trim(),
        sintomas: _sintomasController.text.trim().isNotEmpty 
            ? _sintomasController.text.trim() : null,
        antecedentes: _antecedentesController.text.trim().isNotEmpty 
            ? _antecedentesController.text.trim() : null,
        exploracionFisica: _exploracionController.text.trim().isNotEmpty 
            ? _exploracionController.text.trim() : null,
        diagnostico: _diagnosticoController.text.trim().isNotEmpty 
            ? _diagnosticoController.text.trim() : null,
        diagnosticoCIE10: _cie10Controller.text.trim().isNotEmpty 
            ? _cie10Controller.text.trim() : null,
        tratamiento: _tratamientoController.text.trim().isNotEmpty 
            ? _tratamientoController.text.trim() : null,
        medicamentos: _medicamentosController.text.trim().isNotEmpty 
            ? _medicamentosController.text.trim() : null,
        indicaciones: _indicacionesController.text.trim().isNotEmpty 
            ? _indicacionesController.text.trim() : null,
        pronostico: _pronosticoController.text.trim().isNotEmpty 
            ? _pronosticoController.text.trim() : null,
        notas: _notasController.text.trim().isNotEmpty 
            ? _notasController.text.trim() : null,
        estado: _estado,
        medico: _medicoController.text.trim().isNotEmpty 
            ? _medicoController.text.trim() : null,
        especialidad: _especialidadController.text.trim().isNotEmpty 
            ? _especialidadController.text.trim() : null,
      );

      final provider = context.read<ConsultasProvider>();
      
      // Usar el método que crea historia clínica automáticamente si no existe
      final success = await provider.crearConsultaConHistoriaAutomatica(
        consulta: consulta,
        paciente: _pacienteSeleccionado!,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consulta guardada exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Error al guardar la consulta'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Consulta'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _guardarConsulta,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Guardando consulta...',
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selección de paciente
                _buildPacienteSection(),
                
                const SizedBox(height: 24),
                
                // Fecha y hora
                _buildFechaHoraSection(),
                
                const SizedBox(height: 24),
                
                // Datos de la consulta
                _buildDatosConsultaSection(),
                
                const SizedBox(height: 24),
                
                // Diagnóstico y tratamiento
                _buildDiagnosticoTratamientoSection(),
                
                const SizedBox(height: 24),
                
                // Información adicional
                _buildInformacionAdicionalSection(),
                
                const SizedBox(height: 32),
                
                // Botón guardar
                ActionButton(
                  text: 'Guardar Consulta',
                  icon: Icons.save,
                  onPressed: _guardarConsulta,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPacienteSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Paciente',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const NuevoPacienteDialog(),
                    );
                    if (result == true && mounted) {
                      // Recargar pacientes
                      await context.read<PacientesProvider>().loadPacientes();
                    }
                  },
                  icon: const Icon(Icons.person_add, size: 20),
                  label: const Text('Nuevo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (_pacienteSeleccionado != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pacienteSeleccionado!.nombreCompleto,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'CURP: ${_pacienteSeleccionado!.curp}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _pacienteSeleccionado = null);
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              TextField(
                onChanged: _buscarPaciente,
                decoration: const InputDecoration(
                  hintText: 'Buscar paciente por nombre o CURP...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              if (_isSearchingPaciente)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_pacientesEncontrados.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _pacientesEncontrados.length,
                    itemBuilder: (context, index) {
                      final paciente = _pacientesEncontrados[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppTheme.primaryBlue),
                        ),
                        title: Text(paciente.nombreCompleto),
                        subtitle: Text('CURP: ${paciente.curp}'),
                        onTap: () {
                          setState(() {
                            _pacienteSeleccionado = paciente;
                            _pacientesEncontrados = [];
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFechaHoraSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fecha y Hora',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _seleccionarFechaHora,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                          const SizedBox(width: 12),
                          Text(
                            _formatFecha(_fechaConsulta),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _seleccionarFechaHora,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppTheme.primaryBlue),
                          const SizedBox(width: 12),
                          Text(
                            _horaConsulta.format(context),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomDropdown<String>(
              label: 'Estado',
              value: _estado,
              items: const [
                DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                DropdownMenuItem(value: 'En curso', child: Text('En curso')),
                DropdownMenuItem(value: 'Completada', child: Text('Completada')),
                DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _estado = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatosConsultaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos de la Consulta',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Motivo de Consulta *',
              hint: 'Describa el motivo principal de la consulta',
              controller: _motivoController,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El motivo de consulta es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Síntomas',
              hint: 'Describa los síntomas del paciente',
              controller: _sintomasController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Antecedentes',
              hint: 'Antecedentes relevantes para esta consulta',
              controller: _antecedentesController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Exploración Física',
              hint: 'Hallazgos de la exploración física',
              controller: _exploracionController,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticoTratamientoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diagnóstico y Tratamiento',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Diagnóstico',
              hint: 'Diagnóstico clínico',
              controller: _diagnosticoController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Código CIE-10',
              hint: 'Código de clasificación internacional',
              controller: _cie10Controller,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Tratamiento',
              hint: 'Plan de tratamiento',
              controller: _tratamientoController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Medicamentos',
              hint: 'Medicamentos prescritos',
              controller: _medicamentosController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Indicaciones',
              hint: 'Indicaciones para el paciente',
              controller: _indicacionesController,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionAdicionalSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Adicional',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Pronóstico',
              hint: 'Pronóstico del paciente',
              controller: _pronosticoController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Notas',
              hint: 'Notas adicionales',
              controller: _notasController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Médico',
                    hint: 'Nombre del médico',
                    controller: _medicoController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Especialidad',
                    hint: 'Especialidad médica',
                    controller: _especialidadController,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}
