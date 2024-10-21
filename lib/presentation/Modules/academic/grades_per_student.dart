import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/data/Models/Student_eval.dart';

import 'package:oxschool/core/constants/User.dart';
import 'package:oxschool/core/constants/date_constants.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/data/datasources/temp/teacher_grades_temp.dart';

import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/reusable_methods/logger_actions.dart';
import '../../../core/reusable_methods/translate_messages.dart';
import '../../../core/utils/loader_indicator.dart';
import '../../../data/datasources/temp/studens_temp.dart';
import '../../../data/services/backend/api_requests/api_calls_list.dart';
import '../../../core/constants/Student.dart';
import '../../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../../core/reusable_methods/reusable_functions.dart';
import '../../components/confirm_dialogs.dart';
import '../../components/custom_icon_button.dart';
import '../../components/teacher_eval_dropdownmenu.dart';

class GradesByStudent extends StatefulWidget {
  const GradesByStudent({super.key});

  @override
  State<GradesByStudent> createState() => _GradesByStudentState();
}

String currentMonth = DateFormat.MMMM().format(DateTime.now());

String? subjectSelected = oneTeacherAssignatures.first;
bool isUserAdmin = verifyUserAdmin(currentUser!);
List<PlutoRow> rows = [];

class _GradesByStudentState extends State<GradesByStudent> {
  var commentsController = TextEditingController();
  late PlutoGridStateManager stateManager;

  late PlutoGridStateManager gridAStateManager;

  Key? currentRowKey;
  Timer? _debounce;
  String? asignatureNameListener;
  String selectedStudentName = '';

  String dropDownValue = ''; //oneTeacherAssignatures.first;
  int? assignatureID;

  String? selectedStudentID;

  @override
  void initState() {
    loadStartGrading(currentUser!.employeeNumber!, currentCycle!.claCiclo!);
    super.initState();
  }

  @override
  void dispose() {
    studentsGradesCommentsRows.clear();
    evaluationComments.clear();
    commentStringEval.clear();
    _debounce?.cancel();
    selectedTempGrade = null;
    selectedTempGroup = null;
    selectedTempStudent = null;
    selectedTempCampus = null;
    selectedTempMonth = null;
    selectedCurrentTempMonth = null;
    super.dispose();
  }

  Future<void> fillGrid(List<StudentEval> evaluationList) async {
    Set<String> studentSet = {};
    List<Map<String, String>> uniqueStudents = [];

    for (var student in evaluationList) {
      if (!studentSet.contains(student.studentID)) {
        studentSet.add(student.studentID);
        uniqueStudents.add({
          'studentID': student.studentID,
          'studentName': student.fulllName!,
        });

        // print(uniqueStudents.toString());
      }
    }
    setState(() {
      rows = uniqueStudents.map((item) {
        return PlutoRow(
          cells: {
            'studentID': PlutoCell(value: item.containsKey('StudentID')),
            'studentName': PlutoCell(value: item.containsKey('studentName')),
          },
        );
      }).toList();
    });
  }

  Future<void> populateCommentsGrid(List<Map<String, String>> comments) async {
    if (studentsGradesCommentsRows.isNotEmpty) {
      setState(() {
        evaluationComments = comments.map((item) {
          return PlutoRow(cells: {
            'idcomment': PlutoCell(value: item['idcomment']),
            'comentname': PlutoCell(value: item['comentname']),
          });
        }).toList();
      });
    }
  }

  void searchBUttonAction(String groupSelected, String gradeString,
      int monthSelected, String campusSelected) async {
    try {
      var gradeInt = getKeyFromValue(teacherGradesMap, gradeString!);
      if (studentList.isNotEmpty && studentsGradesCommentsRows.isNotEmpty) {
        studentList.clear();
        studentsGradesCommentsRows.clear();
      }
      studentList = await getSubjectsAndGradesByStudent(gradeInt.toString(),
          groupSelected, currentCycle!.claCiclo, campusSelected, monthSelected);

      if (gradeInt! >= 6) {
        await getCommentsForEvals(gradeInt!);
      }

      fillGrid(studentList); //Fill student list by unque values
      var studentNumber = 0;

      setState(() {
        studentEvaluationRows.clear();
        for (var item in uniqueStudentsList) {
          studentEvaluationRows.add(PlutoRow(cells: {
            'No': PlutoCell(value: studentNumber + 1),
            'studentID': PlutoCell(value: item['studentID']),
            'studentName': PlutoCell(value: item['studentName']),
          }));
          studentNumber++;
        }
      });
    } catch (e) {
      if (context.mounted) {
        insertErrorLog(e.toString(), 'SEARCH STUDENTS');
        var displayMessage = e.toString().split(" ").elementAt(0);
        displayMessage = getMessageToDisplay(displayMessage.toString());

        // ensures the widget is still part of the widget tree after the await
        showErrorFromBackend(context, displayMessage.toString());
      }
    }
  }

  dynamic patchStudentGradesToDB() async {
    var response = await patchStudentsGrades(studentGradesBodyToUpgrade, true);
    if (response == 200) {
      return 200;
    } else {
      return response;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadStartGrading(
          currentUser!.employeeNumber!, currentCycle!.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CustomLoadingIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data available'));
        } else {
          return Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth > 600) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [_buildGradesPerStudent()],
                          )
                        ],
                      ),
                    );
                  } else {
                    return const Placeholder(
                      child: Text('Smaller screen version pending to design'),
                    );
                  }
                }),
              )
            ],
          );
        }
      },
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
                Flexible(child: RefreshButton(onPressed: () {
                  var monthNumber;
                  if (isUserAdmin) {
                    monthNumber =
                        getKeyFromValue(monthsListMap, selectedTempMonth!);
                  } else {
                    monthNumber = getKeyFromValue(
                        monthsListMap, selectedCurrentTempMonth!);
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
                  if (monthNumber == null || monthNumber == '') {
                    return showEmptyFieldAlertDialog(
                        context, 'Seleccionar un mes a evaluar');
                  } else {
                    searchBUttonAction(
                      selectedTempGroup!,
                      selectedTempGrade!,
                      monthNumber,
                      selectedTempCampus!,
                    );
                  }
                })),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: SaveItemButton(
                    onPressed: () {
                      if (studentGradesBodyToUpgrade.isEmpty) {
                        showEmptyFieldAlertDialog(
                            context, 'No se detectó ningun cambio a realizar');
                      } else {
                        var monthNumber;
                        if (isUserAdmin) {
                          monthNumber = getKeyFromValue(
                              monthsListMap, selectedTempMonth!);
                        } else {
                          monthNumber = getKeyFromValue(
                              monthsListMap, selectedCurrentTempMonth!);
                        }
                        saveButtonAction(monthNumber);
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
              )
            ],
          ),
          const Divider(thickness: 1),
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.5,
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
                              child: PlutoGrid(
                                  //Grid for students name and ID
                                  columns: studentColumnsToEvaluateByStudent,
                                  rows: studentEvaluationRows,
                                  mode: PlutoGridMode.select,
                                  onRowDoubleTap: (event) async {
                                    var gradeInt = getKeyFromValue(
                                        teacherGradesMap, selectedTempGrade!);
                                    var selectedmonth;
                                    int? monthNumber;

                                    if (isUserAdmin == true) {
                                      monthNumber = getKeyFromValue(
                                          monthsListMap, selectedTempMonth!);
                                    } else {
                                      monthNumber = getKeyFromValue(
                                          monthsListMap,
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
                                        PlutoGridSelectingMode.cell);
                                    PlutoGridStateManager stateManager =
                                        event.stateManager;

                                    // Select the row where the 'nameColumn' matches 'John Doe'
                                    selectRowByName(stateManager, 'studentName',
                                        selectedStudentName);
                                  },
                                  configuration: const PlutoGridConfiguration(
                                    style: PlutoGridStyleConfig(
                                      enableColumnBorderVertical: false,
                                      enableCellBorderVertical: false,
                                    ),
                                  ),
                                  createFooter: (stateManager) {
                                    stateManager.setPageSize(20,
                                        notify: false); // default 40
                                    return PlutoPagination(stateManager);
                                  })),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 3,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return Column(
                                  children: [
                                    Expanded(
                                      child: selectedStudentRows.isNotEmpty
                                          ? PlutoGrid(
                                              // mode: PlutoGridMode.select,
                                              columns: gradesByStudentColumns,
                                              rows: selectedStudentRows,
                                              onChanged: (event) {
                                                var newValue =
                                                    validateNewGradeValue(
                                                        event.value,
                                                        event.column.title);

                                                final subjectID = event.row
                                                    .cells['subject']?.value;
                                                var monthNumber;
                                                if (isUserAdmin == true) {
                                                  monthNumber = getKeyFromValue(
                                                      monthsListMap,
                                                      selectedTempMonth!);
                                                } else {
                                                  monthNumber = getKeyFromValue(
                                                      monthsListMap,
                                                      currentMonth);
                                                }

                                                validator();
                                                composeBodyToUpdateGradeBySTudent(
                                                  event.column.title,
                                                  selectedStudentID!,
                                                  newValue,
                                                  subjectID,
                                                  monthNumber,
                                                );
                                              },
                                              onRowSecondaryTap: (event) async {
                                                var gradeInt = getKeyFromValue(
                                                    teacherGradesMap,
                                                    selectedTempGrade!);
                                                asignatureNameListener = '';
                                                asignatureNameListener = event
                                                    .row
                                                    .cells['subject_name']
                                                    ?.value
                                                    .toString();

                                                if (gradeInt! >= 6) {
                                                  await showCommentsDialog(
                                                      context,
                                                      commentsAsignated,
                                                      asignatureNameListener!);
                                                } else {
                                                  showInformationDialog(
                                                      context,
                                                      'Aviso',
                                                      'Sin comentarios disponibles a asignar al alumno seleccionado');
                                                }
                                              },
                                              onLoaded: (PlutoGridOnLoadedEvent
                                                  event) {
                                                gridAStateManager =
                                                    event.stateManager;
                                              },
                                              configuration:
                                                  const PlutoGridConfiguration(
                                                style: PlutoGridStyleConfig(
                                                  enableColumnBorderVertical:
                                                      false,
                                                  enableCellBorderVertical:
                                                      false,
                                                ),
                                                columnSize:
                                                    PlutoGridColumnSizeConfig(
                                                  autoSizeMode:
                                                      PlutoAutoSizeMode.scale,
                                                  resizeMode: PlutoResizeMode
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

  void selectRowByName(PlutoGridStateManager stateManager, String columnField,
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
        stateManager.moveScrollByRow(PlutoMoveDirection.up, i);

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

  void saveButtonAction(int? monthNumber) async {
    var response = await patchStudentGradesToDB();

    if (response == 200) {
      if (context.mounted) {
        showConfirmationDialog(
            context, 'Actualizado', 'Cambios realizados con exito');
        searchBUttonAction(
          selectedTempGroup!,
          selectedTempGrade!,
          monthNumber!,
          selectedTempCampus!,
        );
      } else {
        if (context.mounted) {
          showErrorFromBackend(context, response.toString());
        }
      }
    }
  }

  Future<void> loadSelectedStudent(
      String studentID, int? gradeInt, int month) async {
    selectedStudentList.clear();

    selectedStudentList =
        studentList.where((student) => student.studentID == studentID).toList();

    setState(() {
      selectedStudentRows.clear();
      for (var student in selectedStudentList) {
        selectedStudentRows.add(PlutoRow(cells: {
          'subject': PlutoCell(value: student.subject),
          'subject_name': PlutoCell(value: student.subjectName),
          'evaluation': PlutoCell(value: student.evaluation),
          // 'eval_type': PlutoCell(value: student.),
          'absence_eval': PlutoCell(value: student.absence),
          'homework_eval': PlutoCell(value: student.homework),
          'discipline_eval': PlutoCell(value: student.discipline),
          // 'comment': PlutoCell(value: student.comment),
          'habit_eval': PlutoCell(value: student.habits_evaluation),
          'other': PlutoCell(value: student.other),
          'outfit': PlutoCell(value: student.outfit),
        }));
      }
    });

    if (gradeInt! >= 6) {
      commentsAsignatedList =
          await populateAsignatedComments(gradeInt!, month, true, studentID);
    }
  }

  Future<List<PlutoRow>> populateAsignatedComments(
      int grade, month, bool byStudent, String studentid) async {
    commentsAsignated.clear();
    commentsAsignated =
        await getCommentsAsignatedToStudent(grade, byStudent, studentid, month);

    return rows;
  }
}
