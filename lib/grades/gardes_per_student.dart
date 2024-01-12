import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class GradesPerStudent extends StatefulWidget {
  const GradesPerStudent({super.key});

  @override
  State<GradesPerStudent> createState() => _GradesPerStudentState();
}

final List<PlutoRow> rows = [];

class _GradesPerStudentState extends State<GradesPerStudent> {
  var rows;

  @override
  Widget build(BuildContext context) {
    //Definition of Colums
    final List<PlutoColumn> assignaturesColumns = <PlutoColumn>[
      PlutoColumn(
          title: 'Clave', field: 'ClaMateria', type: PlutoColumnType.number()),
      PlutoColumn(
          title: 'Materia', field: 'nomMateria', type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Grado escolar',
          field: 'nomGradoEscolar',
          type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Grado secuencia',
          field: 'gradoSecuencia',
          type: PlutoColumnType.text()),
      PlutoColumn(title: 'Grado', field: 'grado', type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'grupo', field: 'gradoGrupo', type: PlutoColumnType.text())
    ];

    final List<PlutoColumn> columns2 = <PlutoColumn>[
      PlutoColumn(
        title: 'Id',
        field: 'id',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Age',
        field: 'age',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Role',
        field: 'role',
        type: PlutoColumnType.select(<String>[
          'Programmer',
          'Designer',
          'Owner',
        ]),
      ),
      PlutoColumn(
        title: 'Joined',
        field: 'joined',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Working time',
        field: 'working_time',
        type: PlutoColumnType.time(),
      ),
      PlutoColumn(
        title: 'salary',
        field: 'salary',
        type: PlutoColumnType.currency(),
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            formatAsCurrency: true,
            type: PlutoAggregateColumnType.sum,
            format: '#,###',
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Sum',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(text: ' : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
    ];

    final List<PlutoRow> rows2 = [
      PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user1'),
          'name': PlutoCell(value: 'Mike'),
          'age': PlutoCell(value: 20),
          'role': PlutoCell(value: 'Programmer'),
          'joined': PlutoCell(value: '2021-01-01'),
          'working_time': PlutoCell(value: '09:00'),
          'salary': PlutoCell(value: 300),
        },
      ),
      PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user2'),
          'name': PlutoCell(value: 'Jack'),
          'age': PlutoCell(value: 25),
          'role': PlutoCell(value: 'Designer'),
          'joined': PlutoCell(value: '2021-02-01'),
          'working_time': PlutoCell(value: '10:00'),
          'salary': PlutoCell(value: 400),
        },
      ),
      PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user3'),
          'name': PlutoCell(value: 'Suzi'),
          'age': PlutoCell(value: 40),
          'role': PlutoCell(value: 'Owner'),
          'joined': PlutoCell(value: '2021-03-01'),
          'working_time': PlutoCell(value: '11:00'),
          'salary': PlutoCell(value: 700),
        },
      ),
    ];

    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  Text('Insertar tabla')
                  // PlutoGrid(
                  //     columns: assignaturesColumns,
                  //     rows: populateAssignatureRows(rows))
                ],
              )
              // if (nurseryHistoryStudent != null)
              //   Text('Nombre del estudiante', style: TextStyle(fontSize: 22.0)),
              // Text(
              //   selectedStudent.nombre,
              //   style: TextStyle(fontSize: 18.0),
              // ),
              // SizedBox(height: 8.0),
              // Text('Datos de contacto', style: TextStyle(fontSize: 18.0)),
              // SizedBox(height: 8.0),
              // Divider(),
              // Expanded(
              //     child: PlutoGrid(
              //   // configuration: const PlutoGridConfiguration.dark(),
              //   columns: columns,
              //   rows: rows,
              //   onLoaded: (PlutoGridOnLoadedEvent event) {
              //     stateManager = event.stateManager;
              //     stateManager.setShowColumnFilter(true);
              //   },
              // )),
              // if (nurseryHistoryStudent == null ||
              //     nurseryHistoryStudent.isEmpty)
              //   Text('Sin informacion disponible'), // Placeholder or message
            ],
          )),
    );
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
