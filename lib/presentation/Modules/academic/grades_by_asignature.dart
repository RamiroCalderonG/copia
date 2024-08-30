// ignore_for_file: constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/User.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

import '../../../data/Models/Student_eval.dart';

import '../../../data/services/backend/api_requests/api_calls_list.dart';
import '../../../core/constants/Student.dart';
import '../../../core/constants/date_constants.dart';
import '../../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../../core/config/flutter_flow/flutter_flow_util.dart';
import '../../../core/reusable_methods/academic_functions.dart';
import '../../../core/reusable_methods/user_functions.dart';
import '../../../data/datasources/temp/teacher_grades_temp.dart';
import '../../components/confirm_dialogs.dart';
import '../../components/student_eval_comments_dialog.dart';
import '../../components/teacher_eval_dropdownmenu.dart';

/// A widget for displaying grades by assignature.
///
/// This widget fetches data from the backend and displays it in a grid.
/// It also provides functionality for searching, updating, and saving grades.
///
/// Example:
///
/// ```dart
/// GradesByAsignature(
///   // Optional parameters
///   // ...
/// )
/// ```

class GradesByAsignature extends StatefulWidget {
  const GradesByAsignature({super.key});

  @override
  State<GradesByAsignature> createState() => _GradesByAsignatureState();
}

/// The current month.
String currentMonth = DateFormat.MMMM().format(DateTime.now());

/// The selected subject.
String? subjectSelected = oneTeacherAssignatures.first;

/// Whether the user is an admin.
bool isUserAdmin = verifyUserAdmin(currentUser!);

/// The list of rows in the grid.
List<PlutoRow> rows = [];

/// The selected group.
String groupSelected = '';

/// The selected grade.

String gradeSelected = '';

/// The selected subject value.

String subjectValue = '';

class _GradesByAsignatureState extends State<GradesByAsignature> {
  // = oneTeacherGroups.first.toString();
  // = oneTeacherAssignatures.first;
  String? asignatureNameListener;
  String? selectedStudentName;
  var gradeInt;
  int? monthNumber;
  String monthValue = isUserAdmin ? academicMonthsList.first : currentMonth;
  // int? monthNumber;
  //oneTeacherAssignatures.first;
  int? assignatureID;
  String campusSelected = '';

  /// Whether the teacher teaches multiple campuses.
  bool teacherTeachMultipleCampuses = false;

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  // oneTeacherGrades.clear();
  // oneTeacherGroups.clear();
  // oneTeacherAssignatures.clear();
  // oneTeacherStudents.clear();
  // oneTeacherStudentID.clear();
  // assignaturesMap.clear();
  // studentList.clear();
  // assignatureRows.clear();
  // assignaturesColumns.clear();
  // studentGradesBodyToUpgrade.clear();
  // super.dispose();
  // }

  /// Fills the grid with data from the backend.
  ///
  /// [//evaluationList] is the list of evaluations to display in the grid.
  Future<void> fillGrid(List<StudentEval> evaluationList) async {
    setState(() {
      rows = evaluationList.map((item) {
        return PlutoRow(
          cells: {
            // 'Matricula': PlutoCell(value: item.studentID),
            'Nombre': PlutoCell(value: item.studentName),
            'Apellido paterno': PlutoCell(value: item.student1LastName),
            'Apellido materno': PlutoCell(value: item.student2LastName),
          },
        );
      }).toList();
    });
  }

  /// Searches for grades based on the selected parameters.
  ///
  /// [groupSelected] is the selected group.
  /// [gradeInt] is the selected grade.
  /// [assignatureID] is the selected assignature ID.
  /// [monthNumber] is the selected month number.
  /// [campus] is the selected campus.
  void searchBUttonAction(String groupSelected, gradeInt, assignatureID,
      monthNumber, campus) async {
    try {
      studentList = await getStudentsByAssinature(
          groupSelected,
          gradeInt.toString(),
          assignatureID.toString(),
          monthNumber.toString(),
          campus);

      await getCommentsForEvals(int.parse(gradeInt));
      fillGrid(studentList);
      setState(() {
        assignatureRows.clear();
        for (var item in studentList) {
          assignatureRows.add(PlutoRow(cells: {
            'Matricula': PlutoCell(value: item.studentID),
            'Nombre': PlutoCell(value: item.studentName),
            'Apellido paterno': PlutoCell(value: item.student1LastName),
            'Apellido materno': PlutoCell(value: item.student2LastName),
            'Calif': PlutoCell(value: item.evaluation),
            'Conducta': PlutoCell(value: item.discipline),
            'Uniforme': PlutoCell(value: item.outfit),
            'Ausencia': PlutoCell(value: item.absence),
            'Tareas': PlutoCell(value: item.homework),
          }));
        }
//                           // StudentsPlutoGrid(rows: assignatureRows);
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

  /// Updates the grades in the backend.
  ///
  /// Returns a future that completes with a boolean indicating whether the update was successful.
  dynamic patchStudentGradesToDB() async {
    var response = await patchStudentsGrades(studentGradesBodyToUpgrade, false);
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
                            children: [_buildGradesbyAssignature()],
                          )
                        ],
                      ),
                    );
                  } else {
                    return const Placeholder(
                      child: Text('Smaller version pending to design'),
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

  Widget _buildGradesbyAssignature() {
    campusSelected = campusesWhereTeacherTeach.first;
    if (campusesWhereTeacherTeach.length != 1) {
      teacherTeachMultipleCampuses = true;
    }

    return Expanded(
      child: Column(
        children: [
          TeacherEvalDropDownMenu(
              jsonData: jsonDataForDropDownMenuClass,
              campusesList: campusesWhereTeacherTeach),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      studentGradesBodyToUpgrade.clear();
                      validator();

                      searchBUttonAction(
                          groupSelected,
                          gradeInt.toString(),
                          assignatureID.toString(),
                          monthNumber.toString(),
                          selectedUnity!);
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
                      updateButtonFunction((success) {
                        if (success) {
                          showConfirmationDialog(
                              context, 'Exito', 'Cambios realizados con exito');
                          validator();

                          var assignatureID =
                              getKeyFromValue(assignaturesMap, subjectValue);

                          searchBUttonAction(
                              groupSelected,
                              gradeInt.toString(),
                              assignatureID.toString(),
                              monthNumber.toString(),
                              selectedUnity!);
                        } else {
                          showErrorFromBackend(context, 'Error');
                        }
                      });
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
                if (rows.isEmpty) {
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
                      return PlutoGrid(
                          columns: assignaturesColumns,
                          rows: assignatureRows,
                          onChanged: (event) {
                            var newValue = validateNewGradeValue(
                                event.value.toString(), event.column.title);

                            composeUpdateStudentGradesBody(
                                event.column.title, newValue, event.rowIdx);
                          },
                          onRowSecondaryTap: (event) async {
                            asignatureNameListener = '';
                            asignatureNameListener = subjectSelected;
                            var studentID = event.row.cells['Matricula']?.value;

                            var selectedStudentName =
                                event.row.cells['Nombre']?.value;
                            validator();
                            commentsAsignated.clear();
                            commentsAsignated =
                                await getCommentsAsignatedToStudent(gradeInt,
                                    true, studentID.toString(), monthNumber);

                            showCommentsDialog(commentsAsignated,
                                asignatureNameListener!, selectedStudentName);
                          },
                          configuration: const PlutoGridConfiguration(),
                          createFooter: (stateManager) {
                            stateManager.setPageSize(30,
                                notify: false); // default 40
                            return PlutoPagination(stateManager);
                          });
                    },
                  );
                }
              })),
        ],
      ),
    );
  }

  /// Updates the grid with new data.
  ///
  /// [studentList] is the list of students to display in the grid.
  /// [assignatureRows] is the list of rows to display in the grid.
  void updateGrid(
      List<StudentEval> studentList, List<PlutoRow> assignatureRows) {
    setState(() {
      rows = studentList.map((item) {
        return PlutoRow(
          cells: {
            'Matricula': PlutoCell(value: item.studentID),
            'Nombre': PlutoCell(value: item.studentName),
            'Apellido paterno': PlutoCell(value: item.student1LastName),
            'Apellido materno': PlutoCell(value: item.student2LastName),
          },
        );
      }).toList();
      assignatureRows = assignatureRows;
    });
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
    if (subjectValue.isEmpty || subjectValue == '') {
      subjectValue = oneTeacherAssignatures.first;
    }
    if (monthValue.isEmpty) {
      monthValue = academicMonthsList.first;
    }
    selectedUnity ??= campusesWhereTeacherTeach.first;

    if (isUserAdmin == true) {
      monthNumber = getKeyFromValue(monthsListMap, monthValue);
    } else {
      monthNumber = getKeyFromValue(monthsListMap, currentMonth);
    }
    gradeInt = getKeyFromValue(teacherGradesMap, gradeSelected);

    assignatureID = getKeyFromValue(assignaturesMap, subjectValue);
  }

  /// Updates the grades in the backend and shows a confirmation dialog.
  ///
  /// [callback] is a function that is called with a boolean indicating whether the update was successful.
  void updateButtonFunction(void Function(bool success) callback) async {
    if (studentGradesBodyToUpgrade.isEmpty) {
      callback(false);
    } else {
      var response;
      try {
        response = await patchStudentGradesToDB();
      } catch (e) {
        callback(false);
      }
      if (response == 200) {
        callback(true);
      } else {
        callback(false);
      }
    }
  }

  Future<dynamic> showCommentsDialog(
      // BuildContext context,
      List<Map<String, dynamic>> comments,
      String subjectName,
      selectedStudentName) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StudentEvalCommentDialog(
            studentName: selectedStudentName,
            comments: comments,
            subjectName: subjectName,
          );
        });
  }
}
