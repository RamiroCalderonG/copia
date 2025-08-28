import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/data/DataTransferObjects/AttendanceHistory.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:convert';

class UserAttendanceHistoryScreen extends StatefulWidget {
  const UserAttendanceHistoryScreen({super.key});

  @override
  State<UserAttendanceHistoryScreen> createState() =>
      _UserAttendanceHistoryScreenState();
}

class _UserAttendanceHistoryScreenState
    extends State<UserAttendanceHistoryScreen> {
  List<TrinaRow> attendanceRows = [];
  List<AttendanceHistory> attendanceData = [];
  final TextEditingController initialDateController = TextEditingController();
  final TextEditingController finalDateController = TextEditingController();
  DateTime? initialDateTime;
  DateTime? finalDateTime;
  DateTime? _selectedDate;
  bool isLoading = false;
  TrinaGridStateManager? _stateManager;
  int pageSize = 25; // Default page size for pagination

  final List<TrinaColumn> columns = [
    TrinaColumn(
      title: "Empleado",
      field: "employee",
      type: TrinaColumnType.text(),
      readOnly: true,
      width: 200,
    ),
    TrinaColumn(
      title: "No. Empleado",
      field: "employeeNumber",
      type: TrinaColumnType.text(),
      readOnly: true,
      width: 120,
    ),
    TrinaColumn(
      title: "Fecha",
      field: "date",
      type: TrinaColumnType.dateTime(
        format: 'yyyy-MM-dd HH:mm:ss',
      ),
      readOnly: true,
      width: 120,
    ),
    TrinaColumn(
      title: "Día",
      field: "day",
      type: TrinaColumnType.text(),
      readOnly: true,
      width: 100,
    ),
    TrinaColumn(
      title: "Ubicación",
      field: "where",
      type: TrinaColumnType.text(),
      readOnly: true,
      width: 150,
    ),
    TrinaColumn(
      title: "Registro",
      field: "record",
      type: TrinaColumnType.number(
        format: '#,##0', // Format for numbers with commas
        negative: false,
      ),
      readOnly: true,
      width: 100,
    ),
    TrinaColumn(
      title: "Origen",
      field: "origin",
      type: TrinaColumnType.text(),
      readOnly: true,
      hide: true,
      width: 100,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    initialDateController.dispose();
    finalDateController.dispose();
    attendanceRows.clear();
    attendanceData.clear();
    super.dispose();
  }

  Future<void> fetchAttendanceHistory() async {
    if (initialDateTime == null || finalDateTime == null) {
      showErrorFromBackend(context, "Por favor, seleccione ambas fechas");
      return;
    }

    if (initialDateTime!.isAfter(finalDateTime!)) {
      showErrorFromBackend(
          context, "La fecha inicial no puede ser mayor que la final");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Format dates to YYYYMMDD format as required by the backend
      String formattedInitialDate =
          "${initialDateTime!.year}${initialDateTime!.month.toString().padLeft(2, '0')}${initialDateTime!.day.toString().padLeft(2, '0')}";
      String formattedFinalDate =
          "${finalDateTime!.year}${finalDateTime!.month.toString().padLeft(2, '0')}${finalDateTime!.day.toString().padLeft(2, '0')}";

      var response = await getUserAttendanceHistoryByDates(
          formattedInitialDate, formattedFinalDate);

      setState(() {
        attendanceData.clear();
        attendanceRows.clear();

        if (response is List) {
          for (var item in response) {
            AttendanceHistory attendance = item is AttendanceHistory
                ? item
                : AttendanceHistory.fromJson(item);
            attendanceData.add(attendance);

            attendanceRows.add(TrinaRow(cells: {
              'employee': TrinaCell(value: attendance.employee),
              'employeeNumber': TrinaCell(value: attendance.employeeNumber),
              'date': TrinaCell(value: attendance.date),
              'day': TrinaCell(value: attendance.day),
              'where': TrinaCell(value: attendance.where),
              'record': TrinaCell(value: attendance.record),
              'origin':
                  TrinaCell(value: attendance.origin == true ? 'Sí' : 'No'),
            }));
          }
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorFromBackend(context,
          "Error al obtener el historial de asistencia: ${e.toString()}");
      insertErrorLog(e.toString(), 'fetchAttendanceHistory()');
    }
  }

  void _copySelectedCells() {
    if (_stateManager == null) return;

    String textToCopy = '';

    // Check if there are selected rows
    if (_stateManager!.currentSelectingRows.isNotEmpty) {
      // Copy selected rows (includes header for better Excel compatibility)
      List<String> headerValues = [];
      for (var column in columns) {
        if (!column.hide) {
          headerValues.add(column.title);
        }
      }

      List<String> rowTexts = [headerValues.join('\t')]; // Add header row

      for (var row in _stateManager!.currentSelectingRows) {
        List<String> cellValues = [];
        for (var column in columns) {
          if (!column.hide) {
            cellValues.add(row.cells[column.field]?.value.toString() ?? '');
          }
        }
        rowTexts.add(cellValues.join('\t'));
      }
      textToCopy = rowTexts.join('\n');
    } else if (_stateManager!.currentCell != null) {
      // Copy current cell if no rows are selected
      textToCopy = _stateManager!.currentCell!.value.toString();
    }

    if (textToCopy.isNotEmpty) {
      // Copy to clipboard
      Clipboard.setData(ClipboardData(text: textToCopy));

      // Show feedback to user
      int selectedCount = _stateManager!.currentSelectingRows.length;
      String message = selectedCount > 0
          ? 'Datos copiados al portapapeles ($selectedCount filas)'
          : 'Celda copiada al portapapeles';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _copyAllData() {
    if (attendanceData.isEmpty) return;

    // Create header row
    List<String> headerValues = [];
    for (var column in columns) {
      if (!column.hide) {
        headerValues.add(column.title);
      }
    }

    List<String> allRows = [headerValues.join('\t')]; // Add header

    // Add all data rows
    for (var attendance in attendanceData) {
      List<String> cellValues = [];
      for (var column in columns) {
        if (!column.hide) {
          String value = '';
          switch (column.field) {
            case 'employee':
              value = attendance.employee ?? '';
              break;
            case 'employeeNumber':
              value = attendance.employeeNumber ?? '';
              break;
            case 'date':
              value = attendance.date ?? '';
              break;
            case 'day':
              value = attendance.day ?? '';
              break;
            case 'where':
              value = attendance.where ?? '';
              break;
            case 'record':
              value = attendance.record?.toString() ?? '';
              break;
            case 'origin':
              value = (attendance.origin ?? false) ? 'Sí' : 'No';
              break;
          }
          cellValues.add(value);
        }
      }
      allRows.add(cellValues.join('\t'));
    }

    String textToCopy = allRows.join('\n');

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: textToCopy));

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Todos los datos copiados al portapapeles (${attendanceData.length} registros)'),
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _exportToExcel() async {
    if (attendanceData.isEmpty) {
      showErrorFromBackend(context, "No hay datos para exportar");
      return;
    }

    try {
      // Create header row
      List<String> headerValues = [];
      for (var column in columns) {
        if (!column.hide) {
          headerValues.add(column.title);
        }
      }

      // Create data rows
      List<List<String>> csvData = [headerValues];

      for (var attendance in attendanceData) {
        List<String> rowData = [];
        for (var column in columns) {
          if (!column.hide) {
            String value = '';
            switch (column.field) {
              case 'employee':
                value = attendance.employee ?? '';
                break;
              case 'employeeNumber':
                value = attendance.employeeNumber ?? '';
                break;
              case 'date':
                value = attendance.date ?? '';
                break;
              case 'day':
                value = attendance.day ?? '';
                break;
              case 'where':
                value = attendance.where ?? '';
                break;
              case 'record':
                value = attendance.record?.toString() ?? '';
                break;
              case 'origin':
                value = (attendance.origin ?? false) ? 'Sí' : 'No';
                break;
            }
            rowData.add(value);
          }
        }
        csvData.add(rowData);
      }

      // Convert to CSV format
      String csvContent = const ListToCsvConverter().convert(csvData);

      // Convert to bytes
      Uint8List bytes = Uint8List.fromList(utf8.encode(csvContent));

      // Generate default filename with current date
      String dateRange = '';
      if (initialDateTime != null && finalDateTime != null) {
        dateRange =
            '_${initialDateTime!.year}${initialDateTime!.month.toString().padLeft(2, '0')}${initialDateTime!.day.toString().padLeft(2, '0')}_${finalDateTime!.year}${finalDateTime!.month.toString().padLeft(2, '0')}${finalDateTime!.day.toString().padLeft(2, '0')}';
      }
      String defaultFileName = 'historial_asistencia$dateRange';

      // Save file with dialog (allows user to choose location and filename)
      await FileSaver.instance.saveAs(
        name: defaultFileName,
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '👍Archivo exportado exitosamente',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar archivo: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      insertErrorLog(e.toString(), '_exportToExcel()');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Asistencia'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: FlutterFlowTheme.of(context).primaryText,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Panel
            _buildFilterPanel(theme, isSmallScreen),
            const SizedBox(height: 16),

            // Data Grid Section
            Expanded(
              child: _buildDataSection(theme),
            ),
          ],
        ),
      ),
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
          // Page size selector
          Row(
            children: [
              Icon(
                Icons.view_list,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Registros por página:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: pageSize,
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 25, child: Text('25')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                  DropdownMenuItem(value: 100, child: Text('100')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      pageSize = value;
                    });
                    // Update page size if grid is already loaded
                    if (_stateManager != null) {
                      _stateManager!.setPageSize(pageSize);
                    }
                  }
                },
                style: theme.textTheme.bodyMedium,
                underline: Container(
                  height: 1,
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  flex: 1,
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
              'Fecha Inicial', initialDateController, theme, true),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              _buildDateField('Fecha Final', finalDateController, theme, false),
        ),
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
              lastDate: DateTime.now(),
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
        // Copy selected button
        ElevatedButton.icon(
          onPressed: attendanceRows.isNotEmpty ? _copySelectedCells : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copiar'),
        ),
        // Copy all button
        ElevatedButton.icon(
          onPressed: attendanceData.isNotEmpty ? _copyAllData : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.select_all, size: 18),
          label: const Text('Copiar Todo'),
        ),
        // Export to Excel button
        ElevatedButton.icon(
          onPressed: attendanceData.isNotEmpty ? _exportToExcel : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.file_download, size: 18),
          label: const Text('Exportar'),
        ),
        // Search button
        ElevatedButton.icon(
          onPressed: isLoading ? null : fetchAttendanceHistory,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary),
                  ),
                )
              : const Icon(Icons.search),
          label: Text(isLoading ? 'Cargando...' : 'Consultar'),
        ),
      ],
    );
  }

  Widget _buildDataSection(ThemeData theme) {
    if (attendanceRows.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos de asistencia',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seleccione un rango de fechas y presione "Consultar". Use los controles de paginación para navegar entre páginas. Use Ctrl+C, "Copiar" para filas seleccionadas, "Copiar Todo" para todos los datos, o "Exportar" para descargar como archivo CSV.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CustomLoadingIndicator());
    }

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              // Handle Ctrl+C for copy
              if (event.logicalKey == LogicalKeyboardKey.keyC &&
                  (HardwareKeyboard.instance.logicalKeysPressed
                          .contains(LogicalKeyboardKey.controlLeft) ||
                      HardwareKeyboard.instance.logicalKeysPressed
                          .contains(LogicalKeyboardKey.controlRight))) {
                _copySelectedCells();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: TrinaGrid(
            mode: TrinaGridMode.readOnly,
            columns: columns,
            rows: attendanceRows,
            configuration: const TrinaGridConfiguration(
              style: TrinaGridStyleConfig(
                enableColumnBorderVertical: false,
                enableCellBorderVertical: false,
              ),
            ),
            onLoaded: (event) {
              _stateManager = event.stateManager;
              // Enable column filters
              event.stateManager.setShowColumnFilter(true);
              // Enable row selection for copy operations
              event.stateManager.setSelectingMode(TrinaGridSelectingMode.row);
              // Set page size for lazy pagination
              event.stateManager.setPageSize(pageSize, notify: false);
            },
            createFooter: (stateManager) {
              // Create pagination footer
              return TrinaPagination(stateManager);
            },
          ),
        ),
      ),
    );
  }
}
