import 'package:flutter/material.dart';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:intl/intl.dart';

import '../../../../data/Models/Student_eval.dart';

import '../../../../data/datasources/temp/studens_temp.dart';
import '../../../../data/services/backend/api_requests/api_calls_list_dio.dart';

import '../../../../core/constants/date_constants.dart';

import '../../../../core/config/flutter_flow/flutter_flow_util.dart';
import '../../../../core/reusable_methods/academic_functions.dart';
import '../../../../data/datasources/temp/teacher_grades_temp.dart';
import '../../../components/confirm_dialogs.dart';
import '../../../components/student_eval_comments_dialog.dart';
import '../../../components/teacher_eval_dropdownmenu.dart';

/// A widget for displaying grades by assignature.
///
/// This widget fetches data from the backend and displays it in a grid.
/// It also provides functionality for searching, updating, and saving grades.
///
/// Example:
///
/// ```dart
/// GradesByAsignature(
///   // Optional parameters
///   // ...
/// )
/// ```

class GradesByAsignature extends StatefulWidget {
  const GradesByAsignature({super.key});

  @override
  State<GradesByAsignature> createState() => _GradesByAsignatureState();
}

/// The current month.
String currentMonth = DateFormat.MMMM().format(DateTime.now());

/// The selected subject.
String? subjectSelected = oneTeacherAssignatures.first;

/// Whether the user is an admin.
bool isUserAdmin = false;
bool isUserAcademicCoord = false;

/// The list of rows in the grid.
List<TrinaRow> rows = [];

class _GradesByAsignatureState extends State<GradesByAsignature> {
  String? asignatureNameListener;
  String? selectedStudentName;
  // var gradeInt;
  Key trinaGridKey = UniqueKey();
  int? monthNumber;
  String monthValue = isUserAdmin || isUserAcademicCoord
      ? academicMonthsList.first
      : currentMonth;

  // int? assignatureID;
  String campusSelected = '';
  bool isLoading = true;
  var fetchedData;

  // Change tracking variables
  TrinaGridStateManager? stateManager;
  TrinaCell? selectedCell;
  int dirtyCount = 0;
  bool _disposed = false;

  bool hideCommentsColumn = false;
  bool hideAbsencesColumn = false;
  bool hideHomeworksColumn = false;
  bool hideDisciplineColumn = false;
  bool hideHabitsColumn = false;
  bool hideOutfitColumn = false;
  String? homeWorkColumnTitle;
  String? disciplineColumnTitle;

  /// Whether the teacher teaches multiple campuses.
  bool teacherTeachMultipleCampuses = false;

  @override
  void initState() {
    isUserAdmin = currentUser!.isCurrentUserAdmin();
    isUserAcademicCoord = currentUser!.isCurrentUserAcademicCoord();
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _disposed = true;
    rows.clear();
    selectedCurrentTempMonth = null;
    super.dispose();
  }

  List<TrinaColumn> get assignaturesColumns => [
        //TO USE at grades_by_assignature
        TrinaColumn(
          title: 'No.',
          field: 'No',
          width: 80,
          type: TrinaColumnType.number(),
          readOnly: true,
        ),
        TrinaColumn(
            title: 'Matrícula',
            field: 'Matricula',
            type: TrinaColumnType.text(),
            readOnly: true,
            width: 120),
        TrinaColumn(
          title: 'Nombre',
          field: 'Nombre',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 180,
        ),
        TrinaColumn(
            title: 'Apellido Paterno',
            field: 'Apellido paterno',
            type: TrinaColumnType.text(),
            readOnly: true,
            width: 150),
        TrinaColumn(
            title: 'Apellido Materno',
            field: 'Apellido materno',
            type: TrinaColumnType.text(),
            readOnly: true,
            width: 150),
        TrinaColumn(
            title: 'Calificación',
            field: 'Calif',
            type: TrinaColumnType.number(negative: false, format: '##'),
            readOnly: false,
            width: 120),
        TrinaColumn(
            title: 'idCalif',
            field: 'idCalif',
            type: TrinaColumnType.number(negative: false),
            hide: true),
        TrinaColumn(
            hide: hideAbsencesColumn,
            title: 'Faltas',
            field: 'Ausencia',
            type: TrinaColumnType.number(negative: false, format: '#'),
            readOnly: false,
            width: 100),
        TrinaColumn(
            hide: hideHomeworksColumn,
            title: homeWorkColumnTitle ?? 'Tareas',
            field: 'Tareas',
            type: TrinaColumnType.number(negative: false),
            readOnly: false,
            width: 100),
        TrinaColumn(
            hide: hideDisciplineColumn,
            title: disciplineColumnTitle ?? 'Conducta',
            field: 'Conducta',
            type: TrinaColumnType.number(negative: false),
            readOnly: false,
            width: 100),
        TrinaColumn(
            title: 'Hábitos',
            hide: hideHabitsColumn,
            field: 'habit_eval',
            readOnly: true,
            type: TrinaColumnType.number(negative: false),
            width: 100),
        TrinaColumn(
            hide: hideCommentsColumn,
            title: 'Comentarios',
            field: 'Comentarios',
            type: TrinaColumnType.text(),
            readOnly: false,
            width: 200),
      ];

  /// Fills the grid with data from the backend.
  ///
  /// [//evaluationList] is the list of evaluations to display in the grid.
  Future<void> fillGrid(List<StudentEval> evaluationList) async {
    setState(() {
      rows = evaluationList.map((item) {
        return TrinaRow(
          cells: {
            // 'Matricula': TrinaCell(value: item.studentID),
            'Nombre': TrinaCell(value: item.studentName),
            'Apellido paterno': TrinaCell(value: item.student1LastName),
            'Apellido materno': TrinaCell(value: item.student2LastName),
            'idCalif': TrinaCell(value: item.rateID),
          },
        );
      }).toList();
    });
  }

  void _fetchData() async {
    setState(() {
      fetchedData = fetchedDataFromloadStartGrading;
      isLoading = false;
    });
  }

  // Change tracking methods
  void commitChanges() {
    if (_disposed || stateManager == null) return;
    stateManager!.commitChanges();
    updateDirtyCount();
  }

  void revertChanges() {
    if (_disposed || stateManager == null) return;
    stateManager!.revertChanges();
    updateDirtyCount();
  }

  void commitSelectedCell() {
    if (_disposed || stateManager == null) return;
    if (selectedCell != null) {
      stateManager!.commitChanges(cell: selectedCell);
      updateDirtyCount();
    }
  }

  void revertSelectedCell() {
    if (_disposed || stateManager == null) return;
    if (selectedCell != null) {
      stateManager!.revertChanges(cell: selectedCell);
      updateDirtyCount();
    }
  }

  void updateDirtyCount() {
    if (_disposed) return;

    // Use Future.microtask to ensure we're not updating during build or dispose
    Future.microtask(() {
      if (_disposed) return;

      int count = 0;
      for (var row in assignatureRows) {
        for (var cell in row.cells.values) {
          if (cell.isDirty) {
            count++;
          }
        }
      }
      if (!_disposed) {
        setState(() {
          dirtyCount = count;
        });
      }
    });
  }

  Future<void> searchBUttonAction(
    String groupSelected,
    String gradeInt,
    String assignatureID,
    String month,
    String campus,
  ) async {
    try {
      setState(() {
        isLoading = true;
      });
      int? teacherNumber;
      if (isUserAdmin || isUserAcademicCoord) {
        teacherNumber = null;
      } else {
        teacherNumber = currentUser!.employeeNumber;
      }
      if (monthNumber != 8) {
        studentList = await getStudentsByAssinature(groupSelected, gradeInt,
            assignatureID, month, campus, teacherNumber);

        // Get evaluations comments by gradeSequence
        if (studentList.isNotEmpty) {
          studentsGradesCommentsRows =
              await getEvaluationsCommentsByGradeSequence(selectedTempGrade!);
        } else {
          throw Exception(
            'No se encontraron alumnos para el grupo seleccionado: $groupSelected, grado: $gradeInt, ciclo: ${currentCycle!.claCiclo}, campus: $campusSelected, mes: $month',
          );
        }

        await fillGrid(studentList);

        setState(() {
          displayColumnsByGrade(selectedTempGrade!);
          assignatureRows.clear();
          for (var item in studentList) {
            assignatureRows.add(TrinaRow(cells: {
              'No': TrinaCell(value: item.sequentialNumber ?? 0),
              'Matricula': TrinaCell(value: item.studentID),
              'Nombre': TrinaCell(value: item.studentName),
              'Apellido paterno': TrinaCell(value: item.student1LastName),
              'Apellido materno': TrinaCell(value: item.student2LastName),
              'Calif': TrinaCell(value: item.evaluation),
              'idCalif': TrinaCell(value: item.rateID),
              'Ausencia': TrinaCell(value: item.absence ?? 0),
              'Tareas': TrinaCell(value: item.homework ?? 0),
              'Conducta': TrinaCell(value: item.discipline ?? 0),
              'habit_eval': TrinaCell(value: item.habits_evaluation ?? 0),
              'Comentarios': TrinaCell(
                value: item.comment != null && item.comment != 0
                    ? item.comment.toString()
                    : '',
              ),
            }));
          }
          setState(() {
            selectedTempCampus = campus;
            selectedTempGrade = int.parse(gradeInt);
            selectedTempSubjectId = int.parse(assignatureID);

            // Call displayColumnsByGrade BEFORE updating trinaGridKey
            displayColumnsByGrade(selectedTempGrade!);

            // Force grid rebuild with new key AFTER visibility flags are set
            trinaGridKey = UniqueKey();

            isLoading = false;
          });
          // selectedTempCampus = campus;
          // selectedTempGrade = int.parse(gradeInt);
          // selectedTempSubjectId = int.parse(assignatureID);
          // isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        return showErrorFromBackend(context, 'Seleccione un mes');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      insertErrorLog(e.toString(), 'SEARCH STUDENTS BY SUBJECTS ');

      var message = getMessageToDisplay(e.toString());
      if (context.mounted) {
        showErrorFromBackend(context, message.toString());
      }
    }
  }

  /// Updates the grades in the backend.
  ///
  /// Returns a future that completes with a boolean indicating whether the update was successful.
  Future<dynamic> patchStudentGradesToDB() async {
    var response;
    await patchStudentsGrades(studentGradesBodyToUpgrade, false).then((status) {
      if (status == 200) {
        response = 200;
      }
    }).onError((error, statusTrace) {
      insertErrorLog(error.toString(),
          'patchStudentsGrades  | $studentGradesBodyToUpgrade');
      response = 400;
    });
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [
      //       colorScheme.primaryContainer.withOpacity(0.05),
      //       colorScheme.surface,
      //     ],
      //   ),
      // ),
      child: isLoading
          ? _buildLoadingState(theme)
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (fetchedData is Error) {
                  return _buildErrorState(theme);
                } else {
                  return _buildMainContent(theme, colorScheme);
                }
              },
            ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
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
              Icons.assignment_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando calificaciones por materia',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            const CustomLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        margin: const EdgeInsets.all(24),
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
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error de conexión',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Verificar la conectividad a internet',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    _fetchData();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: _buildGradesbyAssignature(theme, colorScheme),
    );
  }

  // Widget _buildHeaderCard(ThemeData theme, ColorScheme colorScheme) {
  //   return Card(
  //     elevation: 0,
  //     color: colorScheme.surfaceContainerHigh,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(20),
  //       side: BorderSide(
  //         color: colorScheme.outlineVariant,
  //         width: 1,
  //       ),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: colorScheme.primaryContainer,
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             child: Icon(
  //               Icons.assignment,
  //               color: colorScheme.onPrimaryContainer,
  //               size: 28,
  //             ),
  //           ),
  //           const SizedBox(width: 16),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Calificaciones por Materia',
  //                   style: theme.textTheme.titleLarge?.copyWith(
  //                     fontWeight: FontWeight.w600,
  //                     color: colorScheme.onSurface,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   'Gestión de evaluaciones académicas',
  //                   style: theme.textTheme.bodyMedium?.copyWith(
  //                     color: colorScheme.onSurfaceVariant,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildGradesbyAssignature(ThemeData theme, ColorScheme colorScheme) {
    campusSelected = campusesWhereTeacherTeach.first;
    if (campusesWhereTeacherTeach.length != 1) {
      teacherTeachMultipleCampuses = true;
    }

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFiltersSection(theme, colorScheme),
            const SizedBox(height: 6),
            _buildActionButtons(theme, colorScheme),
            const SizedBox(height: 6),
            Expanded(
              child: _buildGradesGrid(theme, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Filtros',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 3),
          TeacherEvalDropDownMenu(
            jsonData: jsonDataForDropDownMenuClass,
            campusesList: campusesWhereTeacherTeach,
            byStudent: false,
          ),
          const SizedBox(height: 6),
          _buildCompactChangeTracking(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildCompactChangeTracking(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.track_changes_rounded,
            color: colorScheme.secondary,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'Control de Cambios',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: dirtyCount > 0
                  ? colorScheme.errorContainer
                  : colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$dirtyCount',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: dirtyCount > 0
                    ? colorScheme.onErrorContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCompactButton(
                  'Confirmar',
                  Icons.done_all,
                  stateManager != null ? commitChanges : null,
                  colorScheme.primary,
                  theme),
              const SizedBox(width: 4),
              _buildCompactButton(
                  'Revertir',
                  Icons.undo,
                  stateManager != null ? revertChanges : null,
                  colorScheme.error,
                  theme),
              const SizedBox(width: 4),
              _buildCompactButton(
                  'C',
                  Icons.done,
                  (selectedCell != null && stateManager != null)
                      ? commitSelectedCell
                      : null,
                  colorScheme.tertiary,
                  theme),
              const SizedBox(width: 4),
              _buildCompactButton(
                  'R',
                  Icons.restore,
                  (selectedCell != null && stateManager != null)
                      ? revertSelectedCell
                      : null,
                  colorScheme.secondary,
                  theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton(String label, IconData icon,
      VoidCallback? onPressed, Color color, ThemeData theme) {
    return SizedBox(
      height: 24,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(
              color: onPressed != null ? color : color.withOpacity(0.3),
              width: 0.8),
          foregroundColor: onPressed != null ? color : color.withOpacity(0.3),
          textStyle: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10),
            if (label.length > 1) ...[
              const SizedBox(width: 2),
              Text(label),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildRefreshButton(theme, colorScheme),
        const SizedBox(width: 12),
        _buildSaveButton(theme, colorScheme),
      ],
    );
  }

  Widget _buildRefreshButton(ThemeData theme, ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: () async {
        studentGradesBodyToUpgrade.clear();

        // Revert any pending changes before refreshing
        if (!_disposed && stateManager != null) {
          revertChanges();
        }

        setState(() {
          isLoading = true;
        });
        try {
          if (isUserAdmin || isUserAcademicCoord) {
            //Get month number
            monthNumber = getKeyFromValue(spanishMonthsMap, selectedTempMonth!);
          } else {
            monthNumber =
                getKeyFromValue(spanishMonthsMap, selectedCurrentTempMonth!);
          }
          // get assignature id number
          var assignatureID = selectedTempSubjectId;

          if (selectedTempGroup != null) {
            if (assignatureID != null && assignatureID != 0) {
              await searchBUttonAction(
                  selectedTempGroup!,
                  selectedTempGrade.toString(),
                  assignatureID.toString(),
                  monthNumber.toString(),
                  selectedTempCampus!);
            } else {
              isLoading = false;
              showInformationDialog(context, 'Alerta!',
                  'No se detectó una asignatura, vuelva a intentar.');
            }
          } else {
            isLoading = false;
            showInformationDialog(context, 'Alerta!',
                'No se detectó un grado, vuelva a intentar.');
          }
        } catch (e) {
          insertErrorLog(e.toString(), 'SEARCH STUDENTS BY SUBJECTS ');
          var message = getMessageToDisplay(e.toString());
          if (context.mounted) {
            showErrorFromBackend(context, message.toString());
            setState(() {
              isLoading = false;
            });
          }
        }
      },
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('Actualizar'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        side: BorderSide(color: colorScheme.outline),
        textStyle: theme.textTheme.labelMedium,
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme, ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: () async {
        setState(() {
          isLoading = true;
        });

        // Commit all changes before saving
        if (!_disposed && stateManager != null) {
          commitChanges();
        }

        await updateButtonFunction((success) async {
          if (success) {
            try {
              studentGradesBodyToUpgrade.clear();
              /*
              await searchBUttonAction(
                  selectedTempGroup!,
                  selectedTempGrade.toString(),
                  selectedTempSubjectId.toString(),
                  monthNumber.toString(),
                  selectedTempCampus!);
                  */

              setState(() {
                isLoading = false;
                showInformationDialog(context, 'Éxito',
                    'Cambios realizados!, actualice la página.');
              });
            } catch (e) {
              setState(() {
                isLoading = false;
                showErrorFromBackend(context, e.toString());
              });
            }
          } else {
            isLoading = false;
            showErrorFromBackend(context, 'Error');
          }
        });
        setState(() {
          isLoading = false;
        });
      },
      icon: const Icon(Icons.save, size: 18),
      label: const Text('Confirmar y Guardar'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: theme.textTheme.labelMedium,
      ),
    );
  }

  Widget _buildGradesGrid(ThemeData theme, ColorScheme colorScheme) {
    if (rows.isEmpty) {
      return _buildEmptyGridState(theme, colorScheme);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen size for responsive calculations
        final screenSize = MediaQuery.of(context).size;
        final isTablet = screenSize.width > 600 && screenSize.width < 1200;
        final isMobile = screenSize.width <= 600;

        // Calculate responsive heights based on screen size and orientation
        double minHeight;
        double maxHeight;

        if (isMobile) {
          // Mobile: Use more conservative heights
          minHeight = screenSize.height * 0.3; // 30% of screen height
          maxHeight = constraints.maxHeight > 0
              ? constraints.maxHeight * 0.9
              : screenSize.height * 0.6;
        } else if (isTablet) {
          // Tablet: Balanced approach
          minHeight = 350.0;
          maxHeight = constraints.maxHeight > 0
              ? constraints.maxHeight * 0.85
              : screenSize.height * 0.7;
        } else {
          // Desktop: Can use more space
          minHeight = 400.0;
          maxHeight = constraints.maxHeight > 0
              ? constraints.maxHeight * 0.8
              : screenSize.height * 0.75;
        }

        // Ensure minimum height doesn't exceed available space
        final availableHeight =
            constraints.maxHeight > 0 ? constraints.maxHeight : 600.0;
        final safeMinHeight = 250.0;

        // Ensure we don't violate clamp constraints (min <= max)
        final effectiveMaxForClamp =
            availableHeight > safeMinHeight ? availableHeight : safeMinHeight;

        minHeight = minHeight.clamp(safeMinHeight, effectiveMaxForClamp);
        maxHeight = maxHeight.clamp(minHeight, double.infinity);

        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: minHeight,
            maxHeight: maxHeight,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TrinaGrid(
                key: trinaGridKey,
                mode: TrinaGridMode.normal,
                columns: assignaturesColumns,
                rows: assignatureRows,
                onChanged: (event) {
                  // Validator to avoid double type numbers for 'Calif' column
                  final idEval = event.row.cells['idCalif']?.value as int;

                  var newValue = validateNewGradeValue(
                      //Validate values cant be les that 50
                      event.value,
                      event.column.title);
                  composeUpdateStudentGradesBody(
                      event.column.title, newValue, idEval);

                  // Update dirty count for change tracking
                  updateDirtyCount();
                },
                onLoaded: (event) {
                  // Store state manager reference and enable change tracking
                  stateManager = event.stateManager;
                  stateManager?.setChangeTracking(true);

                  event.stateManager
                      .setSelectingMode(TrinaGridSelectingMode.cell);
                  TrinaGridStateManager localStateManager = event.stateManager;

                  // Apply column visibility based on selectedTempGrade
                  if (selectedTempGrade != null) {
                    // Safe column finder helper function
                    void safeSetColumnVisibility(String fieldName, bool hide) {
                      final columnIndex = localStateManager.columns
                          .indexWhere((col) => col.field == fieldName);
                      if (columnIndex >= 0) {
                        localStateManager.hideColumn(
                            localStateManager.columns[columnIndex], hide,
                            notify: true);
                      }
                    }

                    // Comments column
                    safeSetColumnVisibility('Comentarios', hideCommentsColumn);

                    // Absences column
                    safeSetColumnVisibility('Ausencia', hideAbsencesColumn);

                    // Homeworks column
                    safeSetColumnVisibility('Tareas', hideHomeworksColumn);

                    // Discipline column
                    safeSetColumnVisibility('Conducta', hideDisciplineColumn);

                    // Habits column
                    safeSetColumnVisibility('habit_eval', hideHabitsColumn);
                  }

                  // Apply any other grid configurations you need
                  localStateManager.setPageSize(30, notify: true);
                },
                onActiveCellChanged: (event) {
                  // Track selected cell for change tracking operations
                  setState(() {
                    selectedCell = event.cell;
                  });
                },
                configuration: TrinaGridConfiguration(
                  style: TrinaGridStyleConfig(
                    borderColor: colorScheme.outlineVariant,
                    gridBorderColor: colorScheme.outlineVariant,
                    activatedBorderColor: colorScheme.primary,
                    activatedColor:
                        colorScheme.primaryContainer.withOpacity(0.1),
                    cellColorInEditState: colorScheme.surfaceContainerHighest,
                    cellColorInReadOnlyState: colorScheme.surfaceContainerHigh,
                    // Add dirty cell highlighting
                    cellDirtyColor: Colors.amber[100]!,
                    // Make rows shorter
                    rowHeight: 35,
                  ),
                  columnSize: TrinaGridColumnSizeConfig(
                      autoSizeMode: TrinaAutoSizeMode.scale),
                  scrollbar: TrinaGridScrollbarConfig(
                    isAlwaysShown: true,
                  ),
                ),
                createFooter: (stateManager) {
                  stateManager.setPageSize(30, notify: false);
                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TrinaPagination(stateManager),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyGridState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin datos disponibles',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Configure los filtros y presione "Actualizar" para cargar las calificaciones',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Updates the grid with new data.
  ///
  /// [studentList] is the list of students to display in the grid.
  /// [assignatureRows] is the list of rows to display in the grid.
  void updateGrid(
      List<StudentEval> studentList, List<TrinaRow> assignatureRows) {
    setState(() {
      rows = studentList.map((item) {
        return TrinaRow(
          cells: {
            'Matricula': TrinaCell(value: item.studentID),
            'Nombre': TrinaCell(value: item.studentName),
            'Apellido paterno': TrinaCell(value: item.student1LastName),
            'Apellido materno': TrinaCell(value: item.student2LastName),
          },
        );
      }).toList();
      assignatureRows = assignatureRows;
    });
  }

  void validator() {
    if (studentList.isNotEmpty) {
      studentList.clear();
    }
    if (selectedTempGroup == null || selectedTempGroup == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un grupo a evaluar');
    }
    if (selectedTempGrade == null || selectedTempGrade == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un grado a evaluar');
    }
    if (selectedTempSubject == null || selectedTempSubject == '') {
      return showEmptyFieldAlertDialog(context, 'Seleccionar una materia');
    }
    if (selectedTempCampus == null || selectedTempCampus == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un campus a evaluar');
    }
    if (monthValue.isEmpty) {
      monthValue = academicMonthsList.first;
    }
    selectedUnity ??= campusesWhereTeacherTeach.first;

    if (isUserAdmin || isUserAcademicCoord) {
      monthNumber = getKeyFromValue(spanishMonthsMap, monthValue);
    } else {
      monthNumber = getKeyFromValue(spanishMonthsMap, currentMonth);
    }
    // gradeInt = getKeyFromValue(teacherGradesMap, gradeSelected);

    // assignatureID = getKeyFromValue(assignaturesMap, subjectValue);
  }

  /// Updates the grades in the backend and shows a confirmation dialog.
  ///
  /// [callback] is a function that is called with a boolean indicating whether the update was successful.
  Future<void> updateButtonFunction(
      void Function(bool success) callback) async {
    if (studentGradesBodyToUpgrade.isEmpty) {
      callback(false);
    } else {
      try {
        await patchStudentGradesToDB().then((response) {
          if (response == 200) {
            callback(true);
          } else {
            callback(false);
          }
        }).onError((error, stackTrace) {
          callback(false);
        });
      } catch (e) {
        callback(false);
      }
    }
  }

  Future<dynamic> showCommentsDialog(
      // BuildContext context,
      List<Map<String, dynamic>> comments,
      String subjectName,
      selectedStudentName) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StudentEvalCommentDialog(
            studentName: selectedStudentName,
            comments: comments,
            subjectName: subjectName,
          );
        });
  }

  void displayColumnsByGrade(int grade) {
    // setState(() {
    if ((grade < 12) && (grade > 6)) {
      hideCommentsColumn = false; // Comentarios
      hideAbsencesColumn = true; // Faltas
      hideHomeworksColumn = false; // Tareas
      hideDisciplineColumn = false; //Disciplina
      hideHabitsColumn = true;
      hideOutfitColumn = true;
      homeWorkColumnTitle = 'Hab';
      disciplineColumnTitle = 'Con';
    } else if ((grade < 6 && grade > 0)) {
      hideCommentsColumn = true;
      hideAbsencesColumn = true; // Faltas
      hideHomeworksColumn = true; // Tareas
      hideDisciplineColumn = true; //Disciplina
      hideHabitsColumn = true; //Habits
      hideOutfitColumn = true;
    } else if (grade > 11) {
      hideCommentsColumn = true;
      hideAbsencesColumn = false; // Faltas
      hideHomeworksColumn = false; // Tareas
      hideDisciplineColumn = true; //Disciplina
      hideHabitsColumn = true;
      hideOutfitColumn = true;
      homeWorkColumnTitle = 'R';
    }
    trinaGridKey = UniqueKey();
    // });
  }
}
