import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/services_functions.dart';
import 'package:oxschool/data/datasources/temp/services_temp.dart';
import 'package:oxschool/data/services/backend/validate_user_permissions.dart';
import 'package:oxschool/presentation/Modules/services_ticket/processes/create_service_ticket.dart';
import 'package:oxschool/presentation/Modules/services_ticket/processes/ticket_requests_dashboard/request_ticket_history.dart';
import 'package:oxschool/presentation/Modules/services_ticket/processes/ticket_requests_dashboard/ticket_request_summary.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:trina_grid/trina_grid.dart';

class Processes extends StatefulWidget {
  const Processes({super.key});

  @override
  State<Processes> createState() => _ProcessesState();
}

const List<String> serviceListStatus = <String>[
  'Todos', // 7
  'Capturado', // 0
  'Asignado', // 1
  'En proceso', // 2
  'Terminado', // 3
  //'Evaluado', // 4
  //'Cerrado', // 5
  //'Cancelado' // 6
];

const Map<String, int> serviceListStatusMap = <String, int>{
  'Todos': 7,
  'Capturado': 0,
  'Asignado': 1,
  'En proceso': 2,
  'Terminado': 3,
  //'Evaluado': 4,
  //'Cerrado': 5,
  //'Cancelado': 6
};
String? serviceStatusSelected;

enum SingingCharacter { iWasReported, madeByMe }

class _ProcessesState extends State<Processes> {
  SingingCharacter? _character = SingingCharacter.iWasReported;
  List<TrinaRow> servicesGridRows = <TrinaRow>[];
  bool isLoading = false;
  bool displayError = false;
  String? errorMessage;
  final _dateController = TextEditingController();
  bool isSelectedRequestsIMade = false;

  int selectedOption = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.surface,
              colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // SliverAppBar(
            //   expandedHeight: 60,
            //   floating: false,
            //   pinned: true,
            //   backgroundColor: Colors.transparent,
            //   surfaceTintColor: Colors.transparent,
            //   flexibleSpace: FlexibleSpaceBar(
            //     title: Text(
            //       'Gestión de Tickets',
            //       style: theme.textTheme.bodyLarge?.copyWith(
            //         fontWeight: FontWeight.bold,
            //         color: colorScheme.onSurface,
            //       ),
            //     ),
            //     background: Container(
            //       decoration: BoxDecoration(
            //         gradient: LinearGradient(
            //           begin: Alignment.topLeft,
            //           end: Alignment.bottomRight,
            //           colors: [
            //             colorScheme.primaryContainer.withOpacity(0.3),
            //             colorScheme.secondaryContainer.withOpacity(0.2),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            //   // actions: [
            //   //   IconButton.filledTonal(
            //   //     onPressed: _refreshData,
            //   //     icon: const Icon(Icons.refresh_rounded),
            //   //     tooltip: 'Actualizar',
            //   //   ),
            //   //   const SizedBox(width: 8),
            //   //   IconButton.outlined(
            //   //     onPressed: () {}, // TODO: Implement export
            //   //     icon: const Icon(Icons.download_rounded),
            //   //     tooltip: 'Exportar',
            //   //   ),
            //   //   const SizedBox(width: 16),
            //   // ],
            // ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildActionBar(theme, colorScheme),
                    // const SizedBox(height: 10),
                    _buildFiltersCard(theme, colorScheme),
                    // const SizedBox(height: 10),
                    _buildContentSection(theme, colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(ThemeData theme, ColorScheme colorScheme) {
    final screenSize = MediaQuery.of(context).size;
    final isCompact = screenSize.width < 768;
    final isMobile = screenSize.width < 600;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 6 : 8),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.assignment_rounded,
                color: colorScheme.onPrimaryContainer,
                size: isMobile ? 18 : 20,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            if (!isMobile)
              Text(
                'Gestión de Tickets',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Spacer(),
            if (!isLoading) ...[
              if (isCompact) ...[
                // Compact layout with IconButtons
                IconButton.outlined(
                  onPressed: () {
                    _refreshData();
                  },
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'Refrescar',
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  onPressed: _createNewTicket,
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Nuevo Ticket',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.outlined(
                  onPressed: () {}, // TODO: Implement print
                  icon: const Icon(Icons.print_rounded),
                  tooltip: 'Imprimir',
                ),
                const SizedBox(width: 4),
                IconButton.outlined(
                  onPressed: () {
                    // TODO: Implement export
                  },
                  icon: const Icon(Icons.download_rounded),
                  tooltip: 'Exportar',
                ),
              ] else ...[
                // Full layout with labeled buttons
                OutlinedButton.icon(
                  onPressed: () {
                    _refreshData();
                  },
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Refrescar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _createNewTicket,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo Ticket'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {}, // TODO: Implement print
                  icon: const Icon(Icons.print_rounded),
                  label: const Text('Imprimir'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () {
                    // TODO: Implement export
                  },
                  label: const Text('Exportar'),
                ),
              ],
              SizedBox(width: isMobile ? 8 : 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filtros de Búsqueda',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de inicio',
                      hintText: 'Selecciona una fecha',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: serviceStatusSelected,
                    decoration: InputDecoration(
                      labelText: 'Estado del Ticket',
                      prefixIcon: const Icon(Icons.task_alt_rounded),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    items: serviceListStatus.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        serviceStatusSelected = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              color: colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Tickets',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<SingingCharacter>(
                            title: const Text('Asignados a mí'),
                            value: SingingCharacter.iWasReported,
                            groupValue: _character,
                            onChanged: (value) =>
                                _onTicketTypeChanged(value, false),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<SingingCharacter>(
                            title: const Text('Creados por mí'),
                            value: SingingCharacter.madeByMe,
                            groupValue: _character,
                            onChanged: (value) =>
                                _onTicketTypeChanged(value, true),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(ThemeData theme, ColorScheme colorScheme) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final isShortScreen = screenSize.height < 600;
    final isTallScreen = screenSize.height > 900;

    // Calculate responsive height based on screen size and orientation
    double contentHeight;

    if (isMobile) {
      // Mobile devices - optimize for portrait and landscape
      if (isShortScreen) {
        contentHeight =
            screenSize.height * 0.35; // Very compact for small screens
      } else {
        contentHeight = screenSize.height * 0.42; // Standard mobile height
      }
    } else if (isTablet) {
      // Tablet devices - balance between mobile and desktop
      if (isShortScreen) {
        contentHeight = screenSize.height * 0.45;
      } else if (isTallScreen) {
        contentHeight = screenSize.height * 0.60;
      } else {
        contentHeight = screenSize.height * 0.52; // Standard tablet height
      }
    } else {
      // Desktop devices - maximize available space
      if (isShortScreen) {
        contentHeight = screenSize.height * 0.55;
      } else if (isTallScreen) {
        contentHeight =
            screenSize.height * 0.70; // Take advantage of tall screens
      } else {
        contentHeight = screenSize.height * 0.62; // Standard desktop height
      }
    }

    // Ensure minimum height for usability
    contentHeight = contentHeight.clamp(300.0, double.infinity);

    if (isLoading) {
      return SizedBox(
        height: contentHeight,
        child: _buildLoadingState(theme),
      );
    } else if (displayError) {
      return SizedBox(
        height: contentHeight,
        child: _buildErrorState(theme),
      );
    } else {
      return SizedBox(
        height: contentHeight,
        child: _buildTicketsList(theme, colorScheme),
      );
    }
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando tickets...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Error desconocido',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsList(ThemeData theme, ColorScheme colorScheme) {
    return TicketRequestSummary(
      isSelectedRequestsIMade: isSelectedRequestsIMade,
    );
  }

  void _createNewTicket() {
    bool? isEnabled = canRoleConsumeEvent("Crear ticket de servicio");
    if (isEnabled != null && isEnabled == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateServiceTicket(),
        ),
      );
    } else {
      showInformationDialog(
        context,
        'Sin permisos',
        'No cuenta con permisos para crear tickets. Consulte con el administrador.',
      );
    }
  }

  void _refreshData() {
    if (_dateController.text.isNotEmpty) {
      handleRefresh();
    } else {
      showEmptyFieldAlertDialog(context, 'Seleccione una fecha para continuar');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _onTicketTypeChanged(SingingCharacter? value, bool isRequestsIMade) {
    setState(() {
      _character = value;
      isSelectedRequestsIMade = isRequestsIMade;
      // Clear existing data
      assignedTickets.clear();
      unassignedTickets.clear();
      onProgressTickets.clear();
      closedTickets.clear();
      overdueTickets.clear();
    });
  }

  final List<TrinaColumn> ticketServicesColumns = <TrinaColumn>[
    TrinaColumn(
        title: 'Id',
        field: 'id',
        type: TrinaColumnType.number(),
        readOnly: true,
        enableRowChecked: true),
    TrinaColumn(
        title: 'Reportado por',
        field: 'reportedBy',
        type: TrinaColumnType.text(),
        readOnly: true),
    TrinaColumn(
        title: 'Departamento que solicita',
        field: 'departmentWhoRequest',
        type: TrinaColumnType.text(),
        readOnly: true),
    TrinaColumn(
        title: 'Capturado por',
        field: 'capturedBy',
        type: TrinaColumnType.text(),
        readOnly: true),
    TrinaColumn(
        title: 'Departamento al que se solicita',
        field: 'depRequestIsMadeTo',
        type: TrinaColumnType.text(),
        readOnly: true),
    TrinaColumn(
        title: 'Asignado a ',
        field: 'assignedTo',
        type: TrinaColumnType.text(),
        readOnly: true),
    TrinaColumn(
        title: 'Campus',
        field: 'campus',
        type: TrinaColumnType.text(),
        readOnly: true),
    TrinaColumn(
        title: 'Fecha de elaboración',
        field: 'requestCreationDate',
        type: TrinaColumnType.date(format: 'yyy-MM-dd'),
        sort: TrinaColumnSort.ascending,
        enableSorting: true,
        readOnly: true),
    TrinaColumn(
        title: 'Fecha para cuando se solicita',
        field: 'requesDate',
        type: TrinaColumnType.date(format: 'yyy-MM-dd'),
        readOnly: true),
    TrinaColumn(
        title: 'Fecha compromiso',
        field: 'deadline',
        type: TrinaColumnType.date(format: 'yyy-MM-dd'),
        readOnly: true),
    TrinaColumn(
        title: 'Fecha de término',
        field: 'closureDate',
        type: TrinaColumnType.date(format: 'yyy-MM-dd'),
        readOnly: true),
    TrinaColumn(
        title: 'Descripción',
        field: 'description',
        type: TrinaColumnType.text(),
        renderer: (rendererContext) {
          final description = rendererContext.cell.value ?? 'Sin description';
          return Tooltip(
              message: description,
              child: Text(
                description,
                overflow: TextOverflow.clip,
                maxLines: 4,
              ));
        },
        readOnly: true),
    TrinaColumn(
        title: 'Observaciones',
        field: 'observations',
        renderer: (rendererContext) {
          final description = rendererContext.cell.value ?? 'Sin Observaciones';
          return Tooltip(
              message: description,
              child: Text(
                description,
                overflow: TextOverflow.fade,
                maxLines: 4,
              ));
        },
        type: TrinaColumnType.text(),
        readOnly: true),
    TrinaColumn(
        title: 'Estatus',
        field: 'status',
        type: TrinaColumnType.number(),
        readOnly: true,
        hide: true),
    TrinaColumn(
      title: '¿Fecha compromiso en tiempo?',
      field: 'deadLineOnTime',
      type: TrinaColumnType.text(),
      readOnly: true,
    ),
    TrinaColumn(
        title: '¿Fecha de solicitud en tiempo?',
        field: 'requesttedDateOnTime',
        type: TrinaColumnType.text(),
        readOnly: true)
  ];

  handleRefresh() async {
    setState(() {
      isLoading = true;
      servicesGridRows.clear();
    });
    try {
      if (_dateController.text.isNotEmpty) {
        serviceStatusSelected ??= serviceListStatus.first;
        final int? status = serviceListStatusMap[serviceStatusSelected];

        int byWho = _character == SingingCharacter.madeByMe
            ? 1 //I Made
            : 2; // I Was Reported

        await getServiceTicketsByDate(_dateController.text, status!, byWho)
            .then((value) {
          setState(() {
            servicesGridRows = value;
            isLoading = false;
          });
        }).onError((stacktrace, error) {
          setState(() {
            isLoading = false;
            displayError = true;
            errorMessage = error.toString();
          });
          insertActionIntoLog(error.toString(), 'getServiceTicketsByDate');
        });
      } else {
        showEmptyFieldAlertDialog(context, 'Favor de seleccionar una fecha');
      }
    } catch (e) {
      insertActionIntoLog(e.toString(), 'getServiceTicketsByDate');
      throw Future.error(e.toString());
    }
  }
}

class TicketDetail extends StatefulWidget {
  const TicketDetail(
      {super.key,
      required this.ticketId,
      required this.description,
      this.observations,
      this.deadLine,
      this.requestDate,
      this.creationDate,
      this.closureDate,
      this.assignedTo,
      this.reportedBy,
      required this.isSelectedRequestsIMade});
  final int ticketId;
  final String description;
  final String? observations;
  final DateTime? deadLine;
  final DateTime? requestDate;
  final DateTime? creationDate;
  final DateTime? closureDate;
  final String? assignedTo;
  final String? reportedBy;
  final bool isSelectedRequestsIMade;

  @override
  State<TicketDetail> createState() => _ScreenState();
}

class _ScreenState extends State<TicketDetail> {
  static const List<String> list = <String>[
    'Asignar',
    'Cerrar',
    'Cancelar',
    'Reabrir',
    'Evaluar',
  ];

  List<Map<String, dynamic>> usersMapsL = [];
  List<String> employeeList = <String>[];
  late Future _employeeListFuture;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  bool editMode = false;
  bool isLoading = false;
  bool dateEdited = false;
  bool asigneEdited = false;

  Map<String, dynamic> updateBody = {};
  String selectedValue = list.first;

  @override
  void initState() {
    fetchUsersList(2, currentUser!.work_area!);
    _dateController.text = widget.deadLine != null
        ? DateFormat('yyyy-MM-dd').format(widget.deadLine!)
        : 'Sin fecha compromiso';
    _descriptionController.text = widget.description;

    if (widget.observations == null) {
      _observationsController.text = '';
    } else {
      _observationsController.text = widget.observations!;
    }
    if (widget.creationDate == null) {
      _dateController.text = 'Sin fecha de creación';
    }

    editMode = false;
    super.initState();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _observationsController.dispose();
    editMode = false;
    super.dispose();
  }

  void fetchUsersList(int filter, String dept) {
    _employeeListFuture = getUsersList(filter, dept).then((value) {
      usersMapsL = value;
      getEmployeesNames(value);
    }).onError((error, stacktrace) {
      insertErrorLog(error.toString(),
          'Error al obtener la lista de empleados | fetchUsersList()');
    });
  }

  void getEmployeesNames(List<Map<String, dynamic>> usersLists) {
    employeeList.clear();
    for (var element in usersLists) {
      if (element['users1'] != null) {
        employeeList.add(element['users1'].toString().trim());
      }
    }
  }

  dynamic handleUpdate(int flag) async {
    if (dateEdited || asigneEdited) {
      updateRequestTicket(updateBody, flag);
    } else {
      showEmptyFieldAlertDialog(context, 'Ningun cambio detectado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Map<String, dynamic> ticketId = {'RequestService': widget.ticketId};
    updateBody.addEntries(ticketId.entries);

    return FutureBuilder(
      future: _employeeListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(theme);
        } else if (snapshot.hasError) {
          return _buildErrorState(theme, snapshot.error.toString());
        } else {
          return _buildTicketContent(theme, colorScheme);
        }
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando detalles del ticket...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar ticket',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketContent(ThemeData theme, ColorScheme colorScheme) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            editMode
                ? 'Editando Ticket #${widget.ticketId}'
                : 'Ticket de Servicio #${widget.ticketId}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton.filledTonal(
              onPressed: editMode
                  ? null
                  : () {
                      // TODO: Implement print functionality
                      print('Print ticket');
                    },
              icon: const Icon(Icons.print_rounded),
              tooltip: 'Imprimir ticket',
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () => _showTicketHistory(),
              icon: const Icon(Icons.history_rounded),
              tooltip: 'Historial de movimientos',
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Cerrar',
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primaryContainer.withOpacity(0.1),
                colorScheme.surface,
                colorScheme.surfaceContainerLow,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTicketHeader(theme, colorScheme),
                    const SizedBox(height: 24),
                    _buildTicketForm(theme, colorScheme),
                    const SizedBox(height: 32),
                    _buildActionButtons(theme, colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.assignment_rounded,
            color: colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ticket #${widget.ticketId}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.reportedBy != null)
                Text(
                  'Reportado por: ${widget.reportedBy}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (editMode)
          Chip(
            label: const Text('Modo Edición'),
            backgroundColor: colorScheme.secondaryContainer,
            labelStyle: TextStyle(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildTicketForm(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description Section
        Text(
          'Descripción del Problema',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description_rounded),
          ),
          maxLines: 3,
          readOnly: true,
        ),

        const SizedBox(height: 24),

        // Observations Section
        Text(
          'Observaciones',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _observationsController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note_add_rounded),
          ),
          maxLines: 3,
          readOnly: true,
        ),

        const SizedBox(height: 24),

        // Dates and Assignment Section
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asignado a',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (editMode && widget.assignedTo == "NULL")
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      value:
                          employeeList.isNotEmpty ? employeeList.first : null,
                      hint: const Text('Seleccionar empleado'),
                      items: employeeList.map((employee) {
                        return DropdownMenuItem<String>(
                          value: employee,
                          child: Text(employee),
                        );
                      }).toList(),
                      onChanged: (value) => _onEmployeeAssigned(value),
                    )
                  else
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      initialValue: widget.assignedTo == "NULL"
                          ? 'Pendiente de asignación'
                          : widget.assignedTo,
                      readOnly: true,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha Compromiso',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    readOnly: true,
                    onTap: editMode ? _selectDeadlineDate : null,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha de Creación',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event_rounded),
                    ),
                    initialValue: widget.creationDate != null
                        ? DateFormat('yyyy-MM-dd').format(widget.creationDate!)
                        : 'Sin fecha de creación',
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha Solicitada',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule_rounded),
                    ),
                    initialValue: widget.requestDate != null
                        ? DateFormat('yyyy-MM-dd').format(widget.requestDate!)
                        : 'Sin fecha de solicitud',
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    if (widget.isSelectedRequestsIMade) {
      return const SizedBox
          .shrink(); // Don't show edit buttons for tickets created by user
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (editMode) ...[
          OutlinedButton(
            onPressed: () {
              setState(() {
                editMode = false;
              });
            },
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                isLoading = true;
                handleUpdate(1);
                isLoading = false;
                editMode = false;
              });
            },
            icon: const Icon(Icons.save_rounded),
            label: const Text('Guardar Cambios'),
          ),
        ] else ...[
          FilledButton.icon(
            onPressed: () {
              setState(() {
                editMode = true;
              });
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Editar Ticket'),
          ),
        ],
      ],
    );
  }

  void _showTicketHistory() {
    setState(() {
      isLoading = true;
    });

    getRequestTicketHistory(widget.ticketId).then((value) {
      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Historial - Ticket #${widget.ticketId}'),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.1),
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surfaceContainerLow,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: RequestTicketHistory(history: value),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _onEmployeeAssigned(String? employeeName) {
    if (employeeName == null) return;

    setState(() {
      final matchingUser = usersMapsL.firstWhere(
        (user) => user['users1'].toString().trim() == employeeName.trim(),
        orElse: () => {},
      );

      if (matchingUser.isNotEmpty) {
        final employeeNumber = matchingUser['NoEmpleado'];
        Map<String, dynamic> userMap = {'user': employeeNumber};
        updateBody.addEntries(userMap.entries);
        asigneEdited = true;
      }
    });
  }

  Future<void> _selectDeadlineDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        Map<String, dynamic> dateMap = {'date': _dateController.text};
        updateBody.addEntries(dateMap.entries);
        dateEdited = true;
      });
    }
  }
}
