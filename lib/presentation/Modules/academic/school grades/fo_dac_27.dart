import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/presentation/Modules/academic/school%20grades/fodac_27_new_record_window.dart';

import 'package:trina_grid/trina_grid.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../data/datasources/temp/studens_temp.dart';
import '../../../../data/datasources/temp/teacher_grades_temp.dart';
import '../../../../data/services/backend/api_requests/api_calls_list_dio.dart';
import '../../../components/confirm_dialogs.dart';

import 'fodac_27_dropdownmenu.dart';

import '../../../../core/reusable_methods/academic_functions.dart';
import '../../../../core/utils/loader_indicator.dart';

class FoDac27 extends StatefulWidget {
  const FoDac27({super.key});

  @override
  State<FoDac27> createState() => _FoDac27State();
}

class _FoDac27State extends State<FoDac27> {
  late Future<dynamic> _studentsFuture;
  List<TrinaRow> fodac27HistoryRows = [];
  TrinaGridStateManager? stateManager;

  final TextEditingController studentSelectorController =
      TextEditingController();

  String selectedStudent = '';
  String? selectedstudentId;
  String selectedSubjectNameToEdit = '';
  String selectedStudentIdToEdit = '';

  bool isLoading = true;
  bool isUserAdmin = false;
  bool displayLoading = false;

  int selectedEvalID = 0;
  String selectedCommentToEdit = '';
  String selectedDateToEdit = '';

  @override
  void initState() {
    isUserAdmin = currentUser!.isCurrentUserAdmin();
    _studentsFuture = populateStudentsDropDownMenu();
    super.initState();
  }

  @override
  void dispose() {
    tempStudentMap.clear();
    fodac27HistoryRows.clear();
    teacherGradesListFODAC27.clear();
    teacherGroupsListFODAC27.clear();
    teacherCampusListFODAC27.clear();
    gradesMapFODAC27.clear();
    studentSelectorController.dispose();
    selectedTempStudent = null;
    super.dispose();
  }

  // final exportToExcel = IconButton.outlined(
  //   onPressed: () {},
  //   icon: const FaIcon(FontAwesomeIcons.solidFileExcel),
  //   tooltip: 'Exportar a Excel',
  // );

  final List<TrinaColumn> fodac27Columns = [
    TrinaColumn(
        title: 'id',
        field: 'fodac27',
        type: TrinaColumnType.number(
          format: '####',
          negative: false,
        ),
        readOnly: true,
        sort: TrinaColumnSort.ascending,
        enableColumnDrag: true,
        enableRowDrag: true),
    TrinaColumn(
      title: 'Fecha',
      field: 'date',
      type: TrinaColumnType.dateTime(),
      readOnly: false,
      checkReadOnly: (row, cell) {
        return false;
      },
    ),
    TrinaColumn(
      title: 'Matricula',
      field: 'studentID',
      type: TrinaColumnType.text(),
      readOnly: false,
      checkReadOnly: (row, cell) {
        return false;
      },
    ),
    TrinaColumn(
      title: 'Obs',
      field: 'Obs',
      type: TrinaColumnType.text(),
      renderer: (rendererContext) {
        return Tooltip(
          message: rendererContext.cell.value,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              rendererContext.cell.value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1, // You can adjust this as needed
              style: const TextStyle(
                fontSize: 14, // Adjust font size as needed
                color: Colors.black, // Set the text color to black
              ),
            ),
          ),
        );
      },
      readOnly: false,
      checkReadOnly: (row, cell) {
        return false;
      },
    ),
    TrinaColumn(
        title: 'Materia',
        field: 'subject',
        type: TrinaColumnType.text(),
        readOnly: false,
        checkReadOnly: (row, cell) {
          return false;
        }),
    TrinaColumn(
      title: 'Maestro',
      field: 'teacher',
      type: TrinaColumnType.text(),
      readOnly: false,
      checkReadOnly: (row, cell) {
        return false;
      },
    ),
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
      child: FutureBuilder(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(theme);
          } else if (snapshot.hasError) {
            return _buildErrorState(theme, snapshot.error.toString());
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
              'Cargando formulario FODAC-27',
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

  Widget _buildErrorState(ThemeData theme, String error) {
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
                  Icons.error_outline,
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
                'Error: $error',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _studentsFuture = populateStudentsDropDownMenu();
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
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildStudentSelector(theme, colorScheme),
          const SizedBox(height: 8),
          Expanded(
            child: _buildTrinaGrid(theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSelector(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selección de Estudiante',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Fodac27MenuSelector(),
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionButtons(theme, colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildRefreshButton(theme, colorScheme),
        const SizedBox(height: 8),
        _buildAddButton(theme, colorScheme),
        const SizedBox(height: 8),
        _buildEditButton(theme, colorScheme),
        const SizedBox(height: 8),
        _buildExportButton(theme, colorScheme),
        const SizedBox(height: 8),
        if (isUserAdmin) _buildDeleteButton(theme, colorScheme),
      ],
    );
  }

  Widget _buildRefreshButton(ThemeData theme, ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              studentGradesBodyToUpgrade.clear();
              setState(() {
                isLoading = true;
              });
              await handleRefresh();
              setState(() {
                isLoading = false;
              });
            },
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          : const Icon(Icons.refresh, size: 18),
      label: Text(isLoading ? 'Actualizando...' : 'Actualizar'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        side: BorderSide(color: colorScheme.outline),
        textStyle: theme.textTheme.labelMedium,
      ),
    );
  }

  Widget _buildAddButton(ThemeData theme, ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: () {
        handleAddItem();
        handleRefresh();
      },
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Agregar'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: theme.textTheme.labelMedium,
      ),
    );
  }

  Widget _buildEditButton(ThemeData theme, ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: selectedEvalID == 0
          ? null
          : () {
              _handleEditItem();
            },
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('Editar'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: theme.textTheme.labelMedium,
        side: BorderSide(
          color: selectedEvalID == 0
              ? colorScheme.outline.withOpacity(0.5)
              : colorScheme.primary,
        ),
        foregroundColor: selectedEvalID == 0
            ? colorScheme.onSurface.withOpacity(0.5)
            : colorScheme.primary,
      ),
    );
  }

  Widget _buildExportButton(ThemeData theme, ColorScheme colorScheme) {
    return FilledButton.tonalIcon(
      onPressed: fodac27HistoryRows.isEmpty
          ? null
          : () async {
              await _exportToExcel();
            },
      icon: const Icon(Icons.file_download_outlined, size: 18),
      label: const Text('Exportar'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: theme.textTheme.labelMedium,
        backgroundColor: fodac27HistoryRows.isEmpty
            ? colorScheme.surfaceVariant
            : colorScheme.secondaryContainer,
        foregroundColor: fodac27HistoryRows.isEmpty
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSecondaryContainer,
      ),
    );
  }

  Widget _buildDeleteButton(ThemeData theme, ColorScheme colorScheme) {
    return FilledButton.tonalIcon(
      onPressed: () async {
        if (selectedEvalID == 0) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content:
                  const Text('Primero seleccione un registro para eliminar'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          int confirmation = await showDeleteConfirmationAlertDialog(context);
          if (confirmation == 1) {
            try {
              setState(() {
                isLoading = true;
              });
              await deleteAction(selectedEvalID).catchError((onError) {
                showErrorFromBackend(context, onError.toString());
              }).whenComplete(() {
                setState(() {
                  isLoading = false;
                });
              });
              if (mounted) {
                await showConfirmationDialog(
                    context, 'Realizado', 'Registro eliminado');
                handleRefresh();
                setState(() {
                  isLoading = false;
                });
              }
            } catch (e) {
              if (mounted) {
                showErrorFromBackend(context, e.toString());
              }
            }
          }
        }
      },
      icon: const Icon(Icons.delete_outline, size: 18),
      label: const Text('Eliminar'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: theme.textTheme.labelMedium,
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
      ),
    );
  }

  Widget _buildTrinaGrid(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Historial FODAC-27',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (fodac27HistoryRows.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${fodac27HistoryRows.length} registros',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: fodac27HistoryRows.isEmpty
                ? _buildEmptyGridState(theme, colorScheme)
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: TrinaGrid(
                      // rowColorCallback: (rowColorContext) {
                      //   return rowColorContext.row.cells['fodac27']?.value %
                      //               2 ==
                      //           0
                      //       ? const Color.fromARGB(255, 55, 190, 52)
                      //       : colorScheme.surface;
                      // },
                      mode: TrinaGridMode.selectWithOneTap,
                      columns: fodac27Columns,
                      rows: fodac27HistoryRows,
                      onLoaded: (event) {
                        event.stateManager
                            .setSelectingMode(TrinaGridSelectingMode.cell);
                        stateManager = event.stateManager;
                      },
                      onSelected: handleSelectedCell,
                      onRowDoubleTap: (event) {
                        _showRowDetailsDialog(event.row);
                      },
                      configuration: const TrinaGridConfiguration(
                        style: TrinaGridStyleConfig(
                          enableColumnBorderVertical: false,
                          enableCellBorderVertical: false,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGridState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay registros disponibles',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seleccione un estudiante y agregue registros para comenzar',
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

  void handleAddItem() {
    if (selectedTempStudent == null) {
      showEmptyFieldAlertDialog(context, 'Favor de seleccionar un alumno');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final theme = Theme.of(context);
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isSmallScreen = screenWidth < 600;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? screenWidth * 0.95 : 600,
                maxHeight: screenHeight * 0.9,
              ),
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_comment_outlined,
                        color: theme.colorScheme.primary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Text(
                          'Agregar comentario FODAC-27',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            fontSize: isSmallScreen ? 18 : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: isSmallScreen ? 16 : 18,
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Expanded(
                          child: Text(
                            'Estudiante: $selectedTempStudent',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                              fontSize: isSmallScreen ? 13 : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: NewFODAC27CommentDialog(
                      selectedstudentId: selectedstudentId!,
                      employeeNumber: currentUser!.employeeNumber!,
                      onDialogClose: _handleRefreshWithLoading,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _handleEditItem() {
    if (selectedEvalID == 0) {
      showEmptyFieldAlertDialog(
          context, 'Favor de seleccionar un registro para editar');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCommentScreen(
          id: selectedEvalID,
          comment: selectedCommentToEdit,
          date: selectedDateToEdit,
          selectedSubject: selectedSubjectNameToEdit,
          studentID: selectedStudentIdToEdit,
        );
      },
    ).then((_) {
      // Refresh the grid after editing
      _handleRefreshWithLoading();
    });
  }

  void _handleRefreshWithLoading() {
    setState(() {
      isLoading = true;
    });

    handleRefresh().then((_) {
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      showErrorFromBackend(context, error.toString());
    });
  }

  Future<dynamic> handleRefresh() async {
    setState(() {
      fodac27HistoryRows.clear();
    });

    for (var map in simplifiedStudentsList) {
      if (map.containsKey('student_name') &&
          map['student_name'] == selectedTempStudent) {
        selectedstudentId = map['matricula'];
        break;
      }
    }
    if (selectedstudentId != null) {
      await populateGrid(selectedstudentId!, currentCycle!.claCiclo!, true);
    }
  }

  void handleSelectedCell(TrinaGridOnSelectedEvent event) {
    var selectedRow = event.row;
    selectedEvalID = selectedRow?.cells['fodac27']?.value;
    selectedCommentToEdit = selectedRow?.cells['Obs']?.value;
    selectedDateToEdit = selectedRow?.cells['date']?.value;
    selectedSubjectNameToEdit = selectedRow?.cells['subject']?.value;
    selectedStudentIdToEdit = selectedRow?.cells['studentID']?.value;
  }

  void _showRowDetailsDialog(TrinaRow row) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Dialog(
            elevation: 24,
            shadowColor: colorScheme.shadow.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 28),
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? screenWidth * 0.95 : 650,
                maxHeight: screenHeight * 0.85,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surfaceContainer.withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Beautiful Header with gradient
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.primaryContainer.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.assignment_outlined,
                            color: colorScheme.primary,
                            size: isSmallScreen ? 24 : 28,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registro FODAC-27',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: isSmallScreen ? 20 : 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${row.cells['fodac27']?.value?.toString() ?? 'N/A'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer
                                      .withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close_rounded,
                              color: colorScheme.onPrimaryContainer,
                              size: isSmallScreen ? 22 : 24,
                            ),
                            tooltip: 'Cerrar',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content with better spacing and design
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildBeautifulDetailField(
                              theme: theme,
                              colorScheme: colorScheme,
                              isSmallScreen: isSmallScreen,
                              label: 'Fecha del Registro',
                              value:
                                  row.cells['date']?.value?.toString() ?? 'N/A',
                              icon: Icons.calendar_today_rounded,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            _buildBeautifulDetailField(
                              theme: theme,
                              colorScheme: colorScheme,
                              isSmallScreen: isSmallScreen,
                              label: 'Matrícula del Estudiante',
                              value:
                                  row.cells['studentID']?.value?.toString() ??
                                      'N/A',
                              icon: Icons.person_rounded,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            _buildBeautifulDetailField(
                              theme: theme,
                              colorScheme: colorScheme,
                              isSmallScreen: isSmallScreen,
                              label: 'Materia',
                              value: row.cells['subject']?.value?.toString() ??
                                  'N/A',
                              icon: Icons.subject_rounded,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            _buildBeautifulDetailField(
                              theme: theme,
                              colorScheme: colorScheme,
                              isSmallScreen: isSmallScreen,
                              label: 'Profesor',
                              value: row.cells['teacher']?.value?.toString() ??
                                  'N/A',
                              icon: Icons.school_rounded,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            _buildBeautifulDetailField(
                              theme: theme,
                              colorScheme: colorScheme,
                              isSmallScreen: isSmallScreen,
                              label: 'Observaciones',
                              value: row.cells['Obs']?.value?.toString() ??
                                  'Sin observaciones',
                              icon: Icons.edit_note_rounded,
                              isMultiLine: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Beautiful action button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: colorScheme.primary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: isSmallScreen ? 20 : 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Entendido',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeautifulDetailField({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isSmallScreen,
    required String label,
    required String value,
    required IconData icon,
    bool isMultiLine = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label section with theme-appropriate background
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Value section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: isSmallScreen ? 13 : 14,
                  height: isMultiLine ? 1.5 : 1.3,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: isMultiLine ? null : 2,
                overflow: isMultiLine ? null : TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? getStudentIdByName(String name) {
    return simplifiedStudentsList
        .firstWhere((student) => student["name"] == name)["studentID"];
  }

  Future<void> populateGrid(
      String studentID, String cycle, bool isByStudent) async {
    setState(() {
      isLoading = true;
    });

    try {
      var apiResponse =
          await getStudentFodac27History(cycle, studentID, isByStudent);

      if (apiResponse != null) {
        var decodedResponse = apiResponse as List;
        List<TrinaRow> newRows = decodedResponse.map((item) {
          return TrinaRow(cells: {
            'date': TrinaCell(value: item['date']),
            'studentID': TrinaCell(value: item['studentId']),
            'Obs': TrinaCell(value: item['observation']),
            'subject': TrinaCell(value: item['subjectName']),
            'teacher': TrinaCell(value: item['teacherName']),
            'fodac27': TrinaCell(value: item['fodacId']),
          });
        }).toList();

        setState(() {
          fodac27HistoryRows = newRows;
          // Only update the grid state manager if it's initialized
          if (stateManager != null) {
            stateManager!.removeAllRows();
            stateManager!.appendRows(newRows);
          }
          isLoading = false;
        });
      } else {
        setState(() {
          fodac27HistoryRows.clear();
          stateManager?.removeAllRows();
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        fodac27HistoryRows.clear();
        stateManager?.removeAllRows();
        isLoading = false;
      });
      // Optionally show error to user
      if (mounted) {
        showErrorFromBackend(context, error.toString());
      }
    }
  }

  Future<dynamic> populateStudentsDropDownMenu() async {
    // String userRole = currentUser!.role;

    // var response = await getStudentsByRole(currentCycle!.claCiclo!);
    // List<dynamic> simplifiedStudentsList = json.decode(response);

    simplifiedStudentsList =
        await getStudentsByTeacher(currentCycle!.claCiclo!);

    if (simplifiedStudentsList.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<dynamic> deleteAction(int fodac27ID) async {
    try {
      var response = await deleteFodac27Record(fodac27ID);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<void> _exportToExcel() async {
    if (fodac27HistoryRows.isEmpty) {
      showErrorFromBackend(context, "No hay datos para exportar.");
      return;
    }

    try {
      setState(() {
        displayLoading = true;
      });

      // Prepare CSV data
      List<List<dynamic>> csvData = [];

      // Add headers with Spanish column names
      csvData.add(
          ['ID', 'Fecha', 'Matrícula', 'Materia', 'Maestro', 'Observaciones']);

      // Add rows
      for (var row in fodac27HistoryRows) {
        csvData.add([
          row.cells['fodac27']?.value?.toString() ?? '',
          row.cells['date']?.value?.toString() ?? '',
          row.cells['studentID']?.value?.toString() ?? '',
          row.cells['subject']?.value?.toString() ?? '',
          row.cells['teacher']?.value?.toString() ?? '',
          row.cells['Obs']?.value?.toString() ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      // Let user pick the save location
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar archivo CSV',
        fileName: 'reporteFODAC27.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csv, encoding: utf8);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Archivo CSV guardado exitosamente en $outputFile',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }

      setState(() {
        displayLoading = false;
      });
    } catch (error) {
      setState(() {
        displayLoading = false;
      });

      if (mounted) {
        showErrorFromBackend(context, 'Error al exportar: ${error.toString()}');
      }
    }
  }
}

class EditCellDialog extends StatelessWidget {
  final TrinaCell cell;
  final Function(String) onSave;

  const EditCellDialog({
    super.key,
    required this.cell,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: cell.value);

    return AlertDialog(
      title: const Text('Editar celda'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Nuevo valor',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            controller.dispose();
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            onSave(controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class EditCommentScreen extends StatefulWidget {
  final int id;
  final String comment;
  final String date;
  final String selectedSubject;
  final String studentID;

  const EditCommentScreen({
    super.key,
    required this.id,
    required this.comment,
    required this.date,
    required this.selectedSubject,
    required this.studentID,
  });

  @override
  _EditCommentScreenState createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  late TextEditingController _commentController;
  late TextEditingController _dateController;
  DateTime? _selectedDate;
  DateFormat format = DateFormat("d/M/y");
  DateTime? date;
  List<String> _subjects = [];
  String? _selectedSubject;
  bool _isSaving = false;

  Map<String, dynamic> subjectsMap = {};
  Map<String, dynamic> newObservation = {};
  Map<String, dynamic> newDate = {};
  Map<String, dynamic> newSubject = {};

  @override
  void initState() {
    // Initialize the date controller first
    _dateController = TextEditingController();

    try {
      // Handle different date formats that might come from the API
      if (widget.date.contains('-')) {
        // Format: 2024-11-29 or 2024-11-29 00:00:00.0
        DateTime parsedDate = DateTime.parse(widget.date.split(' ')[0]);
        date = parsedDate;
        _dateController.text =
            "${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}";
      } else {
        // Format: d/M/y
        date = format.parse(widget.date);
        _dateController.text = widget.date;
      }
    } catch (e) {
      // Fallback to current date if parsing fails
      date = DateTime.now();
      _dateController.text =
          "${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}";
    }

    getSubjects();
    _selectedSubject = widget.selectedSubject;
    _commentController = TextEditingController(text: widget.comment);
    _dateController = TextEditingController(text: widget.date);
    _selectedDate = date;
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _dateController.dispose();
    subjectsMap.clear();
    newObservation.clear();
    newDate.clear();
    newSubject.clear();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Display formatted date for user
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        newDate.clear();
        // Send timestamp (milliseconds since epoch) to backend
        newDate = {'date': picked.millisecondsSinceEpoch};
      });
    }
  }

  void getSubjects() async {
    Map<String, dynamic> subjects = await populateSubjectsDropDownSelector(
        widget.studentID, currentCycle!.claCiclo!);
    setState(() {
      _subjects = subjects.keys.toList();
      subjectsMap = subjects;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Editar Registro FODAC-27',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Subject Selection
            _buildEditField(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Materia',
              icon: Icons.subject_outlined,
              child: DropdownButtonFormField<String>(
                hint: const Text('Materia'),
                value: _selectedSubject,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    newSubject.clear();
                    _selectedSubject = newValue;
                    var subjectID = subjectsMap[newValue];
                    newSubject = {'subject': subjectID};
                  });
                },
                items: _subjects.map((String materia) {
                  return DropdownMenuItem<String>(
                    value: materia,
                    child: Text(materia),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Observation Field
            _buildEditField(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Observación',
              icon: Icons.edit_note_outlined,
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  hintText: 'Escriba las observaciones...',
                ),
                onChanged: (value) {
                  newObservation.clear();
                  newObservation = {'observation': value.toUpperCase().trim()};
                },
              ),
            ),
            const SizedBox(height: 16),

            // Date Field
            _buildEditField(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Fecha',
              icon: Icons.calendar_today_outlined,
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: _selectDate,
                onChanged: (value) {
                  // This won't be called since field is readOnly,
                  // but keeping for consistency
                  if (_selectedDate != null) {
                    newDate.clear();
                    newDate = {'date': _selectedDate!.millisecondsSinceEpoch};
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() {
                              _isSaving = true;
                            });

                            try {
                              Map<String, dynamic> id = {'id': widget.id};

                              var bodyToEdit = validateEditedFields(
                                id,
                                newObservation,
                                newDate,
                                newSubject,
                              );
                              if (bodyToEdit != null) {
                                int response =
                                    await updateFodac27Record(bodyToEdit);
                                if (response == 200) {
                                  if (mounted) {
                                    Navigator.pop(context);
                                    showSuccessDialog(context, 'Éxito',
                                        'Registro actualizado correctamente.');
                                  }
                                }
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isSaving = false;
                                });
                              }
                            }
                          },
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CustomLoadingIndicator(),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(
                icon,
                color: colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Map<String, dynamic>? validateEditedFields(
      Map<String, dynamic> id,
      Map<String, dynamic> newObservation,
      Map<String, dynamic> newDate,
      Map<String, dynamic> newSubject) {
    // if (newObservation.isNotEmpty || newDate.isNotEmpty || newSubject.isNotEmpty) {
    Map<String, dynamic> body = {};
    body.addEntries(id.entries);
    if (newObservation.isNotEmpty) {
      body.addEntries(newObservation.entries);
    }
    if (newDate.isNotEmpty) {
      body.addEntries(newDate.entries);
    }
    if (newSubject.isNotEmpty) {
      body.addEntries(newSubject.entries);
    }
    return body;
  }
}
