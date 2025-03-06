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

import 'package:pluto_grid/pluto_grid.dart';

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

String? subjectSelected = oneTeacherAssignatures.first;

List<PlutoRow> rows = [];

class _GradesByStudentState extends State<GradesByStudent> {
  bool isUserAdmin = currentUser!.isCurrentUserAdmin();
  var commentsController = TextEditingController();
  late PlutoGridStateManager stateManager;
  late PlutoGridStateManager gridAStateManager;
  String currentMonth = DateFormat.MMMM('es').format(DateTime.now());

  Key? currentRowKey;
  Timer? _debounce;
  String? asignatureNameListener;
  String selectedStudentName = '';
  var fetchedData;
  bool isFetching = true;
  int? monthNumber;
  String dropDownValue = ''; //oneTeacherAssignatures.first;
  int? assignatureID;
  late Future<dynamic> _fetchedDataFromRequest;
  DateFormat? dateFormat;

  String? selectedStudentID;

  @override
  void initState() {
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
    var response = currentUser!.isCurrentUserAdmin()
        ? loadStartGradingAsAdmin(
            currentCycle!.claCiclo!, null, true, null, null, currentUser!.isCurrentUserAcademicCoord())
        : loadStartGrading(
            currentUser!.employeeNumber!,
            currentCycle!.toString(),
            currentUser!.isCurrentUserAdmin(),
            currentUser!.isCurrentUserAcademicCoord(),
            currentUser!.claUn);
    fetchedData = response;
    setState(() {
      isFetching = false;
    });
  }

  Future<void> fillGrid(List<StudentEval> evaluationList) async {
    Set<String> studentSet = {};
    List<Map<String, String>> uniqueStudents = [];

    for (var student in evaluationList) {
      if (!studentSet.contains(student.studentID)) {
        studentSet.add(student.studentID);
        uniqueStudents.add({
          'studentID': student.studentID,
          'student': student.fulllName!,
        });
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
      studentList = await getSubjectsAndGradesByStudent(
          grade,
          groupSelected,
          currentCycle!.claCiclo!,
          campusSelected,
          monthSelected);

      fillGrid(studentList); //Fill student list by unque values
      int studentNumber = 1;

      setState(() {
        studentEvaluationRows.clear();
        for (var item in uniqueStudentsList) {
          studentEvaluationRows.add(PlutoRow(cells: {
            'No': PlutoCell(value: studentNumber),
            'studentID': PlutoCell(value: item['studentID']!.trim()),
            'studentName':
                PlutoCell(value: item['studentName']!.trim().toTitleCase),
          }));
          studentNumber++;
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
                  if (isUserAdmin) {
                    //Calendar month number
                    monthNumber =
                        getKeyFromValue(spanishMonthsMap, selectedTempMonth!);
                  } else {
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
                  if (selectedTempCampus == null || selectedTempCampus == '') {
                    return showEmptyFieldAlertDialog(
                        context, 'Seleccionar un campus a evaluar');
                  }
                  if (monthNumber == null || monthNumber == '') {
                    return showEmptyFieldAlertDialog(
                        context, 'Seleccionar un mes a evaluar');
                  } else {
                    setState(() {
                      isFetching = true;
                    });
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
                          if (isUserAdmin) {
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
                              showInformationDialog(context, 'Èxito', 'Cambios realizados!');
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
                              child: PlutoGrid(
                                  //Grid for students name and ID
                                  columns: studentColumnsToEvaluateByStudent,
                                  rows: studentEvaluationRows,
                                  mode: PlutoGridMode.select,
                                  onRowDoubleTap: (event) async {
                                    var gradeInt = getKeyFromValue(
                                        teacherGradesMap,
                                        selectedTempGrade!.toString());
                                    var selectedmonth;
                                    int? monthNumber;

                                    if (isUserAdmin == true) {
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
                            flex: 2,
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
                                                final evalId = event
                                                    .row
                                                    .cells['idCicloEscolar']
                                                    ?.value;
                                                int? monthNumber;
                                                if (isUserAdmin == true) {
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

  Future<void> saveButtonAction(int? monthNumber) async {
    await patchStudentGradesToDB().then((response){
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
    }).onError((error, stackTrace){
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
        selectedStudentRows.add(PlutoRow(cells: {
          'subject': PlutoCell(value: student.subject),
          'subject_name':
              PlutoCell(value: student.subjectName!.trim().toTitleCase),
          'evaluation': PlutoCell(value: student.evaluation),
          // 'eval_type': PlutoCell(value: student.),
          'absence_eval': PlutoCell(value: student.absence),
          'homework_eval': PlutoCell(value: student.homework),
          'discipline_eval': PlutoCell(value: student.discipline),
          // 'comment': PlutoCell(value: student.comment),
          'habit_eval': PlutoCell(value: student.habits_evaluation),
          'other': PlutoCell(value: student.other),
          'outfit': PlutoCell(value: student.outfit),
          'idCicloEscolar': PlutoCell(value: student.rateID),
        }));
      }
    });

    // if (gradeInt! >= 6) {
    //   commentsAsignatedList =
    //       await populateAsignatedComments(gradeInt!, month, true, studentID);
    // }
  }

  Future<List<PlutoRow>> populateAsignatedComments(
      int grade, month, bool byStudent, String studentid) async {
    commentsAsignated.clear();
    commentsAsignated =
        await getCommentsAsignatedToStudent(grade, byStudent, studentid, month);

    return rows;
  }
}
