import 'package:flutter/material.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/data/datasources/temp/studens_temp.dart';

import '../../../../core/constants/user_consts.dart';
import '../../../../data/datasources/temp/teacher_grades_temp.dart';

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
    selectedStudentController.dispose();
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 800;
        final isVerySmallScreen = constraints.maxWidth < 600;
        final spacing = isVerySmallScreen ? 8.0 : 10.0;
        final topPadding = isVerySmallScreen ? 12.0 : 15.0;

        return Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: isSmallScreen
              ? _buildVerticalLayout(gradesValues, groupsValues, studentsValues,
                  spacing, isVerySmallScreen)
              : _buildHorizontalLayout(
                  gradesValues, groupsValues, studentsValues, spacing),
        );
      },
    );
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

  Widget _buildHorizontalLayout(List<String> gradesValues,
      List<String> groupsValues, List<String> studentsValues, double spacing) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: spacing),
          SizedBox(
            width: 200,
            child: _buildCampusDropdown(),
          ),
          SizedBox(width: spacing),
          if (selectedCampus != null)
            SizedBox(
              width: 150,
              child: _buildGradeDropdown(gradesValues),
            ),
          if (selectedCampus != null) SizedBox(width: spacing),
          if (selectedGrade != null)
            SizedBox(
              width: 120,
              child: _buildGroupDropdown(groupsValues),
            ),
          if (selectedGrade != null) SizedBox(width: spacing),
          if (selectedGroup != null)
            SizedBox(
              width: 300,
              child: _buildStudentDropdown(studentsValues),
            ),
          SizedBox(width: spacing),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(
      List<String> gradesValues,
      List<String> groupsValues,
      List<String> studentsValues,
      double spacing,
      bool isVerySmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: isVerySmallScreen ? 1 : 2,
              child: _buildCampusDropdown(),
            ),
            if (selectedCampus != null) SizedBox(width: spacing),
            if (selectedCampus != null)
              Expanded(
                flex: 1,
                child: _buildGradeDropdown(gradesValues),
              ),
          ],
        ),
        if (selectedGrade != null) SizedBox(height: spacing),
        if (selectedGrade != null)
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildGroupDropdown(groupsValues),
              ),
              if (selectedGroup != null) SizedBox(width: spacing),
              if (selectedGroup != null)
                Expanded(
                  flex: isVerySmallScreen ? 1 : 2,
                  child: _buildStudentDropdown(studentsValues),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCampusDropdown() {
    return DropdownMenu<String>(
      label: const Text('Campus'),
      trailingIcon: const Icon(Icons.arrow_drop_down),
      expandedInsets: EdgeInsets.zero,
      onSelected: (value) {
        setState(() {
          selectedCampus = value!;
          selectedTempCampus = value;
          selectedGrade = null;
          selectedGroup = null;
        });
      },
      dropdownMenuEntries: teacherCampusListFODAC27
          .toList()
          .map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }

  Widget _buildGradeDropdown(List<String> gradesValues) {
    return DropdownMenu<String>(
      label: const Text('Grado'),
      trailingIcon: const Icon(Icons.arrow_drop_down),
      expandedInsets: EdgeInsets.zero,
      onSelected: (value) {
        setState(() {
          selectedGradeName = value;
          selectedGrade = gradesMapFODAC27[selectedGradeName];
          selectedTempGrade = selectedGrade;
        });
      },
      dropdownMenuEntries:
          gradesValues.toList().map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value.toString());
      }).toList(),
    );
  }

  Widget _buildGroupDropdown(List<String> groupsValues) {
    return DropdownMenu<String>(
      label: const Text('Grupo'),
      trailingIcon: const Icon(Icons.arrow_drop_down),
      expandedInsets: EdgeInsets.zero,
      onSelected: (value) async {
        setState(() {
          selectedGroup = value;
          selectedTempGroup = value;
          selectedStudent = '';
        });
        setState(() {
          selectedStudentController.text = '';
        });
      },
      dropdownMenuEntries:
          groupsValues.toList().map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }

  Widget _buildStudentDropdown(List<String> studentsValues) {
    return DropdownMenu<String>(
      label: const Text('Alumno'),
      trailingIcon: const Icon(Icons.arrow_drop_down),
      expandedInsets: EdgeInsets.zero,
      controller: selectedStudentController,
      onSelected: (student) {
        if (student != null) {
          setState(() {
            selectedStudentController.text = student;
            selectedTempStudent = student;
          });
        }
      },
      dropdownMenuEntries:
          studentsValues.toList().map<DropdownMenuEntry<String>>((var value) {
        return DropdownMenuEntry<String>(
            value: value, label: value.toTitleCase);
      }).toList(),
    );
  }

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
