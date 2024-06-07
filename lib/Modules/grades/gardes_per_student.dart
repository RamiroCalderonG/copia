// ignore_for_file: constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/reusable_methods/reusable_functions.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

import '../../Models/Student_eval.dart';

import '../../constants/date_constants.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../reusable_methods/academic_functions.dart';
import '../../reusable_methods/user_functions.dart';
import '../../temp/teacher_grades_temp.dart';

class GradesPerStudent extends StatefulWidget {
  const GradesPerStudent({super.key});

  @override
  State<GradesPerStudent> createState() => _GradesPerStudentState();
}

String groupSelected = ''; // = oneTeacherGroups.first.toString();
String gradeSelected = ''; // = oneTeacherGrades.first;
String currentMonth = DateFormat.MMMM().format(DateTime.now());

bool isUserAdmin = verifyUserAdmin(currentUser!);
List<PlutoRow> rows = [];

class _GradesPerStudentState extends State<GradesPerStudent> {
  String? subjectSelected;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    oneTeacherGrades.clear();
    oneTeacherGroups.clear();
    oneTeacherAssignatures.clear();
    oneTeacherStudents.clear();
    oneTeacherStudentID.clear();
    assignaturesMap.clear();
    studentList.clear();
    assignatureRows.clear();
    assignaturesColumns.clear();
    super.dispose();
  }

  Future<void> fillGrid(List<StudentEval> evaluationList) async {
    setState(() {
      rows = evaluationList.map((item) {
        return PlutoRow(
          cells: {
            'Matricula': PlutoCell(value: item.studentID),
            'Nombre': PlutoCell(value: item.studentName),
            'Apellido paterno': PlutoCell(value: item.student1LastName),
            'Apellido materno': PlutoCell(value: item.student2LastName),
            'Calif': PlutoCell(value: item.evaluation),
            'Conducta': PlutoCell(value: item.discipline),
            'Uniforme': PlutoCell(value: item.other),
            'Ausencia': PlutoCell(value: item.absence),
            'Tareas': PlutoCell(value: item.homework),
            'Comentario': PlutoCell(value: item.comment),
          },
        );
      }).toList();
    });
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

  final List<PlutoColumn> assignaturesColumns = <PlutoColumn>[
    PlutoColumn(
        title: 'Matricula',
        field: 'Matricula',
        type: PlutoColumnType.number(format: '####'),
        readOnly: true,
        width: 100),
    PlutoColumn(
      title: 'Nombre del alumno',
      field: 'Nombre',
      type: PlutoColumnType.text(),
      readOnly: true,
      sort: PlutoColumnSort.ascending,
    ),
    PlutoColumn(
      title: 'Apellido paterno',
      field: 'Apellido paterno',
      type: PlutoColumnType.text(),
      readOnly: true,
      sort: PlutoColumnSort.ascending,
    ),
    PlutoColumn(
      title: 'Apellido materno',
      field: 'Apellido materno',
      type: PlutoColumnType.text(),
      readOnly: true,
      sort: PlutoColumnSort.ascending,
    ),
    PlutoColumn(
        title: 'Calificación',
        field: 'Calif',
        type: PlutoColumnType.number(),
        readOnly: false,
        width: 100),
    PlutoColumn(
        title: 'Conducta',
        field: 'Conducta',
        type: PlutoColumnType.number(),
        readOnly: false,
        width: 100),
    PlutoColumn(
        title: 'Uniforme',
        field: 'Uniforme',
        type: PlutoColumnType.number(),
        readOnly: false,
        width: 100),
    PlutoColumn(
        title: 'Ausencia',
        field: 'Ausencia',
        type: PlutoColumnType.number(),
        readOnly: false,
        width: 100),
    PlutoColumn(
        title: 'Tareas',
        field: 'Tareas',
        type: PlutoColumnType.number(),
        readOnly: false,
        width: 100),
    PlutoColumn(
        title: 'Comentarios',
        field: 'Comentarios',
        type: PlutoColumnType.number(),
        readOnly: false,
        width: 100),
  ];

  Widget _buildGradesPerStudent() {
    String dropDownValue = ''; //oneTeacherAssignatures.first;
    String monthValue = ''; //monthsList.first;

    final DropdownMenu monthSelectorButton = DropdownMenu<String>(
      initialSelection: monthsList.first,
      onSelected: (String? value) {
        monthValue = value!;
      },
      dropdownMenuEntries:
          monthsList.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );

    final DropdownMenu assignatureSelector = DropdownMenu<String>(
      initialSelection: oneTeacherAssignatures.first,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Materia:',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      assignatureSelector,
                    ],
                  ),
                ),
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () async {
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
                            getKeyFromValue(monthsListMap, monthValue!);
                      } else {
                        monthNumber =
                            getKeyFromValue(monthsListMap, currentMonth);
                      }
                      var gradeInt =
                          getKeyFromValue(teacherGradesMap, gradeSelected!);

                      var assignatureID =
                          getKeyFromValue(assignaturesMap, dropDownValue!);

                      try {
                        studentList = await getStudentsByAssinature(
                          groupSelected,
                          gradeInt.toString(),
                          assignatureID.toString(),
                          monthNumber.toString(),
                        );
                        fillGrid(studentList);
                        setState(() {
                          assignatureRows.clear();
                          for (var item in studentList) {
                            assignatureRows.add(PlutoRow(cells: {
                              'Matricula': PlutoCell(value: item.studentID),
                              'Nombre': PlutoCell(value: item.studentName),
                              'Apellido paterno':
                                  PlutoCell(value: item.student1LastName),
                              'Apellido materno':
                                  PlutoCell(value: item.student2LastName),
                              'Calif': PlutoCell(value: item.evaluation),
                              'Conducta': PlutoCell(value: item.discipline),
                              'Uniforme': PlutoCell(value: item.other),
                              'Ausencia': PlutoCell(value: item.absence),
                              'Tareas': PlutoCell(value: item.homework),
                              'Comentarios': PlutoCell(value: item.comment),
                            }));
                          }
                          // StudentsPlutoGrid(rows: assignatureRows);
                        });
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            elevation: 20,
                            content: Text(
                              e.toString(),
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
                                label: 'Cerrar mensaje',
                                // ignore: use_build_context_synchronously
                                textColor: FlutterFlowTheme.of(context).info,
                                backgroundColor: Colors.black12,
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                }),
                            duration: const Duration(milliseconds: 6700),
                            backgroundColor:
                                // ignore: use_build_context_synchronously
                                FlutterFlowTheme.of(context).secondary,
                          ),
                        );
                      }
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
                    onPressed: () async {},
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
                          columns: assignaturesColumns, rows: assignatureRows);
                    },
                  );
                }
              })),
        ],
      ),
    );
  }
}
