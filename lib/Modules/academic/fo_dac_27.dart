import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/Models/Student.dart';
import 'package:oxschool/constants/User.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../backend/api_requests/api_calls_list.dart';
import '../../components/confirm_dialogs.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_scaffold_messenger.dart';
import '../../reusable_methods/academic_functions.dart';
import '../../utils/loader_indicator.dart';

class FoDac27 extends StatefulWidget {
  const FoDac27({super.key});

  @override
  State<FoDac27> createState() => _FoDac27State();
}

class _FoDac27State extends State<FoDac27> {
  List<dynamic> simplifiedStudentsList = [];
  List<PlutoRow> fodac27HistoryRows = [];

  final TextEditingController studentSelectorController =
      TextEditingController();
  final dateController = TextEditingController();
  String selectedStudent = '';
  bool isLoading = true;

  String? selectedstudentId;

  @override
  void initState() {
    // isLoading = true;
    populateStudentsDropDownMenu();
    super.initState();
  }

  @override
  void dispose() {
    dateController.clear();
    studentSelectorController.clear();
    simplifiedStudentsList.clear();
    super.dispose();
  }

  // final addItemButton = IconButton.outlined(
  //     onPressed: () {},
  //     icon: const Icon(Icons.add),
  //     tooltip: 'Agregar registro');

  final editSelecteditemButton = IconButton.outlined(
    onPressed: () {},
    icon: const Icon(Icons.edit),
    tooltip: 'Editar registro',
  );

  final deleteSelecteditemButton = IconButton.outlined(
      onPressed: () {},
      icon: const Icon(Icons.delete),
      tooltip: 'Eliminar registro');

  final exportToExcel = IconButton.outlined(
    onPressed: () {},
    icon: const FaIcon(FontAwesomeIcons.solidFileExcel),
    tooltip: 'Exportar a Excel',
  );

  final List<PlutoColumn> fodac27Columns = [
    PlutoColumn(
        title: 'Fecha',
        field: 'date',
        type: PlutoColumnType.date(),
        width: 20,
        readOnly: true),
    PlutoColumn(
      title: 'Matricula',
      field: 'studentID',
      type: PlutoColumnType.text(),
      readOnly: true,
    ),
    PlutoColumn(title: 'Obs', field: 'Obs', type: PlutoColumnType.text()),
    PlutoColumn(
        title: 'Materia', field: 'subject', type: PlutoColumnType.text()),
    PlutoColumn(
        title: 'Maestro', field: 'teacher', type: PlutoColumnType.text()),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (isLoading == true) {
        return CustomLoadingIndicator();
      } else {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Flexible(
                  //     // fit: FlexFit.loose,
                  //     child: TextField(
                  //   controller: dateController,
                  //   decoration: const InputDecoration(
                  //     icon: Icon(Icons.calendar_today),
                  //     labelText: "Fecha",
                  //   ),
                  //   readOnly: true,
                  //   onTap: () async {
                  //     // ignore: unused_local_variable
                  //     DateTime? pickedDate = await showDatePicker(
                  //             context: context,
                  //             initialDate: DateTime.now(),
                  //             firstDate: DateTime(2000),
                  //             lastDate: DateTime(2101))
                  //         .then((pickedDate) {
                  //       if (pickedDate != null) {
                  //         setState(() {
                  //           dateController.text =
                  //               DateFormat('yyyy-MM-dd').format(pickedDate);
                  //         });
                  //       }
                  //       return null;
                  //     });
                  //   },
                  // )),
                  // const SizedBox(
                  //   width: 50,
                  // ),
                  Flexible(
                    // flex: 3,
                    fit: FlexFit.loose,
                    child: DropdownMenu<String>(
                      controller: studentSelectorController,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      leadingIcon: const Icon(Icons.search),
                      trailingIcon: IconButton(
                        onPressed: () {
                          studentSelectorController.clear();
                          // fodac27HistoryRows.clear();
                        },
                        icon: const Icon(
                          Icons.clear,
                          // size: 33,
                        ),
                      ),
                      label: const Text('Alumno'),
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      onSelected: (student) {
                        setState(() {
                          selectedStudent = student!;
                          selectedstudentId = simplifiedStudentsList.firstWhere(
                              (student) =>
                                  student["name"] ==
                                  selectedStudent)["studentID"];

                          populateGrid(
                              selectedstudentId, currentCycle!.claCiclo!, true);
                        });
                      },
                      dropdownMenuEntries:
                          simplifiedStudentsList.map<DropdownMenuEntry<String>>(
                        (e) {
                          return DropdownMenuEntry(
                            value: e['name'],
                            label: e['name'],
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Flexible(
                      // padding: const EdgeInsets.only(left: 5, right: 5),
                      // fit: FlexFit.loose,
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // addItemButton,
                      AddItemButton(onPressed: () {
                        if (selectedStudent.isEmpty) {
                          return showEmptyFieldAlertDialog(
                              context, 'Favor de seleccionar un alumno');
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text(
                                      'Observaciones para $selectedStudent'),
                                  content: CustomDialogContent(
                                    selectedstudentId: selectedstudentId!,
                                    employeeNumber:
                                        currentUser!.employeeNumber!,
                                  ));
                            },
                          );
                        }

                        //   createFodac27Record(
                        //   dateController.text,  selectedStudent!, currentCycle!.claCiclo!,
                        // )
                      }),
                      editSelecteditemButton,
                      deleteSelecteditemButton,
                      exportToExcel
                    ],
                  ))
                ],
              ),
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    child: PlutoGrid(
                        columns: fodac27Columns, rows: fodac27HistoryRows))),
          ],
        );
      }
    }));
  }

  void populateGrid(String? studentID, String cycle, bool isByStudent) async {
    // Retrive from FODAC27 table and display
    var apiResponse = await getFodac27History(cycle, studentID, isByStudent);

    if (apiResponse != null) {
      var decodedResponse = json.decode(apiResponse);
      for (var item in decodedResponse) {
        String date = item['date'];
        String studentID = item['student'];
        String cycle = item['cycle'];
        String observation = item['observation'];
        String teacher = item['teacher'];
        String subject = item['subject'];

        setState(() {
          fodac27HistoryRows.clear();

          fodac27HistoryRows.add(PlutoRow(cells: {
            'date': PlutoCell(value: date),
            'studentID': PlutoCell(value: studentID),
            'Obs': PlutoCell(value: observation),
            'subject': PlutoCell(value: subject),
            'teacher': PlutoCell(value: teacher)
          }));
        });
      }
    }
  }

  void populateStudentsDropDownMenu() async {
    String userRole = currentUser!.role;

    simplifiedStudentsList = await getStudentsByTeacher(
        currentUser!.employeeNumber!, currentCycle!.claCiclo!, userRole);
    if (simplifiedStudentsList.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
      // isLoading = false;
    }
  }
}

class CustomDialogContent extends StatefulWidget {
  final String selectedstudentId;
  final int employeeNumber;

  const CustomDialogContent(
      {Key? key,
      required this.selectedstudentId,
      required this.employeeNumber});

  @override
  _CustomDialogContentState createState() => _CustomDialogContentState();
}

class _CustomDialogContentState extends State<CustomDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  String? _selectedMateria;
  List<String> _materias = [];
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void initState() {
    isLoading = true;
    getSubjects();
    // isLoading = false;

    super.initState();
    //_dateController.text = "22/07/2024"; // Initial date
  }

  void getSubjects() async {
    Map<String, dynamic> subjects = await populateSubjectsDropDownSelector(
        widget.selectedstudentId, currentCycle!.claCiclo!);

    _materias = subjects.keys.toList();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Fecha'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    readOnly: true,
                    onTap: () {
                      _selectDate(context);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, seleccione una fecha';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Materia'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMateria,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMateria = newValue;
                      });
                    },
                    items: _materias.map((String materia) {
                      return DropdownMenuItem<String>(
                        value: materia,
                        child: Text(materia),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, seleccione una materia';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Habitos',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Column(
                          children: [
                            Container(
                              color: Colors.grey[300],
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: const Row(
                                children: [
                                  Expanded(child: Text('Descripción')),
                                  Text('Sel'),
                                ],
                              ),
                            ),
                            const Expanded(
                              child:
                                  Center(child: Text('< No existen Habitos >')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Conductas',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Column(
                          children: [
                            Container(
                              color: Colors.grey[300],
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: const Row(
                                children: [
                                  Expanded(child: Text('Descripción')),
                                  Text('Sel'),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                  child: Text('< No existen Conductas >')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Observaciones Generales',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese observaciones generales';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  var result = createFodac27Record(
                    _dateController.text,
                    widget.selectedstudentId,
                    currentCycle!.claCiclo!,
                    _observacionesController.text,
                    widget.employeeNumber,
                    1,
                  );

                  //TODO : IMPLEMENT A NOTIFICATION
                  if (result == 'Succes') {
                    customScaffoldMesg(context, 'Exito', false);
                  }
                  customScaffoldMesg(context, 'Error', true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
