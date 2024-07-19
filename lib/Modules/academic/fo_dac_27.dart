import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/Models/Student.dart';
import 'package:oxschool/constants/User.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../backend/api_requests/api_calls_list.dart';
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
  String? selectedStudent;
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

  final addItemButton = IconButton.outlined(
      onPressed: () {},
      icon: const Icon(Icons.add),
      tooltip: 'Agregar registro');

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
        title: 'Materia', field: 'Assignature', type: PlutoColumnType.text()),
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
                      label: const Text('Alumno'),
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      onSelected: (student) {
                        setState(() {
                          selectedStudent = student;
                          selectedstudentId = simplifiedStudentsList.firstWhere(
                              (student) =>
                                  student["name"] ==
                                  selectedStudent)["studentID"];
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
                      addItemButton,
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
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: PlutoGrid(columns: fodac27Columns, rows: ))),
          ],
        );
      }
    }));
  }

  void populateGrid(String? studentID, String cycle, bool isByStudent) async {
    // Retrive from FODAC27 table and display
// fodac27HistoryRows
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

        fodac27HistoryRows.add(value)

        
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
