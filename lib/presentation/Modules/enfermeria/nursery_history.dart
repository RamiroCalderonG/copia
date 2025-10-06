import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/Student.dart';
import 'package:trina_grid/trina_grid.dart';

class HistoryNursery extends StatefulWidget {
  const HistoryNursery({super.key});

  @override
  State<HistoryNursery> createState() => _HistoryNurseryState();
}

class _HistoryNurseryState extends State<HistoryNursery> {
  late final TrinaGridStateManager stateManager;

  final List<TrinaColumn> columns = <TrinaColumn>[
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

  final List<TrinaRow> rows = [];

  @override
  Widget build(BuildContext context) {
    for (var line in nurseryHistoryStudent) {
      //Modify to History endpoint response
      rows.add(
        TrinaRow(
          cells: {
            'id': TrinaCell(value: line.studentId),
            'Fecha': TrinaCell(value: line.date),
            'Nombre del estudiante': TrinaCell(value: line.studentName),
            'Causa': TrinaCell(value: line.cause),
            'Hora': TrinaCell(value: line.time),
            'Grado': TrinaCell(value: line.grade),
            'Campus': TrinaCell(value: line.campuse),
            'Grupo': TrinaCell(value: line.group),
            'Valoracion': TrinaCell(value: line.diagnosis),
            'Observaciones': TrinaCell(value: line.observations),
            'Se envía con medico': TrinaCell(value: line.canalization),
            'Se envia a clinica': TrinaCell(value: line.hospitalize),
            'tx': TrinaCell(value: line.tx)
          },
        ),
      );
    }

    return Card(
      elevation: 4.0, // Customize card elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (nurseryHistoryStudent != null)
                const Text('Nombre del estudiante',
                    style: TextStyle(fontSize: 22.0)),
              Text(
                selectedStudent.nombre,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              const Text('Datos de contacto', style: TextStyle(fontSize: 18.0)),
              const SizedBox(height: 8.0),
              const Divider(),
              Expanded(
                  child: TrinaGrid(
                // configuration: const TrinaGridConfiguration.dark(),
                columns: columns,
                rows: rows,
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager.setShowColumnFilter(true);
                },
              )),
              if (nurseryHistoryStudent == null ||
                  nurseryHistoryStudent.isEmpty)
                const Text(
                    'Sin informacion disponible'), // Placeholder or message
            ],
          )),
    );
  }
}
