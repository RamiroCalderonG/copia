import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../../../core/constants/Student.dart';

class StudentHistoryGrid extends StatefulWidget {
  const StudentHistoryGrid({super.key});

  @override
  State<StudentHistoryGrid> createState() => _StudentHistoryGridState();
}

class _StudentHistoryGridState extends State<StudentHistoryGrid> {
  final List<TrinaRow> nurseryHistoryRows = [];
  bool isSearching = true;
  late final TrinaGridStateManager stateManager;
  List<TrinaColumn> nurseryHistoryColumns = <TrinaColumn>[];

  @override
  void initState() {
    super.initState();

    nurseryHistoryColumns = <TrinaColumn>[
      TrinaColumn(
        title: 'idReporteEnfermeria',
        field: 'idReporteEnfermeria',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        title: 'Matricula',
        field: 'Matricula',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Fecha',
        field: 'Fecha',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Alumno',
        field: 'Alumno',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Causa',
        field: 'Causa',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Hora',
        field: 'Hora',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Grado',
        field: 'Gradosecuencia',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        title: 'Campus',
        field: 'ClaUn',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Grupo',
        field: 'Grupo',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Valoracion',
        field: 'valoracionenfermeria',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Observaciones',
        field: 'obsGenerales',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Canalizacion medico',
        field: 'irconmedico',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
          title: 'Envio a clinica',
          field: 'envioclinica',
          type: TrinaColumnType.text()),
      TrinaColumn(
        title: 'tx',
        field: 'tx',
        type: TrinaColumnType.text(),
      )
    ];

    for (var line in nurseryHistoryStudent) {
      nurseryHistoryRows.add(
        TrinaRow(
          cells: {
            'idReporteEnfermeria': TrinaCell(value: line.idReport),
            'Matricula': TrinaCell(value: line.studentId),
            'Fecha': TrinaCell(value: line.date),
            'Alumno': TrinaCell(value: line.studentName),
            'Causa': TrinaCell(value: line.cause),
            'Hora': TrinaCell(value: line.time),
            'Gradosecuencia': TrinaCell(value: line.grade),
            'ClaUn': TrinaCell(value: line.campuse),
            'Grupo': TrinaCell(value: line.group),
            'valoracionenfermeria': TrinaCell(value: line.diagnosis),
            'obsGenerales': TrinaCell(value: line.observations),
            'irconmedico': TrinaCell(value: line.canalization),
            'envioclinica': TrinaCell(value: line.hospitalize),
            'tx': TrinaCell(value: line.tx)
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
        MediaQuery.of(context).size.width * 0.9; // 80% of screen width

    return Column(
      children: [
        const Padding(
            padding: EdgeInsets.all(16.0),
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
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0, // Customize card elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Historial del alumno',
                            style: TextStyle(fontSize: 25.0)),
                        Text(
                          selectedStudent.nombre,
                          style: const TextStyle(fontSize: 20.0),
                        ),
                        const SizedBox(height: 8.0),
                        const Divider(),
                        Expanded(
                            child: TrinaGrid(
                          // configuration: const TrinaGridConfiguration.dark(),
                          columns: <TrinaColumn>[
                            TrinaColumn(
                              title: 'idReporteEnfermeria',
                              field: 'idReporteEnfermeria',
                              type: TrinaColumnType.number(),
                            ),
                            TrinaColumn(
                              title: 'Matricula',
                              field: 'Matricula',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                              title: 'Fecha',
                              field: 'Fecha',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                              title: 'Alumno',
                              field: 'Alumno',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                              title: 'Causa',
                              field: 'Causa',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                              title: 'Hora',
                              field: 'Hora',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                              title: 'Grado',
                              field: 'Gradosecuencia',
                              type: TrinaColumnType.number(),
                            ),
                            TrinaColumn(
                              title: 'Campus',
                              field: 'ClaUn',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                              title: 'Grupo',
                              field: 'Grupo',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                              title: 'Valoracion',
                              field: 'valoracionenfermeria',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                              title: 'Observaciones',
                              field: 'obsGenerales',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                              title: 'Canalizacion medico',
                              field: 'irconmedico',
                              type: TrinaColumnType.text(),
                            ),
                            TrinaColumn(
                                title: 'Envio a clinica',
                                field: 'envioclinica',
                                type: TrinaColumnType.text()),
                            TrinaColumn(
                              title: 'tx',
                              field: 'tx',
                              type: TrinaColumnType.text(),
                            )
                          ],
                          // nurseryHistoryColumns,
                          rows: nurseryHistoryRows,
                          onLoaded: (TrinaGridOnLoadedEvent event) {
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
