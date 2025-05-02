import 'package:flutter/material.dart';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

import '../../../data/Models/Student_eval.dart';

import '../../../data/datasources/temp/studens_temp.dart';
import '../../../data/services/backend/api_requests/api_calls_list.dart';
import '../../../core/constants/Student.dart';
import '../../../core/constants/date_constants.dart';

import '../../../core/config/flutter_flow/flutter_flow_util.dart';
import '../../../core/reusable_methods/academic_functions.dart';
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
bool isUserAdmin = false;
bool isUserAcademicCoord = false;

/// The list of rows in the grid.
List<PlutoRow> rows = [];

class _GradesByAsignatureState extends State<GradesByAsignature> {
  String? asignatureNameListener;
  String? selectedStudentName;
  // var gradeInt;
  int? monthNumber;
  String monthValue = isUserAdmin || isUserAcademicCoord ? academicMonthsList.first : currentMonth;

  // int? assignatureID;
  String campusSelected = '';
  bool isLoading = true;
  var fetchedData;

  /// Whether the teacher teaches multiple campuses.
  bool teacherTeachMultipleCampuses = false;

  @override
  void initState() {
    isUserAdmin = currentUser!.isCurrentUserAdmin();
    isUserAcademicCoord = currentUser!.isCurrentUserAcademicCoord();
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    rows.clear();
    selectedCurrentTempMonth = null;
    super.dispose();
  }

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
            'idCalif': PlutoCell(value: item.rateID),
          },
        );
      }).toList();
    });
  }

  void _fetchData() async {
    setState(() {
      fetchedData = fetchedDataFromloadStartGrading;
      isLoading = false;
    });
  }

  /// Searches for grades based on the selected parameters.
  ///
  /// [groupSelected] is the selected group.
  /// [gradeInt] is the selected grade.
  /// [assignatureID] is the selected assignature ID.
  /// [monthNumber] is the selected month number.
  /// [campus] is the selected campus.
  Future<void> searchBUttonAction(String groupSelected, String gradeInt,
      String assignatureID, String month, String campus) async {
    try {
      studentList = await getStudentsByAssinature(
          groupSelected, gradeInt, assignatureID, month, campus);

      await fillGrid(studentList);
      setState(() {
        isLoading = true;
        assignatureRows.clear();
        var index = 0;
        for (var item in studentList) {
          assignatureRows.add(PlutoRow(cells: {
            'No': PlutoCell(value: index +1),
            'Matricula': PlutoCell(value: item.studentID),
            'Nombre': PlutoCell(value: item.studentName),
            'Apellido paterno': PlutoCell(value: item.student1LastName),
            'Apellido materno': PlutoCell(value: item.student2LastName),
            'Calif': PlutoCell(value: item.evaluation),
            'idCalif': PlutoCell(value: item.rateID),
          }));
        }
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      insertErrorLog(e.toString(), 'SEARCH STUDENTS BY SUBJECTS ');

      var message = getMessageToDisplay(e.toString());
      if (context.mounted) {
        showErrorFromBackend(context, message.toString());
      }
    }
  }

  /// Updates the grades in the backend.
  ///
  /// Returns a future that completes with a boolean indicating whether the update was successful.
  Future<dynamic> patchStudentGradesToDB() async {
    var response;
    await patchStudentsGrades(studentGradesBodyToUpgrade, false).then((status) {
      if (status == 200) {
        response = 200;
      }
    }).onError((error, statusTrace) {
      insertErrorLog(error.toString(),
          'patchStudentsGrades  | $studentGradesBodyToUpgrade');
      response = 400;
    });
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CustomLoadingIndicator()
        : SizedBox(
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              if (fetchedData is Error) {
                return const Placeholder(
                    color: Colors.transparent,
                    child: Text(
                        'Error en la conexión, verificar la conectividad: Code: 408'));
              } else {
                if (isLoading) {
                  return const CustomLoadingIndicator();
                } else {
                  return SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildGradesbyAssignature(),
                          ],
                        )
                      ],
                    ),
                  ));
                }
              }
            }),
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
            campusesList: campusesWhereTeacherTeach,
            byStudent: false,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: RefreshButton(onPressed: () {
                    studentGradesBodyToUpgrade.clear();
                    setState(() {
                      isLoading = true;
                    });
                    try {
                   
                      // isUserAdmin = currentUser!.isCurrentUserAdmin();

                      if (isUserAdmin || isUserAcademicCoord) {
                        //Get month number
                        monthNumber = getKeyFromValue(
                            spanishMonthsMap, selectedTempMonth!);
                      } else {
                        monthNumber = getKeyFromValue(
                            spanishMonthsMap, selectedCurrentTempMonth!);
                      }
                      // get assignature id number
                      var assignatureID = selectedTempSubjectId;

                      // var gradeInt = getKeyFromValue(
                      //     teacherGradesMap, selectedTempGrade!.toString());

                      if (assignatureID != null && assignatureID != 0) {
                        searchBUttonAction(
                            selectedTempGroup!,
                            selectedTempGrade.toString(),
                            assignatureID.toString(),
                            monthNumber.toString(),
                            selectedTempCampus!);
                      } else {
                        isLoading = false;
                        showInformationDialog(context, 'Alerta!',
                            'No se detectó una asignatura, vuelva a intentar.');
                      }

                      // setState(() {
                      //   isLoading = false;
                      // });
                    } catch (e) {
                      insertErrorLog(
                          e.toString(), 'SEARCH STUDENTS BY SUBJECTS ');
                      var message = getMessageToDisplay(e.toString());
                      if (context.mounted) {
                        showErrorFromBackend(context, message.toString());
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  }),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.red[400],
                        ),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await updateButtonFunction((success) async {
                        if (success) {
                          /*   var assignatureID = getKeyFromValue(
                              assignaturesMap, selectedTempSubject!);

                          var monthNumber;
                          if (isUserAdmin) {
                            monthNumber = getKeyFromValue(
                                spanishMonthsMap, selectedTempMonth!);
                          } else {
                            monthNumber = getKeyFromValue(
                                spanishMonthsMap, selectedCurrentTempMonth!);
                          }
                          var gradeInt = getKeyFromValue(
                              teacherGradesMap, selectedTempGrade!.toString()); */
                          try  {
                            studentGradesBodyToUpgrade.clear();
                             await searchBUttonAction(
                                    selectedTempGroup!,
                                    selectedTempGrade.toString(),
                                    selectedTempSubjectId.toString(),
                                    monthNumber.toString(),
                                    selectedTempCampus!);

                            setState(() {
                              isLoading = false;
                              showInformationDialog(context, 'Éxito', 'Cambios realizados!');
                            });
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              showErrorFromBackend(context, e.toString());
                            });
                            
                          }
                        } else {
                          isLoading = false;
                          showErrorFromBackend(context, 'Error');
                        }
                      });
                      setState(() {
                        isLoading = false;
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
              height: MediaQuery.of(context).size.height / 1.8,
              // padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(20),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                isLoading ? null : const CustomLoadingIndicator();
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
                        mode: PlutoGridMode.normal,
                        columns: assignaturesColumns,
                        rows: assignatureRows,
                        onChanged: (event) {
                          final idEval =
                              event.row.cells['idCalif']?.value as int;

                          var newValue = validateNewGradeValue(
                              //Validate values cant be les that 50
                              event.value,
                              event.column.title);
                          composeUpdateStudentGradesBody(
                              event.column.title, newValue, idEval);
                        },
                        configuration: PlutoGridConfiguration(
                            columnSize: PlutoGridColumnSizeConfig(
                                autoSizeMode: PlutoAutoSizeMode.scale),
                            scrollbar: PlutoGridScrollbarConfig(
                                isAlwaysShown: true,
                                scrollBarColor: Colors.red)),
                        createFooter: (stateManager) {
                          stateManager.setPageSize(30,
                              notify: false); // default 40
                          return PlutoPagination(stateManager);
                        },
                      );
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
    if (selectedTempGroup == null || selectedTempGroup == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un grupo a evaluar');
    }
    if (selectedTempGrade == null || selectedTempGrade == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un grado a evaluar');
    }
    if (selectedTempSubject == null || selectedTempSubject == '') {
      return showEmptyFieldAlertDialog(context, 'Seleccionar una materia');
    }
    if (selectedTempCampus == null || selectedTempCampus == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un campus a evaluar');
    }
    if (monthValue.isEmpty) {
      monthValue = academicMonthsList.first;
    }
    selectedUnity ??= campusesWhereTeacherTeach.first;

    if (isUserAdmin || isUserAcademicCoord) {
      monthNumber = getKeyFromValue(spanishMonthsMap, monthValue);
    } else {
      monthNumber = getKeyFromValue(spanishMonthsMap, currentMonth);
    }
    // gradeInt = getKeyFromValue(teacherGradesMap, gradeSelected);

    // assignatureID = getKeyFromValue(assignaturesMap, subjectValue);
  }

  /// Updates the grades in the backend and shows a confirmation dialog.
  ///
  /// [callback] is a function that is called with a boolean indicating whether the update was successful.
  Future<void> updateButtonFunction(void Function(bool success) callback) async {
    if (studentGradesBodyToUpgrade.isEmpty) {
      callback(false);
    } else {
      try {
        await patchStudentGradesToDB().then((response) {
          if (response == 200) {
            callback(true);
          } else {
            callback(false);
          }
        }).onError((error, stackTrace) {
          callback(false);
        });
      } catch (e) {
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
