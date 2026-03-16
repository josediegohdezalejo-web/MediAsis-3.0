import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'consultas_screen.dart';
import 'historias_screen.dart';
import 'nueva_consulta_screen.dart';

/// Pantalla principal de MediAsis.
/// Muestra el dashboard con estadísticas y las consultas pendientes del día.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Map<String, int> _estadisticas = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final consultasProvider = context.read<ConsultasProvider>();
    final pacientesProvider = context.read<PacientesProvider>();
    final historiasProvider = context.read<HistoriasProvider>();

    await Future.wait([
      consultasProvider.loadConsultas(),
      pacientesProvider.loadPacientes(),
      historiasProvider.loadHistorias(),
    ]);

    // Cargar estadísticas
    final db = DatabaseHelper();
    _estadisticas = await db.getEstadisticas();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const ConsultasScreen(),
          const HistoriasScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NuevaConsultaScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva Consulta'),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Header con gradiente
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Estadísticas
          SliverToBoxAdapter(
            child: _buildStats(),
          ),

          // Título de sección
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Consultas de Hoy',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _currentIndex = 1);
                    },
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
            ),
          ),

          // Lista de consultas pendientes
          Consumer<ConsultasProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (provider.consultasHoy.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: EmptyState(
                      icon: Icons.event_available,
                      title: 'No hay consultas programadas',
                      message: 'Las consultas que agendes aparecerán aquí',
                      actionText: 'Nueva Consulta',
                      onAction: () {
                        setState(() => _currentIndex = 1);
                      },
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final consulta = provider.consultasHoy[index];
                    return ConsultaCard(
                      pacienteNombre: 'Paciente ID: ${consulta.pacienteId}',
                      hora: consulta.horaFormateada,
                      motivo: consulta.motivoConsulta,
                      estado: consulta.estado,
                      onTap: () {
                        // Navegar a detalle de consulta
                      },
                    );
                  },
                  childCount: provider.consultasHoy.length,
                ),
              );
            },
          ),

          // Espacio final
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MediAsisAppBarLogo(height: 28),
                  IconButton(
                    onPressed: () {
                      // Notificaciones
                    },
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        if (_estadisticas['consultasPendientes'] ?? 0 > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.errorColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${_estadisticas['consultasPendientes']}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getFechaActual(),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, Doctor',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tienes consultas pendientes para hoy',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Pacientes',
              value: '${_estadisticas['totalPacientes'] ?? 0}',
              icon: Icons.people,
              color: AppTheme.primaryBlue,
              onTap: () {
                // Navegar a pacientes
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Consultas Hoy',
              value: '${_estadisticas['consultasHoy'] ?? 0}',
              icon: Icons.event_note,
              color: AppTheme.primaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Consultas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Historias',
          ),
        ],
      ),
    );
  }

  String _getFechaActual() {
    final now = DateTime.now();
    final dias = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${dias[now.weekday - 1]}, ${now.day} de ${meses[now.month - 1]}';
  }
}
