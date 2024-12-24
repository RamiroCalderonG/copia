// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:oxschool/data/Models/Family.dart';
import 'package:oxschool/data/Models/Student.dart';
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
//  if (nurseryStudent?.claFamilia != null) {
//    nurseryStudent?.clear();
//  }
//  if (studentFamily?.idFamilyDet != null) {
//    studentFamily?.clear();
//  }

  selectedStudent = null;
  nurseryHistoryStudent = null;
  selectedFamily = null;

  studentAllowedMedicines = null;
}

final List<PlutoColumn> studentColumnsToEvaluateByStudent = <PlutoColumn>[
  PlutoColumn(
    title: 'No',
    field: 'No',
    type: PlutoColumnType.number(),
    width: 30,
    readOnly: true,
    // sort: PlutoColumnSort.ascending
  ),
  PlutoColumn(
      title: 'Matricula',
      field: 'studentID',
      type: PlutoColumnType.text(),
      readOnly: true,
      // sort: PlutoColumnSort.ascending,
      width: 120),
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
      type: PlutoColumnType.text(),
      readOnly: true,
      width: 100),
  PlutoColumn(
    title: 'Nombre del alumno',
    field: 'Nombre',
    type: PlutoColumnType.text(),
    readOnly: true,
    //sort: PlutoColumnSort.ascending,
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
      //sort: PlutoColumnSort.ascending,
      width: 150),
  PlutoColumn(
      title: 'Calif',
      field: 'Calif',
      type: PlutoColumnType.number(negative: false),
      readOnly: false,
      width: 100),
  PlutoColumn(
      title: 'idCalif',
      field: 'idCalif',
      type: PlutoColumnType.number(negative: false),
      hide: true)
  // PlutoColumn(
  //     hide: true,
  //     title: 'Faltas',
  //     field: 'Ausencia',
  //     type: PlutoColumnType.number(negative: false, format: '#'),
  //     readOnly: false,
  //     width: 100),
  // PlutoColumn(
  //     hide: true,
  //     title: 'Tareas',
  //     field: 'Tareas',
  //     type: PlutoColumnType.number(negative: false),
  //     readOnly: false,
  //     width: 100),
  // PlutoColumn(
  //     hide: true,
  //     title: 'Conducta',
  //     field: 'Conducta',
  //     type: PlutoColumnType.number(negative: false),
  //     readOnly: false,
  //     width: 100),
  // PlutoColumn(
  //     hide: true,
  //     title: 'Uniforme',
  //     field: 'Uniforme',
  //     type: PlutoColumnType.number(negative: false),
  //     readOnly: false,
  //     width: 100),
  // PlutoColumn(
  //     hide: true,
  //     title: 'Comentarios',
  //     field: 'Comentarios',
  //     type: PlutoColumnType.text(),
  //     readOnly: false,
  //     width: 200),
];

final List<PlutoColumn> gradesByStudentColumns = [
  PlutoColumn(
      title: 'Materia',
      field: 'subject',
      type: PlutoColumnType.text(),
      sort: PlutoColumnSort.ascending,
      readOnly: true,
      hide: true),
  PlutoColumn(
    title: 'Materia',
    field: 'subject_name',
    type: PlutoColumnType.text(),
    width: 80,
    frozen: PlutoColumnFrozen.start,
    readOnly: true,
  ),
  PlutoColumn(
    title: 'Calif',
    field: 'evaluation',
    type: PlutoColumnType.number(negative: false),
  ),
  PlutoColumn(
      title: 'idCalif',
      field: 'idCicloEscolar',
      type: PlutoColumnType.number(negative: false),
      hide: true,
      readOnly: true),
  PlutoColumn(
      title: 'Faltas',
      hide: true,
      field: 'absence_eval',
      type: PlutoColumnType.number(negative: false)),
  PlutoColumn(
      title: 'Tareas',
      hide: true,
      field: 'homework_eval',
      type: PlutoColumnType.number(negative: false)),
  PlutoColumn(
      title: 'Conducta',
      hide: true,
      field: 'discipline_eval',
      type: PlutoColumnType.number(negative: false)),
  // PlutoColumn(
  //     title: 'Comentarios',
  //     field: 'comment',
  //     hide: true,
  //     type:
  //         PlutoColumnType.select(commentStringEval, enableColumnFilter: true)),
  PlutoColumn(
      title: 'Habitos',
      hide: true,
      field: 'habit_eval',
      type: PlutoColumnType.number(negative: false)),
  PlutoColumn(
      title: 'Uniforme',
      hide: true,
      field: 'outfit',
      type: PlutoColumnType.number(negative: false)),
];

final List<PlutoColumn> commentsCollumns = [
  PlutoColumn(
      title: 'id',
      field: 'idcomment',
      type: PlutoColumnType.number(),
      width: 10,
      hide: true,
      enableRowChecked: true,
      readOnly: true),
  PlutoColumn(
      title: 'Comentario',
      field: 'comentname',
      type: PlutoColumnType.text(),
      enableRowChecked: true,
      readOnly: true),
  PlutoColumn(title: 'Selec', field: 'active', type: PlutoColumnType.text())
];
