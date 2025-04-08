import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/services_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/data/datasources/temp/services_temp.dart';
import 'package:oxschool/presentation/Modules/services_ticket/processes/ticket_requests_dashboard/request_ticket_history.dart';
import 'package:oxschool/presentation/Modules/services_ticket/processes/ticket_requests_dashboard/ticket_request_summary.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
  List<PlutoRow> servicesGridRows = <PlutoRow>[];
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
    return Wrap(children: [
      Column(
        children: [
          _activeServices(),
        ],
      )
    ]);
  }

  final List<PlutoColumn> ticketServicesColumns = <PlutoColumn>[
    PlutoColumn(
        title: 'Id',
        field: 'id',
        type: PlutoColumnType.number(),
        readOnly: true,
        enableRowChecked: true),
    PlutoColumn(
        title: 'Reportado por',
        field: 'reportedBy',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Departamento que solicita',
        field: 'departmentWhoRequest',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Capturado por',
        field: 'capturedBy',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Departamento al que se solicita',
        field: 'depRequestIsMadeTo',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Asignado a ',
        field: 'assignedTo',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Campus',
        field: 'campus',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Fecha de elaboración',
        field: 'requestCreationDate',
        type: PlutoColumnType.date(format: 'yyy-MM-dd'),
        sort: PlutoColumnSort.ascending,
        enableSorting: true,
        readOnly: true),
    PlutoColumn(
        title: 'Fecha para cuando se solicita',
        field: 'requesDate',
        type: PlutoColumnType.date(format: 'yyy-MM-dd'),
        readOnly: true),
    PlutoColumn(
        title: 'Fecha compromiso',
        field: 'deadline',
        type: PlutoColumnType.date(format: 'yyy-MM-dd'),
        readOnly: true),
    PlutoColumn(
        title: 'Fecha de término',
        field: 'closureDate',
        type: PlutoColumnType.date(format: 'yyy-MM-dd'),
        readOnly: true),
    PlutoColumn(
        title: 'Descripción',
        field: 'description',
        type: PlutoColumnType.text(),
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
    PlutoColumn(
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
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Estatus',
        field: 'status',
        type: PlutoColumnType.number(),
        readOnly: true,
        hide: true),
    PlutoColumn(
      title: '¿Fecha compromiso en tiempo?',
      field: 'deadLineOnTime',
      type: PlutoColumnType.text(),
      readOnly: true,
    ),
    PlutoColumn(
        title: '¿Fecha de solicitud en tiempo?',
        field: 'requesttedDateOnTime',
        type: PlutoColumnType.text(),
        readOnly: true)
  ];

  handleRefresh() async {
    setState(() {
      isLoading = true;
      servicesGridRows.clear();
    });
    try {
      serviceStatusSelected ??= serviceListStatus.first;
      final int? status = serviceListStatusMap[serviceStatusSelected];

      int byWho = _character == SingingCharacter.madeByMe
          ? 1 //I Made
          : 2; // I Was Reported

      await getServiceTicketsByDate(_dateController.text, status!, byWho)
          .then((value) {
        setState(() {
          servicesGridRows = value!;
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
    } catch (e) {
      insertActionIntoLog(e.toString(), 'getServiceTicketsByDate');
      throw Future.error(e.toString());
    }
  }

  Widget _activeServices() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  child: Padding(
                      padding: EdgeInsets.only(left: 3, right: 3),
                      child: isLoading
                          ? null
                          : RefreshButton(onPressed: () {
                              handleRefresh();
                            }))),
              Flexible(
                  child: Padding(
                      padding: EdgeInsets.only(left: 3, right: 3),
                      child:
                          isLoading ? null : ExportButton(onPressed: () {}))),
              Flexible(
                  child: Padding(
                      padding: EdgeInsets.only(left: 3, right: 3),
                      child: isLoading ? null : PrintButton(onPressed: () {}))),
            ],
          ),
        ),
        const Divider(
          thickness: 1,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  //helper: Text('Tickets desde'),
                  labelText: 'Tickets desde',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                readOnly: true,
                onTap: () async {
                  // ignore: unused_local_variable
                  DateTime? pickedDate = await showDatePicker(
                          context: context,
                          helpText: 'MM-DD-AAAA',
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101))
                      .then((pickedDate) {
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                    return DateTime.now();
                  });
                },
              ),
            )),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(right: 5, left: 5),
                    child: DropdownMenu<String>(
                        initialSelection: serviceListStatus.first,
                        label: const Text('Estatus'),
                        onSelected: (String? value) {
                          setState(() {
                            serviceStatusSelected = value;
                          });
                        },
                        dropdownMenuEntries: serviceListStatus
                            .map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(
                              value: value, label: value);
                        }).toList()))),
            const Text(
              'Tipo de servicio:',
              style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: Container(
              width: 250,
              height: 50,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 255, 255, 255),
                  // border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                  title: const Text('Que me reportaron'),
                  leading: Radio<SingingCharacter>(
                    value: SingingCharacter.iWasReported,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                        isSelectedRequestsIMade = false;
                        assignedTickets.clear();
                        unassignedTickets.clear();
                        onProgressTickets.clear();
                        closedTickets.clear();
                        overdueTickets.clear();
                      });
                    },
                  )),
            )),
            Expanded(
                child: Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                  title: const Text('Que reporté'),
                  leading: Radio<SingingCharacter>(
                    value: SingingCharacter.madeByMe,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                        isSelectedRequestsIMade = true;
                        assignedTickets.clear();
                        unassignedTickets.clear();
                        onProgressTickets.clear();
                        closedTickets.clear();
                        overdueTickets.clear();
                      });
                    },
                  )),
            )),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 15),
          child: const Divider(
            thickness: 1,
          ),
        ),
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          if (isLoading) {
            return const Center(
              child: CustomLoadingIndicator(),
            );
          } else if (!isLoading && displayError == false) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.64,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              bottom: 20), // Add padding here
                          child: SingleChildScrollView(
                            child: TicketRequestSummary(
                                isSelectedRequestsIMade:
                                    isSelectedRequestsIMade),
                          )

                          /* PlutoGrid(
      columns: ticketServicesColumns,
      rows: servicesGridRows,
      rowColorCallback: (rowColorContext) {
        final isDeadLineOnTime = rowColorContext.row.cells['deadLineOnTime']?.value;
        final isRequesttedDateOnTime = rowColorContext.row.cells['requesttedDateOnTime']?.value;
        final statusValue = rowColorContext.row.cells['status']?.value;
        if ((isDeadLineOnTime == false &&  statusValue != 3) || (isRequesttedDateOnTime == false && statusValue != 3)) { //If the service is overdue
          return Colors.red.shade50;
        } else  { 
          return Colors.transparent;
        }
      },
      configuration: PlutoGridConfiguration(
        columnSize: PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.none,
        )
      ),
      createFooter: (stateManager) {
        stateManager.setPageSize(20, notify: false); // Display 10 items per page
        return PlutoPagination(stateManager);
      },
      onRowDoubleTap: (event) {
        if (event.row != null) {
          final description = event.row!.cells['description']?.value ?? 'Sin descripción';
          final observations = event.row!.cells['observations']?.value ?? 'Sin onbservaciones';
          final ticketNumber = event.row!.cells['id']?.value ?? 'Sin id';

          showDialog(
            context : context,
            builder: (BuildContext context){
              return Material(
                type: MaterialType.transparency,
                child: TicketDetail(ticketId: ticketNumber, observations: observations, description: description),
              );
            }
          );
        }
      },
  
      
    ), */
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (displayError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage.toString(),
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      handleRefresh();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('No hay datos'),
            );
          }
        })
      ],
    );
  }
}

class TicketDetail extends StatefulWidget {
  const TicketDetail(
      {super.key,
      required this.ticketId,
      required this.description,
      required this.observations,
      this.deadLine,
      required this.requestDate,
      required this.creationDate,
      this.closureDate,
      this.assignedTo,
      this.reportedBy,
      required this.isSelectedRequestsIMade});
  final int ticketId;
  final String description;
  final String observations;
  final DateTime? deadLine;
  final DateTime requestDate;
  final DateTime creationDate;
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

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  bool editMode = false;
  bool isLoading = false;

  String selectedValue = list.first;

  @override
  void initState() {
    _dateController.text = widget.deadLine != null
        ? DateFormat('yyyy-MM-dd').format(widget.deadLine!)
        : 'Sin fecha compromiso';
    _descriptionController.text = widget.description;
    _observationsController.text = widget.observations;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 50, top: 50),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 50, right: 20, top: 8, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ticket de servicio',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 26,
                              ),
                            ),
                            Spacer(),
                            IconButton.outlined(
                              onPressed: () {
                                if (editMode) {
                                  null;
                                } else {
                                  //TODO: INSERT PRINT FUNCTION
                                  print('Print ticket');
                                }
                              },
                              icon:
                                  const Icon(Icons.print, color: Colors.white),
                              iconSize: 20,
                              tooltip: 'Imprimir ticket',
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            IconButton.outlined(
  enableFeedback: true,
  onPressed: () {
    

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Historial de movimientos'),
          content: RequestTicketHistory(history: [],),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  },
  icon: const Icon(Icons.history, color: Colors.white),
  iconSize: 20,
  tooltip: 'Historial de movimientos',
  style: OutlinedButton.styleFrom(
    shape: const CircleBorder(),
    side: const BorderSide(
      color: Colors.white,
      width: 0.5,
    ),
  ),
)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Ticket ID Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    editMode
                        ? 'EDITANDO: #${widget.ticketId}'
                        : 'Ticket  #${widget.ticketId}.',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(
              thickness: 1,
              color: Colors.black,
            ),

            // Scrollable Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  border: Border.all(color: Colors.black)),
                              child: Text('Descripción',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          )
                        ],
                      ),

                      TextField(
                        controller: _descriptionController,
                        readOnly: true,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Observaciones Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  border: Border.all(color: Colors.black)),
                              child: Text('Observaciones',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                      TextField(
                        controller: _observationsController,
                        readOnly: true,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Dropdown and Date Picker Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  border: Border.all(color: Colors.black)),
                              child: Text('Asignado a: ${widget.assignedTo}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                labelText: 'Fecha Compromiso',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              readOnly: true,
                              onTap: () async {
                                if (editMode) {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    helpText: 'MM-DD-AAAA',
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _dateController.text =
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);
                                    });
                                  }
                                } else {
                                  null;
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Fecha de creación',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: widget.creationDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(widget.creationDate)
                                  : 'Sin fecha de creación',
                            ),
                          )),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Fecha solicitada para servicio',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: widget.requestDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(widget.creationDate)
                                  : 'Sin fecha de solicitud',
                            ),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      /* Row(
                      children: [
                        
                      ],
                    ) */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!widget.isSelectedRequestsIMade)
                            editMode
                                ? SaveItemButton(onPressed: () {
                                    setState(() {
                                      isLoading = true;
                                      editMode = !editMode;
                                    });
                                  })
                                : EditItemButton(onPressed: () {
                                    setState(() {
                                      editMode = !editMode;
                                    });
                                  }),
                        ],
                      )
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
}
