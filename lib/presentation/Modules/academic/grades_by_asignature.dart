// ignore_for_file: constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../components/teacher_eval_dropdownmenu.dart';

class GradesByAsignature extends StatefulWidget {
  const GradesByAsignature({super.key});

  @override
  State<GradesByAsignature> createState() => _GradesByAsignatureState();
}

String currentMonth = DateFormat.MMMM().format(DateTime.now());

String? subjectSelected = oneTeacherAssignatures.first;
bool isUserAdmin = verifyUserAdmin(currentUser!);
List<PlutoRow> rows = [];

class _GradesByAsignatureState extends State<GradesByAsignature> {
  String groupSelected = ''; // = oneTeacherGroups.first.toString();
  String gradeSelected = ''; // = oneTeacherAssignatures.first;
  String? asignatureNameListener;
  String? selectedStudentName;
  var gradeInt;
  int? monthNumber;
  String monthValue = isUserAdmin ? academicMonthsList.first : currentMonth;
  // int? monthNumber;
  String dropDownValue = ''; //oneTeacherAssignatures.first;
  int? assignatureID;
  String campusSelected = '';
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

  void searchBUttonAction(
      String groupSelected, gradeInt, assignatureID, monthNumber) async {
    try {
      studentList = await getStudentsByAssinature(
        groupSelected,
        gradeInt.toString(),
        assignatureID.toString(),
        monthNumber.toString(),
      );

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

    final DropdownMenu campusSelector = DropdownMenu<String>(
        initialSelection: campusSelected,
        onSelected: (String? value) {
          campusSelected = value!;
        },
        dropdownMenuEntries: campusesWhereTeacherTeach
            .toList()
            .map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final DropdownMenu monthSelectorButton = DropdownMenu<String>(
      initialSelection: monthValue,
      onSelected: (String? value) {
        monthValue = value!;
      },
      dropdownMenuEntries:
          academicMonthsList.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );

    final DropdownMenu assignatureSelector = DropdownMenu<String>(
      initialSelection: subjectSelected,
      onSelected: (String? value) {
        dropDownValue = value!;
        subjectSelected = dropDownValue;
      },
      dropdownMenuEntries:
          oneTeacherAssignatures.map<DropdownMenuEntry<String>>((String value) {
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
          TeacherEvalDropDownMenu(
              jsonData: jsonDataForDropDownMenuClass,
              campusesList: campusesWhereTeacherTeach),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // teacherTeachMultipleCampuses
                //     ? Flexible(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             const Text(
                //               'Campus',
                //               style: TextStyle(
                //                   fontFamily: 'Sora',
                //                   fontWeight: FontWeight.bold),
                //             ),
                //             campusSelector
                //           ],
                //         ),
                //       )
                //     : const SizedBox.shrink(),
                // Flexible(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         'Grado:',
                //         style: TextStyle(
                //           fontFamily: 'Sora',
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       gradeSelectorButton2,
                //     ],
                //   ),
                // ),
                // Flexible(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         'Grupo:',
                //         style: TextStyle(
                //           fontFamily: 'Sora',
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       groupSelectorButton,
                //     ],
                //   ),
                // ),
                // Flexible(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         'Mes:',
                //         style: TextStyle(
                //           fontFamily: 'Sora',
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       if (isUserAdmin == false)
                //         Text(
                //           currentMonth,
                //           style: const TextStyle(
                //             fontFamily: 'Sora',
                //             fontWeight: FontWeight.bold,
                //           ),
                //         )
                //       else
                //         monthSelectorButton,
                //     ],
                //   ),
                // ),
                // Flexible(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         'Materia:',
                //         style: TextStyle(
                //           fontFamily: 'Sora',
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       assignatureSelector,
                //     ],
                //   ),
                // ),
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
                      );
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
                              'Sin información para enviar, verifique su captura',
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
                          validator();

                          var assignatureID =
                              getKeyFromValue(assignaturesMap, dropDownValue);

                          searchBUttonAction(
                            groupSelected,
                            gradeInt.toString(),
                            assignatureID.toString(),
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
                                await getCommentsAsignatedToStudent(
                                    gradeInt, true, studentID, monthNumber);

                            await showCommentsDialog(context, commentsAsignated,
                                asignatureNameListener!, selectedStudentName);
                          },
                          // onRowDoubleTap: (event) async {
                          //   asignatureNameListener = '';
                          //   asignatureNameListener = subjectSelected;
                          //   await showCommentsDialog(context, commentsAsignated,
                          //       asignatureNameListener!);
                          // },
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
      monthValue = academicMonthsList.first;
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

  Future<void> showCommentsDialog(
      BuildContext context,
      List<Map<String, dynamic>> comments,
      String subjectName,
      selectedStudentName) async {
    final filteredComments = filterCommentsBySubject(comments, subjectName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Asigna comentarios\nAlumno: $selectedStudentName\nMateria: $subjectName'),
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
                      const Divider(),
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
}
