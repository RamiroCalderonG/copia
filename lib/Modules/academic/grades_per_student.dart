import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/Models/Student_eval.dart';

import 'package:oxschool/constants/User.dart';
import 'package:oxschool/constants/date_constants.dart';
import 'package:oxschool/reusable_methods/academic_functions.dart';
import 'package:oxschool/reusable_methods/user_functions.dart';
import 'package:oxschool/temp/teacher_grades_temp.dart';

import 'package:pluto_grid/pluto_grid.dart';

import '../../backend/api_requests/api_calls_list.dart';
import '../../components/multiselector_widget.dart';
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
  late PlutoGridStateManager gridBStateManager;
  late PlutoGridStateManager gridAStateManager;
  Key? currentRowKey;
  Timer? _debounce;
  String? asignatureIDListener;
  var gradeInt;

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
    evaluationComments.clear();
    commentStringEval.clear();
    _debounce?.cancel();
    super.dispose();
  }

  void gridAHandler() {
    if (gridAStateManager.currentRow == null) {
      return;
    }

    if (gridAStateManager.currentRow!.key != currentRowKey) {
      currentRowKey = gridAStateManager.currentRow!.key;

      gridBStateManager.setShowLoading(true, notify: true);

      fetchUserActivity(); //Fetch comments stored by assignature
    }
  }

  void fetchUserActivity() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      Future.delayed(const Duration(milliseconds: 300), () {
        // setState(() {
        //   // gridBStateManager.removeRows(gridBStateManager.rows);
        //   // gridBStateManager.resetCurrentState();
        //   // gridBStateManager.appendRows(rows);
        // });

        gridBStateManager.setShowLoading(false);
      });
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
      await populateCommentsGrid(studentsGradesCommentsRows);

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
    String dropDownValue = ''; //oneTeacherAssignatures.first;

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
                      if (studentList.isNotEmpty) {
                        studentList.clear();
                      }

                      int? monthNumber;

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
                      gradeInt =
                          getKeyFromValue(teacherGradesMap, gradeSelected);

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
                      backgroundColor: Colors.red[400],
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
                                  onRowDoubleTap: (event) {
                                    selectedStudentID =
                                        event.row.cells['studentID']!.value;
                                    loadSelectedStudent(selectedStudentID!);
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
                              child: LayoutBuilder(builder:
                                  (BuildContext context,
                                      BoxConstraints constraints) {
                                if (selectedStudentRows.isNotEmpty) {
                                  return PlutoDualGrid(
                                    gridPropsA: PlutoDualGridProps(
                                        //Middle grid with eval values
                                        columns: gradesByStudentColumns,
                                        rows: selectedStudentRows,
                                        onChanged: (event) {
                                          var newValue = validateNewGradeValue(
                                              event.value.toString(),
                                              event.column.title);

                                          final subjectID =
                                              event.row.cells['subject']?.value;
                                          if (isUserAdmin == true) {
                                            monthNumber = getKeyFromValue(
                                                monthsListMap, monthValue);
                                          } else {
                                            monthNumber = getKeyFromValue(
                                                monthsListMap, currentMonth);
                                          }

                                          composeBodyToUpdateGradeBySTudent(
                                            event.column.title,
                                            selectedStudentID!,
                                            newValue,
                                            subjectID,
                                            monthNumber,
                                          );
                                        },
                                        onRowDoubleTap: (event) {
                                          asignatureIDListener = '';
                                          asignatureIDListener = event
                                              .row!.cells['subject']?.value
                                              .toString();
                                          print(event
                                              .row!.cells['subject']!.value
                                              .toString());
                                        },
                                        // onRowChecked:
                                        //     (PlutoGridOnRowCheckedEvent event) {
                                        //   asignatureIDListener = event
                                        //       .row!.cells['subject']?.value;
                                        //   print(asignatureIDListener);
                                        //   // print(event
                                        //   //     .row!.cells['idcomment']?.value);
                                        // },
                                        onLoaded:
                                            (PlutoGridOnLoadedEvent event) {
                                          gridAStateManager =
                                              event.stateManager;
                                          event.stateManager
                                              .addListener(gridAHandler);
                                        },
                                        configuration:
                                            const PlutoGridConfiguration(
                                          style: PlutoGridStyleConfig(
                                            enableColumnBorderVertical: false,
                                            enableCellBorderVertical: false,
                                          ),
                                          columnSize: PlutoGridColumnSizeConfig(
                                            autoSizeMode:
                                                PlutoAutoSizeMode.scale,
                                            resizeMode:
                                                PlutoResizeMode.pushAndPull,
                                          ),
                                        )),
                                    gridPropsB: PlutoDualGridProps(
                                      columns: commentsCollumns,
                                      rows: evaluationComments,
                                      configuration:
                                          const PlutoGridConfiguration(
                                        style: PlutoGridStyleConfig(
                                          enableColumnBorderVertical: false,
                                          enableCellBorderVertical: false,
                                        ),
                                        columnSize: PlutoGridColumnSizeConfig(
                                          autoSizeMode: PlutoAutoSizeMode.scale,
                                          resizeMode:
                                              PlutoResizeMode.pushAndPull,
                                        ),
                                      ),
                                      onLoaded: (PlutoGridOnLoadedEvent event) {
                                        gridBStateManager = event.stateManager;
                                      },
                                      // onRowChecked:
                                      //     (PlutoGridOnRowCheckedEvent event) {
                                      //   print(event
                                      //       .row!.cells['idcomment']?.value);
                                      // }
                                    ),
                                    display:
                                        PlutoDualGridDisplayRatio(ratio: 0.8),
                                  );
                                } else {
                                  return const Placeholder(
                                    child: Center(
                                      child: Text(
                                          'Seleccione un alumno dando doble click para evaluar'),
                                    ),
                                  );
                                }
                              })),
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

  void loadSelectedStudent(String studentID) {
    selectedStudentList.clear();

    selectedStudentList =
        studentList.where((student) => student.studentID == studentID).toList();

    setState(() {
      selectedStudentRows.clear();
      for (var student in selectedStudentList) {
        selectedStudentRows.add(PlutoRow(cells: {
          'subject': PlutoCell(value: student.subject),
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
  }
}
