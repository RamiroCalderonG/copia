import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/presentation/Modules/academic/fo_dac_27.dart';
import 'package:oxschool/presentation/Modules/academic/grades_by_asignature.dart';
import 'package:oxschool/core/constants/User.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../../core/reusable_methods/academic_functions.dart';
import '../../../core/reusable_methods/user_functions.dart';
import '../../../data/datasources/temp/teacher_grades_temp.dart';
import 'grades_per_student.dart';

class GradesMainScreen extends StatefulWidget {
  const GradesMainScreen({super.key});

  @override
  State<GradesMainScreen> createState() => _GradesMainScreenState();
}

class _GradesMainScreenState extends State<GradesMainScreen>
    with TickerProviderStateMixin {
  bool showGrid = false; // Flag to control grid visibility

  TabController? _tabController;
  bool isSearching = false; // Add a state variable to track search status
  // bool canEvaluateNow =
  //     false; //Evaluate if current dates are available for evaluations
  bool canUserEvaluate = false; //Evaluate if current user have any data
  bool displayEvaluateGrids = false;
  bool isUserAdmin = false;

  onTap() {
    isSearchingGrades = false;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(onTap);
    fetchData();
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
    commentsAsignatedList.clear();
    mergedData.clear();
    commentsIntEval.clear();
    commentStringEval.clear();
    gradesByStudentBodyToUpgrade.clear();
    studentsGradesCommentsRows.clear();
    commentsAsignated.clear();
    // studentEvaluationRows.clear();
    // assignatureRows.clear();
    // studentColumnsToEvaluateByStudent.clear();
    studentGradesBodyToUpgrade.clear();
    campusesWhereTeacherTeach.clear();
    selectedUnity = null;
    // assignaturesColumns.clear();
    super.dispose();
  }

  void fetchData() {
    initSharedPref();
    initGetDate();
    loadStartGrading(currentUser!.employeeNumber!, currentCycle!.claCiclo!);
  }

  void initGetDate() async {
    canEvaluateNow = await isDateToEvaluateStudents();

    setState(() {
      canUserEvaluate = canEvaluateNow;
    });

    validateDateAndUserPriv();
  }

  Future<void> validateDateAndUserPriv() async {
    if (canUserEvaluate || currentUser!.canEditStudentGrades()) {
      setState(() {
        displayEvaluateGrids = true;
      });
    } else {
      if (currentUser!.canEditStudentGrades()) {
        setState(() {
          displayEvaluateGrids = true;
        });
      }
      displayEvaluateGrids = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //_tabController = TabController(length: 3, vsync: this);

    return Scaffold(
        appBar: AppBar(
          actions: const [],
          bottom: TabBar(
            labelColor: Colors.white,
            controller: _tabController,
            tabs: const <Widget>[
              Tab(
                icon: Icon(Icons.abc),
                text: 'Carga por materia',
              ),
              Tab(
                icon: Icon(
                  Icons.boy,
                  // size: 40,
                ),
                text: 'Carga por alumno',
              ),
              Tab(
                icon: FaIcon(
                  FontAwesomeIcons.sheetPlastic,
                ),
                text: 'FO-DAC-27',
              )
            ],
            indicatorColor: Colors.blueAccent,
          ),
          title: const Text('Calificaciones',
              style: TextStyle(color: Colors.white)),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: displayEvaluateGrids
            ? TabBarView(
                key: const PageStorageKey('value'),
                controller: _tabController,
                children: const <Widget>[
                  GradesByAsignature(),
                  GradesByStudent(),
                  FoDac27()
                ],
              )
            : const Placeholder(
                color: Colors.transparent,
                child: Center(
                    child: Center(
                  child: Text(
                    'Sin información, consulte con el administrador',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Sora', fontSize: 20),
                  ),
                )),
              ));
  }

  void initSharedPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isUserAdmin = prefs.getBool('isUserAdmin')!;
    });
  }
}
