import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';

/// Pantalla de detalle de una consulta médica.
class DetalleConsultaScreen extends StatefulWidget {
  final Consulta consulta;

  const DetalleConsultaScreen({
    super.key,
    required this.consulta,
  });

  @override
  State<DetalleConsultaScreen> createState() => _DetalleConsultaScreenState();
}

class _DetalleConsultaScreenState extends State<DetalleConsultaScreen> {
  final _dbHelper = DatabaseHelper();
  Paciente? _paciente;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.consulta.pacienteId.isNotEmpty) {
      _paciente = await _dbHelper.getPacienteById(
        int.parse(widget.consulta.pacienteId),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Consulta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Editar consulta
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Compartir/exportar
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header con estado
                  _buildHeader(),
                  
                  // Información del paciente
                  _buildPacienteInfo(),
                  
                  // Datos de la consulta
                  _buildConsultaData(),
                  
                  // Diagnóstico y tratamiento
                  _buildDiagnosticoTratamiento(),
                  
                  // Información adicional
                  if (_hasAdditionalInfo()) _buildAdditionalInfo(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.consulta.estado.consultaStatusColor.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.consulta.estado.consultaStatusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.consulta.estado,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.consulta.fechaFormateada} - ${widget.consulta.horaFormateada}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacienteInfo() {
    if (_paciente == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Paciente',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryBlue,
                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _paciente!.nombreCompleto,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Edad: ${_paciente!.edad} años | ${_paciente!.genero}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('CURP', _paciente!.curp),
            _buildInfoRow('Teléfono', _paciente!.telefono),
            if (_paciente!.tipoSanguineo != null)
              _buildInfoRow('Tipo Sanguíneo', _paciente!.tipoSanguineo!),
            if (_paciente!.alergias != null && _paciente!.alergias!.isNotEmpty)
              _buildInfoRow('Alergias', _paciente!.alergias!, isAlert: true),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultaData() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            
            _buildSectionItem(
              icon: Icons.assignment,
              title: 'Motivo de Consulta',
              content: widget.consulta.motivoConsulta,
              color: AppTheme.primaryBlue,
            ),
            
            if (widget.consulta.sintomas != null && widget.consulta.sintomas!.isNotEmpty)
              _buildSectionItem(
                icon: Icons.healing,
                title: 'Síntomas',
                content: widget.consulta.sintomas!,
                color: AppTheme.primaryTeal,
              ),
            
            if (widget.consulta.antecedentes != null && widget.consulta.antecedentes!.isNotEmpty)
              _buildSectionItem(
                icon: Icons.history,
                title: 'Antecedentes',
                content: widget.consulta.antecedentes!,
                color: AppTheme.textSecondary,
              ),
            
            if (widget.consulta.exploracionFisica != null && widget.consulta.exploracionFisica!.isNotEmpty)
              _buildSectionItem(
                icon: Icons.accessibility,
                title: 'Exploración Física',
                content: widget.consulta.exploracionFisica!,
                color: AppTheme.accentGreen,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticoTratamiento() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            
            if (widget.consulta.diagnostico != null && widget.consulta.diagnostico!.isNotEmpty)
              _buildSectionItem(
                icon: Icons.assignment_turned_in,
                title: 'Diagnóstico',
                content: widget.consulta.diagnostico!,
                color: AppTheme.primaryBlue,
                showCie10: widget.consulta.diagnosticoCIE10,
              ),
            
            if (widget.consulta.tratamiento != null && widget.consulta.tratamiento!.isNotEmpty)
              _buildSectionItem(
                icon: Icons.local_hospital,
                title: 'Tratamiento',
                content: widget.consulta.tratamiento!,
                color: AppTheme.primaryTeal,
              ),
            
            if (widget.consulta.medicamentos != null && widget.consulta.medicamentos!.isNotEmpty)
              _buildSectionItem(
                icon: Icons.medication,
                title: 'Medicamentos',
                content: widget.consulta.medicamentos!,
                color: AppTheme.successColor,
              ),
            
            if (widget.consulta.indicaciones != null && widget.consulta.indicaciones!.isNotEmpty)
              _buildSectionItem(
                icon: Icons.info,
                title: 'Indicaciones',
                content: widget.consulta.indicaciones!,
                color: AppTheme.warningColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            
            if (widget.consulta.pronostico != null && widget.consulta.pronostico!.isNotEmpty)
              _buildInfoRow('Pronóstico', widget.consulta.pronostico!),
            
            if (widget.consulta.medico != null)
              _buildInfoRow('Médico', widget.consulta.medico!),
            
            if (widget.consulta.especialidad != null)
              _buildInfoRow('Especialidad', widget.consulta.especialidad!),
            
            if (widget.consulta.notas != null && widget.consulta.notas!.isNotEmpty)
              _buildInfoRow('Notas', widget.consulta.notas!),
            
            if (widget.consulta.proximaCita != null)
              _buildInfoRow('Próxima Cita', widget.consulta.proximaCita!),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionItem({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    String? showCie10,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (showCie10 != null && showCie10.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    showCie10,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isAlert ? AppTheme.errorColor : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAdditionalInfo() {
    return widget.consulta.pronostico != null ||
        widget.consulta.medico != null ||
        widget.consulta.especialidad != null ||
        widget.consulta.notas != null ||
        widget.consulta.proximaCita != null;
  }
}
