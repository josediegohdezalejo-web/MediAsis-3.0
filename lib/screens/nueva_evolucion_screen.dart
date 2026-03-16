import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Pantalla para crear una nueva evolución o comentario médico.
class NuevaEvolucionScreen extends StatefulWidget {
  final String historiaClinicaId;

  const NuevaEvolucionScreen({
    super.key,
    required this.historiaClinicaId,
  });

  @override
  State<NuevaEvolucionScreen> createState() => _NuevaEvolucionScreenState();
}

class _NuevaEvolucionScreenState extends State<NuevaEvolucionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _tratamientoController = TextEditingController();
  final _medicoController = TextEditingController();
  
  TipoEvolucion _tipo = TipoEvolucion.evolucion;
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _diagnosticoController.dispose();
    _tratamientoController.dispose();
    _medicoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final evolucion = Evolucion(
        historiaClinicaId: widget.historiaClinicaId,
        tipo: _tipo,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        diagnostico: _diagnosticoController.text.trim().isNotEmpty
            ? _diagnosticoController.text.trim() : null,
        tratamiento: _tratamientoController.text.trim().isNotEmpty
            ? _tratamientoController.text.trim() : null,
        medico: _medicoController.text.trim().isNotEmpty
            ? _medicoController.text.trim() : null,
      );

      final success = await context.read<HistoriasProvider>().addEvolucion(evolucion);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evolución guardada exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la evolución'),
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
        title: const Text('Nueva Evolución'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _guardar,
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
        message: 'Guardando...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo de evolución
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipo de Registro',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: TipoEvolucion.values.map((tipo) {
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getIconForTipo(tipo),
                                    size: 16,
                                    color: _tipo == tipo 
                                        ? Colors.white 
                                        : _getColorForTipo(tipo),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(_getNombreForTipo(tipo)),
                                ],
                              ),
                              selected: _tipo == tipo,
                              selectedColor: _getColorForTipo(tipo),
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: _tipo == tipo ? Colors.white : null,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _tipo = tipo);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Título
                CustomTextField(
                  label: 'Título *',
                  hint: _getHintForTipo(_tipo),
                  controller: _tituloController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El título es requerido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Descripción
                CustomTextField(
                  label: 'Descripción *',
                  hint: 'Describa detalladamente...',
                  controller: _descripcionController,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Diagnóstico y tratamiento (solo para evoluciones)
                if (_tipo == TipoEvolucion.evolucion) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información Médica (Opcional)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Diagnóstico',
                            hint: 'Diagnóstico de esta evolución',
                            controller: _diagnosticoController,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Tratamiento',
                            hint: 'Tratamiento indicado',
                            controller: _tratamientoController,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Médico
                CustomTextField(
                  label: 'Médico',
                  hint: 'Nombre del médico que registra',
                  controller: _medicoController,
                ),

                const SizedBox(height: 32),

                // Botón guardar
                ActionButton(
                  text: 'Guardar Evolución',
                  icon: Icons.save,
                  onPressed: _guardar,
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

  IconData _getIconForTipo(TipoEvolucion tipo) {
    switch (tipo) {
      case TipoEvolucion.evolucion:
        return Icons.assignment;
      case TipoEvolucion.comentario:
        return Icons.comment;
      case TipoEvolucion.procedimiento:
        return Icons.medical_services;
      case TipoEvolucion.interconsulta:
        return Icons.people;
    }
  }

  Color _getColorForTipo(TipoEvolucion tipo) {
    switch (tipo) {
      case TipoEvolucion.evolucion:
        return AppTheme.primaryBlue;
      case TipoEvolucion.comentario:
        return AppTheme.primaryTeal;
      case TipoEvolucion.procedimiento:
        return AppTheme.warningColor;
      case TipoEvolucion.interconsulta:
        return AppTheme.enCursoColor;
    }
  }

  String _getNombreForTipo(TipoEvolucion tipo) {
    switch (tipo) {
      case TipoEvolucion.evolucion:
        return 'Evolución';
      case TipoEvolucion.comentario:
        return 'Comentario';
      case TipoEvolucion.procedimiento:
        return 'Procedimiento';
      case TipoEvolucion.interconsulta:
        return 'Interconsulta';
    }
  }

  String _getHintForTipo(TipoEvolucion tipo) {
    switch (tipo) {
      case TipoEvolucion.evolucion:
        return 'Ej: Control de hipertensión arterial';
      case TipoEvolucion.comentario:
        return 'Ej: Comentario sobre evolución del paciente';
      case TipoEvolucion.procedimiento:
        return 'Ej: Curación de herida quirúrgica';
      case TipoEvolucion.interconsulta:
        return 'Ej: Solicitud de interconsulta a Cardiología';
    }
  }
}
