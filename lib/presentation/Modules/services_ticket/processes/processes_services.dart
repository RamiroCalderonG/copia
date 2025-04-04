import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/services_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
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

enum SingingCharacter { madeBySomeOneElse, madeByMe }

class _ProcessesState extends State<Processes> {
  SingingCharacter? _character = SingingCharacter.madeBySomeOneElse;
  List<PlutoRow> servicesGridRows = <PlutoRow>[];
  bool isLoading = false;
  bool displayError = false;
  String? errorMessage;
  final _dateController = TextEditingController();

  int selectedOption = 1;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return 
    Wrap(children: [
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
            )
          );
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
            )
          );
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
          readOnly: true
        )
  ];

  handleRefresh() async {
    setState(() {
      isLoading = true;
      servicesGridRows.clear();
    });
    try {
      serviceStatusSelected ??= serviceListStatus.first;
      final int? status = serviceListStatusMap[serviceStatusSelected];

      int byWho = _character == SingingCharacter.madeBySomeOneElse
          ? 1
          : 2;


      await getServiceTicketsByDate(_dateController.text, status!, byWho).then((value) {
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
                          child: isLoading ? null : RefreshButton(onPressed: () {
                            handleRefresh();
                          }))),
                  Flexible(
                      child: Padding(
                          padding: EdgeInsets.only(left: 3, right: 3),
                          child:  isLoading ? null : ExportButton(onPressed: () {}))),
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
                  style: TextStyle(
                      fontFamily: 'Sora', fontWeight: FontWeight.bold),
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
                        value: SingingCharacter.madeBySomeOneElse,
                        groupValue: _character,
                        onChanged: (SingingCharacter? value) {
                          setState(() {
                            _character = value;
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
              } else if (!isLoading && displayError == false){
                return Padding(padding: const EdgeInsets.only(bottom: 30), child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.64,
        child: Column(
          children: [
            Expanded(
  child: Container(
    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20), // Add padding here
    child: 
    PlutoGrid(
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
              return AlertDialog(
                title: Text('Detalle del ticket: ${ticketNumber.toString()} '),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: 1,
                    ),
                    Text('Descripción: $description'),
                    const SizedBox(height: 10,),
                    Text('Observaciones: $observations'),
                  ],
                ),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, child: const Text('Close'))
                ],
              );
            }
          );
        }
      },
    ),
  ),
),
          ],
        ),
      ),);  
              } if (displayError) {
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
}
              else {
                return const Center(
                  child: Text('No hay datos'),
                );
              }
            })
          ],
        );
  }
}
