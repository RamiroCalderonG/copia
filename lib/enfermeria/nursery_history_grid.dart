import 'package:pluto_grid/pluto_grid.dart';

import '../constants/Student.dart';

final List<PlutoColumn> nurseryHistoryColumns = <PlutoColumn>[
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

List<PlutoRow> nurseryHistoryRows() {
  final List<PlutoRow> rows = [];
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
  return rows;
}
