import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/data/Models/Student_eval.dart';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/constants/date_constants.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/data/datasources/temp/teacher_grades_temp.dart';
import 'package:oxschool/presentation/Modules/login_view/login_view_widget.dart';

import 'package:trina_grid/trina_grid.dart';

import '../../../../core/utils/loader_indicator.dart';
import '../../../../data/datasources/temp/studens_temp.dart';
import '../../../../data/services/backend/api_requests/api_calls_list.dart';
import '../../../../core/constants/Student.dart';
import '../../../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../../../core/reusable_methods/reusable_functions.dart';
import '../../../components/confirm_dialogs.dart';
import '../../../components/custom_icon_button.dart';
import '../../../components/teacher_eval_dropdownmenu.dart';

class GradesByStudent extends StatefulWidget {
  const GradesByStudent({super.key});

  @override
  State<GradesByStudent> createState() => _GradesByStudentState();
}

String? subjectSelected = oneTeacherAssignatures.first;

List<TrinaRow> rows = [];

class _GradesByStudentState extends State<GradesByStudent> {
  bool isUserAdmin = false;
  bool isUserAcademicCoord = false;
  var commentsController = TextEditingController();
  late TrinaGridStateManager stateManager;
  late TrinaGridStateManager gridAStateManager;
  String currentMonth = DateFormat.MMMM('es').format(DateTime.now());

  Key? currentRowKey;
  Timer? _debounce;
  String? asignatureNameListener;
  String selectedStudentName = '';
  var fetchedData;
  bool isFetching = true;
  bool hideCommentsColumn = true;
  bool hideAbsencesColumn = true;
  bool hideHomeworksColumn = true;
  bool hideDisciplineColumn = true;
  bool hideHabitsColumn = true;
  bool hideOutfitColumn = true;

  String? homeWorkColumnTitle;
  String? disciplineColumnTitle;
  int? monthNumber;
  String dropDownValue = ''; //oneTeacherAssignatures.first;
  int? assignatureID;
  late Future<dynamic> _fetchedDataFromRequest;
  DateFormat? dateFormat;

  String? selectedStudentID;

  @override
  void initState() {
    isUserAdmin = currentUser!.isCurrentUserAdmin();
    isUserAcademicCoord = currentUser!.isCurrentUserAcademicCoord();
    _fetchData();
    initializeDateFormatting();
    super.initState();
  }

  @override
  void dispose() {
    //studentsGradesCommentsRows.clear();
    //evaluationComments.clear();
    //commentStringEval.clear();
    _debounce?.cancel();
    commentsController.dispose();
    //selectedTempGrade = null;
    //selectedTempGroup = null;
    //selectedTempStudent = null;
    //selectedTempCampus = null;
    //selectedTempMonth = null;
    //selectedCurrentTempMonth = null;
    super.dispose();
  }

  void _fetchData() async {
    var response = isUserAdmin || isUserAcademicCoord
        ? loadStartGradingAsAdminOrAcademicCoord(currentCycle!.claCiclo!, null,
            true, null, null, isUserAcademicCoord, isUserAdmin)
        : loadStartGrading(
            currentUser!.employeeNumber!,
            currentCycle!.toString(),
            isUserAdmin,
            isUserAcademicCoord,
            currentUser!.claUn);
    fetchedData = response;
    setState(() {
      isFetching = false;
    });
  }

  //* Populates Grid that only contains the students names and IDs
  Future<void> fillGrid(List<StudentEval> evaluationList) async {
    Set<String> studentSet = {};
    List<Map<String, String>> uniqueStudents = [];

    for (var student in evaluationList) {
      if (!studentSet.contains(student.studentID)) {
        studentSet.add(student.studentID);
        uniqueStudents.add({
          'studentID': student.studentID,
          'student': student.fulllName!,
          'sequentialNumber': student.sequentialNumber.toString(),
        });
      }
    }
    setState(() {
      rows = uniqueStudents.map((item) {
        return TrinaRow(
          cells: {
            'studentID': TrinaCell(value: item.containsKey('StudentID')),
            'studentName': TrinaCell(value: item.containsKey('studentName')),
            'No': TrinaCell(
                value: item.containsKey('sequentialNumber')
                    ? item['sequentialNumber']
                    : '0'),
          },
        );
      }).toList();
    });
  }

  Future<void> populateCommentsGrid(List<Map<String, String>> comments) async {
    if (studentsGradesCommentsRows.isNotEmpty) {
      setState(() {
        evaluationComments = comments.map((item) {
          return TrinaRow(cells: {
            'idcomment': TrinaCell(value: item['idcomment']),
            'comentname': TrinaCell(value: item['comentname']),
          });
        }).toList();
      });
    }
  }

  Future<void> searchBUttonAction(String groupSelected, int grade,
      int monthSelected, String campusSelected) async {
    try {
      setState(() {
        studentList.clear();
        studentEvaluationRows.clear();
        selectedStudentName = '';
        selectedStudentID = null;
        selectedStudentRows.clear();
      });
      //var gradeInt = getKeyFromValue(teacherGradesMap, gradeString);
      if (studentList.isNotEmpty && studentsGradesCommentsRows.isNotEmpty) {
        studentList.clear();
        studentsGradesCommentsRows.clear();
      }
      // Get the students list by group, grade, cycle, campus and month
      studentList = await getSubjectsAndGradesByStudent(grade, groupSelected,
          currentCycle!.claCiclo!, campusSelected, monthSelected);

      // Get evaluations comments by gradeSequence
      if (studentList.isNotEmpty) {
        studentsGradesCommentsRows =
            await getEvaluationsCommentsByGradeSequence(grade);
      } else {
        throw Exception(
            'No se encontraron alumnos para el grupo seleccionado: $groupSelected, grado: $grade, ciclo: ${currentCycle!.claCiclo}, campus: $campusSelected, mes: $monthSelected');
      }

      displayColumnsByGrade(grade);

      fillGrid(studentList); //Fill student list by unque values

      setState(() {
        studentEvaluationRows.clear();
        // var index = 0;
        for (var item in uniqueStudentsList) {
          String sequentialNumber = studentList
              .firstWhere((student) => student.studentID == item['studentID'])
              .sequentialNumber
              .toString();
          studentEvaluationRows.add(TrinaRow(cells: {
            'No': TrinaCell(
                value: sequentialNumber.isNotEmpty
                    ? sequentialNumber
                    : '0'), //* Sequential number of student (NoLista)
            'studentID': TrinaCell(value: item['studentID']!.trim()),
            'studentName':
                TrinaCell(value: item['studentName']!.trim().toTitleCase),
          }));
        }
      });
    } catch (e) {
      insertErrorLog(e.toString(), 'SEARCH GRADES BY STUDENT ');
      var message = getMessageToDisplay(e.toString());
      if (context.mounted) {
        showErrorFromBackend(context, message.toString());
      }
    }
  }

  Future<dynamic> patchStudentGradesToDB() async {
    await patchStudentsGrades(studentGradesBodyToUpgrade, true).then((value) {
      if (value != null) {
        if (value == 200) {
          return 200;
        } else {
          return value;
        }
      }
    }).catchError((onError, stackTrace) {
      insertErrorLog(onError.toString(),
          'PATCH STUDENT GRADES TO DB | $studentGradesBodyToUpgrade');
      throw Future.error(onError.toString);
    });
  }

  String validateTwoDigitNumber(dynamic value) {
    final stringValue = value.toString();
    if (RegExp(r'^\d{1,2}$').hasMatch(stringValue)) {
      return stringValue;
    }
    // If more than 2 digits, return only the first 2 digits
    return stringValue.substring(0, 2);
  }

  List<TrinaColumn> get gradesByStudentColumns => [
        TrinaColumn(
            title: 'Materia',
            field: 'subject',
            type: TrinaColumnType.text(),
            readOnly: true,
            hide: true),
        TrinaColumn(
          title: 'Materia',
          field: 'subject_name',
          type: TrinaColumnType.text(),
          // width: 80,
          frozen: TrinaColumnFrozen.start,
          sort: TrinaColumnSort.ascending,
          readOnly: true,
        ),
        TrinaColumn(
          title: 'Calif',
          field: 'evaluation',
          type: TrinaColumnType.number(
            negative: false,
          ),
        ),
        TrinaColumn(
            title: 'idCalif',
            field: 'idCicloEscolar',
            type: TrinaColumnType.number(negative: false),
            hide: true,
            readOnly: true),
        TrinaColumn(
            title: 'Faltas',
            hide: hideAbsencesColumn,
            field: 'absence_eval',
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            title: homeWorkColumnTitle ?? 'Tareas',
            hide: hideHomeworksColumn,
            field: 'homework_eval',
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            title: disciplineColumnTitle ?? 'Disciplina',
            hide: hideDisciplineColumn,
            field: 'discipline_eval',
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            title: 'Comentarios',
            field: 'comment',
            hide: true,
            type: TrinaColumnType.select(commentStringEval,
                enableColumnFilter: true)),
        TrinaColumn(
            title: 'Habitos',
            hide: hideHabitsColumn,
            field: 'habit_eval',
            type: TrinaColumnType.number(negative: false)),
        // TrinaColumn(
        //     title: 'Uniforme',
        //     hide: hideOutfitColumn,
        //     field: 'outfit',
        //     type: TrinaColumnType.number(negative: false)),
      ];

  @override
  Widget build(BuildContext context) {
    return isFetching
        ? const CustomLoadingIndicator()
        : SizedBox(
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              if (fetchedData is Error || fetchedData is FormatException) {
                return Placeholder(
                  color: Colors.transparent,
                  child: Center(
                    child: Text('Error en la conección: $fetchedData'),
                  ),
                );
              } else {
                return SingleChildScrollView(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [_buildGradesPerStudent()],
                      )
                    ],
                  ),
                ));
              }
            }),
          );
  }

  Widget _buildGradesPerStudent() {
    return Expanded(
      child: Column(
        children: [
          TeacherEvalDropDownMenu(
            jsonData: jsonDataForDropDownMenuClass,
            campusesList: campusesWhereTeacherTeach,
            byStudent: true,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(child: RefreshButton(onPressed: () async {
                  try {
                    setState(() {
                      isFetching = true;
                    });
                    studentGradesBodyToUpgrade.clear();
                    if (isUserAdmin || isUserAcademicCoord) {
                      //Calendar month number
                      monthNumber =
                          getKeyFromValue(spanishMonthsMap, selectedTempMonth!);
                    } else {
                      setState(() {
                        selectedCurrentTempMonth = currentMonth.toCapitalized;
                      });
                      //Calendar month number
                      monthNumber = getKeyFromValue(
                          spanishMonthsMap, selectedCurrentTempMonth!);
                    }
                    if (selectedTempGroup == null || selectedTempGroup == '') {
                      return showEmptyFieldAlertDialog(
                          context, 'Seleccionar un grupo a evaluar');
                    }
                    if (selectedTempGrade == null || selectedTempGrade == '') {
                      return showEmptyFieldAlertDialog(
                          context, 'Seleccionar un grado a evaluar');
                    }
                    if (selectedTempCampus == null ||
                        selectedTempCampus == '') {
                      return showEmptyFieldAlertDialog(
                          context, 'Seleccionar un campus a evaluar');
                    }
                    if (monthNumber == null || monthNumber == '') {
                      return showEmptyFieldAlertDialog(
                          context, 'Seleccionar un mes a evaluar');
                    } else {
                      await searchBUttonAction(
                        selectedTempGroup!,
                        selectedTempGrade!,
                        monthNumber!,
                        selectedTempCampus!,
                      ).whenComplete(() {
                        setState(() {
                          isFetching = false;
                        });
                      });
                    }
                  } catch (e) {
                    setState(() {
                      isFetching = false;
                      insertErrorLog(e.toString(), 'REFRESH BUTTON');
                      showErrorFromBackend(context, e.toString());
                    });
                  }
                })),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: SaveItemButton(
                    onPressed: () {
                      setState(() {
                        isFetching = true;
                      });
                      if (studentGradesBodyToUpgrade.isEmpty) {
                        showEmptyFieldAlertDialog(
                            context, 'No se detectó ningun cambio a realizar');
                        setState(() {
                          isFetching = false;
                        });
                      } else {
                        try {
                          if (isUserAdmin || isUserAcademicCoord) {
                            monthNumber = getKeyFromValue(
                                spanishMonthsMap, selectedTempMonth!);
                          } else {
                            monthNumber = getKeyFromValue(
                                spanishMonthsMap, selectedCurrentTempMonth!);
                          }
                          saveButtonAction(monthNumber).whenComplete(() async {
                            studentGradesBodyToUpgrade.clear();
                            await searchBUttonAction(
                              selectedTempGroup!,
                              selectedTempGrade!,
                              monthNumber!,
                              selectedTempCampus!,
                            );
                            setState(() {
                              isFetching = false;
                              showInformationDialog(
                                  context, 'Èxito', 'Cambios realizados!');
                            });
                          });
                        } catch (e) {
                          setState(() {
                            isFetching = false;
                            showErrorFromBackend(context, e.toString());
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: selectedStudentName.isNotEmpty
                    ? Text(
                        'Evaluando a : ${selectedStudentName.trim()}',
                        style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      )
                    : const Text(
                        ' ',
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
              ),
            ],
          ),
          const Divider(thickness: 1),
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.8,
              margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                if (studentEvaluationRows.isEmpty) {
                  return const Placeholder(
                    child: Column(
                      children: [
                        Center(
                          child: Text('Favor de refrescar información'),
                        )
                      ],
                    ),
                  );
                } else {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              child: TrinaGrid(
                                  //Grid for students name and ID
                                  columns: studentColumnsToEvaluateByStudent,
                                  rows: studentEvaluationRows,
                                  mode: TrinaGridMode.select,
                                  onRowDoubleTap: (event) async {
                                    var gradeInt = getKeyFromValue(
                                        teacherGradesMap,
                                        selectedTempGrade!.toString());
                                    int? monthNumber;

                                    if (isUserAdmin || isUserAcademicCoord) {
                                      monthNumber = getKeyFromValue(
                                          spanishMonthsMap, selectedTempMonth!);
                                    } else {
                                      monthNumber = getKeyFromValue(
                                          spanishMonthsMap,
                                          selectedCurrentTempMonth!);
                                    }
                                    selectedStudentID =
                                        event.row.cells['studentID']!.value;
                                    selectedStudentName = event
                                        .row.cells['studentName']!.value
                                        .toString();

                                    await loadSelectedStudent(
                                        selectedStudentID!,
                                        gradeInt,
                                        monthNumber!);
                                  },
                                  onLoaded: (event) {
                                    event.stateManager.setSelectingMode(
                                        TrinaGridSelectingMode.cell);
                                    TrinaGridStateManager stateManager =
                                        event.stateManager;

                                    // Select the row where the 'nameColumn' matches 'John Doe'
                                    selectRowByName(stateManager, 'studentName',
                                        selectedStudentName);
                                  },
                                  configuration: const TrinaGridConfiguration(
                                    style: TrinaGridStyleConfig(
                                      enableColumnBorderVertical: false,
                                      enableCellBorderVertical: false,
                                    ),
                                  ),
                                  createFooter: (stateManager) {
                                    stateManager.setPageSize(20,
                                        notify: false); // default 40
                                    return TrinaPagination(stateManager);
                                  })),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 2,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return Column(
                                  children: [
                                    Expanded(
                                      child: selectedStudentRows.isNotEmpty
                                          ? TrinaGrid(
                                              // mode: TrinaGridMode.select,
                                              columns: gradesByStudentColumns,
                                              rows: selectedStudentRows,
                                              onChanged: (event) {
                                                // Validator to avoid double type numbers for 'Calif' column
                                                if (event.column.field ==
                                                    'evaluation') {
                                                  // Only allow integers (no decimals)
                                                  if (event.value is double ||
                                                      (event.value is String &&
                                                          event.value
                                                              .contains('.'))) {
                                                    showErrorFromBackend(
                                                        context,
                                                        'Solo se permiten números enteros en la calificación.');
                                                    return; // Prevent further processing
                                                  }
                                                  // Optionally, also check if it's not a number at all
                                                  if (int.tryParse(
                                                          event.toString()) ==
                                                      null) {
                                                    showErrorFromBackend(
                                                        context,
                                                        'Ingrese solo números enteros válidos.');
                                                    return;
                                                  }
                                                }
                                                var newValue =
                                                    validateNewGradeValue(
                                                        event.value,
                                                        event.column.title);

                                                final subjectID = event.row
                                                    .cells['subject']?.value;
                                                final evalId = event
                                                    .row
                                                    .cells['idCicloEscolar']
                                                    ?.value;
                                                int? monthNumber;
                                                if (isUserAdmin ||
                                                    isUserAcademicCoord) {
                                                  monthNumber = getKeyFromValue(
                                                      spanishMonthsMap,
                                                      selectedTempMonth!
                                                          .toCapitalized);
                                                } else {
                                                  monthNumber = getKeyFromValue(
                                                      spanishMonthsMap,
                                                      currentMonth
                                                          .toCapitalized);
                                                }

                                                validator();
                                                composeBodyToUpdateGradeBySTudent(
                                                  event.column.title,
                                                  selectedStudentID!,
                                                  newValue,
                                                  evalId,
                                                  monthNumber,
                                                );
                                              },
                                              // onRowSecondaryTap: (event) async {
                                              //   var gradeInt = getKeyFromValue(
                                              //       teacherGradesMap,
                                              //       selectedTempGrade!);
                                              //   asignatureNameListener = '';
                                              //   asignatureNameListener = event
                                              //       .row
                                              //       .cells['subject_name']
                                              //       ?.value
                                              //       .toString();

                                              //   if (gradeInt! >= 6) {
                                              //     await showCommentsDialog(
                                              //         context,
                                              //         commentsAsignated,
                                              //         asignatureNameListener!);
                                              //   } else {
                                              //     showInformationDialog(
                                              //         context,
                                              //         'Aviso',
                                              //         'Sin comentarios disponibles a asignar al alumno seleccionado');
                                              //   }
                                              // },
                                              onLoaded: (TrinaGridOnLoadedEvent
                                                  event) {
                                                gridAStateManager =
                                                    event.stateManager;
                                              },
                                              configuration:
                                                  const TrinaGridConfiguration(
                                                style: TrinaGridStyleConfig(
                                                  enableColumnBorderVertical:
                                                      false,
                                                  enableCellBorderVertical:
                                                      false,
                                                ),
                                                columnSize:
                                                    TrinaGridColumnSizeConfig(
                                                  autoSizeMode:
                                                      TrinaAutoSizeMode.scale,
                                                  resizeMode: TrinaResizeMode
                                                      .pushAndPull,
                                                ),
                                              ),
                                            )
                                          : const Center(
                                              child: Text(
                                                  'Seleccione un alumno dando doble click para evaluar'),
                                            ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      );
                    },
                  );
                }
              })),
        ],
      ),
    );
  }

  dynamic validator() {
    if (studentList.isNotEmpty) {
      studentList.clear();
    }
    if (selectedTempGroup == null || selectedTempGroup == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un grupo a evaluar');
    }
    if (selectedTempGrade == null || selectedTempGrade == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un grado a evaluar');
    }
    if (selectedTempCampus == null || selectedTempCampus == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un campus a evaluar');
    }
    // if (dropDownValue.isEmpty || dropDownValue == '') {
    //   dropDownValue = oneTeacherAssignatures.first;
    // }
    if (selectedTempMonth == null) {
      if (context.mounted) {
        showEmptyFieldAlertDialog(context, 'Seleccionar mes a evaluar');
      }
    }
  }

  void handleCommentsRefresh(int gradeSequence) async {
    try {} catch (e) {}
  }

  void selectRowByName(TrinaGridStateManager stateManager, String columnField,
      String storedName) {
    for (var i = 0; i < stateManager.rows.length; i++) {
      final cellValue = stateManager.rows[i].cells[columnField]?.value;

      // If the cell value matches the stored name
      if (cellValue == storedName) {
        // Get the first cell in the row to set focus
        final firstCell = stateManager.rows[i].cells.entries.first.value;

        // Set the current cell to the first cell of the matching row and move the grid's focus there
        stateManager.setCurrentCell(firstCell, i);

        // Ensure the row with the selected cell is visible (optional)
        stateManager.moveScrollByRow(TrinaMoveDirection.up, i);

        break;
      }
    }
  }

  List<Map<String, dynamic>> filterCommentsBySubject(
    List<Map<String, dynamic>> comments,
    String subjectName,
  ) {
    return comments
        .where((comment) => comment['subject'] == subjectName)
        .toList();
  }

  Future<void> showCommentsDialog(BuildContext context,
      List<Map<String, dynamic>> comments, String subjectName) async {
    final filteredComments = filterCommentsBySubject(comments, subjectName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Asigna comentarios:\nAlumno: $selectedStudentName\nMateria: $subjectName'),
          titleTextStyle: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20,
              color: FlutterFlowTheme.of(context).primaryText),
          content: SingleChildScrollView(
              child: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: Column(
              children: filteredComments.map((comment) {
                return StatefulBuilder(builder: (context, setState) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(comment[
                            'commentName']), // Assuming 'comment' instead of 'comentname'
                        trailing: Checkbox(
                            value: comment['active'],
                            onChanged: (newValue) async {
                              var studentRateId = comment['student_rate'];
                              var commentId = comment['comment'];
                              var activevalue = newValue;

                              await putStudentEvaluationsComments(
                                  studentRateId, commentId, activevalue!);
                              setState(() => comment['active'] = newValue!);
                            }),
                      )
                    ],
                  );
                });
              }).toList(),
            ),
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveButtonAction(int? monthNumber) async {
    await patchStudentGradesToDB().then((response) {
      return;
/* if (response == 200) {
      if (context.mounted) {
       showInformationDialog(context, 'Èxito', 'Cambios realizados!');

        searchBUttonAction(
          selectedTempGroup!,
          selectedTempGrade!,
          monthNumber!,
          selectedTempCampus!,
        );
      } else {
        if (context.mounted) {
          setState(() {
            isFetching = false;
            studentGradesBodyToUpgrade.clear();
          });
          showErrorFromBackend(context, response.toString());
        }
      }
    } */
    }).onError((error, stackTrace) {
      throw Future.error(error.toString());
    });
  }

  Future<void> loadSelectedStudent(
      String studentID, int? gradeInt, int month) async {
    selectedStudentList.clear();

    selectedStudentList =
        studentList.where((student) => student.studentID == studentID).toList();

    setState(() {
      selectedStudentRows.clear();
      for (var student in selectedStudentList) {
        selectedStudentRows.add(TrinaRow(cells: {
          'subject': TrinaCell(value: student.subject),
          'subject_name':
              TrinaCell(value: student.subjectName!.trim().toTitleCase),
          'evaluation': TrinaCell(value: student.evaluation),
          // 'eval_type': TrinaCell(value: student.),
          'absence_eval': TrinaCell(value: student.absence),
          'homework_eval': TrinaCell(value: student.homework),
          'discipline_eval': TrinaCell(value: student.discipline),
          'comment': TrinaCell(value: student.comment),
          'habit_eval': TrinaCell(value: student.habits_evaluation),
          'other': TrinaCell(value: student.other),
          'outfit': TrinaCell(value: student.outfit),
          'idCicloEscolar': TrinaCell(value: student.rateID),
        }));
      }
    });

    // if (gradeInt! >= 6) {
    //   commentsAsignatedList =
    //       await populateAsignatedComments(gradeInt!, month, true, studentID);
    // }
  }

  void displayColumnsByGrade(int grade) {
    if (grade < 12) {
      hideCommentsColumn = false;
      hideAbsencesColumn = true; // Faltas
      hideHomeworksColumn = true; // Tareas
      hideDisciplineColumn = false; //Disciplina
      hideHabitsColumn = false;
      hideOutfitColumn = false;
      homeWorkColumnTitle = 'Hab';
      disciplineColumnTitle = 'Con';
    } else if (grade < 6) {
      hideCommentsColumn = false;
      hideAbsencesColumn = true; // Faltas
      hideHomeworksColumn = true; // Tareas
      hideDisciplineColumn = true; //Disciplina
      hideHabitsColumn = true;
      hideOutfitColumn = true;
    } else {
      hideCommentsColumn = false;
      hideAbsencesColumn = false; // Faltas
      hideHomeworksColumn = false; // Tareas
      hideDisciplineColumn = false; //Disciplina
      hideHabitsColumn = true;
      hideOutfitColumn = true;
      homeWorkColumnTitle = 'R';
    }
  }
}
