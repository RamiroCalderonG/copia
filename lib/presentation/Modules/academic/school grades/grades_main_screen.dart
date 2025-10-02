import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/reusable_methods/device_functions.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/core/utils/temp_data.dart';
import 'package:oxschool/data/datasources/temp/studens_temp.dart';
import 'package:oxschool/presentation/Modules/academic/school%20grades/fo_dac_27.dart';
import 'package:oxschool/presentation/Modules/academic/school%20grades/grades_by_asignature.dart';
import 'package:oxschool/core/constants/user_consts.dart';

import '../../../../core/reusable_methods/academic_functions.dart';
import '../../../../data/datasources/temp/teacher_grades_temp.dart';
import 'grades_per_student.dart';

class GradesMainScreen extends StatefulWidget {
  const GradesMainScreen({super.key});

  @override
  State<GradesMainScreen> createState() => _GradesMainScreenState();
}

String? preSelectedGrade;
String? preSelectedGroup;
String? preSelectedSubject;
String? preSelectedUnity;

class _GradesMainScreenState extends State<GradesMainScreen>
    with TickerProviderStateMixin {
  bool showGrid = false; // Flag to control grid visibility

  late Future<void> _initializationFuture;

  TabController? _tabController;
  bool isSearching = true;
  bool canEvaluateNow =
      false; //Evaluate if current dates are available for evaluations

  bool canUserEvaluate = false; //Evaluate if current user have any data
  bool displayEvaluateGrids = false;
  bool isUserAdmin = currentUser!.isCurrentUserAdmin();
  bool isUserAcdemicCoord = currentUser!.isCurrentUserAcademicCoord();
  bool isSearchingGrades = false;
  String? errorMessage;
  bool displayErrorMessage = false;
  bool isDeviceMobile = false;

  onTap() {
    isSearchingGrades = false;
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(onTap);

    // fetchData();
    _initializationFuture = validateDateAndUserPriv();
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
    studentGradesBodyToUpgrade.clear();
    campusesWhereTeacherTeach.clear();
    selectedUnity = null;
    displayErrorMessage = false;
    canEvaluateNow = false;
    canUserEvaluate = false;
    displayEvaluateGrids = false;
    preSelectedGrade = null;
    preSelectedGroup = null;
    preSelectedSubject = null;
    preSelectedUnity = null;
    jsonDataForDropDownMenuClass.clear();
    _tabController?.dispose();
    selectedTempMonth = null;
    super.dispose();
  }

  // void fetchData() {
  //   isUserAdmin = currentUser!.isCurrentUserAdmin();
  // }

  Future<void> validateDateAndUserPriv() async {
    try {
      isDeviceMobile = await isCurrentDeviceMobile();
      String? campus;
      setState(() {
        isSearching = true;
      });
      evalMonthFromBackend = await fetchEvalMonthFromBackend(false)
          .catchError((onError) => Future.error(onError));
      evalMonthNameFromBackend = await fetchEvalMonthFromBackend(true)
          .catchError((onError) => Future.error(onError));
      if (isUserAdmin || isUserAcdemicCoord) {
        setState(() {
          canEvaluateNow = true;
          campus = currentUser!.claUn;
        });
        // canEvaluateNow = true;
        // campus = currentUser!.claUn;
      } else {
        //Fetch dates for evaluations, if not current date will not fetch student data
        canEvaluateNow = await isDateToEvaluateStudents().catchError((onError) {
          //showErrorFromBackend(context, onError);
          return Future.error(onError);
        });
      }
      if (canEvaluateNow) {
        if (isUserAdmin || currentUser!.isAcademicCoord!) {
          await loadStartGradingAsAdminOrAcademicCoord(
              currentCycle!.claCiclo!,
              currentUser!.claUn,
              true,
              null,
              null,
              currentUser!.isCurrentUserAcademicCoord(),
              currentUser!.isCurrentUserAdmin());
        } else {
          await loadStartGrading(
              currentUser!.employeeNumber!,
              currentCycle!.claCiclo!,
              currentUser!.isCurrentUserAdmin(),
              currentUser!.isCurrentUserAcademicCoord(),
              campus);
        }

        setState(() {
          canUserEvaluate = canEvaluateNow;
          isSearching = false;
          displayEvaluateGrids = true;
        });
      } else {
        setState(() {
          displayErrorMessage = true;
        });
      }

      setState(() {
        isSearching = false;
      });
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);

    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScaffold(theme);
        } else if (snapshot.hasError) {
          return _buildErrorScaffold(theme, snapshot.error.toString());
        } else {
          return _buildMainScaffold(theme, colorScheme, isDesktop);
        }
      },
    );
  }

  Widget _buildLoadingScaffold(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cargando calificaciones',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por favor, espere mientras se cargan los datos',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const CustomLoadingIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(ThemeData theme, String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.errorContainer.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error al cargar datos',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _initializationFuture = validateDateAndUserPriv();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainScaffold(
      ThemeData theme, ColorScheme colorScheme, bool isDesktop) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildModernAppBar(theme, colorScheme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: isSearching
            ? const Center(child: CustomLoadingIndicator())
            : displayEvaluateGrids
                ? _buildTabContent(theme, isDesktop)
                : _buildEmptyState(theme),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isDeviceMobile
          ? FloatingActionButton.extended(
              onPressed: () {
                // Add action for mobile FAB
              },
              icon: const Icon(Icons.add),
              label: const Text('Acción'),
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            )
          : null,
    );
  }

  PreferredSizeWidget _buildModernAppBar(
      ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: Row(
        children: [
          // Container(
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(
          //     color: colorScheme.primaryContainer,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Icon(
          //     Icons.school,
          //     color: colorScheme.onPrimaryContainer,
          //     size: 24,
          //   ),
          // ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calificaciones',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Captura calificaciones',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: FlutterFlowTheme.of(context).primary,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 4,
      centerTitle: false,
      bottom:
          displayEvaluateGrids ? _buildModernTabBar(theme, colorScheme) : null,
    );
  }

  PreferredSizeWidget _buildModernTabBar(
      ThemeData theme, ColorScheme colorScheme) {
    return TabBar(
      controller: _tabController,
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      indicatorWeight: 3,
      dividerColor: colorScheme.outlineVariant,
      labelStyle: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.subject,
              size: 20,
              color: Colors.white54,
            ),
          ),
          // text: 'Por Materia',
          child: Text(
            'Por Materia',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Tab(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
              size: 20,
              color: Colors.white,
            ),
          ),
          child: Text(
            'Por Alumno',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          // text: 'Por Alumno',
        ),
        Tab(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              FontAwesomeIcons.fileLines,
              size: 16,
              color: Colors.white,
            ),
          ),
          // text: 'FO-DAC-27',
          child: Text(
            'FO-DAC-27',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(ThemeData theme, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: BoxConstraints(
              minHeight: isDesktop ? 600 : 0,
            ),
            child: TabBarView(
              key: const PageStorageKey('grades_tab_view'),
              controller: _tabController,
              children: const [
                GradesByAsignature(),
                GradesByStudent(),
                FoDac27(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    displayErrorMessage
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline,
                    size: 64,
                    color: displayErrorMessage
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  displayErrorMessage ? 'Error' : 'Sin información',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayErrorMessage
                      ? errorMessage!
                      : 'Sin información disponible, consulte con el administrador',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (displayErrorMessage) ...[
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _initializationFuture = validateDateAndUserPriv();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
