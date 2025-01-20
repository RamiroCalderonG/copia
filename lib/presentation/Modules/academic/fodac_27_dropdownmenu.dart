import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/screens.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/data/datasources/temp/studens_temp.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/presentation/Modules/academic/fo_dac_27.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/constants/user_consts.dart';
import '../../../core/reusable_methods/academic_functions.dart';
import '../../../core/reusable_methods/user_functions.dart';
import '../../../data/datasources/temp/teacher_grades_temp.dart';

class Fodac27MenuSelector extends StatefulWidget {
  const Fodac27MenuSelector({super.key});

  @override
  State<Fodac27MenuSelector> createState() => _Fodac27MenuSelectorState();
}

String selectedCampus = '';

class _Fodac27MenuSelectorState extends State<Fodac27MenuSelector> {
  TextEditingController selectedStudentController = TextEditingController();

  // List<Map<String, dynamic>> globalGradesAndGroups = [];

  bool isUserAdmin = false;
  List<String> studentsList = [];

  String selectedStudent = '';
  String? selectedCampus;
  int? selectedGrade;
  String? selectedGradeName;
  String? selectedGroup;
  String? selectedstudentId;
  String selectedSubjectNameToEdit = '';
  String selectedStudentIdToEdit = '';
  String selectedCommentToEdit = '';
  String selectedDateToEdit = '';

  List<String> campusesList = [];

  int selectedEvalID = 0;

  @override
  void initState() {
    isUserAdmin = currentUser!.isCurrentUserAdmin();

    populateDropDownMenus();
    super.initState();
  }

  @override
  void dispose() {
    studentsList.clear();
    selectedTempStudent = null;
    selectedTempCampus = null;
    selectedTempGrade = null;
    selectedTempGroup = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> gradesValues = selectedCampus != null
        ? simplifiedStudentsList
            .where((item) => item['Claun'] == selectedCampus)
            .map((item) => item['gradeName'].trim() as String)
            .toSet()
            .toList()
        : [];
    List<String> groupsValues = selectedGrade != null
        ? simplifiedStudentsList
            .where((item) =>
                item['Claun'] == selectedCampus &&
                item['GradoSecuencia'] == selectedGrade)
            .map((item) => item['Grupo'] as String)
            .toSet()
            .toList()
        : [];
    List<String> studentsValues = selectedGroup != null
        ? simplifiedStudentsList
            .where((item) =>
                item['Claun'] == selectedCampus &&
                item['GradoSecuencia'] == selectedGrade &&
                item['Grupo'] == selectedGroup)
            .map((item) => item['student_name'] as String)
            .toSet()
            .toList()
        : [];

    return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Flexible(
                child: DropdownMenu<String>(
              label: const Text('Campus'),
              trailingIcon: const Icon(Icons.arrow_drop_down),
              onSelected: (value) {
                setState(() {
                  setState(() {
                    selectedCampus = value!;
                    selectedTempCampus = value;
                    selectedGrade = null;
                    selectedGroup = null;
                  });
                });
              },
              dropdownMenuEntries: teacherCampusListFODAC27
                  .toList()
                  .map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            )),
            const SizedBox(width: 10),
            if (selectedCampus != null)
              Flexible(
                  child: DropdownMenu(
                      label: const Text('Grado'),
                      trailingIcon: const Icon(Icons.arrow_drop_down),
                      onSelected: (value) {
                        setState(() {
                          selectedGradeName = value as String?;
                          selectedGrade = gradesMapFODAC27[selectedGradeName];
                          selectedTempGrade = selectedGrade;
                        });
                      },
                      dropdownMenuEntries: gradesValues
                          .toList()
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value.toString());
                      }).toList())),
            const SizedBox(width: 10),
            if (selectedGrade != null)
              Flexible(
                child: DropdownMenu(
                    label: const Text('Grupo'),
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    onSelected: (value) async {
                      setState(() {
                        selectedGroup = value as String?;
                        selectedTempGroup = value;
                        // studentsList.clear();
                        selectedStudent = '';

                        // print('simplifiedList: ' +
                        //     simplifiedStudentsList.toString());
                      });
                      // studentsList = await getStudentsListForFodac27(
                      //     selectedCampus!,
                      //     currentCycle!.claCiclo!,
                      //     selectedGrade.toString(),
                      //     selectedGroup!);
                      setState(() {
                        selectedStudentController.text = '';
                      });
                    },
                    dropdownMenuEntries: groupsValues
                        .toList()
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList()),
              ),
            const SizedBox(width: 10),
            if (selectedGroup != null)
              Flexible(
                flex: 0,
                child: DropdownMenu<String>(
                    label: const Text('Alumno'),
                    width: 350,
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    controller: selectedStudentController,
                    onSelected: (student) {
                      if (student != null) {
                        setState(() {
                          // selectedStudent = student;
                          selectedStudentController.text = student;
                          selectedTempStudent = student;
                        });
                      }
                    },
                    dropdownMenuEntries: studentsValues
                        .toList()
                        .map<DropdownMenuEntry<String>>((var value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value.toTitleCase);
                    }).toList()),
              ),
          ],
        ));
  }

  // void handleAddItem() {
  //   if (selectedStudent.isEmpty) {
  //     showEmptyFieldAlertDialog(context, 'Favor de seleccionar un alumno');
  //   } else {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Agregar comentario a:\n$selectedStudent'),
  //           content: NewFODAC27CommentDialog(
  //             selectedstudentId: selectedstudentId!,
  //             employeeNumber: currentUser!.employeeNumber!, ,
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }

  // void _handleRefreshWithLoading() {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   handleRefresh().then((_) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }).catchError((error) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     showErrorFromBackend(context, error.toString());
  //   });
  // }

  // Future<int> deleteAction(int fodac27ID) async {
  //   var response = await deleteFodac27Record(fodac27ID);
  //   return response;
  // }

  void populateDropDownMenus() {
    if (isUserAdmin) {
      campusesList = teacherCampusListFODAC27;
      selectedCampus = campusesList.first;
    } else {
      campusesList = campusesWhereTeacherTeach.toList();
      selectedCampus = campusesWhereTeacherTeach.first;
      selectedGrade = int.parse(oneTeacherGrades.first);
    }
  }
}

String? getStudentIdByName(String name) {
  return simplifiedStudentsList.firstWhere((student) => student[0] == name)[1];
}
