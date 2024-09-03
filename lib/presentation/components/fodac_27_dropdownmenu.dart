import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/presentation/Modules/academic/fo_dac_27.dart';
import 'package:oxschool/presentation/Modules/login_view/login_view_widget.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

import 'package:pluto_grid/pluto_grid.dart';

import '../../core/constants/User.dart';
import '../../core/reusable_methods/academic_functions.dart';
import '../../core/reusable_methods/user_functions.dart';
import '../../data/datasources/temp/teacher_grades_temp.dart';

class Fodac27MenuSelector extends StatefulWidget {
  const Fodac27MenuSelector({super.key});

  @override
  State<Fodac27MenuSelector> createState() => _Fodac27MenuSelectorState();
}

String selectedCampus = '';

class _Fodac27MenuSelectorState extends State<Fodac27MenuSelector> {
  List<Map<String, dynamic>> globalGradesAndGroups = [];

  bool isUserAdmin = false;
  List<String> studentsList = [];
  List<Map<String, String>> parsedStudentsList = [];
  String selectedStudent = '';
  String? selectedCampus = '';
  String? selectedGrade = '';
  String? selectedGroup = '';
  String? selectedstudentId;
  String selectedSubjectNameToEdit = '';
  String selectedStudentIdToEdit = '';
  String selectedCommentToEdit = '';
  String selectedDateToEdit = '';

  List<String> campusesList = [];

  int selectedEvalID = 0;

  @override
  void initState() {
    isUserAdmin = verifyUserAdmin(currentUser!);
    // studentsList =
    //     simplifiedStudentsList.map((item) => item['name'].toString()).toList();
    parsedStudentsList = studentsList.map((item) {
      // Convert each dynamic item to a Map<String, String>
      return Map<String, String>.from(json.decode(item));
    }).toList();

    populateDropDownMenus();
    super.initState();
  }

  // final CampusSelector =

  @override
  Widget build(BuildContext context) {
    List<String> gradesValues = selectedCampus != null
        ? globalGradesAndGroups
            .where((item) => item['campus'] == selectedCampus)
            .map((item) => item['grade'] as String)
            .toSet()
            .toList()
        : [];
    List<String> groupsValues = selectedGrade != null
        ? globalGradesAndGroups
            .where((item) =>
                item['campus'] == selectedCampus &&
                item['grade'] == selectedGrade)
            .map((item) => item['group'] as String)
            .toSet()
            .toList()
        : [];

    List<String> studentsValues =
        selectedGroup != null && selectedGrade != null && selectedCampus != null
            ? parsedStudentsList
                .where((item) =>
                    // item['grade'] == selectedGrade &&
                    item['group'] == selectedGroup &&
                    item['campus'] == selectedCampus)
                .map((item) => item['name']!)
                .toSet()
                .toList()
            : [];

    // List<String> studentsValues = selectedGroup != null
    //     ? studentsList
    //         .where((item) =>
    //             item[2] == selectedGrade &&
    //             item[3] == selectedGroup &&
    //             item[4] == selectedCampus)
    //         .map((item) => item[0])
    //         .toSet()
    //         .toList()
    //     : [];

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
              child: DropdownMenu<String>(
            label: const Text('Campus'),
            trailingIcon: const Icon(Icons.arrow_drop_down),
            onSelected: (value) {
              setState(() {
                setState(() {
                  selectedCampus = value!;
                  selectedGrade = null;
                  selectedGroup = null;
                });
              });
            },
            dropdownMenuEntries: campusesList
                .toList()
                .map<DropdownMenuEntry<String>>((String value) {
              return DropdownMenuEntry<String>(value: value, label: value);
            }).toList(),
          )),
          if (selectedCampus != null)
            Flexible(
                child: DropdownMenu(
                    label: const Text('Grado'),
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    onSelected: (value) {
                      setState(() {
                        selectedGrade = value!;
                      });
                    },
                    dropdownMenuEntries: gradesValues
                        .toList()
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList())),
          if (selectedGrade != null)
            Flexible(
              child: DropdownMenu(
                  label: const Text('Grupo'),
                  trailingIcon: const Icon(Icons.arrow_drop_down),
                  onSelected: (value) {
                    setState(() {
                      selectedGroup = value;
                      print(studentsValues);
                    });
                  },
                  dropdownMenuEntries: groupsValues
                      .toList()
                      .map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(
                        value: value, label: value);
                  }).toList()),
            ),

          Flexible(
            flex: 1,
            child: DropdownMenu<String>(
                label: const Text('Alumno'),
                width: 200,
                trailingIcon: const Icon(Icons.arrow_drop_down),
                onSelected: (student) {
                  if (student != null) {
                    setState(() {
                      selectedStudent = student;
                      selectedstudentId = getStudentIdByName(student);
                      if (selectedstudentId != null) {
                        populateGrid(
                            selectedstudentId!, currentCycle!.claCiclo!, true);
                      }
                    });
                  }
                },
                dropdownMenuEntries: studentsValues
                    .toList()
                    .map<DropdownMenuEntry<String>>((var value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList()),
          ),

          // Flexible(
          //   flex: 2,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       Flexible(
          //         child: AddItemButton(onPressed: handleAddItem),
          //       ),
          //       const SizedBox(width: 5),
          //       Flexible(child: EditItemButton(
          //         onPressed: () {
          //           if (selectedEvalID == 0) {
          //             const AlertDialog(
          //               title: Text('Error'),
          //               content:
          //                   Text('Primero selecciona un registro para editar'),
          //             );
          //           } else {
          //             showDialog(
          //                 context: context,
          //                 builder: (BuildContext context) {
          //                   return EditCommentScreen(
          //                     id: selectedEvalID,
          //                     comment: selectedCommentToEdit,
          //                     date: selectedDateToEdit,
          //                     selectedSubject: selectedSubjectNameToEdit,
          //                     studentID: selectedStudentIdToEdit,
          //                   );
          //                 });
          //           }
          //         },
          //       )),
          //       const SizedBox(width: 5),
          //       // const SizedBox(width: 10),
          //       Flexible(child: RefreshButton(onPressed: handleRefresh)),
          //       const SizedBox(width: 5),
          //       if (isUserAdmin)
          //         Flexible(
          //           child: DeleteItemButton(
          //             onPressed: () async {
          //               if (selectedEvalID == 0) {
          //                 const AlertDialog(
          //                   title: Text('Error'),
          //                   content: Text(
          //                       'Primero selecciona un registro para editar'),
          //                 );
          //               } else {
          //                 int confirmation =
          //                     await showDeleteConfirmationAlertDialog(context);

          //                 if (confirmation == 1) {
          //                   int response = await deleteAction(selectedEvalID);
          //                   if (response == 200) {
          //                     if (mounted) {
          //                       await showConfirmationDialog(
          //                           context, 'Realizado', 'Registro eliminado');
          //                     }
          //                   }
          //                 }
          //               }
          //             },
          //           ),
          //         ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<void> populateStudentsDropDownMenu() async {
    var response = await getStudentsByTeacher(
      currentUser!.employeeNumber!,
      currentCycle!.claCiclo!,
      currentUser!.role,
    );

    simplifiedStudentsList = response.map((item) => item.toString()).toList();

    if (simplifiedStudentsList.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleAddItem() {
    if (selectedStudent.isEmpty) {
      showEmptyFieldAlertDialog(context, 'Favor de seleccionar un alumno');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Agregar comentario a:\n$selectedStudent'),
            content: NewFODAC27CommentDialog(
              selectedstudentId: selectedstudentId!,
              employeeNumber: currentUser!.employeeNumber!,
            ),
          );
        },
      );
    }
  }

  void handleRefresh() {
    if (selectedstudentId != null) {
      // populateGrid(selectedstudentId!, currentCycle!.claCiclo!, true);
    }
  }

  Future<int> deleteAction(int fodac27ID) async {
    var response = await deleteFodac27Record(fodac27ID);
    return response;
  }

  String? getStudentIdByName(String name) {
    return simplifiedStudentsList
        .firstWhere((student) => student[0] == name)[1];
  }

  Future<void> populateGrid(
      String studentID, String cycle, bool isByStudent) async {
    var apiResponse = await getFodac27History(cycle, studentID, isByStudent);
    if (apiResponse != null) {
      var decodedResponse = json.decode(apiResponse) as List;
      List<PlutoRow> newRows = decodedResponse.map((item) {
        return PlutoRow(cells: {
          'date': PlutoCell(value: item['date']),
          'studentID': PlutoCell(value: item['student']),
          'Obs': PlutoCell(value: item['observation']),
          'subject': PlutoCell(value: item['subject']),
          'teacher': PlutoCell(value: item['teacher']),
          'fodac27': PlutoCell(value: int.parse(item['fodac27'])),
        });
      }).toList();

      // setState(() {
      //   fodac27HistoryRows = newRows;
      //   stateManager.removeAllRows();
      //   stateManager.appendRows(newRows);
      // });
    }
  }

  void populateDropDownMenus() {
    if (isUserAdmin) {
      campusesList = ['ANAHUAC', 'BARRAGAN', 'CONCORDIA', 'SENDERO'];
      selectedCampus = campusesList.first;
    } else {
      campusesList = campusesWhereTeacherTeach.toList();
      selectedCampus = campusesWhereTeacherTeach.first;
      selectedGrade = oneTeacherGrades.first;
    }
    getGradesandGroupByCycle(currentCycle!.claCiclo!);
  }

  void getGradesandGroupByCycle(String cycle) async {
    var list = await getGradesAndGroupsByCampus(cycle);
    List<Map<String, dynamic>> returnedList = list;

    globalGradesAndGroups = returnedList;
  }
}
