import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/presentation/Modules/academic/fo_dac_27.dart';
import 'package:oxschool/presentation/Modules/academic/grades_by_asignature.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../../core/reusable_methods/academic_functions.dart';
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
  bool isSearching = false;
  bool canEvaluateNow =
      false; //Evaluate if current dates are available for evaluations
  bool canUserEvaluate = false; //Evaluate if current user have any data
  bool displayEvaluateGrids = false;
  bool isUserAdmin = false;
  bool isSearchingGrades = false;
  String? errorMessage;
  bool displayErrorMessage = false;

  onTap() {
    isSearchingGrades = false;
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(onTap);
    fetchData();
    super.initState();
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
    displayErrorMessage = false;
    canEvaluateNow = false;
    canUserEvaluate = false;
    displayEvaluateGrids = false;
    // assignaturesColumns.clear();
    super.dispose();
  }

  void fetchData() {
    initSharedPref();
    initGetDate();
  }

  void initGetDate() async {
    await validateDateAndUserPriv();
  }

  Future<void> validateDateAndUserPriv() async {
    try {
      setState(() {
        isSearching = true;
      });
      canEvaluateNow = await isDateToEvaluateStudents().catchError((onError) {
        showErrorFromBackend(context, onError);
      });
      if (canEvaluateNow) {
        loadStartGrading(currentUser!.employeeNumber!, currentCycle!.claCiclo!);
      }
      setState(() {
        canUserEvaluate = canEvaluateNow;
        isSearching = false;
        displayEvaluateGrids = true;
      });
      // setState(() {
      //   isSearching = false;
      // });
    } catch (e) {
      setState(() {
        isSearching = false;
      });
      insertErrorLog(e.toString(),
          'FETCHING DATE TO EVALUATE AND USER ROLE ON GRADESMAINSCREEN');
      setState(() {
        errorMessage = getMessageToDisplay(e.toString());
        displayErrorMessage = true;
      });

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);
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
        body: isSearching
            ? const CustomLoadingIndicator()
            : displayEvaluateGrids
                ? Container(
                    constraints: BoxConstraints(
                      minHeight: isDesktop ? 600 : 0,
                    ),
                    child: TabBarView(
                      key: const PageStorageKey('value'),
                      controller: _tabController,
                      children: const <Widget>[
                        GradesByAsignature(),
                        GradesByStudent(),
                        FoDac27()
                      ],
                    ),
                  )
                : Placeholder(
                    color: Colors.transparent,
                    child: Center(
                        child: Center(
                      child: displayErrorMessage
                          ? Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Sora', fontSize: 20),
                            )
                          : const Text(
                              'Sin información, consulte con el administrador',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontFamily: 'Sora', fontSize: 20),
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
