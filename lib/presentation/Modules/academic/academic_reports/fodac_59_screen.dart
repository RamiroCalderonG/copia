import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_saver/file_saver.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/core/utils/searchable_drop_down.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:trina_grid/trina_grid.dart';

class Fodac59Screen extends StatefulWidget {
  const Fodac59Screen({super.key});

  @override
  State<Fodac59Screen> createState() => _Fodac59ScreenState();
}

class _Fodac59ScreenState extends State<Fodac59Screen>
    with SingleTickerProviderStateMixin {
  bool? includeDeactivatedStudent = false;
  bool? includeValidation = false;
  String? selectedGrade;
  String? selectedGroup;
  String? selectedStudent;
  String? selectedStudentId; // Add selectedStudentId to track the ID
  String? selectedMonth;
  String? selectedCampus;
  List<String> studentsList = [];
  List<String> gradesList = [];
  List<String> groupsList = [];
  List<int> gradeSeqList = [];
  List<dynamic> _rawData = []; // Store the original response
  List<String> _filteredGroups = []; // For filtered groups
  List<String> _filteredStudents = []; // For filtered students
  Map<String, String> _studentNameToIdMap = {}; // Map student names to IDs
  Map<String, String> _filteredStudentNameToIdMap =
      {}; // Map for filtered students
  List<dynamic> _reportData = []; // Store the report response data
  Future<dynamic>? _reportFuture; // Future for report data loading

  Future<dynamic>? future;

  bool isExporting = false;
  String exportStatus = '';
  // PDF specific options
  String pdfTitle = 'FO-DAC-59';
  String pdfCreator = '${currentUser!.userEmail}';
  bool pdfLandscape = false;
  Color headerColor = Colors.blue;
  Color textColor = Colors.black;

  static const String formatCsv = 'csv';
  static const String formatJson = 'json';
  static const String formatPdf = 'pdf';

  final Map<String, bool> selectedColumns = {};
  bool includeHeaders = true;
  bool ignoreFixedRows = false;
  String csvSeparator = ',';
  bool showColumnSelection = false;

  late AnimationController _controller;
  bool _isFilterExpanded = false;
  bool _isRefreshing = false; // Add loading state for refresh button
  bool _isLoadingFilters = false; // Add loading state for filter fetching
  late TrinaGridStateManager _gridStateManager; // Add TrinaGrid state manager

  @override
  void initState() {
    // Don't fetch initial data, just initialize the controller
    future = null; // Initialize as null
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    future = null;
    _reportFuture = null;
    _reportData.clear();
    super.dispose();
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
      if (_isFilterExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 900;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FO-DAC-59 Kinder'),
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: FlutterFlowTheme.of(context).info,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton.filled(
              icon: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _controller,
                color: _isFilterExpanded
                    ? FlutterFlowTheme.of(context).secondary
                    : FlutterFlowTheme.of(context).alternate,
              ),
              onPressed: _toggleFilterPanel,
              tooltip: 'Filtros',
              style: IconButton.styleFrom(
                backgroundColor: _isFilterExpanded
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.primaryContainer.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
      body: future != null
          ? FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CustomLoadingIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 60,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar datos',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intente de nuevo más tarde',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        // FilledButton.icon(
                        //   onPressed: () {
                        //     if (selectedCampus != null) {
                        //       setState(() {
                        //         // future = fetchFiltersData(
                        //         //     selectedCampus!, currentCycle!.claCiclo!);
                        //       });
                        //     }
                        //   },
                        //   icon: const Icon(Icons.refresh),
                        //   label: const Text('Reintentar'),
                        // ),
                      ],
                    ),
                  );
                }

                return _buildMainContent(isSmallScreen, theme);
              },
            )
          : _reportFuture != null
              ? FutureBuilder(
                  future: _reportFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildMainContentWithLoading(isSmallScreen, theme);
                    }

                    if (snapshot.hasError) {
                      return _buildMainContentWithError(isSmallScreen, theme);
                    }

                    return _buildMainContent(isSmallScreen, theme);
                  },
                )
              : _buildMainContent(isSmallScreen, theme),
      // floatingActionButton: _reportData.isNotEmpty
      //     ? FloatingActionButton(
      //         onPressed: () => _showExportOptionsDialog(),
      //         backgroundColor: theme.colorScheme.primaryContainer,
      //         foregroundColor: theme.colorScheme.onPrimaryContainer,
      //         elevation: 4,
      //         child: const Icon(Icons.file_download),
      //       )
      //     : null,
    );
  }

  Widget _buildFilterPanel(bool isSmallScreen, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main filter content
          isSmallScreen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSectionTitle('Configuración de Reporte', theme),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        _buildFilterChip(
                          'Incluir Bajas',
                          includeDeactivatedStudent ?? false,
                          (value) {
                            setState(() {
                              includeDeactivatedStudent = value;
                            });
                          },
                          theme,
                          icon: Icons.person_off_outlined,
                        ),
                        _buildFilterChip(
                          'No Validar',
                          includeValidation ?? false,
                          (value) {
                            setState(() {
                              includeValidation = value;
                            });
                          },
                          theme,
                          icon: Icons.verified_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFilterSectionTitle('Filtros', theme),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildFilterDropdown(
                          'Grado',
                          gradesList,
                          selectedGrade,
                          gradesList.isEmpty
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedGrade = value;
                                    _populateGroupsByGrade(value);
                                  });
                                },
                          theme,
                          icon: Icons.school,
                          isEnabled:
                              gradesList.isNotEmpty && !_isLoadingFilters,
                        ),
                        _buildFilterDropdown(
                          'Grupo',
                          _filteredGroups.isNotEmpty
                              ? _filteredGroups
                              : (selectedGrade != null ? [] : groupsList),
                          selectedGroup,
                          gradesList.isEmpty
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedGroup = value;
                                    _filterStudentsByGradeAndGroup(
                                        selectedGrade, value);
                                  });
                                },
                          theme,
                          icon: Icons.group,
                          isEnabled:
                              gradesList.isNotEmpty && !_isLoadingFilters,
                          key: ValueKey(
                              'grupo_mobile_${selectedGrade ?? 'none'}'),
                        ),
                        _buildMonthFilterDropdown(theme),
                        _buildCampusSelector(theme),
                        _buildFilterDropdown(
                          'Alumno',
                          _filteredStudents.isNotEmpty
                              ? _filteredStudents
                              : (selectedGrade != null && selectedGroup != null
                                  ? []
                                  : studentsList),
                          selectedStudent,
                          gradesList.isEmpty
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedStudent = value;
                                    // Set the corresponding studentId
                                    if (value != null) {
                                      selectedStudentId = _filteredStudents
                                              .isNotEmpty
                                          ? _filteredStudentNameToIdMap[value]
                                          : _studentNameToIdMap[value];
                                      print(
                                          'Selected student: $value, ID: $selectedStudentId');
                                    } else {
                                      selectedStudentId = null;
                                      print('Student selection cleared');
                                    }
                                  });
                                },
                          theme,
                          icon: Icons.person,
                          isEnabled:
                              gradesList.isNotEmpty && !_isLoadingFilters,
                          key: ValueKey(
                              'alumno_mobile_${selectedGroup ?? 'none'}'),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSectionTitle('Filtros y Configuración', theme),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            _buildFilterChip(
                              'Incluir Bajas',
                              includeDeactivatedStudent ?? false,
                              (value) {
                                setState(() {
                                  includeDeactivatedStudent = value;
                                });
                              },
                              theme,
                              icon: Icons.person_off_outlined,
                            ),
                            const SizedBox(height: 10),
                            _buildFilterChip(
                              'No Validar',
                              includeValidation ?? false,
                              (value) {
                                setState(() {
                                  includeValidation = value;
                                });
                              },
                              theme,
                              icon: Icons.verified_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  _buildMonthFilterDropdown(theme),
                                  _buildCampusSelector(theme)
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFilterDropdown(
                                  'Grado',
                                  gradesList,
                                  selectedGrade,
                                  gradesList.isEmpty
                                      ? null
                                      : (value) {
                                          setState(() {
                                            selectedGrade = value;
                                            _populateGroupsByGrade(value);
                                          });
                                        },
                                  theme,
                                  icon: Icons.school,
                                  isEnabled: gradesList.isNotEmpty &&
                                      !_isLoadingFilters,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFilterDropdown(
                                  'Grupo',
                                  _filteredGroups.isNotEmpty
                                      ? _filteredGroups
                                      : (selectedGrade != null
                                          ? []
                                          : groupsList),
                                  selectedGroup,
                                  gradesList.isEmpty
                                      ? null
                                      : (value) {
                                          setState(() {
                                            selectedGroup = value;
                                            _filterStudentsByGradeAndGroup(
                                                selectedGrade, value);
                                          });
                                        },
                                  theme,
                                  icon: Icons.group,
                                  isEnabled: gradesList.isNotEmpty &&
                                      !_isLoadingFilters,
                                  key: ValueKey(
                                      'grupo_desktop_${selectedGrade ?? 'none'}'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFilterDropdown(
                                  'Alumno',
                                  _filteredStudents.isNotEmpty
                                      ? _filteredStudents
                                      : (selectedGrade != null &&
                                              selectedGroup != null
                                          ? []
                                          : studentsList),
                                  selectedStudent,
                                  gradesList.isEmpty
                                      ? null
                                      : (value) {
                                          setState(() {
                                            selectedStudent = value;
                                            // Set the corresponding studentId
                                            if (value != null) {
                                              selectedStudentId = _filteredStudents
                                                      .isNotEmpty
                                                  ? _filteredStudentNameToIdMap[
                                                      value]
                                                  : _studentNameToIdMap[value];
                                              print(
                                                  'Selected student: $value, ID: $selectedStudentId');
                                            } else {
                                              selectedStudentId = null;
                                              print(
                                                  'Student selection cleared');
                                            }
                                          });
                                        },
                                  theme,
                                  icon: Icons.person,
                                  isEnabled: gradesList.isNotEmpty &&
                                      !_isLoadingFilters,
                                  key: ValueKey(
                                      'alumno_desktop_${selectedGroup ?? 'none'}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          // Loading overlay
          if (_isLoadingFilters)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CustomLoadingIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        'Cargando filtros...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontFamily: 'Sora',
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

  Widget _buildMainContent(bool isSmallScreen, ThemeData theme) {
    return Column(
      children: [
        // Filter Panel
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isFilterExpanded ? (isSmallScreen ? 280 : 210) : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: _buildFilterPanel(isSmallScreen, theme),
          ),
        ),

        // Content Area
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reporte FO-DAC-59',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 4),
                            IconButton(
                              icon: _isRefreshing
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme
                                            .colorScheme.onSecondaryContainer,
                                      ),
                                    )
                                  : Icon(
                                      Icons.refresh,
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                    ),
                              onPressed: _canGenerateReport() && !_isRefreshing
                                  ? () async {
                                      setState(() {
                                        _isRefreshing = true;
                                      });
                                      try {
                                        setState(() {
                                          _reportFuture = fetchReportData();
                                        });
                                        await _reportFuture;
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isRefreshing = false;
                                          });
                                        }
                                      }
                                    }
                                  : null,
                              tooltip: _canGenerateReport()
                                  ? (_isRefreshing
                                      ? 'Generando...'
                                      : 'Generar reporte')
                                  : 'Seleccione Grado y Grupo primero',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                Icons.file_download,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              onPressed: _reportData.isNotEmpty
                                  ? () => _showExportOptionsDialog()
                                  : null,
                              tooltip: 'Exportar',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                Icons.print,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              onPressed: _reportData.isNotEmpty
                                  ? () => _printReport()
                                  : null,
                              tooltip: 'Imprimir',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Current Filter Summary
                _buildFilterSummary(theme),

                const SizedBox(height: 16),

                // Data Table Section
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _buildDataTable(theme),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContentWithLoading(bool isSmallScreen, ThemeData theme) {
    return Column(
      children: [
        // Filter Panel
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isFilterExpanded ? (isSmallScreen ? 280 : 210) : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: _buildFilterPanel(isSmallScreen, theme),
          ),
        ),

        // Content Area with Loading
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title and Actions
                _buildSectionHeader(theme),
                const SizedBox(height: 16),
                // Current Filter Summary
                _buildFilterSummary(theme),
                const SizedBox(height: 16),
                // Loading indicator for report data
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomLoadingIndicator(),
                          SizedBox(height: 16),
                          Text('Generando reporte...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContentWithError(bool isSmallScreen, ThemeData theme) {
    return Column(
      children: [
        // Filter Panel
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isFilterExpanded ? (isSmallScreen ? 280 : 210) : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: _buildFilterPanel(isSmallScreen, theme),
          ),
        ),

        // Content Area with Error
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title and Actions
                _buildSectionHeader(theme),
                const SizedBox(height: 16),
                // Current Filter Summary
                _buildFilterSummary(theme),
                const SizedBox(height: 16),
                // Error message
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al generar el reporte',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intente de nuevo más tarde',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reporte FO-DAC-59',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            Card(
              elevation: 0,
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.refresh,
                    //     color: theme.colorScheme.onSecondaryContainer,
                    //   ),
                    //   onPressed: selectedCampus != null
                    //       ? () {
                    //           setState(() {
                    //             // future = fetchFiltersData(
                    //             //     selectedCampus!, currentCycle!.claCiclo!);
                    //           });
                    //         }
                    //       : null,
                    //   tooltip: selectedCampus == null
                    //       ? 'Seleccione un campus primero'
                    //       : 'Refrescar filtros',
                    // ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: _isRefreshing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            )
                          : Icon(
                              Icons.refresh,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                      onPressed: _canGenerateReport() && !_isRefreshing
                          ? () async {
                              setState(() {
                                _isRefreshing = true;
                              });
                              try {
                                setState(() {
                                  _reportFuture = fetchReportData();
                                });
                                await _reportFuture;
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isRefreshing = false;
                                  });
                                }
                              }
                            }
                          : null,
                      tooltip: _canGenerateReport()
                          ? (_isRefreshing ? 'Generando...' : 'Generar reporte')
                          : 'Seleccione Grado y Grupo primero',
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      onPressed: _reportData.isNotEmpty
                          ? () => _showExportOptionsDialog()
                          : null,
                      tooltip: 'Exportar a Excel',
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.print,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      onPressed:
                          _reportData.isNotEmpty ? () => _printReport() : null,
                      tooltip: 'Imprimir',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Export status indicator
        if (isExporting || exportStatus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isExporting)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (isExporting) const SizedBox(width: 8),
                Text(
                  exportStatus,
                  style: TextStyle(
                    color: exportStatus.contains('Error')
                        ? Colors.red
                        : exportStatus.contains('exitosamente')
                            ? Colors.green
                            : theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool selected,
    Function(bool?) onChanged,
    ThemeData theme, {
    IconData? icon,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: selected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onChanged,
      showCheckmark: true,
      checkmarkColor: theme.colorScheme.onSecondaryContainer,
      selectedColor: theme.colorScheme.secondaryContainer,
      backgroundColor: theme.colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?)? onChanged,
    ThemeData theme, {
    IconData? icon,
    bool isEnabled = true,
    Key? key,
  }) {
    return SizedBox(
      key: key,
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEnabled
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: isEnabled
                  ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                  : theme.colorScheme.surfaceVariant.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isEnabled
                    ? theme.colorScheme.outline.withOpacity(0.5)
                    : theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: isEnabled
                ? SearchableDropdown(
                    items: items,
                    label: label,
                    // value: value,
                    onSelected: onChanged ?? (_) {},
                    hint: '$label...',
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.4),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Presione refrescar primero',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.4),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthFilterDropdown(ThemeData theme) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Al mes de',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedMonth,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: InputBorder.none,
                isDense: true,
              ),
              items: months.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: _isLoadingFilters
                  ? null
                  : (String? value) {
                      setState(() {
                        selectedMonth = value;
                      });
                    },
              icon: Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              isExpanded: true,
              hint: Text(
                'Seleccionar mes...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              dropdownColor: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusSelector(ThemeData theme) {
    final campus = ['ANAHUAC', 'BARRAGAN', 'CONCORDIA', 'SENDERO'];
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.holiday_village_sharp,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Campus',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: DropdownButtonFormField<String>(
              // Fix: Change from selectedMonth to selectedCampus
              value: selectedCampus,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: InputBorder.none,
                isDense: true,
              ),
              items: campus.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: _isLoadingFilters
                  ? null
                  : (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedCampus = value;
                          // Add null checks for currentCycle
                          if (currentCycle != null &&
                              currentCycle!.claCiclo != null) {
                            future = fetchFiltersData(
                                value, currentCycle!.claCiclo!);
                          } else {
                            _showErrorNotification(
                                'Error: Ciclo escolar no disponible.');
                          }
                        });
                      }
                    },
              icon: Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              isExpanded: true,
              hint: Text(
                'Seleccionar campus...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              dropdownColor: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtros aplicados',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (selectedGrade != null)
                _buildFilterTag('Grado: $selectedGrade', theme, Icons.school),
              if (selectedGroup != null)
                _buildFilterTag('Grupo: $selectedGroup', theme, Icons.group),
              if (selectedMonth != null)
                _buildFilterTag(
                    'Mes: $selectedMonth', theme, Icons.calendar_month),
              if (selectedStudent != null)
                _buildFilterTag(
                    'Alumno: $selectedStudent', theme, Icons.person),
              if (includeDeactivatedStudent == true)
                _buildFilterTag(
                    'Incluyendo bajas', theme, Icons.person_off_outlined),
              if (includeValidation == true)
                _buildFilterTag('Sin validar', theme, Icons.verified_outlined),
              if (selectedGrade == null &&
                  selectedGroup == null &&
                  selectedMonth == null &&
                  selectedStudent == null &&
                  includeDeactivatedStudent != true &&
                  includeValidation != true)
                Text(
                  'No hay filtros aplicados',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTag(String text, ThemeData theme, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme) {
    // If we have report data, display it with TrinaGrid
    if (_reportData.isNotEmpty) {
      // Define columns for TrinaGrid
      final List<TrinaColumn> columns = [
        TrinaColumn(
          title: 'Clamateria',
          field: 'Clamateria',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 100,
        ),
        TrinaColumn(
          title: 'Mes',
          field: 'Mes',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 80,
        ),
        TrinaColumn(
          title: 'Orden',
          field: 'Orden',
          type: TrinaColumnType.number(),
          readOnly: true,
          width: 80,
        ),
        TrinaColumn(
          title: 'NomGrado',
          field: 'NomGrado',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 120,
        ),
        TrinaColumn(
          title: 'Valor',
          field: 'Valor',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 80,
        ),
        TrinaColumn(
          title: 'Tipo',
          field: 'Tipo',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 80,
        ),
        TrinaColumn(
          title: 'Gp',
          field: 'Gp',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 60,
        ),
        TrinaColumn(
          title: 'PromedioSiNo',
          field: 'PromedioSiNo',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 120,
        ),
        TrinaColumn(
          title: 'Nombre',
          field: 'Nombre',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 200,
        ),
        TrinaColumn(
          title: 'Matricula',
          field: 'Matricula',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 120,
        ),
        TrinaColumn(
          title: 'Grupo',
          field: 'Grupo',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 80,
        ),
        TrinaColumn(
          title: 'ClaCiclo',
          field: 'ClaCiclo',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 100,
        ),
        TrinaColumn(
          title: 'GradoSecuencia',
          field: 'GradoSecuencia',
          type: TrinaColumnType.number(),
          readOnly: true,
          width: 120,
        ),
        TrinaColumn(
          title: 'ClaUN',
          field: 'ClaUN',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 80,
        ),
        TrinaColumn(
          title: 'NomMateria',
          field: 'NomMateria',
          type: TrinaColumnType.text(),
          readOnly: true,
          width: 200,
        ),
      ];

      // Convert data to TrinaRows
      final List<TrinaRow> rows = _reportData.map((item) {
        return TrinaRow(
          cells: {
            'Clamateria':
                TrinaCell(value: item['Clamateria']?.toString() ?? ''),
            'Mes': TrinaCell(value: item['Mes']?.toString() ?? ''),
            'Orden': TrinaCell(value: item['Orden'] ?? 0),
            'NomGrado': TrinaCell(value: item['NomGrado']?.toString() ?? ''),
            'Valor': TrinaCell(value: item['Valor']?.toString() ?? ''),
            'Tipo': TrinaCell(value: item['Tipo']?.toString() ?? ''),
            'Gp': TrinaCell(value: item['Gp']?.toString() ?? ''),
            'PromedioSiNo':
                TrinaCell(value: item['PromedioSiNo']?.toString() ?? ''),
            'Nombre': TrinaCell(value: item['Nombre']?.toString() ?? ''),
            'Matricula': TrinaCell(value: item['Matricula']?.toString() ?? ''),
            'Grupo': TrinaCell(value: item['Grupo']?.toString() ?? ''),
            'ClaCiclo': TrinaCell(value: item['ClaCiclo']?.toString() ?? ''),
            'GradoSecuencia': TrinaCell(value: item['GradoSecuencia'] ?? 0),
            'ClaUN': TrinaCell(value: item['ClaUN']?.toString() ?? ''),
            'NomMateria':
                TrinaCell(value: item['NomMateria']?.toString() ?? ''),
          },
        );
      }).toList();

      return TrinaGrid(
        columns: columns,
        rows: rows,
        mode: TrinaGridMode.readOnly,
        onLoaded: (TrinaGridOnLoadedEvent event) {
          _gridStateManager = event.stateManager;
          _gridStateManager.setShowColumnFilter(true);
        },
        configuration: TrinaGridConfiguration(
          style: TrinaGridStyleConfig(
            borderColor: theme.colorScheme.outlineVariant,
            gridBorderColor: theme.colorScheme.outlineVariant,
            enableColumnBorderVertical: false,
            enableCellBorderVertical: false,
            cellColorInReadOnlyState: theme.colorScheme.surface,
          ),
          columnSize: const TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.scale,
          ),
          scrollbar: const TrinaGridScrollbarConfig(
            isAlwaysShown: true,
          ),
        ),
        createFooter: (stateManager) {
          stateManager.setPageSize(25, notify: false);
          return Container(
            decoration: BoxDecoration(
              // color: theme.colorScheme.surfaceContainerHigh,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: TrinaPagination(stateManager),
          );
        },
      );
    }

    // Show different messages based on state
    if (selectedCampus == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.holiday_village_sharp,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Seleccione un campus',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Debe seleccionar un campus antes de continuar',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (gradesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Presione el botón refrescar',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Para cargar los datos y habilitar los filtros',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (selectedGrade == null || selectedGroup == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Seleccione Grado y Grupo',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Luego presione "Generar reporte" para ver los datos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Show message to generate report
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Presione "Generar reporte"',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Para obtener los datos del reporte con los filtros seleccionados',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> fetchFiltersData(String campus, String cycle) async {
    print('fetchFiltersData called with campus: $campus, cycle: $cycle');
    print('currentUser: $currentUser');
    print('currentCycle: $currentCycle');

    // Set loading state
    setState(() {
      _isLoadingFilters = true;
      _reportData.clear();
    });

    try {
      // Validate required parameters
      if (campus.trim().isEmpty || cycle.trim().isEmpty) {
        _showErrorNotification('Campus y ciclo son requeridos.');
        return null;
      }

      // Check if currentUser exists
      if (currentUser == null) {
        print('currentUser is null');
        _showErrorNotification('Usuario no autenticado.');
        return null;
      }

      // Check if user has access
      try {
        if (!currentUser!.hasAccesToEventById(30)) {
          _showErrorNotification('No tienes acceso para esta acción.');
          return null;
        }
      } catch (e) {
        print('Error checking user access: $e');
        _showErrorNotification('Error al verificar permisos de usuario.');
        return null;
      }

      // Initialize default values
      includeDeactivatedStudent ??= false;
      includeValidation ??= false;

      print('Calling getFodac59FiltersData...');

      // Fetch data from API
      final value = await getFodac59FiltersData(
          campus, cycle, includeDeactivatedStudent, includeValidation);

      print('API response received: ${value?.length ?? 0} items');

      if (value == null) {
        _showWarningNotification('No se recibió respuesta del servidor.');
        return null;
      }

      if (value.isEmpty) {
        _showWarningNotification(
            'No se encontraron datos para los filtros seleccionados.');
        return null;
      }

      // Process the response data
      Set<String> uniqueGrades = {};
      Set<String> uniqueGroups = {};
      Set<String> uniqueStudents = {};

      // Store the raw data for filtering later
      _rawData = List<dynamic>.from(value);
      _studentNameToIdMap.clear();
      gradeSeqList.clear(); // Clear existing data

      for (var element in value) {
        try {
          String studentName = element['student']?.toString() ?? '';
          String studentId = element['studentId']?.toString() ?? '';
          String grade = element['grade']?.toString() ?? '';
          String group = element['groupL']?.toString() ?? '';
          int seq = element['seq'] ?? 0;

          if (studentName.isNotEmpty) uniqueStudents.add(studentName);
          if (grade.isNotEmpty) uniqueGrades.add(grade);
          if (group.isNotEmpty) uniqueGroups.add(group);

          gradeSeqList.add(seq);

          // Build the student name to ID mapping
          if (studentName.isNotEmpty && studentId.isNotEmpty) {
            _studentNameToIdMap[studentName] = studentId;
          }
        } catch (e) {
          print('Error processing element: $element, Error: $e');
          // Continue processing other elements
          continue;
        }
      }

      print(
          'Processed data: ${uniqueGrades.length} grades, ${uniqueGroups.length} groups, ${uniqueStudents.length} students');

      // Update state with processed data
      setState(() {
        studentsList = uniqueStudents.toList();
        gradesList = uniqueGrades.toList();
        groupsList = uniqueGroups.toList();

        // Sort lists for better UI
        studentsList.sort();
        gradesList.sort();
        groupsList.sort();

        // Initialize with empty selections
        selectedGrade = null;
        selectedGroup = null;
        selectedStudent = null;
        selectedStudentId = null;

        // Initialize filtered lists and mappings
        _filteredGroups = [];
        _filteredStudents = [];
        _filteredStudentNameToIdMap.clear();
      });

      _showSuccessNotification('Filtros cargados exitosamente.');
      return value;
    } catch (e) {
      print('Error in fetchFiltersData: $e');
      print('Stack trace: ${StackTrace.current}');
      String errorMessage =
          'Error al obtener los datos. Inténtalo de nuevo más tarde.';

      // Provide more specific error messages based on the error type
      if (e.toString().contains('Bad state: No element')) {
        errorMessage =
            'Error: No se encontraron elementos en la respuesta del servidor.';
      } else if (e.toString().contains('Connection')) {
        errorMessage = 'Error de conexión. Verifica tu conexión a internet.';
      } else if (e.toString().contains('Timeout')) {
        errorMessage = 'Tiempo de espera agotado. Inténtalo de nuevo.';
      }

      _showErrorNotification(errorMessage);
      return null;
    } finally {
      // Always reset loading state
      setState(() {
        _isLoadingFilters = false;
      });
    }
  }

  void _showSuccessNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWarningNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _populateGroupsByGrade(String? grade) {
    if (grade == null || grade.isEmpty) {
      setState(() {
        _filteredGroups = [];
        selectedGroup = null;
        // Also clear students when grade is cleared
        _filteredStudents = [];
        _filteredStudentNameToIdMap.clear();
        selectedStudent = null;
        selectedStudentId = null;
      });
      return;
    }

    // Find all unique groups that match the selected grade
    Set<String> groups = {};
    for (var item in _rawData) {
      if (item['grade'] != null &&
          item['grade'].toString().trim() == grade.trim()) {
        if (item['groupL'] != null) {
          groups.add(item['groupL'].toString().trim());
        }
      }
    }

    setState(() {
      _filteredGroups.clear();
      _filteredGroups = groups.toList()..sort();
      // Reset group and student selections when grade changes
      selectedGroup = null;
      _filteredStudents = [];
      _filteredStudentNameToIdMap.clear();
      selectedStudent = null;
      selectedStudentId = null;
    });

    // Debug print to see what groups were found
    print('Grade: $grade, Groups found: $_filteredGroups');
  }

  void _filterStudentsByGradeAndGroup(String? grade, String? group) {
    if (grade == null || group == null) {
      setState(() {
        _filteredStudents = [];
        _filteredStudentNameToIdMap.clear();
        selectedStudent = null;
        selectedStudentId = null;
      });
      return;
    }

    // Find all students that match the selected grade and group
    Set<String> students = {};
    Map<String, String> studentMapping = {};

    for (var item in _rawData) {
      if (item['grade'].toString().trim() == grade.trim() &&
          item['groupL'].toString().trim() == group.trim()) {
        String studentName = item['student'].toString().trim();
        String studentId = item['studentId'] ?? '';
        students.add(studentName);
        studentMapping[studentName] = studentId;
      }
    }

    setState(() {
      _filteredStudents = students.toList()..sort();
      _filteredStudentNameToIdMap = studentMapping;
      selectedStudent = null; // Reset student selection
      selectedStudentId = null;
    });
  }

  Future<dynamic> fetchReportData() async {
    if (selectedCampus == null ||
        selectedGrade == null ||
        selectedGroup == null) {
      return null;
    }

    // Validate currentCycle
    if (currentCycle == null || currentCycle!.claCiclo == null) {
      _showErrorNotification('Error: Ciclo escolar no disponible.');
      return null;
    }

    try {
      includeDeactivatedStudent ??= false;
      includeValidation ??= false;

      // Call the getFodac59Response function with correct parameters
      // Get the gradeSeq for the selected grade
      int gradeSeq = _getGradeSeq(selectedGrade!);
      int monthIndex = _getMonthIndex(selectedMonth);

      String studentIdToSend;
      if (selectedStudent == null || selectedStudentId == null) {
        studentIdToSend = 'ND'; // Default value if no student is selected
        print('No student selected, sending: ND');
      } else {
        studentIdToSend = selectedStudentId!.trim();
        print(
            'Sending student ID: $studentIdToSend for student: $selectedStudent');
      }

      await getFodac59Response(
              currentCycle!.claCiclo!,
              selectedCampus!,
              gradeSeq,
              selectedGroup!,
              monthIndex,
              0,
              'NONAME', // computerName
              includeDeactivatedStudent ?? false,
              studentIdToSend) // Send studentId instead of student name
          .then((value) {
        if (value != null) {
          setState(() {
            _reportData = List<dynamic>.from(value);
          });
        }
        return value;
      }).onError((error, stackTrace) {
        print('Error fetching report data: $error');
        _showErrorNotification(
            'No se pudo obtener los datos del reporte. Inténtalo de nuevo más tarde.');
      });
    } catch (e) {
      print('Error in fetchReportData: $e');
      _showErrorNotification(
          'No se pudo obtener los datos del reporte. Inténtalo de nuevo más tarde.');
    }
  }

  bool _canGenerateReport() {
    // bool hasAcces = currentUser!.hasAccesToEventById(30);

    return selectedCampus != null &&
        selectedGrade != null &&
        selectedGroup != null &&
        gradesList.isNotEmpty;
  }

  int _getGradeSeq(String grade) {
    // Find the corresponding gradeSeq for the selected grade
    for (var item in _rawData) {
      if (item['grade']?.toString().trim() == grade.trim()) {
        return item['seq'] ?? 0;
      }
    }
    return 0; // Default fallback
  }

  int _getMonthIndex(String? month) {
    if (month == null) return DateTime.now().month;

    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    int index = months.indexOf(month);
    return index >= 0 ? index + 1 : DateTime.now().month;
  }

  List<String> _getAvailableColumns() {
    if (_reportData.isEmpty) return [];

    // Initialize column selection map if empty
    if (selectedColumns.isEmpty && _reportData.isNotEmpty) {
      final columns = [
        'Clamateria',
        'Mes',
        'Orden',
        'NomGrado',
        'Valor',
        'Tipo',
        'Gp',
        'PromedioSiNo',
        'Nombre',
        'Matricula',
        'Grupo',
        'ClaCiclo',
        'GradoSecuencia',
        'ClaUN',
        'NomMateria'
      ];
      for (var column in columns) {
        selectedColumns[column] = true;
      }
    }

    return [
      'Clamateria',
      'Mes',
      'Orden',
      'NomGrado',
      'Valor',
      'Tipo',
      'Gp',
      'PromedioSiNo',
      'Nombre',
      'Matricula',
      'Grupo',
      'ClaCiclo',
      'GradoSecuencia',
      'ClaUN',
      'NomMateria'
    ];
  }

  // Export functionality methods
  void _showExportOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Opciones de Exportación'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: const Text('Incluir encabezados'),
                        value: includeHeaders,
                        onChanged: (value) {
                          setDialogState(() {
                            includeHeaders = value ?? true;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Ignorar filas fijas/congeladas'),
                        value: ignoreFixedRows,
                        onChanged: (value) {
                          setDialogState(() {
                            ignoreFixedRows = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      const Text('Separador CSV:'),
                      Row(
                        children: [
                          Radio<String>(
                            value: ',',
                            groupValue: csvSeparator,
                            onChanged: (value) {
                              setDialogState(() {
                                csvSeparator = value!;
                              });
                            },
                          ),
                          const Text('Coma (,)'),
                          const SizedBox(width: 10),
                          Radio<String>(
                            value: ';',
                            groupValue: csvSeparator,
                            onChanged: (value) {
                              setDialogState(() {
                                csvSeparator = value!;
                              });
                            },
                          ),
                          const Text('Punto y coma (;)'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Seleccionar columnas a exportar:'),
                      const SizedBox(height: 8),

                      // Select/Deselect all buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                for (var key in selectedColumns.keys) {
                                  selectedColumns[key] = true;
                                }
                              });
                            },
                            child: const Text('Seleccionar Todo'),
                          ),
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                for (var key in selectedColumns.keys) {
                                  selectedColumns[key] = false;
                                }
                              });
                            },
                            child: const Text('Deseleccionar Todo'),
                          ),
                        ],
                      ),

                      // Column checkboxes
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          itemCount: _getAvailableColumns().length,
                          itemBuilder: (context, index) {
                            final column = _getAvailableColumns()[index];
                            return CheckboxListTile(
                              title: Text(column),
                              value: selectedColumns[column] ?? false,
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedColumns[column] = value ?? false;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Get selected columns
                    final List<String> columnsToExport = selectedColumns.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList();

                    // Close dialog
                    Navigator.of(context).pop();

                    // Show format selection
                    _showFormatSelectionDialog(columnsToExport);
                  },
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFormatSelectionDialog(List<String> selectedColumns) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Formato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('CSV'),
                subtitle: const Text('Archivo de valores separados por comas'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportGrid(formatCsv, selectedColumns: selectedColumns);
                },
              ),
              ListTile(
                leading: const Icon(Icons.code, color: Colors.blue),
                title: const Text('JSON'),
                subtitle:
                    const Text('Formato de intercambio de datos JavaScript'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportGrid(formatJson, selectedColumns: selectedColumns);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('PDF'),
                subtitle: const Text('Documento PDF imprimible'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPdfOptionsDialog(selectedColumns);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showPdfOptionsDialog(List<String> selectedColumns) {
    final titleController = TextEditingController(text: pdfTitle);
    final creatorController = TextEditingController(text: pdfCreator);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Opciones PDF'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Título del PDF',
                          border: OutlineInputBorder(),
                        ),
                        controller: titleController,
                        onChanged: (value) {
                          setDialogState(() {
                            pdfTitle = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Creador',
                          border: OutlineInputBorder(),
                        ),
                        controller: creatorController,
                        onChanged: (value) {
                          setDialogState(() {
                            pdfCreator = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Orientación horizontal'),
                        value: pdfLandscape,
                        onChanged: (value) {
                          setDialogState(() {
                            pdfLandscape = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      const Text('Colores del tema:'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Color del encabezado: '),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              final selectedColor =
                                  await _showColorPicker(context, headerColor);
                              if (selectedColor != null) {
                                setDialogState(() {
                                  headerColor = selectedColor;
                                });
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 24,
                              decoration: BoxDecoration(
                                color: headerColor,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Color del texto: '),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: () async {
                              final selectedColor =
                                  await _showColorPicker(context, textColor);
                              if (selectedColor != null) {
                                setDialogState(() {
                                  textColor = selectedColor;
                                });
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 24,
                              decoration: BoxDecoration(
                                color: textColor,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _exportGrid(formatPdf, selectedColumns: selectedColumns);
                  },
                  child: const Text('Generar PDF'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color currentColor) {
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final colorGroup in [
                Colors.primaries,
                [Colors.black, Colors.white, Colors.grey]
              ])
                Wrap(
                  children: [
                    for (final color in colorGroup)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _exportGrid(String formatName,
      {List<String>? selectedColumns}) async {
    setState(() {
      isExporting = true;
      exportStatus = 'Exportando como $formatName...';
    });

    try {
      String content = '';
      Uint8List? pdfBytes;

      if (formatName == formatCsv) {
        content = await _exportToCsv(selectedColumns);
        final path = await _downloadFile(content, 'fodac_59_report', 'csv',
            isText: true);
        _showFileLocationDialog(path, 'CSV');
      } else if (formatName == formatJson) {
        content = await _exportToJson(selectedColumns);
        final path = await _downloadFile(content, 'fodac_59_report', 'json',
            isText: true);
        _showFileLocationDialog(path, 'JSON');
      } else if (formatName == formatPdf) {
        pdfBytes = await _exportToPdf(selectedColumns);
        final path =
            await _downloadFileBytes(pdfBytes, 'fodac_59_report', 'pdf');
        _showFileLocationDialog(path, 'PDF');
      }

      setState(() {
        exportStatus = 'Exportado exitosamente como $formatName';
        isExporting = false;
      });
    } catch (e) {
      setState(() {
        exportStatus = 'Error en la exportación: $e';
        isExporting = false;
      });

      _showErrorNotification('Error al exportar: $e');
    }
  }

  Future<String> _exportToCsv(List<String>? selectedColumns) async {
    final List<String> columns = selectedColumns ?? _getAvailableColumns();
    final List<List<String>> csvData = [];

    // Add headers if requested
    if (includeHeaders) {
      csvData.add(columns);
    }

    // Add data rows
    for (var item in _reportData) {
      final List<String> rowData = [];
      for (var column in columns) {
        rowData.add(item[column]?.toString() ?? '');
      }
      csvData.add(rowData);
    }

    // Use the csv package to properly format the CSV
    return const ListToCsvConverter().convert(csvData);
  }

  Future<String> _exportToJson(List<String>? selectedColumns) async {
    final List<String> columns = selectedColumns ?? _getAvailableColumns();
    final List<Map<String, dynamic>> jsonData = [];

    for (var item in _reportData) {
      final Map<String, dynamic> rowData = {};
      for (var column in columns) {
        rowData[column] = item[column];
      }
      jsonData.add(rowData);
    }

    // Convert to JSON string with pretty formatting
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonData);
  }

  Future<Uint8List> _exportToPdf(List<String>? selectedColumns) async {
    final List<String> columns = selectedColumns ?? _getAvailableColumns();

    // Create page format based on orientation
    final format = pdfLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    // Function to convert Flutter Color to PdfColor
    PdfColor flutterToPdfColor(Color color) {
      return PdfColor.fromInt(color.value);
    }

    final pdf = pw.Document();

    final themeData = pw.ThemeData(
      tableHeader: pw.TextStyle(
        color: PdfColors.white,
        font: pw.Font.ttf(await rootBundle
            .load("assets/fonts/SoraFont/static/Sora-Bold.ttf")),
        fontSize: 12,
      ),
      defaultTextStyle: pw.TextStyle(
        color: flutterToPdfColor(textColor),
        font: pw.Font.ttf(await rootBundle
            .load("assets/fonts/SoraFont/static/Sora-Regular.ttf")),
        fontSize: 10,
      ),
    );

    // Prepare table data
    final List<List<String>> tableData = [];

    // Add headers if requested
    if (includeHeaders) {
      tableData.add(columns);
    }

    // Add data rows
    for (var item in _reportData) {
      final List<String> rowData = [];
      for (var column in columns) {
        rowData.add(item[column]?.toString() ?? '');
      }
      tableData.add(rowData);
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: format,
          theme: themeData,
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                pdfTitle,
                style: pw.TextStyle(
                  fontSize: 20,
                  font: pw.Font.timesBold(),
                  color: flutterToPdfColor(headerColor),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey500,
                width: 0.5,
              ),
              columnWidths: {
                for (int i = 0; i < columns.length; i++)
                  i: const pw.FlexColumnWidth(),
              },
              children: tableData.map((row) {
                final isHeader = includeHeaders && tableData.indexOf(row) == 0;
                return pw.TableRow(
                  decoration: isHeader
                      ? pw.BoxDecoration(
                          color: flutterToPdfColor(headerColor),
                        )
                      : null,
                  children: row.map((cell) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        cell,
                        style: pw.TextStyle(
                          color: isHeader
                              ? PdfColors.white
                              : flutterToPdfColor(textColor),
                          fontSize: isHeader ? 12 : 10,
                          font:
                              isHeader ? pw.Font.timesBold() : pw.Font.times(),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<String> _downloadFile(
      String content, String filename, String extension,
      {bool isText = true}) async {
    try {
      final String fullFilename =
          '${filename}_${DateTime.now().millisecondsSinceEpoch}';

      // Convert string to bytes
      final Uint8List bytes = Uint8List.fromList(utf8.encode(content));

      // Use file_saver to save the file
      final String path = await FileSaver.instance.saveFile(
        name: fullFilename,
        bytes: bytes,
        ext: extension,
        mimeType: extension == 'csv' ? MimeType.csv : MimeType.json,
      );

      return path;
    } catch (e) {
      throw Exception('Error al guardar archivo: $e');
    }
  }

  Future<String> _downloadFileBytes(
      Uint8List bytes, String filename, String extension) async {
    try {
      final String fullFilename =
          '${filename}_${DateTime.now().millisecondsSinceEpoch}';

      // Use file_saver to save the file
      final String path = await FileSaver.instance.saveFile(
        name: fullFilename,
        bytes: bytes,
        ext: extension,
        mimeType: MimeType.pdf,
      );

      return path;
    } catch (e) {
      throw Exception('Error al guardar archivo: $e');
    }
  }

  void _showFileLocationDialog(String filePath, String formatName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Exportación Exitosa'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'El archivo $formatName ha sido guardado exitosamente.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ubicación del archivo:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      filePath,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Puedes encontrar este archivo en la ubicación mostrada arriba.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Copy path to clipboard
                Clipboard.setData(ClipboardData(text: filePath));
                _showSuccessNotification(
                    'Ruta del archivo copiada al portapapeles');
              },
              child: const Text('Copiar Ruta'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _printReport() async {
    try {
      setState(() {
        isExporting = true;
        exportStatus = 'Preparando impresión...';
      });

      // Get all available columns for printing
      final List<String> columns = _getAvailableColumns();

      // Generate PDF bytes for printing
      final Uint8List pdfBytes = await _exportToPdf(columns);

      setState(() {
        exportStatus = 'Enviando a impresora...';
      });

      // Use the printing package to print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'FO-DAC-59_Reporte_${DateTime.now().millisecondsSinceEpoch}',
        format: pdfLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
      );

      setState(() {
        exportStatus = 'Documento enviado a impresora exitosamente';
        isExporting = false;
      });

      _showSuccessNotification('Documento enviado a impresora exitosamente');
    } catch (e) {
      setState(() {
        exportStatus = 'Error al imprimir: $e';
        isExporting = false;
      });
      if (e is pw.TooManyPagesException) {
        _showErrorNotification(
            'El documento es demasiado grande para imprimir. Intenta reducir el número de columnas o filas.');
      } else {
        _showErrorNotification('Error al imprimir: $e');
      }

      _showErrorNotification('Error al imprimir: $e');
      print('Error in _printReport: $e');
    }
  }
}
