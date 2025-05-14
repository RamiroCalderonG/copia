import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/presentation/Modules/academic/discipline/create_discipline_screen.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';
import 'package:oxschool/presentation/components/pdf/discipline_report.dart';
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
  bool isLoading = false;

  final List<PlutoColumn> columns = [
    PlutoColumn(
        title: "Matrícula",
        field: "studentId",
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 110),
    PlutoColumn(
        title: "Ciclo",
        field: "cycle",
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 120),
    PlutoColumn(
        title: "Alumno",
        field: "student",
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: "Campus",
        field: "campus",
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 110),
    PlutoColumn(
        title: "Grado",
        field: "academicLevel",
        type: PlutoColumnType.number(),
        readOnly: true,
        width: 80),
    PlutoColumn(
        title: "Grupo",
        field: "group",
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 80),
    PlutoColumn(
      title: "Total",
      field: "total",
      type: PlutoColumnType.number(),
      readOnly: true,
      width: 80,
      footerRenderer: (context) {
        final sum = context.stateManager.refRows.fold<int>(
          0,
          (previousValue, row) =>
              previousValue + ((row.cells['total']?.value ?? 0) as int),
        );
        return Text(
          '$sum',
          textAlign: TextAlign.center,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        );
      },
    ),
    PlutoColumn(
        title: "Menores",
        field: "minors",
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 100),
    PlutoColumn(
      title: "Mayores",
      field: "mayors",
      type: PlutoColumnType.text(),
      readOnly: true,
      width: 100,
      footerRenderer: (context) {
        final sum = context.stateManager.refRows.fold<int>(
          0,
          (previousValue, row) =>
              previousValue + ((row.cells['mayors']?.value ?? 0) as int),
        );
        return Text(
          '$sum',
          textAlign: TextAlign.center,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        );
      },
    ),
    PlutoColumn(
      title: "Notif1",
      field: "notif1",
      type: PlutoColumnType.number(),
      readOnly: true,
      width: 90,
      footerRenderer: (context) {
        final sum = context.stateManager.refRows.fold<int>(
          0,
          (previousValue, row) =>
              previousValue + ((row.cells['notif1']?.value ?? 0) as int),
        );
        return Text(
          '$sum',
          textAlign: TextAlign.center,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        );
      },
    ),
    PlutoColumn(
      title: "Notif2",
      field: "notif2",
      type: PlutoColumnType.number(),
      readOnly: true,
      width: 90,
      footerRenderer: (context) {
        final sum = context.stateManager.refRows.fold<int>(
          0,
          (previousValue, row) =>
              previousValue + ((row.cells['notif2']?.value ?? 0) as int),
        );
        return Text(
          '$sum',
          textAlign: TextAlign.center,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        );
      },
    ),
    PlutoColumn(
        title: "Notif3",
        field: "notif3",
        type: PlutoColumnType.number(),
        readOnly: true,
        width: 90)
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
    apiResponse = null;
    plutoRows.clear();
    columns.clear();
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
                      setState(() {
                        isLoading = true;
                      });
                      if ((initialDateTime != null && finalDateTime != null)) {
                        if (initialDateTime!.isAfter(finalDateTime!)) {
                          setState(() {
                            isLoading = false;
                          });
                          showErrorFromBackend(context,
                              "Fecha inicial no puede ser mayor que la final");
                        } else {
                          setState(() {
                            isLoading = true;
                            handleRefresh(currentCycle!.claCiclo!,
                                    initialDateTime!, finalDateTime!)
                                .whenComplete(() => setState(() {
                                      isLoading = false;
                                    }));
                          });
                        }
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        showEmptyFieldAlertDialog(context,
                            "Favor de seleccionar un rango de fechas correcto");
                      }
                      setState(() {
                        isLoading = false;
                      });
                    }),
                    SizedBox(width: 5),
                    ExcelActionButton(onPressed: () {
                      if (apiResponse == null) {
                        showErrorFromBackend(
                            context, "No hay datos para generar el reporte");
                        setState(() {
                          isLoading = false;
                        });
                        return;
                      } else {
                        setState(() {
                          isLoading = true;
                        });
                        exportPlutoGridToCsv(context)
                            .whenComplete(() => setState(() {
                                  isLoading = false;
                                }));
                      }
                    }),
                    SizedBox(width: 5),
                    ExportButton(onPressed: () {
                      if (apiResponse == null) {
                        showErrorFromBackend(
                            context, "No hay datos para generar el reporte");
                        setState(() {
                          isLoading = false;
                        });
                        return;
                      } else {
                        setState(() {
                          isLoading = true;
                        });
                        generateDisciplinaryReport(
                                currentCycle!.claCiclo!, apiResponse, context)
                            .whenComplete(() => setState(() {
                                  isLoading = false;
                                }));
                      }
                    }),
                    SizedBox(
                      width: 5,
                    ),
                    AddItemButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateDisciplineScreen()));
                      },
                    )
                  ],
                )
              ],
            ))
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: buttonsMenu,
        ),
        const Divider(thickness: 2),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: apiResponse != null
                ? LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return isLoading
                          ? Center(
                              child: CustomLoadingIndicator(),
                            )
                          : Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  child: PlutoGrid(
                                      mode: PlutoGridMode.readOnly,
                                      columns: columns,
                                      rows: plutoRows),
                                ),
                              ),
                            );
                    },
                  )
                : const Center(child: Placeholder()),
          ),
        ),
      ],
    );
  }

  void populateGrid(List<dynamic> data) {
    for (var item in data) {
      plutoRows.add(PlutoRow(cells: {
        'studentId':
            PlutoCell(value: item['Matricula'].toString().trim() ?? ''),
        'cycle': PlutoCell(value: item['ClaCiclo'].toString().trim() ?? ''),
        'student': PlutoCell(value: item['Alumno'].toString().trim() ?? ''),
        'campus': PlutoCell(value: item['claun'].toString().trim() ?? ''),
        'academicLevel':
            PlutoCell(value: item['NomGradoEscolar'].toString().trim() ?? ''),
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
      setState(() {
        isLoading = true;
      });
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
          isLoading = false;
          showErrorFromBackend(context, error.toString());
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> exportPlutoGridToCsv(BuildContext context) async {
    if (plutoRows.isEmpty) {
      showErrorFromBackend(context, "No hay datos para exportar.");
      return;
    }

    // Prepare CSV data
    List<List<dynamic>> csvData = [];

    // Add headers
    csvData.add(columns.map((col) => col.title).toList());

    // Add rows
    for (var row in plutoRows) {
      csvData.add(
          columns.map((col) => row.cells[col.field]?.value ?? '').toList());
    }

    String csv = const ListToCsvConverter().convert(csvData);

    // Let user pick the save location
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar archivo CSV',
      fileName: 'reporteDisciplina.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(csv, encoding: utf8);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Archivo CSV guardado exitosamente en $outputFile',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void getStudentDisciplinaryDetails(
      String initialDate, String finalDate, String cycle) {}
}
