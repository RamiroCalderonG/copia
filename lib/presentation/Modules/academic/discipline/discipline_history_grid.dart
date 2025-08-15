import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/presentation/Modules/academic/discipline/create_discipline_screen.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/pdf/discipline_report.dart';
import 'package:trina_grid/trina_grid.dart';

class DisciplineHistoryGrid extends StatefulWidget {
  const DisciplineHistoryGrid({super.key});

  @override
  State<DisciplineHistoryGrid> createState() => _DisciplineHistoryGridState();
}

class _DisciplineHistoryGridState extends State<DisciplineHistoryGrid> {
  List<TrinaRow> plutoRows = [];
  dynamic apiResponse;
  var disciplinaryData;
  final TextEditingController initialDateController = TextEditingController();
  DateTime? initialDateTime;
  DateTime? finalDateTime;
  final TextEditingController finalDateController = TextEditingController();
  DateTime? _selectedDate;
  bool isLoading = false;

  final List<TrinaColumn> columns = [
    TrinaColumn(
        title: "Matrícula",
        field: "studentId",
        type: TrinaColumnType.text(),
        readOnly: true,
        width: 110),
    TrinaColumn(
        title: "Ciclo",
        field: "cycle",
        type: TrinaColumnType.text(),
        readOnly: true,
        width: 120),
    TrinaColumn(
        title: "Alumno",
        field: "student",
        type: TrinaColumnType.text(),
        readOnly: true),
    TrinaColumn(
        title: "Campus",
        field: "campus",
        type: TrinaColumnType.text(),
        readOnly: true,
        width: 110),
    TrinaColumn(
        title: "Grado",
        field: "academicLevel",
        type: TrinaColumnType.number(),
        readOnly: true,
        width: 80),
    TrinaColumn(
        title: "Grupo",
        field: "group",
        type: TrinaColumnType.text(),
        readOnly: true,
        width: 80),
    TrinaColumn(
      title: "Total",
      field: "total",
      type: TrinaColumnType.number(),
      readOnly: true,
      width: 80,
    ),
    TrinaColumn(
        title: "Menores",
        field: "minors",
        type: TrinaColumnType.text(),
        readOnly: true,
        width: 100),
    TrinaColumn(
      title: "Mayores",
      field: "mayors",
      type: TrinaColumnType.text(),
      readOnly: true,
      width: 100,
    ),
    TrinaColumn(
      title: "Notif1",
      field: "notif1",
      type: TrinaColumnType.number(),
      readOnly: true,
      width: 90,
    ),
    TrinaColumn(
      title: "Notif2",
      field: "notif2",
      type: TrinaColumnType.number(),
      readOnly: true,
      width: 90,
    ),
    TrinaColumn(
        title: "Notif3",
        field: "notif3",
        type: TrinaColumnType.number(),
        readOnly: true,
        width: 90)
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    initialDateController.dispose();
    finalDateController.dispose();
    apiResponse = null;
    plutoRows.clear();
    columns.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter and Action Panel
        _buildFilterPanel(theme, isSmallScreen),
        const SizedBox(height: 16),

        // Data Grid Section
        Expanded(
          child: _buildDataSection(theme),
        ),
      ],
    );
  }

  Widget _buildFilterPanel(ThemeData theme, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Filtros de Consulta', theme),
          const SizedBox(height: 8),
          if (isSmallScreen)
            Column(
              children: [
                _buildDateFilters(theme),
                const SizedBox(height: 16),
                _buildActionButtons(theme),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDateFilters(theme),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: _buildActionButtons(theme),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.filter_list,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilters(ThemeData theme) {
    return Row(
      children: [
        Expanded(
            child: _buildDateField(
                'Fecha Inicial', initialDateController, theme, true)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildDateField(
                'Fecha Final', finalDateController, theme, false)),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      ThemeData theme, bool isInitial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'dd/mm/aaaa',
            prefixIcon: Icon(
              Icons.date_range,
              color: theme.colorScheme.primary,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null) {
              setState(() {
                if (isInitial) {
                  initialDateTime = picked;
                } else {
                  finalDateTime = picked;
                }
                controller.text =
                    "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, seleccione una fecha';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _buildActionButton(
          label: isLoading ? 'Cargando...' : 'Consultar',
          icon: isLoading ? Icons.hourglass_empty : Icons.search,
          onPressed: isLoading
              ? null
              : () {
                  if (initialDateTime != null && finalDateTime != null) {
                    if (initialDateTime!.isAfter(finalDateTime!)) {
                      showErrorFromBackend(context,
                          "Fecha inicial no puede ser mayor que la final");
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    handleRefresh(currentCycle!.claCiclo!, initialDateTime!,
                            finalDateTime!)
                        .then((_) {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }).catchError((error) {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                        showErrorFromBackend(context, error.toString());
                      }
                    });
                  } else {
                    showEmptyFieldAlertDialog(context,
                        "Favor de seleccionar un rango de fechas correcto");
                  }
                },
          theme: theme,
          isPrimary: true,
        ),
        _buildActionButton(
          label: 'Excel',
          icon: Icons.table_chart,
          onPressed: () {
            if (apiResponse == null) {
              showErrorFromBackend(
                  context, "No hay datos para generar el reporte");
              setState(() {
                isLoading = false;
              });
              return;
            } else {
              setState(() {
                isLoading = true;
              });
              exportTrinaGridToCsv(context).whenComplete(() => setState(() {
                    isLoading = false;
                  }));
            }
          },
          theme: theme,
        ),
        _buildActionButton(
          label: 'PDF',
          icon: Icons.picture_as_pdf,
          onPressed: () {
            if (apiResponse == null) {
              showErrorFromBackend(
                  context, "No hay datos para generar el reporte");
              setState(() {
                isLoading = false;
              });
              return;
            } else {
              setState(() {
                isLoading = true;
              });
              generateDisciplinaryReport(
                      currentCycle!.claCiclo!, apiResponse, context)
                  .whenComplete(() => setState(() {
                        isLoading = false;
                      }));
            }
          },
          theme: theme,
        ),
        _buildActionButton(
          label: 'Nuevo',
          icon: Icons.add,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateDisciplineScreen()));
          },
          theme: theme,
          isSecondary: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required ThemeData theme,
    bool isPrimary = false,
    bool isSecondary = false,
  }) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: onPressed == null
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (isSecondary) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: theme.colorScheme.primary),
        ),
      );
    } else {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildDataSection(ThemeData theme) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomLoadingIndicator(),
            const SizedBox(height: 16),
            Text(
              'Cargando datos...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (apiResponse == null) {
      return _buildEmptyState(theme);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resultados de Consulta',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${plutoRows.length} registros',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TrinaGrid(
                mode: TrinaGridMode.readOnly,
                columns: columns,
                rows: plutoRows,
                configuration: const TrinaGridConfiguration(
                  style: TrinaGridStyleConfig(
                    enableColumnBorderVertical: false,
                    enableCellBorderVertical: false,
                  ),
                ),
                onLoaded: (TrinaGridOnLoadedEvent event) {
                  // Enable column filters
                  event.stateManager.setShowColumnFilter(true);
                },
                createFooter: (stateManager) {
                  stateManager.setPageSize(25, notify: false);
                  return TrinaPagination(stateManager);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin datos para mostrar',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seleccione un rango de fechas y presione "Consultar"\npara obtener los reportes de disciplina',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void populateGrid(List<dynamic> data) {
    for (var item in data) {
      plutoRows.add(TrinaRow(cells: {
        'studentId':
            TrinaCell(value: item['Matricula']?.toString().trim() ?? ''),
        'cycle': TrinaCell(value: item['ClaCiclo']?.toString().trim() ?? ''),
        'student': TrinaCell(value: item['Alumno']?.toString().trim() ?? ''),
        'campus': TrinaCell(value: item['claun']?.toString().trim() ?? ''),
        'academicLevel':
            TrinaCell(value: item['NomGradoEscolar']?.toString().trim() ?? ''),
        'group': TrinaCell(value: item['Grupo'] ?? ''),
        'total': TrinaCell(value: item['Reportes'] ?? 0),
        'minors': TrinaCell(value: item['Menores'] ?? 0),
        'mayors': TrinaCell(value: item['Mayores'] ?? 0),
        'notif1': TrinaCell(value: item['Notif1'] ?? 0),
        'notif2': TrinaCell(value: item['Notif2'] ?? 0),
        'notif3': TrinaCell(value: item['Notif3'] ?? 0)
      }));
    }
  }

  Future<void> handleRefresh(
      String cycle, DateTime initialDate, DateTime finalDate) async {
    try {
      await getStudentsDisciplinaryReportsByDates(
              cycle,
              "${initialDate.year}${initialDate.month.toString().padLeft(2, '0')}${initialDate.day.toString().padLeft(2, '0')}",
              "${finalDate.year}${finalDate.month.toString().padLeft(2, '0')}${finalDate.day.toString().padLeft(2, '0')}")
          .then((value) {
        setState(() {
          plutoRows.clear();
          populateGrid(value);
          apiResponse = value;
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> exportTrinaGridToCsv(BuildContext context) async {
    if (plutoRows.isEmpty) {
      showErrorFromBackend(context, "No hay datos para exportar.");
      return;
    }

    // Prepare CSV data
    List<List<dynamic>> csvData = [];

    // Add headers
    csvData.add(columns.map((col) => col.title).toList());

    // Add rows
    for (var row in plutoRows) {
      csvData.add(
          columns.map((col) => row.cells[col.field]?.value ?? '').toList());
    }

    String csv = const ListToCsvConverter().convert(csvData);

    // Let user pick the save location
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar archivo CSV',
      fileName: 'reporteDisciplina.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(csv, encoding: utf8);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Archivo CSV guardado exitosamente en $outputFile',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void getStudentDisciplinaryDetails(
      String initialDate, String finalDate, String cycle) {}
}
