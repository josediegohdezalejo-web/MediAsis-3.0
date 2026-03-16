import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../database/database_helper.dart';
import 'nueva_evolucion_screen.dart';

/// Pantalla de detalle de una historia clínica.
/// Permite ver todos los datos y evoluciones, además de editar.
class DetalleHistoriaScreen extends StatefulWidget {
  final HistoriaClinica historia;
  final bool isEditing;

  const DetalleHistoriaScreen({
    super.key,
    required this.historia,
    this.isEditing = false,
  });

  @override
  State<DetalleHistoriaScreen> createState() => _DetalleHistoriaScreenState();
}

class _DetalleHistoriaScreenState extends State<DetalleHistoriaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  
  Paciente? _paciente;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Controladores para edición
  late TextEditingController _antHeredofamiliaresController;
  late TextEditingController _antPersonalesController;
  late TextEditingController _antQuirurgicosController;
  late TextEditingController _antAlergicosController;
  late TextEditingController _antTraumaticosController;
  late TextEditingController _antTransfusionalesController;
  late TextEditingController _antGinecobstetricosController;
  late TextEditingController _habitosController;
  late TextEditingController _inmunizacionesController;
  late TextEditingController _medicamentosActualesController;
  late TextEditingController _notasController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _isEditing = widget.isEditing;
    
    // Inicializar controladores
    _antHeredofamiliaresController = TextEditingController(
      text: widget.historia.antecedentesHeredofamiliares ?? '',
    );
    _antPersonalesController = TextEditingController(
      text: widget.historia.antecedentesPersonales ?? '',
    );
    _antQuirurgicosController = TextEditingController(
      text: widget.historia.antecedentesQuirurgicos ?? '',
    );
    _antAlergicosController = TextEditingController(
      text: widget.historia.antecedentesAlergicos ?? '',
    );
    _antTraumaticosController = TextEditingController(
      text: widget.historia.antecedentesTraumaticos ?? '',
    );
    _antTransfusionalesController = TextEditingController(
      text: widget.historia.antecedentesTransfusionales ?? '',
    );
    _antGinecobstetricosController = TextEditingController(
      text: widget.historia.antecedentesGinecobstetricos ?? '',
    );
    _habitosController = TextEditingController(
      text: widget.historia.habitos ?? '',
    );
    _inmunizacionesController = TextEditingController(
      text: widget.historia.inmunizaciones ?? '',
    );
    _medicamentosActualesController = TextEditingController(
      text: widget.historia.medicamentosActuales ?? '',
    );
    _notasController = TextEditingController(
      text: widget.historia.notasGenerales ?? '',
    );
    
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _antHeredofamiliaresController.dispose();
    _antPersonalesController.dispose();
    _antQuirurgicosController.dispose();
    _antAlergicosController.dispose();
    _antTraumaticosController.dispose();
    _antTransfusionalesController.dispose();
    _antGinecobstetricosController.dispose();
    _habitosController.dispose();
    _inmunizacionesController.dispose();
    _medicamentosActualesController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _paciente = await _dbHelper.getPacienteById(
      int.parse(widget.historia.pacienteId),
    );
    setState(() => _isLoading = false);
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final historiaActualizada = widget.historia.copyWith(
      antecedentesHeredofamiliares: _antHeredofamiliaresController.text.trim().isNotEmpty
          ? _antHeredofamiliaresController.text.trim() : null,
      antecedentesPersonales: _antPersonalesController.text.trim().isNotEmpty
          ? _antPersonalesController.text.trim() : null,
      antecedentesQuirurgicos: _antQuirurgicosController.text.trim().isNotEmpty
          ? _antQuirurgicosController.text.trim() : null,
      antecedentesAlergicos: _antAlergicosController.text.trim().isNotEmpty
          ? _antAlergicosController.text.trim() : null,
      antecedentesTraumaticos: _antTraumaticosController.text.trim().isNotEmpty
          ? _antTraumaticosController.text.trim() : null,
      antecedentesTransfusionales: _antTransfusionalesController.text.trim().isNotEmpty
          ? _antTransfusionalesController.text.trim() : null,
      antecedentesGinecobstetricos: _antGinecobstetricosController.text.trim().isNotEmpty
          ? _antGinecobstetricosController.text.trim() : null,
      habitos: _habitosController.text.trim().isNotEmpty
          ? _habitosController.text.trim() : null,
      inmunizaciones: _inmunizacionesController.text.trim().isNotEmpty
          ? _inmunizacionesController.text.trim() : null,
      medicamentosActuales: _medicamentosActualesController.text.trim().isNotEmpty
          ? _medicamentosActualesController.text.trim() : null,
      notasGenerales: _notasController.text.trim().isNotEmpty
          ? _notasController.text.trim() : null,
    );

    final success = await context.read<HistoriasProvider>().updateHistoria(historiaActualizada);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Historia clínica actualizada'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Historia' : 'Historia Clínica'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
          if (_isEditing)
            TextButton.icon(
              onPressed: _guardarCambios,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Antecedentes'),
            Tab(text: 'Evoluciones'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAntecedentesTab(),
                _buildEvolucionesTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 1 && !_isEditing
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NuevaEvolucionScreen(
                      historiaClinicaId: widget.historia.id!,
                    ),
                  ),
                );
                // Recargar historia
                context.read<HistoriasProvider>().loadHistorias();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva Evolución'),
            )
          : null,
    );
  }

  Widget _buildAntecedentesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del paciente
            _buildPacienteHeader(),
            
            const SizedBox(height: 24),
            
            // Antecedentes
            if (_isEditing) ...[
              _buildEditableSection(),
            ] else ...[
              _buildViewSection(),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPacienteHeader() {
    if (_paciente == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.historia.numeroExpediente,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableSection() {
    return Column(
      children: [
        _buildEditableCard(
          'Antecedentes Heredofamiliares',
          _antHeredofamiliaresController,
          Icons.family_restroom,
        ),
        _buildEditableCard(
          'Antecedentes Personales Patológicos',
          _antPersonalesController,
          Icons.person_outline,
        ),
        _buildEditableCard(
          'Antecedentes Quirúrgicos',
          _antQuirurgicosController,
          Icons.healing,
        ),
        _buildEditableCard(
          'Antecedentes Alérgicos',
          _antAlergicosController,
          Icons.warning_amber,
          isAlert: true,
        ),
        _buildEditableCard(
          'Antecedentes Traumáticos',
          _antTraumaticosController,
          Icons.local_hospital,
        ),
        _buildEditableCard(
          'Antecedentes Transfusionales',
          _antTransfusionalesController,
          Icons.bloodtype,
        ),
        if (_paciente?.genero == 'Femenino')
          _buildEditableCard(
            'Antecedentes Ginecobstétricos',
            _antGinecobstetricosController,
            Icons.pregnant_woman,
          ),
        _buildEditableCard(
          'Hábitos',
          _habitosController,
          Icons.smoke_free,
        ),
        _buildEditableCard(
          'Inmunizaciones',
          _inmunizacionesController,
          Icons.vaccines,
        ),
        _buildEditableCard(
          'Medicamentos Actuales',
          _medicamentosActualesController,
          Icons.medication,
        ),
        _buildEditableCard(
          'Notas Generales',
          _notasController,
          Icons.notes,
        ),
      ],
    );
  }

  Widget _buildEditableCard(
    String title,
    TextEditingController controller,
    IconData icon, {
    bool isAlert = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isAlert ? AppTheme.errorColor : AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isAlert ? AppTheme.errorColor : AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ingrese $title...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSection() {
    return Column(
      children: [
        _buildViewCard(
          'Antecedentes Heredofamiliares',
          widget.historia.antecedentesHeredofamiliares,
          Icons.family_restroom,
        ),
        _buildViewCard(
          'Antecedentes Personales Patológicos',
          widget.historia.antecedentesPersonales,
          Icons.person_outline,
        ),
        _buildViewCard(
          'Antecedentes Quirúrgicos',
          widget.historia.antecedentesQuirurgicos,
          Icons.healing,
        ),
        _buildViewCard(
          'Antecedentes Alérgicos',
          widget.historia.antecedentesAlergicos,
          Icons.warning_amber,
          isAlert: true,
        ),
        _buildViewCard(
          'Antecedentes Traumáticos',
          widget.historia.antecedentesTraumaticos,
          Icons.local_hospital,
        ),
        _buildViewCard(
          'Antecedentes Transfusionales',
          widget.historia.antecedentesTransfusionales,
          Icons.bloodtype,
        ),
        if (_paciente?.genero == 'Femenino')
          _buildViewCard(
            'Antecedentes Ginecobstétricos',
            widget.historia.antecedentesGinecobstetricos,
            Icons.pregnant_woman,
          ),
        _buildViewCard(
          'Hábitos',
          widget.historia.habitos,
          Icons.smoke_free,
        ),
        _buildViewCard(
          'Inmunizaciones',
          widget.historia.inmunizaciones,
          Icons.vaccines,
        ),
        _buildViewCard(
          'Medicamentos Actuales',
          widget.historia.medicamentosActuales,
          Icons.medication,
        ),
        _buildViewCard(
          'Notas Generales',
          widget.historia.notasGenerales,
          Icons.notes,
        ),
      ],
    );
  }

  Widget _buildViewCard(String title, String? content, IconData icon, {bool isAlert = false}) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isAlert ? AppTheme.errorColor : AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isAlert ? AppTheme.errorColor : AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildEvolucionesTab() {
    final evoluciones = widget.historia.evoluciones ?? [];

    if (evoluciones.isEmpty) {
      return EmptyState(
        icon: Icons.note_add,
        title: 'No hay evoluciones',
        message: 'Añada evoluciones médicas para llevar el seguimiento del paciente',
        actionText: 'Nueva Evolución',
        onAction: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NuevaEvolucionScreen(
                historiaClinicaId: widget.historia.id!,
              ),
            ),
          );
          context.read<HistoriasProvider>().loadHistorias();
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: evoluciones.length,
      itemBuilder: (context, index) {
        final evolucion = evoluciones[index];
        return _EvolucionCard(
          evolucion: evolucion,
          onDelete: () async {
            final confirm = await ConfirmDialog.show(
              context: context,
              title: 'Eliminar Evolución',
              message: '¿Está seguro de que desea eliminar esta evolución?',
              confirmText: 'Eliminar',
              confirmColor: AppTheme.errorColor,
            );
            if (confirm == true) {
              await context.read<HistoriasProvider>().deleteEvolucion(
                int.parse(evolucion.id!),
                widget.historia.id!,
              );
            }
          },
        );
      },
    );
  }
}

class _EvolucionCard extends StatelessWidget {
  final Evolucion evolucion;
  final VoidCallback? onDelete;

  const _EvolucionCard({
    required this.evolucion,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color tipoColor;
    IconData tipoIcon;
    
    switch (evolucion.tipo) {
      case TipoEvolucion.comentario:
        tipoColor = AppTheme.primaryTeal;
        tipoIcon = Icons.comment;
        break;
      case TipoEvolucion.procedimiento:
        tipoColor = AppTheme.warningColor;
        tipoIcon = Icons.medical_services;
        break;
      case TipoEvolucion.interconsulta:
        tipoColor = AppTheme.enCursoColor;
        tipoIcon = Icons.people;
        break;
      default:
        tipoColor = AppTheme.primaryBlue;
        tipoIcon = Icons.assignment;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tipoColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tipoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(tipoIcon, color: tipoColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evolucion.titulo,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${evolucion.fechaFormateada} - ${evolucion.horaFormateada}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tipoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    evolucion.tipoNombre,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tipoColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              evolucion.descripcion,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            if (evolucion.diagnostico != null && evolucion.diagnostico!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_turned_in, size: 16, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dx: ${evolucion.diagnostico}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (evolucion.medico != null) ...[
              const SizedBox(height: 8),
              Text(
                'Dr(a). ${evolucion.medico}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorColor),
                  label: const Text(
                    'Eliminar',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
