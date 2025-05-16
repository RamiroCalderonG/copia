import 'package:trina_grid/trina_grid.dart';

import '../../../core/constants/Student.dart';

final List<TrinaColumn> nurseryHistoryColumns = <TrinaColumn>[
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

List<TrinaRow> nurseryHistoryRows() {
  final List<TrinaRow> rows = [];
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
  return rows;
}
