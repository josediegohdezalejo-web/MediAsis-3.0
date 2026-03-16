import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../database/database_helper.dart';
import 'nueva_consulta_screen.dart';
import 'detalle_consulta_screen.dart';

/// Pantalla de gestión de consultas médicas.
/// Permite ver, buscar y gestionar todas las consultas.
class ConsultasScreen extends StatefulWidget {
  const ConsultasScreen({super.key});

  @override
  State<ConsultasScreen> createState() => _ConsultasScreenState();
}

class _ConsultasScreenState extends State<ConsultasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<ConsultasProvider>().loadConsultas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filtros
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar consulta...',
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Todas'),
                  Tab(text: 'Pendientes'),
                  Tab(text: 'Completadas'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsultasList(TipoFiltro.todas),
          _buildConsultasList(TipoFiltro.pendientes),
          _buildConsultasList(TipoFiltro.completadas),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NuevaConsultaScreen(),
            ),
          );
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Consulta'),
      ),
    );
  }

  Widget _buildConsultasList(TipoFiltro filtro) {
    return Consumer<ConsultasProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Consulta> consultas;
        switch (filtro) {
          case TipoFiltro.pendientes:
            consultas = provider.consultasPendientes;
            break;
          case TipoFiltro.completadas:
            consultas = provider.consultas
                .where((c) => c.estado == 'Completada')
                .toList();
            break;
          default:
            consultas = provider.consultas;
        }

        // Filtrar por búsqueda
        if (_searchQuery.isNotEmpty) {
          consultas = consultas.where((c) {
            final query = _searchQuery.toLowerCase();
            return c.motivoConsulta.toLowerCase().contains(query) ||
                c.diagnostico?.toLowerCase().contains(query) ?? false;
          }).toList();
        }

        if (consultas.isEmpty) {
          return EmptyState(
            icon: Icons.medical_services,
            title: filtro == TipoFiltro.pendientes
                ? 'No hay consultas pendientes'
                : filtro == TipoFiltro.completadas
                    ? 'No hay consultas completadas'
                    : 'No hay consultas registradas',
            message: 'Las consultas que registres aparecerán aquí',
            actionText: 'Nueva Consulta',
            onAction: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NuevaConsultaScreen(),
                ),
              );
              _loadData();
            },
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: consultas.length,
            itemBuilder: (context, index) {
              final consulta = consultas[index];
              return _ConsultaListTile(
                consulta: consulta,
                dbHelper: _dbHelper,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleConsultaScreen(
                        consulta: consulta,
                      ),
                    ),
                  );
                  _loadData();
                },
                onStatusChange: (nuevoEstado) async {
                  await provider.actualizarEstadoConsulta(
                    int.parse(consulta.id!),
                    nuevoEstado,
                  );
                },
                onDelete: () async {
                  final confirm = await ConfirmDialog.show(
                    context: context,
                    title: 'Eliminar Consulta',
                    message: '¿Está seguro de que desea eliminar esta consulta?',
                    confirmText: 'Eliminar',
                    confirmColor: AppTheme.errorColor,
                  );
                  if (confirm == true) {
                    await provider.deleteConsulta(int.parse(consulta.id!));
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

enum TipoFiltro { todas, pendientes, completadas }

class _ConsultaListTile extends StatelessWidget {
  final Consulta consulta;
  final DatabaseHelper dbHelper;
  final VoidCallback? onTap;
  final void Function(String)? onStatusChange;
  final VoidCallback? onDelete;

  const _ConsultaListTile({
    required this.consulta,
    required this.dbHelper,
    this.onTap,
    this.onStatusChange,
    this.onDelete,
  });

  Future<Paciente?> _getPaciente() async {
    if (consulta.pacienteId.isEmpty) return null;
    return await dbHelper.getPacienteById(int.parse(consulta.pacienteId));
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
                      color: consulta.estado.consultaStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person,
                      color: consulta.estado.consultaStatusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<Paciente?>(
                          future: _getPaciente(),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data?.nombreCompleto ?? 'Cargando...',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${consulta.fechaFormateada} - ${consulta.horaFormateada}',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: consulta.estado.consultaStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      consulta.estado,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: consulta.estado.consultaStatusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                consulta.motivoConsulta,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (consulta.diagnostico != null &&
                  consulta.diagnostico!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.assignment,
                        size: 16,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dx: ${consulta.diagnostico}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppTheme.primaryBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cambiar estado
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete?.call();
                      } else {
                        onStatusChange?.call(value);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Pendiente',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, color: AppTheme.pendienteColor),
                            SizedBox(width: 8),
                            Text('Marcar Pendiente'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'En curso',
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow, color: AppTheme.enCursoColor),
                            SizedBox(width: 8),
                            Text('Marcar En Curso'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Completada',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: AppTheme.completadaColor),
                            SizedBox(width: 8),
                            Text('Marcar Completada'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Cancelada',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: AppTheme.canceladaColor),
                            SizedBox(width: 8),
                            Text('Marcar Cancelada'),
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
            ],
          ),
        ),
      ),
    );
  }
}
