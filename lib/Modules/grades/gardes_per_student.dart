// ignore_for_file: constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oxschool/constants/User.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../constants/date_constants.dart';
import '../../reusable_methods/academic_functions.dart';
import '../../temp/teacher_grades_temp.dart';

class GradesPerStudent extends StatefulWidget {
  const GradesPerStudent({super.key});

  @override
  State<GradesPerStudent> createState() => _GradesPerStudentState();
}

final List<PlutoRow> rows = [];
const List<String> grade_groups = <String>[
  //TO STORE The teacher groups
  '1 A',
  '1 B',
  '1 C',
  '1 D'
];
String? groupSelected;

const List<String> months = <String>['Enero', 'Febrero', 'Marzo', 'Abril'];

class _GradesPerStudentState extends State<GradesPerStudent> {
  var rows;

  @override
  void initState() {
    super.initState();
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
                    return const Placeholder();
                  }
                }),
              )
            ]);
          }
        });
  }

  Widget _buildGradesPerStudent() {
    // ignore: unused_local_variable
    String? dropDownValue;
    bool pause = true;

    final List<PlutoRow> assignatureRows = [
      PlutoRow(
        cells: {
          'Matricula': PlutoCell(value: 0001),
          'Nombre': PlutoCell(value: 'Fulano Mendez '),
          'Calif': PlutoCell(value: '100'),
          'Conducta': PlutoCell(value: '4'),
          'Uniforme': PlutoCell(value: '1'),
          'Calificacion2': PlutoCell(value: 'B'),
        },
      ),
      PlutoRow(
        cells: {
          'Matricula': PlutoCell(value: 0002),
          'Nombre': PlutoCell(value: 'Jose velzaquez '),
          'Calif': PlutoCell(value: '50'),
          'Conducta': PlutoCell(value: '3'),
          'Uniforme': PlutoCell(value: '5'),
          'Calificacion2': PlutoCell(value: 'B'),
        },
      ),
      PlutoRow(
        cells: {
          'Matricula': PlutoCell(value: 0003),
          'Nombre': PlutoCell(value: 'Antonio Antonino Antonello '),
          'Calif': PlutoCell(value: '100'),
          'Conducta': PlutoCell(value: '9'),
          'Uniforme': PlutoCell(value: '10'),
          'Calificacion2': PlutoCell(value: 'A+'),
        },
      ),
    ];

    final List<PlutoColumn> assignaturesColumns = <PlutoColumn>[
      PlutoColumn(
        title: 'Matricula',
        field: 'Matricula',
        type: PlutoColumnType.number(),
        readOnly: true,
      ),
      PlutoColumn(
          title: 'Nombre del alumno',
          field: 'Nombre',
          type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'Calificación',
        field: 'Calif',
        type: PlutoColumnType.text(),
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
          setState(() {
            dropDownValue = value;
          });
        },
        dropdownMenuEntries:
            monthsList.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final DropdownMenu assignatureSelector = DropdownMenu<String>(
        initialSelection: oneTeacherAssignatures.first,
        onSelected: (String? value) {
          setState(() {
            dropDownValue = value;
          });
        },
        dropdownMenuEntries: oneTeacherAssignatures
            .map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final DropdownMenu groupSelectorButton = DropdownMenu<String>(
        initialSelection: oneTeacherGrades.first,
        onSelected: (String? value) {
          setState(() {
            groupSelected = value;
          });
        },
        dropdownMenuEntries:
            oneTeacherGrades.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    return Expanded(
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        child: Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 100),
            Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                padding: const EdgeInsets.all(1),
                child: Row(
                  children: [
                    const SizedBox(width: 50),
                    Row(
                      children: [
                        const Text(
                          'Grupo:    ',
                          style: TextStyle(
                              fontFamily: 'Sora', fontWeight: FontWeight.bold),
                        ),
                        groupSelectorButton,
                      ],
                    ),
                    const SizedBox(width: 50),
                    Row(
                      children: [
                        const Text(
                          'Mes:    ',
                          style: TextStyle(
                              fontFamily: 'Sora', fontWeight: FontWeight.bold),
                        ),
                        monthSelectorButton,
                        const SizedBox(width: 18),
                        const Text(
                          'Materia:',
                          style: TextStyle(
                              fontFamily: 'Sora', fontWeight: FontWeight.bold),
                        ),
                        assignatureSelector,
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(width: 50),
                    Container(
                      padding: const EdgeInsets.all(2),
                      child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              pause = !pause;
                            });

                            LoadingIndicator(
                                indicatorType: Indicator.ballPulse,
                                colors: const [Colors.red],
                                backgroundColor: Colors.black87,
                                strokeWidth: 2,
                                pause: pause,
                                pathBackgroundColor: Colors.black);
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Buscar')),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(2),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400]),
                          onPressed: () {},
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar')),
                    ),
                    const SizedBox(width: 10),
                  ],
                )),
          ],
        ),
        const Divider(thickness: 1),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 1.5,
          margin: const EdgeInsets.all(20),
          child: PlutoGrid(columns: assignaturesColumns, rows: assignatureRows),
        )
      ],
    ));
  }
}

//Function to populate Assignature Rows
List<PlutoRow> populateAssignatureRows(var assignatures) {
  for (var line in assignatures) {
    rows.add(PlutoRow(cells: {
      'ClaMateria': PlutoCell(value: line.claMateria),
      'nomMateria': PlutoCell(value: line.nomMateria),
      'nomGradoEscolar': PlutoCell(value: line.nomGradoEscolar),
      'gradoSecuencia': PlutoCell(value: line.gradoSecuencia),
      'grado': PlutoCell(value: line.grado),
    }));
  }
  return rows;
}
