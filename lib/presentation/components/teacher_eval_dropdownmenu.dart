import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/flutter_flow/flutter_flow_util.dart';
import '../../core/constants/date_constants.dart';
import '../../core/reusable_methods/academic_functions.dart';
import '../../data/datasources/temp/teacher_grades_temp.dart';
import 'confirm_dialogs.dart';

class TeacherEvalDropDownMenu extends StatefulWidget {
  final List<dynamic> jsonData;
  final Set<String> campusesList;

  const TeacherEvalDropDownMenu(
      {super.key, required this.jsonData, required this.campusesList});

  @override
  State<TeacherEvalDropDownMenu> createState() =>
      _TeacherEvalDropDownMenuState();
}

int currentMonthNumber = DateTime.now().month;
String currentMonth = monthsListMap[currentMonthNumber] ?? 'Unknown month';

class _TeacherEvalDropDownMenuState extends State<TeacherEvalDropDownMenu> {
  String? selectedGrade;
  String? selectedGroup;
  String? selectedSubject;
  String? selectedUnity;
  List<String> unityList = [];
  List<String> filteredGrade = [];
  List<String> filteredGroup = [];
  List<String> filteredSubject = [];

  String monthValue = '';
  bool userStatus = false;

  @override
  void initState() {
    _isUserAdminResult();
    super.initState();
    unityList = widget.campusesList.toList();
    filterData();
  }

  _isUserAdminResult() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isUserAdmin = prefs.getBool('isUserAdmin')!;
    monthValue = isUserAdmin ? academicMonthsList.first : currentMonth;
    setState(() {
      userStatus = isUserAdmin;
      if (isUserAdmin == false) {
        monthValue = currentMonth;
      }
    });
  }

  void filterData() {
    if (selectedUnity != null) {
      filteredGrade = widget.jsonData
          .where((item) => item['campus'] == selectedUnity)
          .map<String>((item) => item['grade'].toString())
          .toSet()
          .toList();

      filteredGroup = widget.jsonData
          .where((item) => item['campus'] == selectedUnity)
          .map<String>((item) => item['school_group'].toString())
          .toSet()
          .toList();

      filteredSubject = widget.jsonData
          .where((item) => item['campus'] == selectedUnity)
          .map<String>((item) => item['assignature_name'].toString())
          .toSet()
          .toList();

      // selectedGrade = null;
      // selectedGroup = null;
      // selectedSubject = null;

      selectedGrade = filteredGrade.first;
      selectedGroup = filteredGroup.first;
      selectedSubject = filteredSubject.first;
    } else {
      // Handle the case when no unity is selected or all data should be shown
      filteredGrade = widget.jsonData
          .map<String>((item) => item['grade'].toString())
          .toSet()
          .toList();

      filteredGroup = widget.jsonData
          .map<String>((item) => item['group'].toString())
          .toSet()
          .toList();

      filteredSubject = widget.jsonData
          .map<String>((item) => item['assignature_name'].toString())
          .toSet()
          .toList();

      // selectedGrade = null;
      // selectedGroup = null;
      // selectedSubject = null;

      selectedGrade = filteredGrade.first;
      selectedGroup = filteredGroup.first;
      selectedSubject = filteredSubject.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // The Unity Dropdown
            if (unityList.length > 1)
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownMenu<String>(
                      label: const Text(' Campus '),
                      trailingIcon: const Icon(Icons.arrow_drop_down),
                      initialSelection: selectedUnity,
                      onSelected: (String? value) {
                        setState(() {
                          selectedUnity = value;
                          filterData();
                        });
                      },
                      dropdownMenuEntries: unityList
                          .toList()
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList()),

                  // DropdownButton<String>(
                  //   value: selectedUnity,
                  //   items: unityList.map((String value) {
                  //     return DropdownMenuItem<String>(
                  //       value: value,
                  //       child: Text(value),
                  //     );
                  //   }).toList(),
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       selectedUnity = newValue;
                  //       filterData();
                  //     });
                  //   },
                  //   hint: const Text("Campus "),
                  //   icon: const Icon(Icons.business_outlined),
                  // ),
                ],
              )),

            Flexible(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu<String>(
                    label: const Text(' Grado '),
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    initialSelection: selectedGrade,
                    onSelected: (String? value) {
                      selectedGrade = value;
                    },
                    dropdownMenuEntries: filteredGrade
                        .toList()
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList()),
              ],
            )),

            Flexible(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu<String>(
                    label: const Text(' Grupo '),
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    initialSelection: selectedGroup,
                    onSelected: (String? value) {
                      selectedGroup = value;
                    },
                    dropdownMenuEntries: filteredGroup
                        .toList()
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList()),

                // DropdownButton<String>(
                //   items: filteredGroup.map((String value) {
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: Text(value),
                //     );
                //   }).toList(),
                //   onChanged: (String? newValue) {
                //     // Handle the second dropdown selection
                //   },
                //   hint: const Text("Grupo "),
                //   icon: const Icon(Icons.group),
                // ),
              ],
            )),
            Flexible(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu<String>(
                    label: const Text(' Materia '),
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    initialSelection: selectedSubject,
                    onSelected: (String? value) {
                      selectedSubject = value;
                    },
                    dropdownMenuEntries: filteredSubject
                        .toList()
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList()),
              ],
            )),

            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userStatus)
                    DropdownMenu<String>(
                        label: const Text(' Mes '),
                        trailingIcon: const Icon(Icons.arrow_drop_down),
                        initialSelection: monthValue,
                        onSelected: (String? value) {
                          monthValue = value!;
                        },
                        dropdownMenuEntries: academicMonthsList
                            .toList()
                            .map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(
                              value: value, label: value);
                        }).toList())
                  else
                    Text(
                      currentMonth,
                      style: const TextStyle(
                          fontFamily: 'Sora', fontWeight: FontWeight.bold),
                    )
                ],
              ),
            ),

            Flexible(
                child: ElevatedButton.icon(
                    onPressed: () async {
                      validateEmptryFields();
                      searchGradesBySubjectButton(
                          selectedGrade!,
                          selectedGroup!,
                          selectedSubject!,
                          monthValue,
                          selectedUnity!);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar')))
          ],
        ));
  }

  void validateEmptryFields() {
    if (studentList.isNotEmpty) {
      studentList.clear();
    }

    //TODO: COMPLETE VALIDATION TO EXECUTE BEFORE SENDING THE REQUEST

    if (selectedGrade == null ||
        selectedGroup == null ||
        selectedSubject == null ||
        selectedUnity == null) {
      showEmptyFieldAlertDialog(context, 'Campo vacio, verificar');
    }
  }
}
