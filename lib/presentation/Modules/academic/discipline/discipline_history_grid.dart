import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
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
  dynamic apiResponse;
  var disciplinaryData;
  final TextEditingController initialDateController = TextEditingController();
  DateTime? initialDateTime;
  DateTime? finalDateTime;
  final TextEditingController finalDateController = TextEditingController();
  DateTime? _selectedDate;

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
  void dispose() {
    initialDateController.dispose();
    finalDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialDateField = Padding(
      padding: const EdgeInsets.all(5),
      child: TextFormField(
        controller: initialDateController,
        decoration: const InputDecoration(
          label: Text("Fecha inicial "),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
        readOnly: true,
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            setState(() {
              initialDateTime = picked;
              initialDateController.text =
                  "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, seleccione una fecha';
          }
          return null;
        },
      ),
    );

    final finalDateField = Padding(
      padding: const EdgeInsets.all(5),
      child: TextFormField(
        controller: finalDateController,
        decoration: const InputDecoration(
          label: Text("Fecha Final "),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
        readOnly: true,
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            setState(() {
              finalDateTime = picked;
              finalDateController.text =
                  "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, seleccione una fecha';
          }
          return null;
        },
      ),
    );

    final buttonsMenu = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: initialDateField),
                  Expanded(child: finalDateField)
                ],
              )
            ],
          ),
        ),
        Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RefreshButton(onPressed: () {
                      if ((initialDateTime != null && finalDateTime != null)) {
                        if (initialDateTime!.isAfter(finalDateTime!)) {
                          showErrorFromBackend(context,
                              "Fecha inicial no puede ser mayor que la final");
                        } else {
                          handleRefresh(currentCycle!.claCiclo!,
                              initialDateTime!, finalDateTime!);
                        }
                      } else {
                        showEmptyFieldAlertDialog(context,
                            "Favor de seleccionar un rango de fechas correcto");
                      }
                    }),
                    SizedBox(width: 5),
                    PrintButton(onPressed: () {}),
                    SizedBox(width: 5),
                    ExportButton(onPressed: () {}),
                    SizedBox(
                      width: 5,
                    ),
                    AddItemButton(
                      onPressed: () {},
                    )
                  ],
                )
              ],
            ))
      ],
    );

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (apiResponse != null) {
        return SafeArea(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, top: 10, right: 15, bottom: 10),
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
        ));
      } else {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, top: 10, right: 15, bottom: 10),
              child: buttonsMenu,
            ),
            const Divider(thickness: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Placeholder(),
              ),
            ),
          ],
        );
      }
    });

    // return FutureBuilder(
    //   future: disciplinaryData,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       return Center(
    //         child: Text('Error: ${snapshot.error}'),
    //       );
    //     } else if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center(
    //         child: CustomLoadingIndicator(),
    //       );
    //     } else if (snapshot.hasData && snapshot.data != null) {
    //       return Column(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.only(
    //                 left: 15, top: 10, right: 15, bottom: 10),
    //             child: buttonsMenu,
    //           ),
    //           const Divider(thickness: 2),
    //           Expanded(
    //             child: Padding(
    //               padding: const EdgeInsets.all(20),
    //               child: SingleChildScrollView(
    //                 scrollDirection: Axis.horizontal,
    //                 child: SingleChildScrollView(
    //                   scrollDirection: Axis.vertical,
    //                   child: PlutoGrid(columns: columns, rows: plutoRows),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ],
    //       );
    //     } else {
    //       return Column(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.all(10),
    //             child: buttonsMenu,
    //           ),
    //           Divider(
    //             thickness: 2,
    //           ),
    //           Center(
    //             child: Text('No data available.'),
    //           )
    //         ],
    //       );
    //     }
    //   },
    // );
  }

  void populateGrid(List<dynamic> data) {
    for (var item in data) {
      String studentId = item['Matricula'];
      String cycle = item['ClaCiclo'];
      String studentName = item['Alumno'];
      String campus = item['claun'];
      int academicLevel = item['GradoSecuencia'];
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
      String cycle, DateTime initialDate, DateTime finalDate) async {
    try {
      await getStudentsDisciplinaryReportsByDates(
              cycle,
              "${initialDate.year}${initialDate.month.toString().padLeft(2, '0')}${initialDate.day.toString().padLeft(2, '0')}",
              "${finalDate.year}${finalDate.month.toString().padLeft(2, '0')}${finalDate.day.toString().padLeft(2, '0')}")
          .then((value) {
        setState(() {
          plutoRows.clear();
          populateGrid(value);
          apiResponse = value;
        });
      }).onError((error, stackTrace) {
        setState(() {
          print(error);
          //showErrorFromBackend(context, error.toString());
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  void getStudentDisciplinaryDetails(
      String initialDate, String finalDate, String cycle) {}
}
