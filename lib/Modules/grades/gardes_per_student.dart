import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: MediaQuery.of(context).size.width,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
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
            return Placeholder();
          }
        }),
      )
    ]);
  }

  Widget _buildGradesPerStudent() {
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
        initialSelection: months.first,
        onSelected: (String? value) {
          setState(() {
            dropDownValue = value;
          });
        },
        dropdownMenuEntries:
            months.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final DropdownMenu groupSelectorButton = DropdownMenu<String>(
        initialSelection: grade_groups.first,
        onSelected: (String? value) {
          setState(() {
            groupSelected = value;
          });
        },
        dropdownMenuEntries:
            grade_groups.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    return Expanded(
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        child: Column(
      children: [
        Row(
          children: [
            SizedBox(width: 100),
            Container(
                margin: EdgeInsets.only(top: 20, bottom: 20),
                padding: EdgeInsets.all(1),
                child: Row(
                  children: [
                    SizedBox(width: 50),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            'Grado y Grupo:    ',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold),
                          ),
                          groupSelectorButton,
                        ],
                      ),
                    ),
                    SizedBox(width: 50),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            'Mes:    ',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold),
                          ),
                          monthSelectorButton,
                          SizedBox(width: 18),
                          Text(
                            'Selector de materia:',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 48),
                        ],
                      ),
                    ),
                    SizedBox(width: 50),
                    Container(
                      padding: EdgeInsets.all(2),
                      child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              pause = !pause;
                            });

                            LoadingIndicator(
                                indicatorType: Indicator.ballPulse,
                                colors: [Colors.red],
                                backgroundColor: Colors.black87,
                                strokeWidth: 2,
                                pause: pause,
                                pathBackgroundColor: Colors.black);
                          },
                          icon: Icon(Icons.search),
                          label: Text('Buscar')),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(2),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400]),
                          onPressed: () {},
                          icon: Icon(Icons.save),
                          label: Text('Guardar')),
                    ),
                    SizedBox(width: 10),
                  ],
                )),
          ],
        ),
        Divider(thickness: 1),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 1.5,
          margin: EdgeInsets.all(20),
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
      'ClaMateria': PlutoCell(value: assignatures.claMateria),
      'nomMateria': PlutoCell(value: assignatures.nomMateria),
      'nomGradoEscolar': PlutoCell(value: assignatures.nomGradoEscolar),
      'gradoSecuencia': PlutoCell(value: assignatures.gradoSecuencia),
      'grado': PlutoCell(value: assignatures.grado),
    }));
  }
  return rows;
}
