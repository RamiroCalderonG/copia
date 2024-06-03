// ignore_for_file: constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/reusable_methods/reusable_functions.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../constants/date_constants.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../reusable_methods/academic_functions.dart';
import '../../reusable_methods/user_functions.dart';
import '../../temp/teacher_grades_temp.dart';

class GradesPerStudent extends StatefulWidget {
  const GradesPerStudent({super.key});

  @override
  State<GradesPerStudent> createState() => _GradesPerStudentState();
}

final List<PlutoRow> rows = [];

String? groupSelected = oneTeacherGroups.first;
String? gradeSelected = oneTeacherGrades.first;
String currentMonth = DateFormat.MMMM().format(DateTime.now());

bool isUserAdmin = verifyUserAdmin(currentUser!);

class _GradesPerStudentState extends State<GradesPerStudent> {
  var rows;

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
    oneTeacherGroup.clear();
    assignaturesMap.clear();

    super.dispose();
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
            return Stack(children: [
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
                    //TODO: CREATE A VERSION FOR SMALLER SCREEN
                    return const Placeholder(
                      child: Text('Smaller version pending to design'),
                    );
                  }
                }),
              )
            ]);
          }
        });
  }

  Widget _buildGradesPerStudent() {
    // ignore: unused_local_variable
    String? dropDownValue = oneTeacherAssignatures.first;
    String? monthValue = monthsList.first;

    List<PlutoRow> assignatureRows = [];

    for (var i = 0; i < oneTeacherStudents.length; i++) {
      assignatureRows.add(PlutoRow(
        cells: {
          'Matricula': PlutoCell(value: oneTeacherStudentID[i]),
          'Nombre': PlutoCell(value: oneTeacherStudents[i]),
          'Calif': PlutoCell(value: '100'),
          'Conducta': PlutoCell(value: '4'),
          'Uniforme': PlutoCell(value: '1'),
          'Calificacion2': PlutoCell(value: 'B'),
        },
      ));
    }

    //   PlutoRow(
    //     cells: {
    //       'Matricula': PlutoCell(value: 0001),
    //       'Nombre': PlutoCell(value: 'Fulano Mendez '),
    //       'Calif': PlutoCell(value: '100'),
    //       'Conducta': PlutoCell(value: '4'),
    //       'Uniforme': PlutoCell(value: '1'),
    //       'Calificacion2': PlutoCell(value: 'B'),
    //     },
    //   ),
    //   PlutoRow(
    //     cells: {
    //       'Matricula': PlutoCell(value: 0002),
    //       'Nombre': PlutoCell(value: 'Jose velzaquez '),
    //       'Calif': PlutoCell(value: '50'),
    //       'Conducta': PlutoCell(value: '3'),
    //       'Uniforme': PlutoCell(value: '5'),
    //       'Calificacion2': PlutoCell(value: 'B'),
    //     },
    //   ),
    //   PlutoRow(
    //     cells: {
    //       'Matricula': PlutoCell(value: 0003),
    //       'Nombre': PlutoCell(value: 'Antonio Antonino Antonello '),
    //       'Calif': PlutoCell(value: '100'),
    //       'Conducta': PlutoCell(value: '9'),
    //       'Uniforme': PlutoCell(value: '10'),
    //       'Calificacion2': PlutoCell(value: 'A+'),
    //     },
    //   ),
    // ];

    final List<PlutoColumn> assignaturesColumns = <PlutoColumn>[
      PlutoColumn(
        title: 'Matricula',
        field: 'Matricula',
        type: PlutoColumnType.number(format: '####'),
        readOnly: true,
      ),
      PlutoColumn(
          title: 'Nombre del alumno',
          field: 'Nombre',
          type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'Calificación',
        field: 'Calif',
        type: PlutoColumnType.number(),
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            formatAsCurrency: false,
            type: PlutoAggregateColumnType.average,
            format: '#,###.##',
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Promedio general',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(text: ' : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      PlutoColumn(
          title: 'Conducta', field: 'Conducta', type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Uniforme', field: 'Uniforme', type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Califiacion extra',
          field: 'Calificacion2',
          type: PlutoColumnType.text())
    ];
    final DropdownMenu monthSelectorButton = DropdownMenu<String>(
        initialSelection: monthsList.first,
        onSelected: (String? value) {
          monthValue = value;
          // setState(() {

          // });
        },
        dropdownMenuEntries:
            monthsList.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final DropdownMenu assignatureSelector = DropdownMenu<String>(
        initialSelection: oneTeacherAssignatures.first,
        onSelected: (String? value) {
          dropDownValue = value;
          // setState(() {

          // });
        },
        dropdownMenuEntries: oneTeacherAssignatures
            .map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final DropdownMenu gradeSelectorButton2 = DropdownMenu<String>(
        initialSelection: oneTeacherGrades.first,
        onSelected: (String? value) {
          gradeSelected = value;
          // setState(() {

          // });
        },
        dropdownMenuEntries:
            oneTeacherGrades.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final DropdownMenu groupSelectorButton = DropdownMenu<String>(
        initialSelection: oneTeacherGroups.first,
        onSelected: (String? value) {
          groupSelected = value;
          // setState(() {

          // });
        },
        dropdownMenuEntries:
            oneTeacherGroups.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

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

                      if (isUserAdmin == true) {
                        monthNumber =
                            getKeyFromValue(monthsListMap, monthValue!);
                      } else {
                        monthNumber =
                            getKeyFromValue(monthsListMap, currentMonth);
                      }
                      var gradeInt =
                          getKeyFromValue(assignaturesMap, gradeSelected!);

                      var studentList = await getStudentsByAssinature(
                          groupSelected!,
                          gradeInt.toString(), //IS SENDING 0
                          dropDownValue!,
                          monthNumber.toString() //SENGIND 0
                          );

                      print(studentList.toString());
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
            child:
                PlutoGrid(columns: assignaturesColumns, rows: assignatureRows),
          ),
        ],
      ),
    );
  }
}

// //Function to populate Assignature Rows
// List<PlutoRow> populateAssignatureRows(var assignatures) {
//   for (var line in assignatures) {
//     rows.add(PlutoRow(cells: {
//       'ClaMateria': PlutoCell(value: line.claMateria),
//       'nomMateria': PlutoCell(value: line.nomMateria),
//       'nomGradoEscolar': PlutoCell(value: line.nomGradoEscolar),
//       'gradoSecuencia': PlutoCell(value: line.gradoSecuencia),
//       'grado': PlutoCell(value: line.grado),
//     }));
//   }
//   return rows;
// }
