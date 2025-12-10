import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../tickets/data/repositories/ticket_repository.dart';
import '../../../tickets/domain/entities/ticket.dart';
import '../../../tickets/presentation/pages/add_ticket_screen.dart';

/// Pantalla principal de MisTickets (Dashboard)
///
/// Esta es la pantalla principal donde el usuario puede:
/// - Ver la lista de todos sus tickets
/// - Ver el total de gastos
/// - Agregar nuevos tickets con el FloatingActionButton
/// - Ver detalles de cada ticket (imagen, monto, categoría)
/// - Cerrar sesión
class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  final RepositorioAuth _repositorioAuth = RepositorioAuth();
  final RepositorioTicket _repositorioTicket = RepositorioTicket();

  List<Ticket> _tickets = [];
  bool _cargandoTickets = true;
  bool _cargandoCierreSesion = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarTickets();
  }

  /// Carga los tickets del usuario desde Supabase
  Future<void> _cargarTickets() async {
    setState(() {
      _cargandoTickets = true;
      _error = null;
    });

    try {
      final tickets = await _repositorioTicket.obtenerTickets();
      setState(() {
        _tickets = tickets;
        _cargandoTickets = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargandoTickets = false;
      });
    }
  }

  /// Navega a la pantalla de agregar ticket
  Future<void> _agregarTicket() async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const PantallaAgregarTicket(),
      ),
    );

    // Si se agregó un ticket exitosamente, recargar la lista
    if (resultado == true) {
      _cargarTickets();
    }
  }

  /// Maneja el cierre de sesión del usuario
  Future<void> _cerrarSesion() async {
    setState(() {
      _cargandoCierreSesion = true;
    });

    try {
      await _repositorioAuth.cerrarSesion();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PantallaLogin()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargandoCierreSesion = false;
        });
      }
    }
  }

  /// Calcula el total de gastos
  double get _totalGastos {
    return _tickets.fold<double>(0.0, (sum, ticket) => sum + ticket.monto);
  }

  /// Formatea un número como moneda
  String _formatearMoneda(double monto) {
    final formato = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_MX',
    );
    return formato.format(monto);
  }

  /// Formatea una fecha
  String _formatearFecha(DateTime fecha) {
    final formato = DateFormat('dd/MM/yyyy', 'es_MX');
    return formato.format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _repositorioAuth.obtenerUsuarioActual();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'MisTickets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cargandoCierreSesion ? null : _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarTickets,
        child: Column(
          children: [
            // Header con total de gastos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Email del usuario
                  if (usuario != null)
                    Text(
                      usuario.email ?? 'Usuario',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Total de gastos
                  const Text(
                    'Total de Gastos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatearMoneda(_totalGastos),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_tickets.length} ${_tickets.length == 1 ? 'ticket' : 'tickets'}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de tickets
            Expanded(
              child: _cargandoTickets
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E3A8A),
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar tickets',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _cargarTickets,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _tickets.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay tickets aún',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Presiona el botón + para agregar tu primer ticket',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _tickets.length,
                              itemBuilder: (context, index) {
                                final ticket = _tickets[index];
                                return _TicketCard(
                                  ticket: ticket,
                                  formatearMoneda: _formatearMoneda,
                                  formatearFecha: _formatearFecha,
                                  onEliminar: () async {
                                    // Mostrar diálogo de confirmación
                                    final confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Eliminar ticket'),
                                        content: const Text(
                                          '¿Estás seguro de que deseas eliminar este ticket?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmar == true) {
                                      try {
                                        await _repositorioTicket.eliminarTicket(ticket.id);
                                        _cargarTickets();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Ticket eliminado'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error al eliminar: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarTicket,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Ticket'),
      ),
    );
  }
}

/// Widget de tarjeta de ticket
class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final String Function(double) formatearMoneda;
  final String Function(DateTime) formatearFecha;
  final VoidCallback onEliminar;

  const _TicketCard({
    required this.ticket,
    required this.formatearMoneda,
    required this.formatearFecha,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Mostrar imagen en pantalla completa
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text(formatearMoneda(ticket.monto)),
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Flexible(
                    child: InteractiveViewer(
                      child: Image.network(
                        ticket.imagenUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, size: 64),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen en miniatura
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  ticket.imagenUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Información del ticket
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatearMoneda(ticket.monto),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.categoria,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatearFecha(ticket.fechaCreacion),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                onPressed: onEliminar,
                tooltip: 'Eliminar ticket',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
