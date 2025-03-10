
import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:oxschool/presentation/Modules/academic/grades_main_screen.dart';
import '../../core/constants/date_constants.dart';
import '../../core/constants/user_consts.dart';
import '../../data/datasources/temp/studens_temp.dart';
import '../../data/datasources/temp/teacher_grades_temp.dart';
// import '../Modules/academic/grades_by_asignature.dart';

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
  // List<String> unityAdminList = ['ANAHUAC', 'BARRAGAN', 'CONCORDIA', 'SENDERO'];
  List<String> filteredGrade = [];
  List<String> filteredGroup = [];
  List<String> filteredSubject = [];
  Map<String, int> filteredSubjectMap = {};
  String currentMonth = spanishMonthsMap[currentMonthNumber] ?? 'Unknown month';

  String monthValue = '';
  // bool userStatus = false;
  bool hasBeenFiltered = false;

  @override
  void initState() {
    _isUserAdminResult();
    unityList = widget.campusesList.toList();
    if (unityList.length == 1) {
      selectedTempCampus = unityList.first;
      selectedUnity = unityList.first;
    }
    filterData();
    super.initState();
  }

  @override
  void dispose() {
    //monthValue = '';
    //selectedCurrentTempMonth = null;
    //selectedTempMonth = null;
    super.dispose();
  }

  _isUserAdminResult() async {
    setState(() {
      if (currentUser!.isCurrentUserAdmin() == false && currentUser!.isCurrentUserAcademicCoord() == false) {
        //If user not admin, will assign current month, and it will not change
        selectedCurrentTempMonth = currentMonth;
        monthValue = currentMonth;
      } else {
        //If user is admin, will assign current month and then can change
        if (selectedTempMonth != null) {
          monthValue = selectedTempMonth!;
        } else {
          selectedTempMonth = currentMonth;
          monthValue = currentMonth;
        }
      }
    });
  }

  void filterData() {
    filteredSubjectMap.clear();
    if (selectedUnity != null) {
      // Filter grades based on Campus
      filteredGrade = widget.jsonData
          .where((item) => (item['Campus'] ?? item['campus']) == selectedUnity)
          .map<String>(
              (item) => (item['Grade'] ?? item['grade'])?.toString() ?? '')
          .toSet()
          .toList();

      // Reset dependent selections when Campus changes
      if (!filteredGrade.contains(selectedGrade)) {
        selectedGrade = null;
        selectedGroup = null;
        selectedSubject = null;
      }

      // Filter groups based on Campus and Grade
      filteredGroup = widget.jsonData
          .where((item) =>
              (item['Campus'] ?? item['campus']) == selectedUnity &&
              (selectedGrade == null ||
                  (item['Grade'] ?? item['grade']) == selectedGrade))
          .map<String>((item) =>
              (item['School_group'] ?? item['school_group'])?.toString() ?? '')
          .toSet()
          .toList();

      // Reset dependent selections when Grade changes
      if (!filteredGroup.contains(selectedGroup)) {
        selectedGroup = null;
        selectedSubject = null;
      }

      // Filter subjects based on Campus, Grade, and Group
      filteredSubject = widget.jsonData
          .where((item) =>
              (item['Campus'] ?? item['campus']) == selectedUnity &&
              (selectedGrade == null ||
                  (item['Grade'] ?? item['grade']) == selectedGrade) &&
              (selectedGroup == null ||
                  (item['School_group'] ?? item['school_group']) ==
                      selectedGroup))
          .map<String>(
              (item) => (item['Subject'] ?? item['subject'])?.toString() ?? '')
          .toSet()
          .toList();

      filteredSubjectMap = {
        for (var item in widget.jsonData.where((item) =>
            (item['Campus'] ?? item['campus']) == selectedUnity &&
            (selectedGrade == null ||
                (item['Grade'] ?? item['grade']) == selectedGrade) &&
            (selectedGroup == null ||
                (item['School_group'] ?? item['school_group']) ==
                    selectedGroup)))
          (item['Subject'] ?? item['subject'])?.toString() ?? '':
              (item['Subject_id'] ?? item['subject_id']) ?? ''
      };

      // Reset Subject if it doesn't match the new filter
      if (!filteredSubject.contains(selectedSubject)) {
        selectedSubject = null;
      }
    } else {
      // Reset to full lists if no Campus is selected
      filteredGrade = widget.jsonData
          .map<String>(
              (item) => (item['Grade'] ?? item['grade'])?.toString() ?? '')
          .toSet()
          .toList();
      filteredGroup = widget.jsonData
          .map<String>((item) =>
              (item['School_group'] ?? item['school_group'])?.toString() ?? '')
          .toSet()
          .toList();
      filteredSubject = widget.jsonData
          .map<String>(
              (item) => (item['Subject'] ?? item['subject'])?.toString() ?? '')
          .toSet()
          .toList();

      selectedGrade = null;
      selectedGroup = null;
      selectedSubject = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(bottom: 20, top: 25, right: 20, left: 20),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The Unity Dropdown
            if (unityList.length > 1)
              
                  DropdownMenu<String>(
                    label: const Text(
                      ' Campus ',
                     style: TextStyle(fontSize: 12),
                    ),
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    initialSelection: selectedUnity,
                    onSelected: (String? value) {
                      setState(() {
                        selectedUnity = value;
                        selectedGrade = null; // Clear dependent selections
                        selectedGroup = null;
                        selectedSubject = null;
                        selectedTempCampus = value;
                        filterData();
                      });
                    },
                    dropdownMenuEntries: unityList
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList(),
                  ),
                
              
            if (unityList.length == 1) Text(unityList.first),
           // Flexible(
            //    child: 
                DropdownMenu<String>(
                  label: const Text(
                    ' Grado ',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailingIcon: const Icon(Icons.arrow_drop_down),
                  initialSelection: preSelectedGrade ?? selectedGrade,
                  onSelected: (String? value) {
                    setState(() {
                      preSelectedGrade = value;
                      selectedGrade = value;
                      selectedGroup = null; // Clear dependent selections
                      selectedSubject = null;
                      selectedTempGrade = getKeyFromValue(
                          teacherGradesMap, value!); //int.parse(value!);
                      filterData();
                    });
                  },
                  dropdownMenuEntries: filteredGrade
                      .map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(
                        value: value, label: value);
                  }).toList(),
                ),
         // ),

          //  Flexible(
          //      child: 
                DropdownMenu<String>(
                  label: const Text(
                    ' Grupo ',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailingIcon: const Icon(Icons.arrow_drop_down),
                  initialSelection: preSelectedGroup ?? selectedGroup,
                  onSelected: (String? value) {
                    setState(() {

                      preSelectedGroup = value;
                      selectedGroup = value;
                      selectedSubject = filteredSubject.first; // Clear dependent selections
                      selectedTempGroup = value;

                      filterData();
                    });
                  },
                  dropdownMenuEntries: filteredGroup
                      .map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(
                        value: value, label: value);
                  }).toList(),
                ),
          //    ),
            if (!widget.byStudent) //Not by student
              //Flexible(
               //   flex: 2,
                //  fit: FlexFit.loose,
                //  child: 
                      DropdownMenu<String>(
                        label: const Text(
                          ' Materia ',
                          style: TextStyle(fontSize: 12),
                        ),
                        
                        trailingIcon: const Icon(Icons.arrow_drop_down),
                        initialSelection: preSelectedSubject ?? selectedSubject,
                        onSelected: (String? value) {
                          setState(() {
                            selectedTempSubjectId = filteredSubjectMap[value];
                            preSelectedSubject = value;
                            selectedSubject = value;
                            selectedTempSubject = value;
                          });
                        },
                        dropdownMenuEntries: filteredSubject
                            .map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(
                              value: value, label: value);
                        }).toList(),
                      ),
//),

           // Flexible(
            //  child: 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentUser!.isCurrentUserAdmin() || currentUser!.isCurrentUserAcademicCoord())
                    DropdownMenu<String>(
                        label: const Text(' Mes '),
                        trailingIcon: const Icon(Icons.arrow_drop_down),
                        initialSelection: monthValue,
                        onSelected: (String? value) {
                          setState(() {
                            monthValue = value!;
                            selectedTempMonth = value;
                          });
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
           // ),
          ],
        ));
  }

  void validateEmptryFields() {
    // Check if any of the fields are empty
    if (studentList.isNotEmpty) {
      studentList.clear();
    }
    selectedGrade ??= filteredGrade.first;
    selectedGroup ??= filteredGroup.first;
    selectedSubject ??= filteredSubject.first;

    if (currentUser!.isCurrentUserAdmin() || currentUser!.isCurrentUserAcademicCoord()) {
      monthValue = getKeyFromValue(spanishMonthsMap, monthValue).toString();
    } else {
      monthValue = getKeyFromValue(spanishMonthsMap, currentMonth).toString();
    }
  }
}
