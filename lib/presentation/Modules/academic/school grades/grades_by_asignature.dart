import 'package:flutter/material.dart';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:intl/intl.dart';

import '../../../../data/Models/Student_eval.dart';

import '../../../../data/datasources/temp/studens_temp.dart';
import '../../../../data/services/backend/api_requests/api_calls_list.dart';

import '../../../../core/constants/date_constants.dart';

import '../../../../core/config/flutter_flow/flutter_flow_util.dart';
import '../../../../core/reusable_methods/academic_functions.dart';
import '../../../../data/datasources/temp/teacher_grades_temp.dart';
import '../../../components/confirm_dialogs.dart';
import '../../../components/student_eval_comments_dialog.dart';
import '../../../components/teacher_eval_dropdownmenu.dart';

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
List<TrinaRow> rows = [];

class _GradesByAsignatureState extends State<GradesByAsignature> {
  String? asignatureNameListener;
  String? selectedStudentName;
  // var gradeInt;
  Key trinaGridKey = UniqueKey();
  int? monthNumber;
  String monthValue = isUserAdmin || isUserAcademicCoord
      ? academicMonthsList.first
      : currentMonth;

  // int? assignatureID;
  String campusSelected = '';
  bool isLoading = true;
  var fetchedData;

  bool hideCommentsColumn = false;
  bool hideAbsencesColumn = false;
  bool hideHomeworksColumn = false;
  bool hideDisciplineColumn = false;
  bool hideHabitsColumn = false;
  bool hideOutfitColumn = false;
  String? homeWorkColumnTitle;
  String? disciplineColumnTitle;

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

  List<TrinaColumn> get assignaturesColumns => [
        //TO USE at grades_by_assignature
        TrinaColumn(
          title: 'No.Lista',
          field: 'No',
          width: 20,
          type: TrinaColumnType.number(),
          readOnly: true,
        ),
        TrinaColumn(
            title: 'Matricula',
            field: 'Matricula',
            type: TrinaColumnType.text(),
            readOnly: true,
            width: 100),
        TrinaColumn(
          title: 'Nombre del alumno',
          field: 'Nombre',
          type: TrinaColumnType.text(),
          readOnly: true,
        ),
        TrinaColumn(
            title: 'Apellido paterno',
            field: 'Apellido paterno',
            type: TrinaColumnType.text(),
            readOnly: true,
            //sort: TrinaColumnSort.ascending,
            width: 150),
        TrinaColumn(
            title: 'Apellido materno',
            field: 'Apellido materno',
            type: TrinaColumnType.text(),
            readOnly: true,
            //sort: TrinaColumnSort.ascending,
            width: 150),
        TrinaColumn(
            title: 'Calif',
            field: 'Calif',
            type: TrinaColumnType.number(negative: false, format: '##'),
            readOnly: false,
            width: 100),
        TrinaColumn(
            title: 'idCalif',
            field: 'idCalif',
            type: TrinaColumnType.number(negative: false),
            hide: true),
        TrinaColumn(
            hide: hideAbsencesColumn,
            title: 'Faltas',
            field: 'Ausencia',
            type: TrinaColumnType.number(negative: false, format: '#'),
            readOnly: false,
            width: 100),
        TrinaColumn(
            hide: hideHomeworksColumn,
            title: homeWorkColumnTitle ?? 'Tareas',
            field: 'Tareas',
            type: TrinaColumnType.number(negative: false),
            readOnly: false,
            width: 100),
        TrinaColumn(
            hide: hideDisciplineColumn,
            title: disciplineColumnTitle ?? 'Conducta',
            field: 'Conducta',
            type: TrinaColumnType.number(negative: false),
            readOnly: false,
            width: 100),
        // TrinaColumn(
        //     hide: true,
        //     title: 'Uniforme',
        //     field: 'Uniforme',
        //     type: TrinaColumnType.number(negative: false),
        //     readOnly: hideOutfitColumn,
        //     width: 100),
        TrinaColumn(
            title: 'Habitos',
            hide: hideHabitsColumn,
            field: 'habit_eval',
            readOnly: true,
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            hide: hideCommentsColumn,
            title: 'Comentarios',
            field: 'Comentarios',
            type: TrinaColumnType.text(),
            readOnly: false,
            width: 200),
      ];

  /// Fills the grid with data from the backend.
  ///
  /// [//evaluationList] is the list of evaluations to display in the grid.
  Future<void> fillGrid(List<StudentEval> evaluationList) async {
    setState(() {
      rows = evaluationList.map((item) {
        return TrinaRow(
          cells: {
            // 'Matricula': TrinaCell(value: item.studentID),
            'Nombre': TrinaCell(value: item.studentName),
            'Apellido paterno': TrinaCell(value: item.student1LastName),
            'Apellido materno': TrinaCell(value: item.student2LastName),
            'idCalif': TrinaCell(value: item.rateID),
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

  Future<void> searchBUttonAction(
    String groupSelected,
    String gradeInt,
    String assignatureID,
    String month,
    String campus,
  ) async {
    try {
      setState(() {
        isLoading = true;
      });
      int? teacherNumber;
      if (isUserAdmin || isUserAcademicCoord) {
        teacherNumber = null;
      } else {
        teacherNumber = currentUser!.employeeNumber;
      }
      studentList = await getStudentsByAssinature(
          groupSelected, gradeInt, assignatureID, month, campus, teacherNumber);

      // Get evaluations comments by gradeSequence
      if (studentList.isNotEmpty) {
        studentsGradesCommentsRows =
            await getEvaluationsCommentsByGradeSequence(selectedTempGrade!);
      } else {
        throw Exception(
          'No se encontraron alumnos para el grupo seleccionado: $groupSelected, grado: $gradeInt, ciclo: ${currentCycle!.claCiclo}, campus: $campusSelected, mes: $month',
        );
      }

      await fillGrid(studentList);

      setState(() {
        displayColumnsByGrade(selectedTempGrade!);
        assignatureRows.clear();
        for (var item in studentList) {
          assignatureRows.add(TrinaRow(cells: {
            'No': TrinaCell(value: item.sequentialNumber ?? 0),
            'Matricula': TrinaCell(value: item.studentID),
            'Nombre': TrinaCell(value: item.studentName),
            'Apellido paterno': TrinaCell(value: item.student1LastName),
            'Apellido materno': TrinaCell(value: item.student2LastName),
            'Calif': TrinaCell(value: item.evaluation),
            'idCalif': TrinaCell(value: item.rateID),
            'Ausencia': TrinaCell(value: item.absence ?? 0),
            'Tareas': TrinaCell(value: item.homework ?? 0),
            'Conducta': TrinaCell(value: item.discipline ?? 0),
            'habit_eval': TrinaCell(value: item.habits_evaluation ?? 0),
            'Comentarios': TrinaCell(
              value: item.comment != null && item.comment != 0
                  ? item.comment.toString()
                  : '',
            ),
          }));
        }
        setState(() {
          selectedTempCampus = campus;
          selectedTempGrade = int.parse(gradeInt);
          selectedTempSubjectId = int.parse(assignatureID);

          // Call displayColumnsByGrade BEFORE updating trinaGridKey
          displayColumnsByGrade(selectedTempGrade!);

          // Force grid rebuild with new key AFTER visibility flags are set
          trinaGridKey = UniqueKey();

          isLoading = false;
        });
        // selectedTempCampus = campus;
        // selectedTempGrade = int.parse(gradeInt);
        // selectedTempSubjectId = int.parse(assignatureID);
        // isLoading = false;
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
    // dynamic gradesGridWidget = TrinaGrid(
    //   key: trinaGridKey,
    //   mode: TrinaGridMode.normal,
    //   columns: assignaturesColumns,
    //   rows: assignatureRows,
    //   onChanged: (event) {
    //     // Validator to avoid double type numbers for 'Calif' column
    //     final idEval = event.row.cells['idCalif']?.value as int;

    //     var newValue = validateNewGradeValue(
    //         //Validate values cant be les that 50
    //         event.value,
    //         event.column.title);
    //     composeUpdateStudentGradesBody(event.column.title, newValue, idEval);
    //   },
    //   configuration: TrinaGridConfiguration(
    //       columnSize:
    //           TrinaGridColumnSizeConfig(autoSizeMode: TrinaAutoSizeMode.scale),
    //       scrollbar: TrinaGridScrollbarConfig(
    //         isAlwaysShown: true,
    //         //scrollBarColor: Colors.red
    //       )),
    //   createFooter: (stateManager) {
    //     stateManager.setPageSize(30, notify: false); // default 40
    //     return TrinaPagination(stateManager);
    //   },
    // );

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
                  child: RefreshButton(onPressed: () async {
                    studentGradesBodyToUpgrade.clear();
                    setState(() {
                      isLoading = true;
                    });
                    try {
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

                      if (assignatureID != null && assignatureID != 0) {
                        await searchBUttonAction(
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
                    style: ElevatedButton.styleFrom(),
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
                          try {
                            studentGradesBodyToUpgrade.clear();
                            await searchBUttonAction(
                                selectedTempGroup!,
                                selectedTempGrade.toString(),
                                selectedTempSubjectId.toString(),
                                monthNumber.toString(),
                                selectedTempCampus!);

                            setState(() {
                              isLoading = false;
                              showInformationDialog(
                                  context, 'Éxito', 'Cambios realizados!');
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
                  // return StatefulBuilder(
                  //   // key: trinaGridKey,
                  //   builder: (context, setState) {
                  return TrinaGrid(
                    key: trinaGridKey,
                    mode: TrinaGridMode.normal,
                    columns: assignaturesColumns,
                    rows: assignatureRows,
                    onChanged: (event) {
                      // Validator to avoid double type numbers for 'Calif' column
                      final idEval = event.row.cells['idCalif']?.value as int;

                      var newValue = validateNewGradeValue(
                          //Validate values cant be les that 50
                          event.value,
                          event.column.title);
                      composeUpdateStudentGradesBody(
                          event.column.title, newValue, idEval);
                    },
                    onLoaded: (event) {
                      event.stateManager
                          .setSelectingMode(TrinaGridSelectingMode.cell);
                      TrinaGridStateManager stateManager = event.stateManager;

                      // Apply column visibility based on selectedTempGrade
                      if (selectedTempGrade != null) {
                        // Safe column finder helper function
                        void safeSetColumnVisibility(
                            String fieldName, bool hide) {
                          final columnIndex = stateManager.columns
                              .indexWhere((col) => col.field == fieldName);
                          if (columnIndex >= 0) {
                            stateManager.hideColumn(
                                stateManager.columns[columnIndex], hide,
                                notify: true); // Changed to notify: true
                          }
                        }

                        // Comments column
                        safeSetColumnVisibility(
                            'Comentarios', hideCommentsColumn);

                        // Absences column
                        safeSetColumnVisibility('Ausencia', hideAbsencesColumn);

                        // Homeworks column
                        safeSetColumnVisibility('Tareas', hideHomeworksColumn);

                        // Discipline column
                        safeSetColumnVisibility(
                            'Conducta', hideDisciplineColumn);

                        // Habits column
                        safeSetColumnVisibility('habit_eval', hideHabitsColumn);
                      }

                      // Apply any other grid configurations you need
                      stateManager.setPageSize(30, notify: true);
                    },
                    configuration: TrinaGridConfiguration(
                        style: TrinaGridStyleConfig(
                          borderColor: Colors.grey.shade300,
                        ),
                        columnSize: TrinaGridColumnSizeConfig(
                            autoSizeMode: TrinaAutoSizeMode.scale),
                        scrollbar: TrinaGridScrollbarConfig(
                          isAlwaysShown: true,
                          //scrollBarColor: Colors.red
                        )),
                    createFooter: (stateManager) {
                      stateManager.setPageSize(30, notify: false); // default 40
                      return TrinaPagination(stateManager);
                    },
                  );
                  //     },
                  //   );
                  // }
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
      List<StudentEval> studentList, List<TrinaRow> assignatureRows) {
    setState(() {
      rows = studentList.map((item) {
        return TrinaRow(
          cells: {
            'Matricula': TrinaCell(value: item.studentID),
            'Nombre': TrinaCell(value: item.studentName),
            'Apellido paterno': TrinaCell(value: item.student1LastName),
            'Apellido materno': TrinaCell(value: item.student2LastName),
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
  Future<void> updateButtonFunction(
      void Function(bool success) callback) async {
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

  void displayColumnsByGrade(int grade) {
    // setState(() {
    if ((grade < 12) && (grade > 6)) {
      hideCommentsColumn = false; // Comentarios
      hideAbsencesColumn = true; // Faltas
      hideHomeworksColumn = false; // Tareas
      hideDisciplineColumn = false; //Disciplina
      hideHabitsColumn = true;
      hideOutfitColumn = true;
      homeWorkColumnTitle = 'Hab';
      disciplineColumnTitle = 'Con';
    } else if ((grade < 6 && grade > 0)) {
      hideCommentsColumn = true;
      hideAbsencesColumn = true; // Faltas
      hideHomeworksColumn = true; // Tareas
      hideDisciplineColumn = true; //Disciplina
      hideHabitsColumn = true; //Habits
      hideOutfitColumn = true;
    } else if (grade > 11) {
      hideCommentsColumn = true;
      hideAbsencesColumn = false; // Faltas
      hideHomeworksColumn = false; // Tareas
      hideDisciplineColumn = true; //Disciplina
      hideHabitsColumn = true;
      hideOutfitColumn = true;
      homeWorkColumnTitle = 'R';
    }
    trinaGridKey = UniqueKey();
    // });
  }
}
