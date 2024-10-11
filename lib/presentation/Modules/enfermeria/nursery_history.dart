import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/Student.dart';
import 'package:pluto_grid/pluto_grid.dart';

class HistoryNursery extends StatefulWidget {
  const HistoryNursery({super.key});

  @override
  State<HistoryNursery> createState() => _HistoryNurseryState();
}

class _HistoryNurseryState extends State<HistoryNursery> {
  late final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns = <PlutoColumn>[
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

  final List<PlutoRow> rows = [];

  @override
  Widget build(BuildContext context) {
    for (var line in nurseryHistoryStudent) {
      //Modify to History endpoint response
      rows.add(
        PlutoRow(
          cells: {
            'id': PlutoCell(value: line.studentId),
            'Fecha': PlutoCell(value: line.date),
            'Nombre del estudiante': PlutoCell(value: line.studentName),
            'Causa': PlutoCell(value: line.cause),
            'Hora': PlutoCell(value: line.time),
            'Grado': PlutoCell(value: line.grade),
            'Campus': PlutoCell(value: line.campuse),
            'Grupo': PlutoCell(value: line.group),
            'Valoracion': PlutoCell(value: line.diagnosis),
            'Observaciones': PlutoCell(value: line.observations),
            'Se envía con medico': PlutoCell(value: line.canalization),
            'Se envia a clinica': PlutoCell(value: line.hospitalize),
            'tx': PlutoCell(value: line.tx)
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
                  child: PlutoGrid(
                // configuration: const PlutoGridConfiguration.dark(),
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
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
