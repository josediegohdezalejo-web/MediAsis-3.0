import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Diálogo para crear un nuevo paciente.
class NuevoPacienteDialog extends StatefulWidget {
  const NuevoPacienteDialog({super.key});

  @override
  State<NuevoPacienteDialog> createState() => _NuevoPacienteDialogState();
}

class _NuevoPacienteDialogState extends State<NuevoPacienteDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _nombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _curpController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _contactoEmergenciaController = TextEditingController();
  final _telefonoEmergenciaController = TextEditingController();
  final _alergiasController = TextEditingController();
  
  DateTime _fechaNacimiento = DateTime.now().subtract(const Duration(days: 365 * 25));
  String _genero = 'Masculino';
  String? _tipoSanguineo;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _curpController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _contactoEmergenciaController.dispose();
    _telefonoEmergenciaController.dispose();
    _alergiasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    
    if (fecha != null) {
      setState(() => _fechaNacimiento = fecha);
    }
  }

  Future<void> _guardarPaciente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final paciente = Paciente(
        nombre: _nombreController.text.trim().toUpperCase(),
        apellidoPaterno: _apellidoPaternoController.text.trim().toUpperCase(),
        apellidoMaterno: _apellidoMaternoController.text.trim().toUpperCase(),
        fechaNacimiento: _fechaNacimiento,
        genero: _genero,
        curp: _curpController.text.trim().toUpperCase(),
        telefono: _telefonoController.text.trim(),
        email: _emailController.text.trim().isNotEmpty 
            ? _emailController.text.trim() : null,
        direccion: _direccionController.text.trim(),
        contactoEmergencia: _contactoEmergenciaController.text.trim().isNotEmpty 
            ? _contactoEmergenciaController.text.trim() : null,
        telefonoEmergencia: _telefonoEmergenciaController.text.trim().isNotEmpty 
            ? _telefonoEmergenciaController.text.trim() : null,
        alergias: _alergiasController.text.trim().isNotEmpty 
            ? _alergiasController.text.trim() : null,
        tipoSanguineo: _tipoSanguineo,
      );

      final success = await context.read<PacientesProvider>().addPaciente(paciente);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
      } else {
        final error = context.read<PacientesProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al guardar el paciente'),
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuevo Paciente',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Complete los datos del paciente',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nombre
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Nombre *',
                              hint: 'Nombre(s)',
                              controller: _nombreController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Apellidos
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Apellido Paterno *',
                              controller: _apellidoPaternoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Apellido Materno *',
                              controller: _apellidoMaternoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // CURP
                      CustomTextField(
                        label: 'CURP *',
                        controller: _curpController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El CURP es requerido';
                          }
                          if (value.length != 18) {
                            return 'El CURP debe tener 18 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Género y fecha de nacimiento
                      Row(
                        children: [
                          Expanded(
                            child: CustomDropdown<String>(
                              label: 'Género *',
                              value: _genero,
                              items: const [
                                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _genero = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _seleccionarFechaNacimiento,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de Nacimiento',
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatFecha(_fechaNacimiento),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const Icon(Icons.calendar_today, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Teléfono
                      CustomTextField(
                        label: 'Teléfono *',
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Email
                      CustomTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      
                      // Dirección
                      CustomTextField(
                        label: 'Dirección *',
                        controller: _direccionController,
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Tipo sanguíneo
                      CustomDropdown<String>(
                        label: 'Tipo Sanguíneo',
                        value: _tipoSanguineo,
                        items: const [
                          DropdownMenuItem(value: 'A+', child: Text('A+')),
                          DropdownMenuItem(value: 'A-', child: Text('A-')),
                          DropdownMenuItem(value: 'B+', child: Text('B+')),
                          DropdownMenuItem(value: 'B-', child: Text('B-')),
                          DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                          DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                          DropdownMenuItem(value: 'O+', child: Text('O+')),
                          DropdownMenuItem(value: 'O-', child: Text('O-')),
                        ],
                        onChanged: (value) {
                          setState(() => _tipoSanguineo = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Alergias
                      CustomTextField(
                        label: 'Alergias',
                        controller: _alergiasController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      
                      // Contacto de emergencia
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Contacto Emergencia',
                              controller: _contactoEmergenciaController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Tel. Emergencia',
                              controller: _telefonoEmergenciaController,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading 
                                  ? null 
                                  : () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _guardarPaciente,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
