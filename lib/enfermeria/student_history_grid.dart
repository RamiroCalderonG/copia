import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../constants/Student.dart';

class StudentHistoryGrid extends StatefulWidget {
  const StudentHistoryGrid({super.key});

  @override
  State<StudentHistoryGrid> createState() => _StudentHistoryGridState();
}

class _StudentHistoryGridState extends State<StudentHistoryGrid> {
  final List<PlutoRow> nurseryHistoryRows = [];
  bool isSearching = true;
  late final PlutoGridStateManager stateManager;
  List<PlutoColumn> nurseryHistoryColumns = <PlutoColumn>[];

  @override
  void initState() {
    super.initState();

    nurseryHistoryColumns = <PlutoColumn>[
      PlutoColumn(
        title: 'idReporteEnfermeria',
        field: 'idReporteEnfermeria',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Matricula',
        field: 'Matricula',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Fecha',
        field: 'Fecha',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Alumno',
        field: 'Alumno',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Causa',
        field: 'Causa',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Hora',
        field: 'Hora',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Grado',
        field: 'Gradosecuencia',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Campus',
        field: 'ClaUn',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Grupo',
        field: 'Grupo',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Valoracion',
        field: 'valoracionenfermeria',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Observaciones',
        field: 'obsGenerales',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Canalizacion medico',
        field: 'irconmedico',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
          title: 'Envio a clinica',
          field: 'envioclinica',
          type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'tx',
        field: 'tx',
        type: PlutoColumnType.text(),
      )
    ];

    for (var line in nurseryHistoryStudent) {
      nurseryHistoryRows.add(
        PlutoRow(
          cells: {
            'idReporteEnfermeria': PlutoCell(value: line.idReport),
            'Matricula': PlutoCell(value: line.studentId),
            'Fecha': PlutoCell(value: line.date),
            'Alumno': PlutoCell(value: line.studentName),
            'Causa': PlutoCell(value: line.cause),
            'Hora': PlutoCell(value: line.time),
            'Gradosecuencia': PlutoCell(value: line.grade),
            'ClaUn': PlutoCell(value: line.campuse),
            'Grupo': PlutoCell(value: line.group),
            'valoracionenfermeria': PlutoCell(value: line.diagnosis),
            'obsGenerales': PlutoCell(value: line.observations),
            'irconmedico': PlutoCell(value: line.canalization),
            'envioclinica': PlutoCell(value: line.hospitalize),
            'tx': PlutoCell(value: line.tx)
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = screenHeight / 1.0;
    double cardWidth =
        MediaQuery.of(context).size.width * 0.8; // 80% of screen width

    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                //
              ],
              // ,
            )),
        if (isSearching) // Display the Card when searching

          Expanded(
            // child: Center(
            child: Container(
              width: cardWidth, // Set the card width here
              height: cardHeight,
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0, // Customize card elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Historial del alumno',
                            style: TextStyle(fontSize: 22.0)),
                        Text(
                          selectedStudent.nombre,
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 8.0),
                        Divider(),
                        Expanded(
                            child: PlutoGrid(
                          // configuration: const PlutoGridConfiguration.dark(),
                          columns: <PlutoColumn>[
                            PlutoColumn(
                              title: 'idReporteEnfermeria',
                              field: 'idReporteEnfermeria',
                              type: PlutoColumnType.number(),
                            ),
                            PlutoColumn(
                              title: 'Matricula',
                              field: 'Matricula',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                              title: 'Fecha',
                              field: 'Fecha',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                              title: 'Alumno',
                              field: 'Alumno',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                              title: 'Causa',
                              field: 'Causa',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                              title: 'Hora',
                              field: 'Hora',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                              title: 'Grado',
                              field: 'Gradosecuencia',
                              type: PlutoColumnType.number(),
                            ),
                            PlutoColumn(
                              title: 'Campus',
                              field: 'ClaUn',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                              title: 'Grupo',
                              field: 'Grupo',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                              title: 'Valoracion',
                              field: 'valoracionenfermeria',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                              title: 'Observaciones',
                              field: 'obsGenerales',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                              title: 'Canalizacion medico',
                              field: 'irconmedico',
                              type: PlutoColumnType.text(),
                            ),
                            PlutoColumn(
                                title: 'Envio a clinica',
                                field: 'envioclinica',
                                type: PlutoColumnType.text()),
                            PlutoColumn(
                              title: 'tx',
                              field: 'tx',
                              type: PlutoColumnType.text(),
                            )
                          ],
                          // nurseryHistoryColumns,
                          rows: nurseryHistoryRows,
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            stateManager = event.stateManager;
                            stateManager.setShowColumnFilter(true);
                          },
                        ))
                      ],
                    )),
              ),
            ),
          ),
        // Placeholder or message
      ],
    );
  }
}
