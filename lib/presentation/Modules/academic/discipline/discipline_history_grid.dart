import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DisciplineHistoryGrid extends StatefulWidget {
  const DisciplineHistoryGrid({super.key});

  @override
  State<DisciplineHistoryGrid> createState() => _DisciplineHistoryGridState();
}

class _DisciplineHistoryGridState extends State<DisciplineHistoryGrid> {
  List<PlutoRow> plutoRows = [];
  var disciplinaryData;

  final List<PlutoColumn> columns = [
    PlutoColumn(
        title: "Matrícula", field: "studentId", type: PlutoColumnType.text()),
    PlutoColumn(title: "Ciclo", field: "cycle", type: PlutoColumnType.text()),
    PlutoColumn(
        title: "Alumno", field: "student", type: PlutoColumnType.text()),
    PlutoColumn(title: "Campus", field: "campus", type: PlutoColumnType.text()),
    PlutoColumn(
        title: "Grado", field: "academicLevel", type: PlutoColumnType.text()),
    PlutoColumn(title: "Group", field: "group", type: PlutoColumnType.text()),
    PlutoColumn(title: "Total", field: "total", type: PlutoColumnType.number()),
    PlutoColumn(
        title: "Menores", field: "minors", type: PlutoColumnType.text()),
    PlutoColumn(
        title: "Mayores", field: "mayors", type: PlutoColumnType.text()),
    PlutoColumn(title: "Notif1", field: "notif1", type: PlutoColumnType.text()),
    PlutoColumn(title: "Notif2", field: "notif2", type: PlutoColumnType.text()),
    PlutoColumn(title: "Notif3", field: "notif3", type: PlutoColumnType.text())
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final buttonsMenu = Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Text('Buscador')],
              )
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RefreshButton(onPressed: () {}),
                  SizedBox(
                    width: 5,
                  ),
                  EditItemButton(onPressed: () {})
                ],
              )
            ],
          )
        ],
      ),
    );

    return FutureBuilder(
        future: disciplinaryData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CustomLoadingIndicator(),
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: buttonsMenu,
                ),
                const Divider(thickness: 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: PlutoGrid(columns: columns, rows: plutoRows),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }

  void populateGrid(List<dynamic> data) {
    for (var item in data) {
      String studentId = item['Matricula'];
      String cycle = item['ClaCiclo'];
      String studentName = item['Alumno'];
      String campus = item['claun'];
      String academicLevel = item['GradoSecuencia'];
      String group = item['Grupo'];
      int minors = item['Menores'];
      int mayor = item['Mayores'];
      int notif1 = item['Notif1'];
      int notif2 = item['Notif2'];
      int notif3 = item['Notif3'];
      int total = item['Reportes'];

      plutoRows.add(PlutoRow(cells: {
        'studentId': PlutoCell(value: item['Matricula'] ?? ''),
        'cycle': PlutoCell(value: item['ClaCiclo'] ?? ''),
        'student': PlutoCell(value: item['Alumno'] ?? ''),
        'campus': PlutoCell(value: item['claun'] ?? ''),
        'academicLevel': PlutoCell(value: item['NomGradoEscolar'] ?? ''),
        'group': PlutoCell(value: item['Grupo'] ?? ''),
        'total': PlutoCell(value: item['Reportes'] ?? 0),
        'minors': PlutoCell(value: item['Menores'] ?? 0),
        'mayors': PlutoCell(value: item['Mayores'] ?? 0),
        'notif1': PlutoCell(value: item['Notif1'] ?? 0),
        'notif2': PlutoCell(value: item['Notif2'] ?? 0),
        'notif3': PlutoCell(value: item['Notif3'] ?? 0)
      }));
    }
  }

  Future<void> handleRefresh(
      String cycle, String initialDate, String finalDate) async {
    try {
      await getStudentsDisciplinaryReportsByDates(cycle, initialDate, finalDate)
          .then((value) {
        setState(() {
          disciplinaryData = value;
          populateGrid(disciplinaryData);
        });
      }).onError((error, stackTrace) {
        setState(() {
          showErrorFromBackend(context, error.toString());
        });
      });
    } catch (e) {
      rethrow;
    }
  }
}
