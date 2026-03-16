import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../database/database_helper.dart';
import 'detalle_historia_screen.dart';
import 'nueva_evolucion_screen.dart';

/// Pantalla de gestión de historias clínicas.
/// Permite ver, buscar, editar y eliminar historias clínicas.
class HistoriasScreen extends StatefulWidget {
  const HistoriasScreen({super.key});

  @override
  State<HistoriasScreen> createState() => _HistoriasScreenState();
}

class _HistoriasScreenState extends State<HistoriasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<HistoriasProvider>().loadHistorias();
  }

  Future<void> _deleteHistoria(HistoriaClinica historia) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Eliminar Historia Clínica',
      message: '¿Está seguro de que desea eliminar la historia clínica ${historia.numeroExpediente}? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      confirmColor: AppTheme.errorColor,
    );

    if (confirm == true) {
      final success = await context.read<HistoriasProvider>().deleteHistoria(
        int.parse(historia.id!),
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historia clínica eliminada'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historias Clínicas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filtros
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por expediente o paciente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          // Lista de historias
          Expanded(
            child: Consumer<HistoriasProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var historias = provider.historias;

                // Filtrar por búsqueda
                if (_searchQuery.isNotEmpty) {
                  historias = historias.where((h) {
                    final query = _searchQuery.toLowerCase();
                    return h.numeroExpediente.toLowerCase().contains(query) ||
                        h.pacienteId.toLowerCase().contains(query);
                  }).toList();
                }

                if (historias.isEmpty) {
                  return const EmptyState(
                    icon: Icons.folder_open,
                    title: 'No hay historias clínicas',
                    message: 'Las historias clínicas se crearán automáticamente al registrar consultas',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: historias.length,
                    itemBuilder: (context, index) {
                      final historia = historias[index];
                      return _HistoriaListTile(
                        historia: historia,
                        dbHelper: _dbHelper,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleHistoriaScreen(
                                historia: historia,
                              ),
                            ),
                          );
                          _loadData();
                        },
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleHistoriaScreen(
                                historia: historia,
                                isEditing: true,
                              ),
                            ),
                          );
                          _loadData();
                        },
                        onDelete: () => _deleteHistoria(historia),
                        onAddEvolucion: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NuevaEvolucionScreen(
                                historiaClinicaId: historia.id!,
                              ),
                            ),
                          );
                          _loadData();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoriaListTile extends StatelessWidget {
  final HistoriaClinica historia;
  final DatabaseHelper dbHelper;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddEvolucion;

  const _HistoriaListTile({
    required this.historia,
    required this.dbHelper,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAddEvolucion,
  });

  Future<Paciente?> _getPaciente() async {
    return await dbHelper.getPacienteById(int.parse(historia.pacienteId));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder_shared,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          historia.numeroExpediente,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<Paciente?>(
                          future: _getPaciente(),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data?.nombreCompleto ?? 'Cargando...',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'evolucion':
                          onAddEvolucion?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppTheme.primaryBlue),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'evolucion',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle, color: AppTheme.primaryTeal),
                            SizedBox(width: 8),
                            Text('Añadir Evolución'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildBadge(
                    Icons.calendar_today,
                    historia.fechaAperturaFormateada.split(' ').take(3).join(' '),
                  ),
                  const SizedBox(width: 12),
                  _buildBadge(
                    Icons.assignment,
                    '${historia.cantidadEvoluciones} evoluciones',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
