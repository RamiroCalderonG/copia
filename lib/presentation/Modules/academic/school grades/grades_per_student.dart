import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/core/utils/temp_data.dart';
import 'package:oxschool/data/Models/AcademicEvaluationsComment.dart';
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

  bool _disposed = false;
  Key? studentsGridKey;
  Key? evalsGridKey;

  Key? currentRowKey;
  Timer? _debounce;
  Timer? _validationDebounce;
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

  String? habitsWorkColumnTitle;
  String? homeworkColumnTitle;
  String? disciplineColumnTitle;
  String? absencesColumnTitle;
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

  /// Checks for unevaluated students - simplified for per-student view
  void _checkForUnevaluatedStudents() {
    // For grades_per_student, we don't show notifications
    // The zero values will be highlighted in red in the grid
    if (!mounted) return;

    // Force rebuild to update cell colors
    setState(() {
      // This triggers a rebuild which will apply the cell styling
    });
  }

  @override
  void dispose() {
    _disposed = true;
    //studentsGradesCommentsRows.clear();
    //evaluationComments.clear();
    //commentStringEval.clear();
    _debounce?.cancel();
    _validationDebounce?.cancel();
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

  /// Clears student data before switching to prevent TrinaGrid initialization errors
  void _clearStudentDataBeforeSwitching() {
    if (_disposed || !mounted) return;

    // Clear any pending validation debounce
    _validationDebounce?.cancel();

    // Clear any unsaved changes from the current student
    studentGradesBodyToUpgrade.clear();

    // Force a rebuild of the grades grid by clearing the selected student rows
    setState(() {
      selectedStudentRows.clear();
    });

    // Allow the UI to update before loading new student data
    Future.microtask(() {
      if (!_disposed && mounted) {
        // Additional cleanup if needed
      }
    });
  }

  /// Populates the commentStringEval list from studentsGradesCommentsRows
  void populateCommentsForDropdown() {
    commentStringEval.clear();
    if (studentsGradesCommentsRows.isNotEmpty) {
      for (var comment in studentsGradesCommentsRows) {
        if (!commentStringEval.contains(comment.commentName)) {
          commentStringEval.add(comment.commentName);
        }
      }
    }
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
      if (monthSelected != 99) {
        if (!currentUser!.isCurrentUserAdmin() ||
            !currentUser!.isCurrentUserAcademicCoord()) {
          monthNumber = monthSelected;
          selectedTempGradeStr = getValueFromKey(teacherGradesMap, grade);
        }

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
          // Populate comments for dropdown and update visibility
          populateCommentsForDropdown();
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

        // Check for unevaluated students after data is loaded
        Future.microtask(() {
          if (mounted) {
            _checkForUnevaluatedStudents();
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
            readOnly: false,
            checkReadOnly: (row, cell) {
              return false;
            },
            hide: true),
        TrinaColumn(
          title: 'Materia',
          field: 'subject_name',
          type: TrinaColumnType.text(),
          // width: 80,
          //frozen: TrinaColumnFrozen.start,
          sort: TrinaColumnSort.ascending,
          readOnly: false,
          checkReadOnly: (row, cell) {
            return false;
          },
        ),
        TrinaColumn(
            title: 'Calificación',
            field: 'evaluation',
            type: TrinaColumnType.number(
              negative: false,
            ),
            width: 100),
        TrinaColumn(
          title: 'idCalif',
          field: 'idCicloEscolar',
          type: TrinaColumnType.number(negative: false),
          hide: true,
          readOnly: false,
          checkReadOnly: (row, cell) {
            return false;
          },
        ),
        TrinaColumn(
            title: absencesColumnTitle ?? 'Faltas',
            hide: hideAbsencesColumn,
            field: 'absence_eval',
            width: 60,
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            title: homeworkColumnTitle ?? 'Tareas',
            hide: hideHomeworksColumn,
            width: 60,
            field: 'homework_eval',
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            title: habitsWorkColumnTitle ?? 'Habitos',
            hide: hideHabitsColumn,
            field: 'habit_eval',
            width: 60,
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            title: disciplineColumnTitle ?? 'Conducta',
            hide: hideDisciplineColumn,
            field: 'discipline_eval',
            width: 80,
            type: TrinaColumnType.number(negative: false)),
        TrinaColumn(
            hide: hideCommentsColumn,
            title: 'Comentarios',
            field: 'Comentarios',
            type: TrinaColumnType.select(commentStringEval,
                enableColumnFilter: true),
            readOnly: false,
            width: 200),

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
      //selectedCurrentTempMonth = currentMonth.toCapitalized;
      return evalMonthFromBackend; //getKeyFromValue(spanishMonthsMap, selectedCurrentTempMonth!);
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
      var confirmation = await showConfirmationDialog(
          context, 'Confirmar', '¿Desea guardar los cambios realizados?');
      if (confirmation.isEqual(1)) {
        _setLoadingState(true);

        final calculatedMonthNumber = _calculateMonthNumber();

        await saveButtonAction(calculatedMonthNumber);

        // Optionally reload the current student to ensure fresh data
        if (selectedStudentID != null) {
          final gradeInt =
              getKeyFromValue(teacherGradesMap, selectedTempGrade!.toString());
          await loadSelectedStudent(
              selectedStudentID!, gradeInt, calculatedMonthNumber!);
        }

        if (context.mounted) {
          showInformationDialog(context, 'Éxito', 'Cambios realizados!');
          // Clear the changes and refresh only the current student's data
          studentGradesBodyToUpgrade.clear();
        }
      } else {
        return;
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
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Evaluando a: ${selectedStudentName.trim()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasZeroValuesInEvaluableSubjects()
                            ? 'Tiene calificaciones pendientes'
                            : 'Evaluación completa',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: _hasZeroValuesInEvaluableSubjects()
                                ? Colors.red
                                : Colors.green,
                            shape: BoxShape.circle,
                          )),
                    ],
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
                  Icons.groups,
                  color: Colors.blue,
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
                // selectedTempGradeStr =
                //     getValueFromKey(teacherGradesMap, selectedTempGrade);
                var gradeInt = selectedTempGrade;
                //getKeyFromValue(teacherGradesMap, selectedTempGradeStr);
                int? monthNumber;

                if (isUserAdmin || isUserAcademicCoord) {
                  monthNumber =
                      getKeyFromValue(spanishMonthsMap, selectedTempMonth!);
                } else {
                  monthNumber = evalMonthFromBackend; //getKeyFromValue(
                  // spanishMonthsMap, selectedCurrentTempMonth!);
                }
                selectedStudentID = event.row.cells['studentID']!.value;
                selectedStudentName =
                    event.row.cells['studentName']!.value.toString();

                // Clear any pending changes before switching students
                _clearStudentDataBeforeSwitching();

                // Add a small delay to ensure UI updates before loading new data
                await Future.delayed(const Duration(milliseconds: 50));

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
                  Icons.grade_rounded,
                  color: Colors.amber,
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
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: TrinaGrid(
                      key: ValueKey('grades_grid_$selectedStudentID'),
                      columns: gradesByStudentColumns,
                      rows: selectedStudentRows,
                      onChanged: (event) {
                        //* Ensure we have a valid state before processing changes
                        if (_disposed ||
                            !mounted ||
                            selectedStudentID == null) {
                          return;
                        }
                        var newValue;
                        var commentiD = 0;
                        var originalValue = event.value;

                        //* Only process changes for editable columns
                        if (_isEditableField(event.column.title)) {
                          //* Process changes for editable columns

                          if (event.value is String) {
                            //* Obtain the id of the comment
                            if (event.column.field == 'Comentarios') {
                              if (event.value != null && event.value != '') {
                                //* Find comment ID based on selected comment text
                                var matchingComment =
                                    studentsGradesCommentsRows.firstWhere(
                                        (comment) =>
                                            comment.commentName == event.value,
                                        orElse: () =>
                                            Academicevaluationscomment(
                                                0, '', false, 0, 0));
                                commentiD = matchingComment.commentId ?? 0;
                                newValue = commentiD;
                              } else {
                                commentiD = 0; //! No comment selected
                              }
                            }
                          } else {
                            // Handle numeric fields with appropriate validation
                            if (event.column.field == 'absence_eval' ||
                                event.column.field == 'homework_eval' ||
                                event.column.field == 'discipline_eval' ||
                                event.column.field == 'habit_eval') {
                              // Validate smallint fields
                              var validationResult = validateSmallintValue(
                                  event.value, event.column.title);
                              newValue = validationResult['value'];

                              // Show validation message if value was adjusted
                              if (validationResult['message'] != null &&
                                  context.mounted) {
                                _validationDebounce?.cancel();
                                _validationDebounce = Timer(
                                    const Duration(milliseconds: 100), () {
                                  if (context.mounted && !_disposed) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '⚠️ ${validationResult['message']} ⚠️',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                });

                                // Update the cell value to the validated value
                                Future.microtask(() {
                                  if (!_disposed && mounted) {
                                    try {
                                      event.row.cells[event.column.field]
                                          ?.value = newValue;
                                    } catch (e) {
                                      insertErrorLog(e.toString(),
                                          'SMALLINT_VALIDATION_CELL_UPDATE_ERROR');
                                    }
                                  }
                                });
                              }
                            } else {
                              String? subjectName;
                              if (selectedTempSubject?.trim().toUpperCase() ==
                                      'SALIDAS TEMPRANO' ||
                                  selectedTempSubject?.trim().toUpperCase() ==
                                      'BOOKS READ' ||
                                  selectedTempSubject?.trim().toUpperCase() ==
                                      'CUIDADO DEL MEDIO AMBIENTE' ||
                                  selectedTempSubject?.trim().toUpperCase() ==
                                      'P.E.T') {
                                subjectName =
                                    selectedTempSubject?.trim().toUpperCase();
                              }

                              // Use existing validation for grade fields
                              newValue = validateNewGradeValue(
                                  event.value, event.column.title, subjectName);
                            }
                          }
                          // Show validation message if value was adjusted for evaluation field
                          if (event.column.field == 'evaluation' &&
                              originalValue != newValue) {
                            String message = '';
                            if (originalValue is num && originalValue < 50) {
                              message =
                                  'La calificación no puede ser menor a 50. Se ajustó automáticamente a 50.';
                            } else if (originalValue is num &&
                                originalValue > 100) {
                              message =
                                  'La calificación no puede ser mayor a 100. Se ajustó automáticamente a 100.';
                            }

                            if (message.isNotEmpty && context.mounted) {
                              // Cancel any existing validation debounce to prevent duplicate messages
                              _validationDebounce?.cancel();

                              // Show validation message using Future.microtask to avoid setState during build
                              _validationDebounce =
                                  Timer(const Duration(milliseconds: 100), () {
                                if (context.mounted && !_disposed) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '❌ $message ❌',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary, // Amber background for warnings
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              });

                              // Update the cell value to the validated value
                              Future.microtask(() {
                                if (!_disposed && mounted) {
                                  try {
                                    event.row.cells[event.column.field]?.value =
                                        newValue;
                                  } catch (e) {
                                    // Handle any cell update errors gracefully
                                    insertErrorLog(
                                        e.toString(), 'CELL_UPDATE_ERROR');
                                  }
                                }
                              });
                            }
                          }

                          final evalId =
                              event.row.cells['idCicloEscolar']?.value;
                          int? monthNumber;
                          if (isUserAdmin || isUserAcademicCoord) {
                            monthNumber = getKeyFromValue(spanishMonthsMap,
                                selectedTempMonth!.toCapitalized);
                          } else {
                            monthNumber = getKeyFromValue(
                                spanishMonthsMap, currentMonth.toCapitalized);
                          }

                          // composeBodyToUpdateGradeBySTudent(
                          //   event.column.title,
                          //   selectedStudentID!,
                          //   newValue,
                          //   evalId,
                          //   monthNumber,
                          // );

                          composeUpdateStudentGradesBody(
                              event.column.title, newValue, evalId);
                        } else {
                          //revertSelectedCell();
                          return;
                        }
                      },
                      onLoaded: (TrinaGridOnLoadedEvent event) {
                        gridAStateManager = event.stateManager;
                      },
                      configuration: TrinaGridConfiguration(
                        style: TrinaGridStyleConfig(
                          enableColumnBorderVertical: false,
                          enableCellBorderVertical: false,
                          // Make rows shorter
                          rowHeight: 35,
                        ),
                        columnSize: TrinaGridColumnSizeConfig(
                          autoSizeMode: TrinaAutoSizeMode.scale,
                          resizeMode: TrinaResizeMode.pushAndPull,
                        ),
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

  /// Checks if there are any zero values in the selected student's grades for evaluable subjects
  /// Excludes: "Uniforme y Presentacion", "Conducta", "Faltas", "Retardos", "Salidas Temprano", "puntualidad y asistencia"
  bool _hasZeroValuesInEvaluableSubjects() {
    // List of subjects to exclude from zero validation
    const excludedSubjects = {
      'uniforme y presentación',
      'conducta',
      'faltas',
      'retardos',
      'salidas temprano',
      'puntualidad y asistencia'
    };

    for (var row in selectedStudentRows) {
      String subjectName = (row.cells['subject_name']?.value ?? '')
          .toString()
          .trim()
          .toLowerCase();

      // Skip excluded subjects
      if (excludedSubjects.contains(subjectName)) {
        continue;
      }

      // Check if evaluation is zero for non-excluded subjects
      if (row.cells['evaluation']?.value == 0) {
        return true;
      }
    }
    return false;
  }

  dynamic validator() {
    bool result = false;
    if (studentList.isNotEmpty) {
      studentList.clear();
    }
    if (selectedTempGroup == null || selectedTempGroup == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un grupo a evaluar');
    } else {
      result = true;
    }
    if (selectedTempGrade == null || selectedTempGrade == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un grado a evaluar');
    } else {
      result = true;
    }
    if (selectedTempCampus == null || selectedTempCampus == '') {
      return showEmptyFieldAlertDialog(
          context, 'Seleccionar un campus a evaluar');
    } else {
      result = true;
    }
    // if (dropDownValue.isEmpty || dropDownValue == '') {
    //   dropDownValue = oneTeacherAssignatures.first;
    // }
    if (currentUser!.isAcademicCoord! || currentUser!.isAdmin!) {
      if (selectedTempMonth == null || selectedTempMonth == '') {
        return showEmptyFieldAlertDialog(context, 'Seleccionar mes a evaluar');
      } else {
        result = true;
      }
    } else {
      if (monthNumber == null || monthNumber == 0) {
        return showEmptyFieldAlertDialog(context, 'Seleccionar mes a evaluar');
      } else {
        result = true;
      }
    }
    return result;
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

  bool _isEditableField(String fieldName) {
    const restrictedFields = {
      'No',
      'Matrícula',
      'Nombre del alumno',
      'Materia'
    };
    return !restrictedFields.contains(fieldName);
  }

  /// Validates smallint values (0 to 32767 for positive smallint)
  /// Returns the validated value and a validation message if needed
  Map<String, dynamic> validateSmallintValue(dynamic value, String fieldName) {
    if (value == null || value == '') {
      return {'value': 0, 'message': null};
    }

    int? intValue;
    if (value is String) {
      intValue = int.tryParse(value);
    } else if (value is num) {
      intValue = value.toInt();
    }

    if (intValue == null) {
      return {
        'value': 0,
        'message': 'Valor inválido en $fieldName. Se estableció en 0.'
      };
    }

    // Validate smallint range (0 to 32767 for positive values)
    if (intValue < 0) {
      return {
        'value': 0,
        'message': '$fieldName no puede ser negativo. Se ajustó a 0.'
      };
    }

    if (intValue > 32767) {
      return {
        'value': 32767,
        'message':
            '$fieldName excede el límite máximo (32767). Se ajustó automáticamente.'
      };
    }

    return {'value': intValue, 'message': null};
  }

  Future<void> saveButtonAction(int? monthNumberDefined) async {
    monthNumber = monthNumberDefined;
    if (validator()) {
      await patchStudentGradesToDB().then((response) {
        _handleRefreshAction();
        return;
      }).onError((error, stackTrace) {
        throw Future.error(error.toString());
      });
    }
  }

  Future<void> loadSelectedStudent(
      String studentID, int? gradeInt, int month) async {
    selectedStudentList.clear();

    selectedStudentList =
        studentList.where((student) => student.studentID == studentID).toList();

    // Use setState to ensure proper widget rebuild
    setState(() {
      selectedStudentRows.clear();

      // Rebuild the rows with fresh TrinaCell instances
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
          'Comentarios': TrinaCell(
            value: student.comment != null && student.comment != 0
                ? student.comment
                : '',
          ),
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
    hideHomeworksColumn = false;
    hideDisciplineColumn = false;

    bool hasComments = commentStringEval.isNotEmpty;
    if (grade < 12) {
      // Elementaty 1 to 6
      hideCommentsColumn = !hasComments; // Show comments only if available
      hideAbsencesColumn = true; // Faltas
      hideHomeworksColumn = true; // Tareas
      hideDisciplineColumn = false; //Disciplina
      hideHabitsColumn = false;
      hideOutfitColumn = true;
      habitsWorkColumnTitle = 'H';
      disciplineColumnTitle = 'Con';
    }
    if (grade < 6) {
      // Kinder to 3k
      hideCommentsColumn = true; //-!hasComments;
      hideAbsencesColumn = true; // Faltas
      hideHomeworksColumn = true; // Tareas
      hideDisciplineColumn = true; //Disciplina
      hideHabitsColumn = true; //Habits
      habitsWorkColumnTitle = 'H';
      hideOutfitColumn = true;
    }
    if (grade > 11) {
      // Middle School 7 to 9
      hideCommentsColumn = !hasComments;
      hideAbsencesColumn = false; // Faltas
      hideHomeworksColumn = false; // Tareas
      hideDisciplineColumn = false; //Disciplina
      hideHabitsColumn = false; //Habitos
      hideOutfitColumn = true;
      homeworkColumnTitle = 'R';
      absencesColumnTitle = 'F';
      habitsWorkColumnTitle = 'H';
      disciplineColumnTitle = 'Con';
    }
  }
}
