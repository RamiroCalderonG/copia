import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/Models/Student_eval.dart';

import 'package:oxschool/constants/User.dart';
import 'package:oxschool/constants/date_constants.dart';
import 'package:oxschool/reusable_methods/academic_functions.dart';
import 'package:oxschool/reusable_methods/user_functions.dart';
import 'package:oxschool/temp/teacher_grades_temp.dart';

import 'package:pluto_grid/pluto_grid.dart';

import '../../backend/api_requests/api_calls_list.dart';
import '../../constants/Student.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../reusable_methods/reusable_functions.dart';

class GradesByStudent extends StatefulWidget {
  const GradesByStudent({super.key});

  @override
  State<GradesByStudent> createState() => _GradesByStudentState();
}

String currentMonth = DateFormat.MMMM().format(DateTime.now());

String? subjectSelected = oneTeacherAssignatures.first;
bool isUserAdmin = verifyUserAdmin(currentUser!);
List<PlutoRow> rows = [];
int? monthNumber;

class _GradesByStudentState extends State<GradesByStudent> {
  String groupSelected = ''; // = oneTeacherGroups.first.toString();
  String gradeSelected = ''; // = oneTeacherAssignatures.first;
  String monthValue = monthsList.first;
  var commentsController = TextEditingController();
  late PlutoGridStateManager stateManager;
  // late PlutoGridStateManager gridBStateManager;
  late PlutoGridStateManager gridAStateManager;

  Key? currentRowKey;
  Timer? _debounce;
  String? asignatureNameListener;
  String selectedStudentName = '';
  var gradeInt;
  int? monthNumber;
  // int? monthNumber;
  String dropDownValue = ''; //oneTeacherAssignatures.first;
  int? assignatureID;

  String? selectedStudentID;

  @override
  void initState() {
    // loadStartGrading(currentUser!.employeeNumber!, currentCycle!.claCiclo!);
    loadStartGrading(currentUser!.employeeNumber!, currentCycle!.claCiclo!);
    super.initState();
  }

  @override
  void dispose() {
    studentsGradesCommentsRows.clear();
    // studentGradesBodyToUpgrade.clear();
    evaluationComments.clear();
    commentStringEval.clear();
    _debounce?.cancel();
    super.dispose();
  }

  // void gridAHandler() {
  //   if (gridAStateManager.currentRow == null) {
  //     return;
  //   }

  //   if (gridAStateManager.currentRow!.key != currentRowKey) {
  //     currentRowKey = gridAStateManager.currentRow!.key;

  //     gridBStateManager.setShowLoading(true, notify: true);

  //     fetchUserActivity(); //Fetch comments stored by assignature
  //   }
  // }

  // void fetchUserActivity() {
  //   if (_debounce?.isActive ?? false) {
  //     _debounce!.cancel();
  //   }

  //   _debounce = Timer(const Duration(milliseconds: 300), () {
  //     Future.delayed(const Duration(milliseconds: 300), () {
  //       // setState(() {
  //       //   // gridBStateManager.removeRows(gridBStateManager.rows);
  //       //   // gridBStateManager.resetCurrentState();
  //       //   // gridBStateManager.appendRows(rows);
  //       // });

  //       gridBStateManager.setShowLoading(false);
  //     });
  //   });
  // }

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

  void searchBUttonAction(String groupSelected, gradeInt, monthNumber) async {
    try {
      if (studentList.isNotEmpty && studentsGradesCommentsRows.isNotEmpty) {
        studentList.clear();
        studentsGradesCommentsRows.clear();
      }
      studentList = await getSubjectsAndGradesByStudent(gradeInt, groupSelected,
          currentCycle!.claCiclo, currentUser!.claUn, monthNumber);

      await getCommentsForEvals(int.parse(gradeInt));
      // await populateCommentsGrid(studentsGradesCommentsRows); <----WORKING WELL

      // List<Map<String, dynamic>> mergedData =
      //     mergeCommentsData(apiData1, apiData2);

      fillGrid(studentList); //Fill student list by unque values
      var studentNumber = 1;

      setState(() {
        studentEvaluationRows.clear();
        for (var item in uniqueStudentsList) {
          studentEvaluationRows.add(PlutoRow(cells: {
            'No': PlutoCell(value: studentNumber),
            'studentID': PlutoCell(value: item['studentID']),
            'studentName': PlutoCell(value: item['studentName']),
          }));
          studentNumber++;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 20,
          content: Text(
            e.toString(),
            // ignore: use_build_context_synchronously
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  fontFamily: 'Sora',
                  color: const Color(0xFF130C0D),
                  fontWeight: FontWeight.w500,
                ),
          ),
          action: SnackBarAction(
              label: 'Cerrar mensaje',
              // ignore: use_build_context_synchronously
              textColor: FlutterFlowTheme.of(context).info,
              backgroundColor: Colors.black12,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }),
          duration: const Duration(milliseconds: 6700),
          backgroundColor:
              // ignore: use_build_context_synchronously
              FlutterFlowTheme.of(context).secondary,
        ),
      );
    }
  }

  dynamic patchStudentGradesToDB() async {
    var response = await patchStudentsGrades(studentGradesBodyToUpgrade, true);
    if (response == 200) {
      return 200;
    } else {
      return 400;
    }

    // return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadStartGrading(
          currentUser!.employeeNumber!, currentCycle!.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
    //String dropDownValue = ''; //oneTeacherAssignatures.first;

    final DropdownMenu monthSelectorButton = DropdownMenu<String>(
      initialSelection: monthValue, //monthsList.first,
      onSelected: (String? value) {
        monthValue = value!;
      },
      dropdownMenuEntries:
          monthsList.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );

    final DropdownMenu gradeSelectorButton2 = DropdownMenu<String>(
      initialSelection: oneTeacherGrades.first,
      onSelected: (String? value) {
        gradeSelected = value!;
      },
      dropdownMenuEntries:
          oneTeacherGrades.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );

    final DropdownMenu groupSelectorButton = DropdownMenu<String>(
      initialSelection: oneTeacherGroups.first,
      onSelected: (String? value) {
        groupSelected = value!;
      },
      dropdownMenuEntries:
          oneTeacherGroups.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grado:',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gradeSelectorButton2,
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grupo:',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      groupSelectorButton,
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mes:',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isUserAdmin == false)
                        Text(
                          currentMonth,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        monthSelectorButton,
                    ],
                  ),
                ),
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      studentGradesBodyToUpgrade.clear();
                      selectedStudentName = '';
                      validator();
                      searchBUttonAction(
                        groupSelected,
                        gradeInt.toString(),
                        monthNumber.toString(),
                      );

                      setState(() {
                        selectedStudentRows.clear();
                      });
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar'),
                  ),
                ),
                Flexible(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.red[400],
                        ),
                    onPressed: () async {
                      if (studentGradesBodyToUpgrade.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            elevation: 20,
                            content: Text(
                              'Sin información para actualizar, verifique su captura',
                              // ignore: use_build_context_synchronously
                              style: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Sora',
                                    color: const Color(0xFF130C0D),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            action: SnackBarAction(
                                label: 'Copiar mensaje a portapapeles',
                                // ignore: use_build_context_synchronously
                                textColor: FlutterFlowTheme.of(context).info,
                                backgroundColor: Colors.black12,
                                onPressed: () {
                                  Clipboard.setData(const ClipboardData(
                                      text:
                                          'Sin información para enviar, verifique su captura '));
                                }),
                            duration: const Duration(milliseconds: 6700),
                            backgroundColor:
                                // ignore: use_build_context_synchronously
                                FlutterFlowTheme.of(context).secondary,
                          ),
                        );
                      } else {
                        var response;
                        try {
                          response = await patchStudentGradesToDB();
                        } catch (e) {
                          print(e);
                        }
                        if (response == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Cambios guardados con exito!',
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Roboto',
                                      color: const Color(0xFF130C0D),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              duration: const Duration(milliseconds: 6000),
                              backgroundColor: Colors.green[200]));
                          if (studentList.isNotEmpty) {
                            studentList.clear();
                          }

                          if (groupSelected.isEmpty || groupSelected == '') {
                            groupSelected = oneTeacherGroups.first.toString();
                          }
                          if (gradeSelected.isEmpty || gradeSelected == '') {
                            gradeSelected = oneTeacherGrades.first;
                          }
                          if (dropDownValue.isEmpty || dropDownValue == '') {
                            dropDownValue = oneTeacherAssignatures.first;
                          }
                          if (monthValue.isEmpty) {
                            monthValue = monthsList.first;
                          }

                          if (isUserAdmin == true) {
                            monthNumber =
                                getKeyFromValue(monthsListMap, monthValue);
                          } else {
                            monthNumber =
                                getKeyFromValue(monthsListMap, currentMonth);
                          }
                          var gradeInt =
                              getKeyFromValue(teacherGradesMap, gradeSelected);
                          // validator();
                          searchBUttonAction(
                            groupSelected,
                            gradeInt.toString(),
                            monthNumber.toString(),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Error: $response',
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Roboto',
                                      color: const Color(0xFF130C0D),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              duration: const Duration(milliseconds: 6000),
                              backgroundColor: Colors.green[200]));
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: selectedStudentName.isNotEmpty
                    ? Text(
                        'Evaluando a : $selectedStudentName',
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
              margin: const EdgeInsets.all(20),
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
                                  mode: PlutoGridMode.selectWithOneTap,
                                  onRowDoubleTap: (event) async {
                                    var gradeInt = getKeyFromValue(
                                        teacherGradesMap, gradeSelected);

                                    if (isUserAdmin == true) {
                                      monthNumber = getKeyFromValue(
                                          monthsListMap, monthValue);
                                    } else {
                                      monthNumber = getKeyFromValue(
                                          monthsListMap, currentMonth);
                                    }
                                    // validator();

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
                                  },
                                  configuration: const PlutoGridConfiguration(
                                    style: PlutoGridStyleConfig(
                                      enableColumnBorderVertical: false,
                                      enableCellBorderVertical: false,
                                    ),
                                  ),
                                  createFooter: (stateManager) {
                                    stateManager.setPageSize(30,
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
                                              columns: gradesByStudentColumns,
                                              rows: selectedStudentRows,
                                              onChanged: (event) {
                                                var newValue =
                                                    validateNewGradeValue(
                                                        event.value.toString(),
                                                        event.column.title);

                                                final subjectID = event.row
                                                    .cells['subject']?.value;
                                                // if (isUserAdmin == true) {
                                                //   monthNumber = getKeyFromValue(
                                                //       monthsListMap,
                                                //       monthValue);
                                                // } else {
                                                //   monthNumber = getKeyFromValue(
                                                //       monthsListMap,
                                                //       currentMonth);
                                                // }

                                                validator();
                                                composeBodyToUpdateGradeBySTudent(
                                                  event.column.title,
                                                  selectedStudentID!,
                                                  newValue,
                                                  subjectID,
                                                  monthNumber,
                                                );
                                              },
                                              onRowDoubleTap: (event) async {
                                                asignatureNameListener = '';
                                                asignatureNameListener = event
                                                    .row!
                                                    .cells['subject_name']
                                                    ?.value
                                                    .toString();
                                                await showCommentsDialog(
                                                    context,
                                                    commentsAsignated,
                                                    asignatureNameListener!);
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

  void validator() {
    if (studentList.isNotEmpty) {
      studentList.clear();
    }

    if (groupSelected.isEmpty || groupSelected == '') {
      groupSelected = oneTeacherGroups.first.toString();
    }
    if (gradeSelected.isEmpty || gradeSelected == '') {
      gradeSelected = oneTeacherGrades.first;
    }
    if (dropDownValue.isEmpty || dropDownValue == '') {
      dropDownValue = oneTeacherAssignatures.first;
    }
    if (monthValue.isEmpty) {
      monthValue = monthsList.first;
    }

    if (isUserAdmin == true) {
      monthNumber = getKeyFromValue(monthsListMap, monthValue);
    } else {
      monthNumber = getKeyFromValue(monthsListMap, currentMonth);
    }
    gradeInt = getKeyFromValue(teacherGradesMap, gradeSelected);

    assignatureID = getKeyFromValue(assignaturesMap, dropDownValue);
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
          'comment': PlutoCell(value: student.comment),
          'habit_eval': PlutoCell(value: student.habits_evaluation),
          'other': PlutoCell(value: student.other),
          'outfit': PlutoCell(value: student.outfit),
        }));
      }
    });

    commentsAsignatedList =
        await populateAsignatedComments(gradeInt!, month, true, studentID);
  }

  Future<List<PlutoRow>> populateAsignatedComments(
      int grade, month, bool byStudent, String studentid) async {
    commentsAsignated.clear();
    commentsAsignated =
        await getCommentsAsignatedToStudent(grade, byStudent, studentid, month);

    // setState(() {
    // mergedData.clear();
    // mergedData =
    //     mergeCommentsData(studentsGradesCommentsRows, commentsAsignated);

    // List<PlutoRow> rows = mergedData.map((item) {
    //   return PlutoRow(cells: {
    //     'idcomment': PlutoCell(value: item['idcomment']),
    //     'comentname': PlutoCell(value: item['comentname']),
    //     'is_active':
    //         PlutoCell(value: item['is_active'] ? 'Active' : 'Inactive'),
    //   });
    // }).toList();
    // });
    return rows;
  }
}
