import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/core/utils/searchable_drop_down.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';

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
  String? selectedMonth;
  String? selectedCampus;
  List<String> studentsList = [];
  List<String> gradesList = [];
  List<String> groupsList = [];
  List<int> gradeSeqList = [];
  List<dynamic> _rawData = []; // Store the original response
  List<String> _filteredGroups = []; // For filtered groups
  List<String> _filteredStudents = []; // For filtered students
  List<dynamic> _reportData = []; // Store the report response data
  Future<dynamic>? _reportFuture; // Future for report data loading

  Future<dynamic>? future;
  late AnimationController _controller;
  bool _isFilterExpanded = false;

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
                        FilledButton.icon(
                          onPressed: () {
                            if (selectedCampus != null) {
                              setState(() {
                                future = fetchFiltersData(
                                    selectedCampus!, currentCycle!.claCiclo!);
                              });
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add print or export action here
        },
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 4,
        child: const Icon(Icons.print),
      ),
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
      child: isSmallScreen
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
                      isEnabled: gradesList.isNotEmpty,
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
                      isEnabled: gradesList.isNotEmpty,
                      key: ValueKey('grupo_mobile_${selectedGrade ?? 'none'}'),
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
                              });
                            },
                      theme,
                      icon: Icons.person,
                      isEnabled: gradesList.isNotEmpty,
                      key: ValueKey('alumno_mobile_${selectedGroup ?? 'none'}'),
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
                              isEnabled: gradesList.isNotEmpty,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFilterDropdown(
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
                              isEnabled: gradesList.isNotEmpty,
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
                                      });
                                    },
                              theme,
                              icon: Icons.person,
                              isEnabled: gradesList.isNotEmpty,
                              key: ValueKey(
                                  'alumno_desktop_${selectedGroup ?? 'none'}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Column(
                //       children: [
                //         _buildFilterChip(
                //           'Incluir Bajas',
                //           includeDeactivatedStudent ?? false,
                //           (value) {
                //             setState(() {
                //               includeDeactivatedStudent = value;
                //             });
                //           },
                //           theme,
                //           icon: Icons.person_off_outlined,
                //         ),
                //         const SizedBox(height: 10),
                //         _buildFilterChip(
                //           'No Validar',
                //           includeValidation ?? false,
                //           (value) {
                //             setState(() {
                //               includeValidation = value;
                //             });
                //           },
                //           theme,
                //           icon: Icons.verified_outlined,
                //         ),
                //       ],
                //     ),
                //     const SizedBox(
                //       width: 10,
                //     ),
                //     Expanded(
                //       // flex: 5,
                //       child: Row(
                //         children: [
                //           Column(
                //             children: [
                //               _buildMonthFilterDropdown(theme),
                //               _buildCampusSelector(theme)
                //             ],
                //           ),
                //           const SizedBox(width: 16),
                //           Expanded(
                //             child: _buildFilterDropdown(
                //               'Grado',
                //               gradesList,
                //               selectedGrade,
                //               (value) {
                //                 setState(() {
                //                   selectedGrade = value;
                //                 });
                //               },
                //               theme,
                //               icon: Icons.school,
                //             ),
                //           ),
                //           const SizedBox(width: 16),
                //           Expanded(
                //             child: _buildFilterDropdown(
                //               'Grupo',
                //               groupsList,
                //               selectedGroup,
                //               (value) {
                //                 setState(() {
                //                   selectedGroup = value;
                //                 });
                //               },
                //               theme,
                //               icon: Icons.group,
                //             ),
                //           ),
                //           const SizedBox(width: 16),
                //           Expanded(
                //             child: _buildFilterDropdown(
                //               'Alumno',
                //               studentsList,
                //               selectedStudent,
                //               (value) {
                //                 setState(() {
                //                   selectedStudent = value;
                //                 });
                //               },
                //               theme,
                //               icon: Icons.person,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
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
                            IconButton(
                              icon: Icon(
                                Icons.refresh,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              onPressed: selectedCampus != null
                                  ? () {
                                      setState(() {
                                        future = fetchFiltersData(
                                            selectedCampus!,
                                            currentCycle!.claCiclo!);
                                      });
                                    }
                                  : null,
                              tooltip: selectedCampus == null
                                  ? 'Seleccione un campus primero'
                                  : 'Refrescar filtros',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                Icons.analytics,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              onPressed: _canGenerateReport()
                                  ? () {
                                      setState(() {
                                        _reportFuture = fetchReportData();
                                      });
                                    }
                                  : null,
                              tooltip: _canGenerateReport()
                                  ? 'Generar reporte'
                                  : 'Seleccione Grado y Grupo primero',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                Icons.file_download,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              onPressed: _reportData.isNotEmpty ? () {} : null,
                              tooltip: 'Exportar a Excel',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                Icons.print,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              onPressed: _reportData.isNotEmpty ? () {} : null,
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
    return Row(
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
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  onPressed: selectedCampus != null
                      ? () {
                          setState(() {
                            future = fetchFiltersData(
                                selectedCampus!, currentCycle!.claCiclo!);
                          });
                        }
                      : null,
                  tooltip: selectedCampus == null
                      ? 'Seleccione un campus primero'
                      : 'Refrescar filtros',
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.analytics,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  onPressed: _canGenerateReport()
                      ? () {
                          setState(() {
                            _reportFuture = fetchReportData();
                          });
                        }
                      : null,
                  tooltip: _canGenerateReport()
                      ? 'Generar reporte'
                      : 'Seleccione Grado y Grupo primero',
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.file_download,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  onPressed: _reportData.isNotEmpty ? () {} : null,
                  tooltip: 'Exportar a Excel',
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.print,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  onPressed: _reportData.isNotEmpty ? () {} : null,
                  tooltip: 'Imprimir',
                ),
              ],
            ),
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
              onChanged: (String? value) {
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
              onChanged: (String? value) {
                setState(() {
                  selectedCampus = value;
                });
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
    // If we have report data, display it
    if (_reportData.isNotEmpty) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.primaryContainer.withOpacity(0.3),
            ),
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Grado')),
              DataColumn(label: Text('Grupo')),
              DataColumn(label: Text('Campus')),
              DataColumn(label: Text('Mes')),
              // Add more columns based on your data structure
            ],
            rows: _reportData.map<DataRow>((item) {
              return DataRow(
                cells: [
                  DataCell(Text(item['student']?.toString() ?? '')),
                  DataCell(Text(item['grade']?.toString() ?? '')),
                  DataCell(Text(item['groupL']?.toString() ?? '')),
                  DataCell(Text(selectedCampus ?? '')),
                  DataCell(Text(selectedMonth ?? '')),
                  // Add more cells based on your data structure
                ],
              );
            }).toList(),
          ),
        ),
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
              Icons.analytics,
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
            Icons.table_chart,
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
    try {
      Set<String> uniqueGrades = {};
      Set<String> uniqueGroups = {};
      Set<String> uniqueStudents = {};

      includeDeactivatedStudent ??= false;
      includeValidation ??= false;

      await getFodac59FiltersData(
              campus, cycle, includeDeactivatedStudent, includeValidation)
          .then((value) {
        // Store the raw data for filtering later
        _rawData = List<dynamic>.from(value);

        for (var element in value) {
          uniqueStudents.add(element['student']);
          uniqueGrades.add(element['grade']);
          uniqueGroups.add(element['groupL']);
          gradeSeqList.add(element['seq']);
        }

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

          // Initialize filtered lists
          _filteredGroups = [];
          _filteredStudents = [];
        });

        return value;
      }).onError((error, stackTrace) {
        print('Error fetching data: $error');
        Get.snackbar(
          'Error',
          'No se pudo obtener la información. Inténtalo de nuevo más tarde.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print('Error in fetchFiltersData: $e');
      Get.snackbar(
        'Error',
        'No se pudo obtener la información. Inténtalo de nuevo más tarde.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _populateGroupsByGrade(String? grade) {
    if (grade == null || grade.isEmpty) {
      setState(() {
        _filteredGroups = [];
        selectedGroup = null;
        // Also clear students when grade is cleared
        _filteredStudents = [];
        selectedStudent = null;
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
      selectedStudent = null;
    });

    // Debug print to see what groups were found
    print('Grade: $grade, Groups found: $_filteredGroups');
  }

  void _filterStudentsByGradeAndGroup(String? grade, String? group) {
    if (grade == null || group == null) {
      setState(() {
        _filteredStudents = [];
        selectedStudent = null;
      });
      return;
    }

    // Find all students that match the selected grade and group
    Set<String> students = {};
    for (var item in _rawData) {
      if (item['grade'].toString().trim() == grade.trim() &&
          item['groupL'].toString().trim() == group.trim()) {
        students.add(item['student'].toString().trim());
      }
    }

    setState(() {
      _filteredStudents = students.toList()..sort();
      selectedStudent = null; // Reset student selection
    });
  }

  Future<dynamic> fetchReportData() async {
    if (selectedCampus == null ||
        selectedGrade == null ||
        selectedGroup == null) {
      return null;
    }

    try {
      includeDeactivatedStudent ??= false;
      includeValidation ??= false;

      // Call the getFodac59Response function with correct parameters
      // Get the gradeSeq for the selected grade
      int gradeSeq = _getGradeSeq(selectedGrade!);
      int monthIndex = _getMonthIndex(selectedMonth);

      await getFodac59Response(
        currentCycle!.claCiclo!,
        selectedCampus!,
        gradeSeq,
        selectedGroup!,
        monthIndex,
        0,
        'NONAME', // computerName
        includeDeactivatedStudent ?? false,
      ).then((value) {
        setState(() {
          _reportData = List<dynamic>.from(value);
        });
        return value;
      }).onError((error, stackTrace) {
        print('Error fetching report data: $error');
        Get.snackbar(
          'Error',
          'No se pudo obtener los datos del reporte. Inténtalo de nuevo más tarde.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print('Error in fetchReportData: $e');
      Get.snackbar(
        'Error',
        'No se pudo obtener los datos del reporte. Inténtalo de nuevo más tarde.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool _canGenerateReport() {
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
}
