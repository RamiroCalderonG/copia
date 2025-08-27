import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/data/Models/Student_eval.dart';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/constants/date_constants.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/data/datasources/temp/teacher_grades_temp.dart';

import 'package:trina_grid/trina_grid.dart';

import '../../../../core/utils/loader_indicator.dart';
import '../../../../data/datasources/temp/studens_temp.dart';
import '../../../../data/services/backend/api_requests/api_calls_list_dio.dart';
import '../../../../core/constants/Student.dart';
import '../../../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../../../core/reusable_methods/reusable_functions.dart';
import '../../../components/confirm_dialogs.dart';
import '../../../components/teacher_eval_dropdownmenu.dart';

class GradesByStudent extends StatefulWidget {
  const GradesByStudent({super.key});

  @override
  State<GradesByStudent> createState() => _GradesByStudentState();
}

String? subjectSelected = oneTeacherAssignatures.first;

List<TrinaRow> rows = [];

class _GradesByStudentState extends State<GradesByStudent> {
  bool isUserAdmin = false;
  bool isUserAcademicCoord = false;
  var commentsController = TextEditingController();
  late TrinaGridStateManager stateManager;
  late TrinaGridStateManager gridAStateManager;
  String currentMonth = DateFormat.MMMM('es').format(DateTime.now());

  // Change tracking variables
  TrinaGridStateManager? gradesStateManager;
  TrinaCell? selectedCell;
  int dirtyCount = 0;
  bool _disposed = false;
  Key? studentsGridKey;
  Key? evalsGridKey;

  Key? currentRowKey;
  Timer? _debounce;
  String? asignatureNameListener;
  String selectedStudentName = '';
  var fetchedData;
  bool isFetching = true;
  bool hideCommentsColumn = true;
  bool hideAbsencesColumn = true;
  bool hideHomeworksColumn = true;
  bool hideDisciplineColumn = true;
  bool hideHabitsColumn = true;
  bool hideOutfitColumn = true;

  String? homeWorkColumnTitle;
  String? disciplineColumnTitle;
  int? monthNumber;
  String dropDownValue = ''; //oneTeacherAssignatures.first;
  int? assignatureID;
  DateFormat? dateFormat;

  String? selectedStudentID;

  @override
  void initState() {
    isUserAdmin = currentUser!.isCurrentUserAdmin();
    isUserAcademicCoord = currentUser!.isCurrentUserAcademicCoord();
    _fetchData();
    initializeDateFormatting();
    super.initState();
  }

  @override
  void dispose() {
    _disposed = true;
    //studentsGradesCommentsRows.clear();
    //evaluationComments.clear();
    //commentStringEval.clear();
    _debounce?.cancel();
    commentsController.dispose();
    //selectedTempGrade = null;
    //selectedTempGroup = null;
    //selectedTempStudent = null;
    //selectedTempCampus = null;
    //selectedTempMonth = null;
    //selectedCurrentTempMonth = null;
    fetchedData = null;
    rows.clear();
    super.dispose();
  }

  // Change tracking methods
  void commitChanges() {
    if (_disposed || gradesStateManager == null || !mounted) return;
    try {
      gradesStateManager!.commitChanges();
      updateDirtyCount();
    } catch (e) {
      // Handle any errors gracefully
      insertErrorLog(e.toString(), 'COMMIT_CHANGES_ERROR');
    }
  }

  void revertChanges() {
    if (_disposed || gradesStateManager == null || !mounted) return;
    try {
      gradesStateManager!.revertChanges();
      updateDirtyCount();
    } catch (e) {
      // Handle any errors gracefully
      insertErrorLog(e.toString(), 'REVERT_CHANGES_ERROR');
    }
  }

  void commitSelectedCell() {
    if (_disposed || gradesStateManager == null || !mounted) return;
    if (selectedCell != null) {
      try {
        gradesStateManager!.commitChanges(cell: selectedCell);
        updateDirtyCount();
      } catch (e) {
        // Handle any errors gracefully
        insertErrorLog(e.toString(), 'COMMIT_SELECTED_CELL_ERROR');
      }
    }
  }

  void revertSelectedCell() {
    if (_disposed || gradesStateManager == null || !mounted) return;
    if (selectedCell != null) {
      try {
        gradesStateManager!.revertChanges(cell: selectedCell);
        updateDirtyCount();
      } catch (e) {
        // Handle any errors gracefully
        insertErrorLog(e.toString(), 'REVERT_SELECTED_CELL_ERROR');
      }
    }
  }

  void updateDirtyCount() {
    if (_disposed || gradesStateManager == null) return;

    // Use Future.microtask to ensure we're not updating during build or dispose
    Future.microtask(() {
      if (_disposed || gradesStateManager == null) return;

      int count = 0;
      try {
        // Use the state manager's rows instead of selectedStudentRows
        // This ensures we're working with properly initialized cells
        for (var row in gradesStateManager!.rows) {
          for (var cell in row.cells.values) {
            if (cell.isDirty) {
              count++;
            }
          }
        }
      } catch (e) {
        // If there's an error accessing isDirty (cells not initialized),
        // just set count to 0
        count = 0;
      }

      if (!_disposed && mounted) {
        setState(() {
          dirtyCount = count;
        });
      }
    });
  }

  void _fetchData() async {
    var response = isUserAdmin || isUserAcademicCoord
        ? loadStartGradingAsAdminOrAcademicCoord(currentCycle!.claCiclo!, null,
            true, null, null, isUserAcademicCoord, isUserAdmin)
        : loadStartGrading(
            currentUser!.employeeNumber!,
            currentCycle!.toString(),
            isUserAdmin,
            isUserAcademicCoord,
            currentUser!.claUn);
    fetchedData = response;
    setState(() {
      isFetching = false;
    });
  }

  //* Populates Grid that only contains the students names and IDs
  Future<void> fillGrid(List<StudentEval> evaluationList) async {
    Set<String> studentSet = {};
    List<Map<String, String>> uniqueStudents = [];

    for (var student in evaluationList) {
      if (!studentSet.contains(student.studentID)) {
        studentSet.add(student.studentID);
        uniqueStudents.add({
          'studentID': student.studentID,
          'student': student.fulllName!,
          'sequentialNumber': student.sequentialNumber.toString(),
        });
      }
    }
    setState(() {
      rows = uniqueStudents.map((item) {
        return TrinaRow(
          cells: {
            'studentID': TrinaCell(value: item.containsKey('StudentID')),
            'studentName': TrinaCell(value: item.containsKey('studentName')),
            'No': TrinaCell(
                value: item.containsKey('sequentialNumber')
                    ? item['sequentialNumber']
                    : '0'),
          },
        );
      }).toList();
    });
  }

  Future<void> populateCommentsGrid(List<Map<String, String>> comments) async {
    if (studentsGradesCommentsRows.isNotEmpty) {
      setState(() {
        evaluationComments = comments.map((item) {
          return TrinaRow(cells: {
            'idcomment': TrinaCell(value: item['idcomment']),
            'comentname': TrinaCell(value: item['comentname']),
          });
        }).toList();
      });
    }
  }

  Future<void> searchBUttonAction(String groupSelected, int grade,
      int monthSelected, String campusSelected) async {
    try {
      setState(() {
        studentList.clear();
        studentEvaluationRows.clear();
        selectedStudentName = '';
        selectedStudentID = null;
        selectedStudentRows.clear();
      });
      //var gradeInt = getKeyFromValue(teacherGradesMap, gradeString);
      if (studentList.isNotEmpty && studentsGradesCommentsRows.isNotEmpty) {
        studentList.clear();
        studentsGradesCommentsRows.clear();
      }
      // August wont fetch data
      if (monthSelected != 8) {
        // Get the students list by group, grade, cycle, campus and month
        studentList = await getSubjectsAndGradesByStudent(
            grade,
            groupSelected,
            currentCycle!.claCiclo!,
            campusSelected,
            monthSelected,
            currentUser!.isAdmin!,
            currentUser!.isAcademicCoord!,
            currentUser!.isAdmin! || currentUser!.isAcademicCoord!
                ? null
                : currentUser!.employeeNumber!);

        // Get evaluations comments by gradeSequence
        if (studentList.isNotEmpty) {
          studentsGradesCommentsRows =
              await getEvaluationsCommentsByGradeSequence(grade);
        } else {
          throw Exception(
              'No se encontraron alumnos para el grupo seleccionado: $groupSelected, grado: $grade, ciclo: ${currentCycle!.claCiclo}, campus: $campusSelected, mes: $monthSelected');
        }

        displayColumnsByGrade(grade);

        fillGrid(studentList); //Fill student list by unque values

        setState(() {
          studentEvaluationRows.clear();
          // var index = 0;
          for (var item in uniqueStudentsList) {
            String sequentialNumber = studentList
                .firstWhere((student) => student.studentID == item['studentID'])
                .sequentialNumber
                .toString();
            studentEvaluationRows.add(TrinaRow(cells: {
              'No': TrinaCell(
                  value: sequentialNumber.isNotEmpty
                      ? sequentialNumber
                      : '0'), //* Sequential number of student (NoLista)
              'studentID': TrinaCell(value: item['studentID']!.trim()),
              'studentName':
                  TrinaCell(value: item['studentName']!.trim().toTitleCase),
            }));
          }
        });
      } else {
        return showErrorFromBackend(context, 'Seleccione un mes');
      }
    } catch (e) {
      insertErrorLog(e.toString(), 'SEARCH GRADES BY STUDENT ');
      var message = getMessageToDisplay(e.toString());
      if (context.mounted) {
        showErrorFromBackend(context, message.toString());
      }
    }
  }

  Future<dynamic> patchStudentGradesToDB() async {
    await patchStudentsGrades(studentGradesBodyToUpgrade, true).then((value) {
      if (value != null) {
        if (value == 200) {
          return 200;
        } else {
          return value;
        }
      }
    }).catchError((onError, stackTrace) {
      insertErrorLog(onError.toString(),
          'PATCH STUDENT GRADES TO DB | $studentGradesBodyToUpgrade');
      throw Future.error(onError.toString);
    });
  }

  String validateTwoDigitNumber(dynamic value) {
    final stringValue = value.toString();
    if (RegExp(r'^\d{1,2}$').hasMatch(stringValue)) {
      return stringValue;
    }
    // If more than 2 digits, return only the first 2 digits
    return stringValue.substring(0, 2);
  }

  List<TrinaColumn> get gradesByStudentColumns => [
        TrinaColumn(
            title: 'Materia',
            field: 'subject',
            type: TrinaColumnType.text(),
            readOnly: true,
            hide: true),
        TrinaColumn(
          title: 'Materia',
          field: 'subject_name',
          type: TrinaColumnType.text(),
          // width: 80,
          //frozen: TrinaColumnFrozen.start,
          sort: TrinaColumnSort.ascending,
          readOnly: true,
        ),
        TrinaColumn(
          title: 'Calif',
          field: 'evaluation',
          type: TrinaColumnType.number(
            negative: false,
          ),
        ),
        TrinaColumn(
            title: 'idCalif',
            field: 'idCicloEscolar',
            type: TrinaColumnType.number(negative: false),
            hide: true,
            readOnly: true),
        TrinaColumn(
            title: 'Faltas',
            hide: hideAbsencesColumn,
            field: 'absence_eval',
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            title: homeWorkColumnTitle ?? 'Tareas',
            hide: hideHomeworksColumn,
            field: 'homework_eval',
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            title: disciplineColumnTitle ?? 'Disciplina',
            hide: hideDisciplineColumn,
            field: 'discipline_eval',
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            title: 'Comentarios',
            field: 'comment',
            hide: true,
            type: TrinaColumnType.select(commentStringEval,
                enableColumnFilter: true)),
        TrinaColumn(
            title: 'Habitos',
            hide: hideHabitsColumn,
            field: 'habit_eval',
            type: TrinaColumnType.number(negative: false)),
        // TrinaColumn(
        //     title: 'Uniforme',
        //     hide: hideOutfitColumn,
        //     field: 'outfit',
        //     type: TrinaColumnType.number(negative: false)),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primaryContainer.withOpacity(0.05),
            colorScheme.surface,
          ],
        ),
      ),
      child: isFetching
          ? _buildLoadingState(theme)
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (fetchedData is Error || fetchedData is FormatException) {
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
              Icons.person_search_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando calificaciones por alumno',
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
                'Error en la conexión: $fetchedData',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    isFetching = true;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen size for responsive calculations
        final screenSize = MediaQuery.of(context).size;
        final isTablet = screenSize.width > 600 && screenSize.width < 1200;
        final isMobile = screenSize.width <= 600;

        // Calculate responsive padding based on screen size
        double horizontalPadding;
        double verticalPadding;

        if (isMobile) {
          horizontalPadding = 8.0;
          verticalPadding = 8.0;
        } else if (isTablet) {
          horizontalPadding = 12.0;
          verticalPadding = 12.0;
        } else {
          horizontalPadding = 16.0;
          verticalPadding = 16.0;
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: _buildGradesPerStudent(theme, colorScheme),
        );
      },
    );
  }

  Widget _buildGradesPerStudent(ThemeData theme, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen size for responsive calculations
        final screenSize = MediaQuery.of(context).size;
        final isTablet = screenSize.width > 600 && screenSize.width < 1200;
        final isMobile = screenSize.width <= 600;

        // Calculate responsive card padding and border radius
        double cardPadding;
        double borderRadius;

        if (isMobile) {
          cardPadding = 12.0;
          borderRadius = 16.0;
        } else if (isTablet) {
          cardPadding = 14.0;
          borderRadius = 18.0;
        } else {
          cardPadding = 16.0;
          borderRadius = 20.0;
        }

        return Card(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFiltersSection(theme, colorScheme),
                SizedBox(height: isMobile ? 4 : 6),
                _buildCompactChangeTracking(theme, colorScheme),
                SizedBox(height: isMobile ? 4 : 6),
                _buildActionButtons(theme, colorScheme),
                SizedBox(height: isMobile ? 4 : 6),
                _buildStudentNameSection(theme, colorScheme),
                SizedBox(height: isMobile ? 4 : 6),
                Expanded(
                  child: _buildGradesGrids(theme, colorScheme),
                ),
              ],
            ),
          ),
        );
      },
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
          const SizedBox(height: 8),
          TeacherEvalDropDownMenu(
            jsonData: jsonDataForDropDownMenuClass,
            campusesList: campusesWhereTeacherTeach,
            byStudent: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen size for responsive calculations
        final screenSize = MediaQuery.of(context).size;
        final isMobile = screenSize.width <= 600;

        // On mobile, stack buttons vertically or reduce spacing
        if (isMobile && constraints.maxWidth < 400) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRefreshButton(theme, colorScheme),
              const SizedBox(height: 8),
              _buildSaveButton(theme, colorScheme),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildRefreshButton(theme, colorScheme),
            SizedBox(width: isMobile ? 8 : 12),
            _buildSaveButton(theme, colorScheme),
          ],
        );
      },
    );
  }

  Widget _buildRefreshButton(ThemeData theme, ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: _handleRefreshAction,
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('Actualizar'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        side: BorderSide(color: colorScheme.outline),
        textStyle: theme.textTheme.labelMedium,
      ),
    );
  }

  /// Handles the refresh button action with optimized validation and error handling
  Future<void> _handleRefreshAction() async {
    try {
      _setLoadingState(true);
      studentGradesBodyToUpgrade.clear();

      // Calculate month number based on user role
      final calculatedMonthNumber = _calculateMonthNumber();

      // Validate all required fields
      final validationError = _validateRequiredFields(calculatedMonthNumber);
      if (validationError != null) {
        _setLoadingState(false);
        return showEmptyFieldAlertDialog(context, validationError);
      }

      // Perform the search action
      await searchBUttonAction(
        selectedTempGroup!,
        selectedTempGrade!,
        calculatedMonthNumber!,
        selectedTempCampus!,
      );
    } catch (e) {
      insertErrorLog(e.toString(), 'REFRESH BUTTON');
      if (context.mounted) {
        showErrorFromBackend(context, e.toString());
      }
    } finally {
      _setLoadingState(false);
    }
  }

  /// Calculates the month number based on user role and current selection
  int? _calculateMonthNumber() {
    if (isUserAdmin || isUserAcademicCoord) {
      return selectedTempMonth != null
          ? getKeyFromValue(spanishMonthsMap, selectedTempMonth!)
          : null;
    } else {
      selectedCurrentTempMonth = currentMonth.toCapitalized;
      return getKeyFromValue(spanishMonthsMap, selectedCurrentTempMonth!);
    }
  }

  /// Validates all required fields and returns error message if any field is invalid
  String? _validateRequiredFields(int? monthNumber) {
    if (selectedTempGroup == null || selectedTempGroup!.isEmpty) {
      return 'Seleccionar un grupo a evaluar';
    }
    if (selectedTempGrade == null) {
      return 'Seleccionar un grado a evaluar';
    }
    if (selectedTempCampus == null || selectedTempCampus!.isEmpty) {
      return 'Seleccionar un campus a evaluar';
    }
    if (monthNumber == null) {
      return 'Seleccionar un mes a evaluar';
    }
    /* if (selectedCampus == null || selectedCampus!.isEmpty) {
      return 'Seleccionar un campus a evaluar';
    } */
    return null; // All validations passed
  }

  /// Centralized loading state management
  void _setLoadingState(bool loading) {
    if (mounted) {
      setState(() {
        isFetching = loading;
      });
    }
  }

  Widget _buildSaveButton(ThemeData theme, ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: _handleSaveAction,
      icon: const Icon(Icons.save, size: 18),
      label: const Text('Guardar'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: theme.textTheme.labelMedium,
      ),
    );
  }

  /// Handles the save button action with optimized validation and error handling
  Future<void> _handleSaveAction() async {
    if (studentGradesBodyToUpgrade.isEmpty) {
      showEmptyFieldAlertDialog(
          context, 'No se detectó ningun cambio a realizar');
      return;
    }

    try {
      _setLoadingState(true);

      final calculatedMonthNumber = _calculateMonthNumber();

      await saveButtonAction(calculatedMonthNumber);

      // Clear the changes and refresh the data
      studentGradesBodyToUpgrade.clear();
      await searchBUttonAction(
        selectedTempGroup!,
        selectedTempGrade!,
        calculatedMonthNumber!,
        selectedTempCampus!,
      );

      if (context.mounted) {
        showInformationDialog(context, 'Éxito', 'Cambios realizados!');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorFromBackend(context, e.toString());
      }
    } finally {
      _setLoadingState(false);
    }
  }

  Widget _buildStudentNameSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: selectedStudentName.isNotEmpty
                ? Text(
                    'Evaluando a: ${selectedStudentName.trim()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  )
                : Text(
                    'Seleccione un alumno para evaluar',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesGrids(ThemeData theme, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (studentEvaluationRows.isEmpty) {
          return _buildEmptyGridState(theme, colorScheme);
        } else {
          return _buildGridsContent(theme, colorScheme, constraints);
        }
      },
    );
  }

  Widget _buildEmptyGridState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay estudiantes disponibles',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Favor de actualizar la información con los filtros seleccionados',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridsContent(
      ThemeData theme, ColorScheme colorScheme, BoxConstraints constraints) {
    // Get screen size for responsive calculations
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600 && screenSize.width < 1200;
    final isMobile = screenSize.width <= 600;

    // Calculate responsive heights based on screen size
    double availableHeight;
    if (isMobile) {
      availableHeight = constraints.maxHeight * 0.9; // Use 90% on mobile
    } else if (isTablet) {
      availableHeight = constraints.maxHeight * 0.95; // Use 95% on tablet
    } else {
      availableHeight = constraints.maxHeight; // Use full height on desktop
    }

    // Ensure minimum height
    availableHeight = availableHeight.clamp(300.0, double.infinity);

    return StatefulBuilder(
      builder: (context, setState) {
        // On mobile, use vertical layout with tabs or collapsible sections
        if (isMobile) {
          return _buildMobileLayout(theme, colorScheme, availableHeight);
        }

        // On tablet and desktop, use side-by-side layout
        return _buildDesktopTabletLayout(
            theme, colorScheme, availableHeight, isTablet);
      },
    );
  }

  Widget _buildMobileLayout(
      ThemeData theme, ColorScheme colorScheme, double availableHeight) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: colorScheme.onPrimaryContainer,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(text: 'Estudiantes'),
                Tab(text: 'Calificaciones'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tab Views
          Expanded(
            child: TabBarView(
              children: [
                _buildStudentsGrid(theme, colorScheme, availableHeight),
                _buildGradesGrid(theme, colorScheme, availableHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTabletLayout(ThemeData theme, ColorScheme colorScheme,
      double availableHeight, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Students Grid (Left Panel)
        Expanded(
          flex: isTablet ? 1 : 1, // Equal flex on tablet, 1:2 ratio on desktop
          child: _buildStudentsGrid(theme, colorScheme, availableHeight),
        ),
        SizedBox(width: isTablet ? 12 : 16),
        // Grades Grid (Right Panel)
        Expanded(
          flex: isTablet ? 1 : 2, // Equal flex on tablet, 1:2 ratio on desktop
          child: _buildGradesGrid(theme, colorScheme, availableHeight),
        ),
      ],
    );
  }

  Widget _buildStudentsGrid(
      ThemeData theme, ColorScheme colorScheme, double availableHeight) {
    return Container(
      height: availableHeight,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.groups_outlined,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lista de Estudiantes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TrinaGrid(
              key: studentsGridKey,
              columns: studentColumnsToEvaluateByStudent,
              rows: studentEvaluationRows,
              mode: TrinaGridMode.select,
              onRowDoubleTap: (event) async {
                var gradeInt = getKeyFromValue(
                    teacherGradesMap, selectedTempGrade!.toString());
                int? monthNumber;

                if (isUserAdmin || isUserAcademicCoord) {
                  monthNumber =
                      getKeyFromValue(spanishMonthsMap, selectedTempMonth!);
                } else {
                  monthNumber = getKeyFromValue(
                      spanishMonthsMap, selectedCurrentTempMonth!);
                }
                selectedStudentID = event.row.cells['studentID']!.value;
                selectedStudentName =
                    event.row.cells['studentName']!.value.toString();

                await loadSelectedStudent(
                    selectedStudentID!, gradeInt, monthNumber!);
              },
              onLoaded: (event) {
                event.stateManager
                    .setSelectingMode(TrinaGridSelectingMode.cell);
                TrinaGridStateManager stateManager = event.stateManager;

                selectRowByName(
                    stateManager, 'studentName', selectedStudentName);
              },
              configuration: const TrinaGridConfiguration(
                style: TrinaGridStyleConfig(
                  enableColumnBorderVertical: false,
                  enableCellBorderVertical: false,
                ),
              ),
              createFooter: (stateManager) {
                stateManager.setPageSize(20, notify: false);
                return TrinaPagination(stateManager);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesGrid(
      ThemeData theme, ColorScheme colorScheme, double availableHeight) {
    return Container(
      height: availableHeight,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.grade_outlined,
                  color: colorScheme.secondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Calificaciones del Estudiante',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedStudentRows.isNotEmpty
                ? TrinaGrid(
                    key: evalsGridKey,
                    columns: gradesByStudentColumns,
                    rows: selectedStudentRows,
                    onChanged: (event) {
                      // Validator to avoid double type numbers for 'Calif' column
                      if (event.column.field == 'evaluation') {
                        // Only allow integers (no decimals)
                        if (event.value is double ||
                            (event.value is String &&
                                event.value.contains('.'))) {
                          showErrorFromBackend(context,
                              'Solo se permiten números enteros en la calificación.');
                          return;
                        }
                      }
                      var newValue = validateNewGradeValue(
                          event.value, event.column.title);

                      final evalId = event.row.cells['idCicloEscolar']?.value;
                      int? monthNumber;
                      if (isUserAdmin || isUserAcademicCoord) {
                        monthNumber = getKeyFromValue(
                            spanishMonthsMap, selectedTempMonth!.toCapitalized);
                      } else {
                        monthNumber = getKeyFromValue(
                            spanishMonthsMap, currentMonth.toCapitalized);
                      }

                      validator();
                      composeBodyToUpdateGradeBySTudent(
                        event.column.title,
                        selectedStudentID!,
                        newValue,
                        evalId,
                        monthNumber,
                      );

                      // Update dirty count for change tracking
                      updateDirtyCount();
                    },
                    onLoaded: (TrinaGridOnLoadedEvent event) {
                      gridAStateManager = event.stateManager;

                      // Store state manager reference and enable change tracking
                      gradesStateManager = event.stateManager;
                      gradesStateManager?.setChangeTracking(true);

                      // Ensure cells are properly initialized before enabling change tracking
                      Future.microtask(() {
                        if (gradesStateManager != null && !_disposed) {
                          updateDirtyCount();
                        }
                      });
                    },
                    onActiveCellChanged: (event) {
                      // Track selected cell for change tracking operations
                      if (!_disposed && mounted) {
                        setState(() {
                          selectedCell = event.cell;
                        });
                      }
                    },
                    configuration: TrinaGridConfiguration(
                      style: TrinaGridStyleConfig(
                        enableColumnBorderVertical: false,
                        enableCellBorderVertical: false,
                        // Add dirty cell highlighting
                        cellDirtyColor: Colors.amber[100]!,
                        // Make rows shorter
                        rowHeight: 35,
                      ),
                      columnSize: TrinaGridColumnSizeConfig(
                        autoSizeMode: TrinaAutoSizeMode.scale,
                        resizeMode: TrinaResizeMode.pushAndPull,
                      ),
                    ),
                  )
                : Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 40,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Seleccione un estudiante',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Haga doble clic en un estudiante para ver y editar sus calificaciones',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  dynamic validator() {
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
    if (selectedTempCampus == null || selectedTempCampus == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un campus a evaluar');
    }
    // if (dropDownValue.isEmpty || dropDownValue == '') {
    //   dropDownValue = oneTeacherAssignatures.first;
    // }
    if (selectedTempMonth == null) {
      if (context.mounted) {
        showEmptyFieldAlertDialog(context, 'Seleccionar mes a evaluar');
      }
    }
  }

  void handleCommentsRefresh(int gradeSequence) async {
    try {} catch (e) {}
  }

  void selectRowByName(TrinaGridStateManager stateManager, String columnField,
      String storedName) {
    for (var i = 0; i < stateManager.rows.length; i++) {
      final cellValue = stateManager.rows[i].cells[columnField]?.value;

      // If the cell value matches the stored name
      if (cellValue == storedName) {
        // Get the first cell in the row to set focus
        final firstCell = stateManager.rows[i].cells.entries.first.value;

        // Set the current cell to the first cell of the matching row and move the grid's focus there
        stateManager.setCurrentCell(firstCell, i);

        // Ensure the row with the selected cell is visible (optional)
        stateManager.moveScrollByRow(TrinaMoveDirection.up, i);

        break;
      }
    }
  }

  List<Map<String, dynamic>> filterCommentsBySubject(
    List<Map<String, dynamic>> comments,
    String subjectName,
  ) {
    return comments
        .where((comment) => comment['subject'] == subjectName)
        .toList();
  }

  Future<void> showCommentsDialog(BuildContext context,
      List<Map<String, dynamic>> comments, String subjectName) async {
    final filteredComments = filterCommentsBySubject(comments, subjectName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Get screen size for responsive calculations
            final screenSize = MediaQuery.of(context).size;
            final isMobile = screenSize.width <= 600;

            // Calculate responsive dialog width
            double dialogWidth;
            if (isMobile) {
              dialogWidth = screenSize.width * 0.9; // 90% on mobile
            } else {
              dialogWidth = screenSize.width / 3; // 1/3 on larger screens
            }

            return AlertDialog(
              title: Text(
                  'Asigna comentarios:\nAlumno: $selectedStudentName\nMateria: $subjectName'),
              titleTextStyle: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: isMobile ? 16 : 20,
                  color: FlutterFlowTheme.of(context).primaryText),
              content: SingleChildScrollView(
                  child: SizedBox(
                width: dialogWidth,
                child: Column(
                  children: filteredComments.map((comment) {
                    return StatefulBuilder(builder: (context, setState) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(comment['commentName']),
                            trailing: Checkbox(
                                value: comment['active'],
                                onChanged: (newValue) async {
                                  // Note: Commented out unused variables to fix lint errors
                                  // var studentRateId = comment['student_rate'];
                                  // var commentId = comment['comment'];
                                  // var activevalue = newValue;

                                  //await putStudentEvaluationsComments(
                                  //    studentRateId, commentId, activevalue!);
                                  setState(() => comment['active'] = newValue!);
                                }),
                          )
                        ],
                      );
                    });
                  }).toList(),
                ),
              )),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> saveButtonAction(int? monthNumber) async {
    await patchStudentGradesToDB().then((response) {
      return;
/* if (response == 200) {
      if (context.mounted) {
       showInformationDialog(context, 'Èxito', 'Cambios realizados!');

        searchBUttonAction(
          selectedTempGroup!,
          selectedTempGrade!,
          monthNumber!,
          selectedTempCampus!,
        );
      } else {
        if (context.mounted) {
          setState(() {
            isFetching = false;
            studentGradesBodyToUpgrade.clear();
          });
          showErrorFromBackend(context, response.toString());
        }
      }
    } */
    }).onError((error, stackTrace) {
      throw Future.error(error.toString());
    });
  }

  Future<void> loadSelectedStudent(
      String studentID, int? gradeInt, int month) async {
    selectedStudentList.clear();

    selectedStudentList =
        studentList.where((student) => student.studentID == studentID).toList();

    setState(() {
      selectedStudentRows.clear();
      for (var student in selectedStudentList) {
        selectedStudentRows.add(TrinaRow(cells: {
          'subject': TrinaCell(value: student.subject),
          'subject_name':
              TrinaCell(value: student.subjectName!.trim().toTitleCase),
          'evaluation': TrinaCell(value: student.evaluation),
          // 'eval_type': TrinaCell(value: student.),
          'absence_eval': TrinaCell(value: student.absence),
          'homework_eval': TrinaCell(value: student.homework),
          'discipline_eval': TrinaCell(value: student.discipline),
          'comment': TrinaCell(value: student.comment),
          'habit_eval': TrinaCell(value: student.habits_evaluation),
          'other': TrinaCell(value: student.other),
          'outfit': TrinaCell(value: student.outfit),
          'idCicloEscolar': TrinaCell(value: student.rateID),
        }));
      }
    });

    // if (gradeInt! >= 6) {
    //   commentsAsignatedList =
    //       await populateAsignatedComments(gradeInt!, month, true, studentID);
    // }
  }

  void displayColumnsByGrade(int grade) {
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
                  gradesStateManager != null ? commitChanges : null,
                  colorScheme.primary,
                  theme),
              const SizedBox(width: 4),
              _buildCompactButton(
                  'Revertir',
                  Icons.undo,
                  gradesStateManager != null ? revertChanges : null,
                  colorScheme.error,
                  theme),
              const SizedBox(width: 4),
              _buildCompactButton(
                  'C',
                  Icons.done,
                  (selectedCell != null && gradesStateManager != null)
                      ? commitSelectedCell
                      : null,
                  colorScheme.tertiary,
                  theme),
              const SizedBox(width: 4),
              _buildCompactButton(
                  'R',
                  Icons.restore,
                  (selectedCell != null && gradesStateManager != null)
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
}
