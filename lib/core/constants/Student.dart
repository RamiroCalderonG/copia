// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:oxschool/data/Models/Family.dart';
import 'package:oxschool/data/Models/Student.dart';
import 'package:trina_grid/trina_grid.dart';

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

final List<TrinaColumn> studentColumnsToEvaluateByStudent = <TrinaColumn>[
  TrinaColumn(
      title: 'No',
      field: 'No',
      type: TrinaColumnType.number(),
      width: 60,
      readOnly: false,
      checkReadOnly: (row, cell) {
        return false;
      },
      sort: TrinaColumnSort.ascending),
  TrinaColumn(
      title: 'Matricula',
      field: 'studentID',
      type: TrinaColumnType.text(),
      readOnly: false,
      checkReadOnly: (row, cell) {
        return false;
      },
      // sort: TrinaColumnSort.ascending,
      width: 120),
  TrinaColumn(
    title: 'Nombre de alumno',
    field: 'studentName',
    type: TrinaColumnType.text(),
    readOnly: false,
    checkReadOnly: (row, cell) {
      return false;
    },
    sort: TrinaColumnSort.ascending,
  ),
];

final List<TrinaColumn> evaluationColumnsToEvaluateByStudent = <TrinaColumn>[];

// final List<TrinaColumn> gradesByStudentColumns = [
//   TrinaColumn(
//       title: 'Materia',
//       field: 'subject',
//       type: TrinaColumnType.text(),
//       readOnly: true,
//       hide: true),
//   TrinaColumn(
//     title: 'Materia',
//     field: 'subject_name',
//     type: TrinaColumnType.text(),
//     width: 80,
//     frozen: TrinaColumnFrozen.start,
//     sort: TrinaColumnSort.ascending,
//     readOnly: true,
//   ),
//   TrinaColumn(
//     title: 'Calif',
//     field: 'evaluation',
//     type: TrinaColumnType.number(negative: false),
//   ),
//   TrinaColumn(
//       title: 'idCalif',
//       field: 'idCicloEscolar',
//       type: TrinaColumnType.number(negative: false),
//       hide: true,
//       readOnly: true),
//   TrinaColumn(
//       title: 'Faltas',
//       hide: true,
//       field: 'absence_eval',
//       type: TrinaColumnType.number(negative: false)),
//   TrinaColumn(
//       title: 'Tareas',
//       hide: true,
//       field: 'homework_eval',
//       type: TrinaColumnType.number(negative: false)),
//   TrinaColumn(
//       title: 'Conducta',
//       hide: true,
//       field: 'discipline_eval',
//       type: TrinaColumnType.number(negative: false)),
//   // TrinaColumn(
//   //     title: 'Comentarios',
//   //     field: 'comment',
//   //     hide: true,
//   //     type:
//   //         TrinaColumnType.select(commentStringEval, enableColumnFilter: true)),
//   TrinaColumn(
//       title: 'Habitos',
//       hide: true,
//       field: 'habit_eval',
//       type: TrinaColumnType.number(negative: false)),
//   TrinaColumn(
//       title: 'Uniforme',
//       hide: true,
//       field: 'outfit',
//       type: TrinaColumnType.number(negative: false)),
// ];

final List<TrinaColumn> commentsCollumns = [
  TrinaColumn(
    title: 'id',
    field: 'idcomment',
    type: TrinaColumnType.number(),
    width: 10,
    hide: true,
    enableRowChecked: true,
    readOnly: false,
    checkReadOnly: (row, cell) {
      return false;
    },
  ),
  TrinaColumn(
    title: 'Comentario',
    field: 'comentname',
    type: TrinaColumnType.text(),
    enableRowChecked: true,
    readOnly: false,
    checkReadOnly: (row, cell) {
      return false;
    },
  ),
  TrinaColumn(title: 'Selec', field: 'active', type: TrinaColumnType.text())
];
