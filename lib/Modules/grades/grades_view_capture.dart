import 'package:flutter/material.dart';
import 'package:oxschool/Modules/grades/grades_by_asignature.dart';
import 'package:oxschool/constants/User.dart';

import '../../constants/Student.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../reusable_methods/academic_functions.dart';
import '../../temp/teacher_grades_temp.dart';
import 'grades_per_student.dart';

class GradesViewScreen extends StatefulWidget {
  const GradesViewScreen({super.key});

  @override
  State<GradesViewScreen> createState() => _GradesViewScreenState();
}

class _GradesViewScreenState extends State<GradesViewScreen>
    with TickerProviderStateMixin {
  bool showGrid = false; // Flag to control grid visibility

  late final TabController _tabController;
  bool isSearching = false; // Add a state variable to track search status

  onTap() {
    isSearching = false;
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
    // _tabController = TabController(vsync: this, length: nurseryTabs.length);
    _tabController.addListener(onTap);

    loadStartGrading(currentUser!.employeeNumber!, currentCycle!.claCiclo!);
  }

  @override
  void dispose() {
    oneTeacherGrades.clear();
    oneTeacherGroups.clear();
    oneTeacherAssignatures.clear();
    oneTeacherStudents.clear();
    oneTeacherStudentID.clear();
    assignaturesMap.clear();
    studentList.clear();
    assignatureRows.clear();
    studentEvaluationRows.clear();
    uniqueStudents.clear();
    uniqueStudentsList.clear();
    selectedStudentList.clear();
    selectedStudentRows.clear();
    // studentEvaluationRows.clear();
    // assignatureRows.clear();
    // studentColumnsToEvaluateByStudent.clear();
    studentGradesBodyToUpgrade.clear();
    // assignaturesColumns.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: const [],
          bottom: TabBar(
            labelColor: Colors.white,
            controller: _tabController,
            tabs: const <Widget>[
              Tab(
                icon: Icon(Icons.abc, color: Colors.white),
                text: 'Carga por materia',
              ),
              Tab(
                icon: Icon(
                  Icons.boy,
                  // size: 40,
                ),
                text: 'Carga por alumno',
              ),
            ],
            indicatorColor: Colors.blueAccent,
          ),
          title: const Text('Calificaciones',
              style: TextStyle(color: Colors.white)),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: TabBarView(
          controller: _tabController,
          children: const <Widget>[GradesByAsignature(), GradesByStudent()],
        ));
  }
}
