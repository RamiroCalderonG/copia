// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:oxschool/Models/Family.dart';
import 'package:oxschool/Models/Student.dart';
import 'package:pluto_grid/pluto_grid.dart';

late Student? nurseryStudent; //Student data getted from nursery/student
var selectedStudent; //Student data getted from nursery/student
var nurseryHistoryStudent; //Student history from Nursery, from /nursery/history

late var selectedFamily; //Selected family from /family
late Family? studentFamily; //Selected family from /family
var studentAllowedMedicines; //Medicines allowed from the current student
var studentsList; //Students to update grades

late var nurseryCauses; //causes fetched from nursery call

void clearStudentData() {
  if (nurseryStudent?.claFamilia != null) {
    nurseryStudent?.clear();
  }
  if (studentFamily?.idFamilyDet != null) {
    studentFamily?.clear();
  }

  selectedStudent = null;
  nurseryHistoryStudent = null;
  selectedFamily = null;

  studentAllowedMedicines = null;
}

final List<PlutoColumn> studentColumnsToEvaluateByStudent = <PlutoColumn>[
  PlutoColumn(
      title: 'Matricula',
      field: 'studentID',
      type: PlutoColumnType.text(),
      readOnly: true,
      sort: PlutoColumnSort.ascending,
      width: 150),
  PlutoColumn(
    title: 'Nombre de alumno',
    field: 'studentName',
    type: PlutoColumnType.text(),
    readOnly: true,
    sort: PlutoColumnSort.ascending,
  ),
];

final List<PlutoColumn> evaluationColumnsToEvaluateByStudent = <PlutoColumn>[];

final List<PlutoColumn> assignaturesColumns = <PlutoColumn>[
  //TO USE at grades_by_assignature
  PlutoColumn(
      title: 'Matricula',
      field: 'Matricula',
      type: PlutoColumnType.number(format: '####'),
      readOnly: true,
      width: 100),
  PlutoColumn(
    title: 'Nombre del alumno',
    field: 'Nombre',
    type: PlutoColumnType.text(),
    readOnly: true,
    sort: PlutoColumnSort.ascending,
  ),
  PlutoColumn(
      title: 'Apellido paterno',
      field: 'Apellido paterno',
      type: PlutoColumnType.text(),
      readOnly: true,
      sort: PlutoColumnSort.ascending,
      width: 150),
  PlutoColumn(
      title: 'Apellido materno',
      field: 'Apellido materno',
      type: PlutoColumnType.text(),
      readOnly: true,
      sort: PlutoColumnSort.ascending,
      width: 150),
  PlutoColumn(
      title: 'Calif',
      field: 'Calif',
      type: PlutoColumnType.number(negative: false),
      readOnly: false,
      width: 100),
  PlutoColumn(
      title: 'Faltas',
      field: 'Ausencia',
      type: PlutoColumnType.number(negative: false, format: '#'),
      readOnly: false,
      width: 100),
  PlutoColumn(
      title: 'Tareas',
      field: 'Tareas',
      type: PlutoColumnType.number(negative: false),
      readOnly: false,
      width: 100),
  PlutoColumn(
      title: 'Conducta',
      field: 'Conducta',
      type: PlutoColumnType.number(negative: false),
      readOnly: false,
      width: 100),
  PlutoColumn(
      title: 'Uniforme',
      field: 'Uniforme',
      type: PlutoColumnType.number(negative: false),
      readOnly: false,
      width: 100),
  PlutoColumn(
      title: 'Comentarios',
      field: 'Comentarios',
      type: PlutoColumnType.number(negative: false),
      readOnly: false,
      width: 100),
];

final List<PlutoColumn> gradesByStudentColumns = [
  PlutoColumn(
    title: 'Materia',
    field: 'subject',
    type: PlutoColumnType.text(),
    readOnly: true,
  ),
  PlutoColumn(
    title: 'Calif',
    field: 'evaluation',
    type: PlutoColumnType.number(negative: false),
  ),
  PlutoColumn(
      title: 'Faltas',
      field: 'absence_eval',
      type: PlutoColumnType.number(negative: false)),
  PlutoColumn(
      title: 'Tareas',
      field: 'homework_eval',
      type: PlutoColumnType.number(negative: false)),
  PlutoColumn(
      title: 'Conducta',
      field: 'discipline_eval',
      type: PlutoColumnType.number(negative: false)),
  PlutoColumn(
      title: 'Comentarios',
      field: 'comment',
      type: PlutoColumnType.number(negative: false)),
  PlutoColumn(
      title: 'Habitos',
      field: 'habit_eval',
      type: PlutoColumnType.number(negative: false)),
  PlutoColumn(
      title: 'Uniforme',
      field: 'outfit',
      type: PlutoColumnType.number(negative: false)),
];

final List<PlutoColumn> commentsCollumns = [
  PlutoColumn(
      title: 'Comentario',
      field: 'comment',
      type: PlutoColumnType.text(),
      readOnly: true)
];
