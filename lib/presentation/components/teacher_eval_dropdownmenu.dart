import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/date_constants.dart';
import '../../data/datasources/temp/studens_temp.dart';
import '../../data/datasources/temp/teacher_grades_temp.dart';
import '../Modules/academic/grades_by_asignature.dart';

class TeacherEvalDropDownMenu extends StatefulWidget {
  final List<dynamic> jsonData;
  final Set<String> campusesList;
  final bool byStudent;

  const TeacherEvalDropDownMenu(
      {super.key,
      required this.jsonData,
      required this.campusesList,
      required this.byStudent});

  @override
  State<TeacherEvalDropDownMenu> createState() =>
      _TeacherEvalDropDownMenuState();
}

int currentMonthNumber = DateTime.now().month;

class _TeacherEvalDropDownMenuState extends State<TeacherEvalDropDownMenu> {
  String? selectedGrade;
  String? selectedGroup;
  String? selectedSubject;
  // String? selectedUnity;
  List<String> unityList = [];
  List<String> filteredGrade = [];
  List<String> filteredGroup = [];
  List<String> filteredSubject = [];
  String currentMonth = monthsListMap[currentMonthNumber] ?? 'Unknown month';

  String monthValue = '';
  bool userStatus = false;
  bool hasBeenFiltered = false;

  @override
  void initState() {
    _isUserAdminResult();
    if (selectedTempMonth != null) {
      monthValue = selectedTempMonth!;
    }
    unityList = widget.campusesList.toList();
    if (unityList.length == 1) {
      selectedTempCampus = unityList.first;
    }
    filterData();
    super.initState();
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

      if (hasBeenFiltered) {
        selectedGrade = filteredGrade.first;
        selectedGroup = filteredGroup.first;
        selectedSubject = filteredSubject.first;
      } else {
        selectedGrade = gradeSelected;
        selectedGroup = groupSelected;
        selectedSubject = subjectSelected;
      }
    } else {
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

      if (hasBeenFiltered) {
        selectedGrade = filteredGrade.first;
        selectedGroup = filteredGroup.first;
        selectedSubject = filteredSubject.first;
      } else {
        selectedGrade = gradeSelected;
        selectedGroup = groupSelected;
        selectedSubject = subjectSelected;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(bottom: 20, top: 25, right: 20, left: 20),
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
                          selectedTempCampus = value;
                          filterData();
                          hasBeenFiltered = true;
                        });
                      },
                      dropdownMenuEntries: unityList
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
                    label: const Text(' Grado '),
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    initialSelection: selectedGrade,
                    onSelected: (String? value) {
                      selectedGrade = value;
                      gradeSelected = value!;
                      selectedTempGrade = value;
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
                      groupSelected = value!;
                      selectedTempGroup = value;
                    },
                    dropdownMenuEntries: filteredGroup
                        .toList()
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList()),
              ],
            )),
            if (!widget.byStudent)
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
                        subjectValue = value!;
                        subjectSelected = value;
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
                          selectedTempMonth = value;
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

            // Flexible(
            //     child: ElevatedButton.icon(
            //   onPressed: () async {
            //     // studentGradesBodyToUpgrade.clear();
            //     // validator();

            //     // searchBUttonAction(
            //     //     groupSelected,
            //     //     gradeInt.toString(),
            //     //     assignatureID.toString(),
            //     //     monthNumber.toString(),
            //     //     selectedUnity!);
            //   },
            //   icon: const Icon(Icons.search),
            //   label: const Text('Buscar'),
            // ))
          ],
        ));
  }

  void validateEmptryFields() {
    if (studentList.isNotEmpty) {
      studentList.clear();
    }

    selectedGrade ??= filteredGrade.first;
    selectedGroup ??= filteredGroup.first;
    selectedSubject ??= filteredSubject.first;

    if (userStatus == true) {
      monthValue = getKeyFromValue(monthsListMap, monthValue).toString();
    } else {
      monthValue = getKeyFromValue(monthsListMap, currentMonth).toString();
    }
  }
}
