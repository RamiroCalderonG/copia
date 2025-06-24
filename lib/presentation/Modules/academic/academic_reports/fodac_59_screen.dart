import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/core/utils/searchable_drop_down.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';

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

  late Future<dynamic>? future;
  late AnimationController _controller;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    future = fetchInitialData();
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
      body: FutureBuilder(
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
                      setState(() {
                        future = fetchInitialData();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        future = fetchInitialData();
                                      });
                                    },
                                    tooltip: 'Refrescar',
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: Icon(
                                      Icons.file_download,
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                    ),
                                    onPressed: () {},
                                    tooltip: 'Exportar a Excel',
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: Icon(
                                      Icons.print,
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                    ),
                                    onPressed: () {},
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
        },
      ),
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
                      (value) {
                        setState(() {
                          selectedGrade = value;
                          _filterGroupsByGrade(value);
                        });
                      },
                      theme,
                      icon: Icons.school,
                    ),
                    _buildFilterDropdown(
                      'Grupo',
                      _filteredGroups.isEmpty && selectedGrade == null
                          ? groupsList
                          : _filteredGroups,
                      selectedGroup,
                      (value) {
                        setState(() {
                          selectedGroup = value;
                          _filterStudentsByGradeAndGroup(selectedGrade, value);
                        });
                      },
                      theme,
                      icon: Icons.group,
                    ),
                    _buildMonthFilterDropdown(theme),
                    _buildCampusSelector(theme),
                    _buildFilterDropdown(
                      'Alumno',
                      _filteredStudents.isEmpty &&
                              (selectedGrade == null || selectedGroup == null)
                          ? studentsList
                          : _filteredStudents,
                      selectedStudent,
                      (value) {
                        setState(() {
                          selectedStudent = value;
                        });
                      },
                      theme,
                      icon: Icons.person,
                    ),
                  ],
                ),
                // Wrap(
                //   spacing: 16,
                //   runSpacing: 16,
                //   children: [
                //     _buildFilterDropdown(
                //       'Grado',
                //       gradesList,
                //       selectedGrade,
                //       (value) {
                //         setState(() {
                //           selectedGrade = value;
                //         });
                //       },
                //       theme,
                //       icon: Icons.school,
                //     ),
                //     _buildFilterDropdown(
                //       'Grupo',
                //       groupsList,
                //       selectedGroup,
                //       (value) {
                //         setState(() {
                //           selectedGroup = value;
                //         });
                //       },
                //       theme,
                //       icon: Icons.group,
                //     ),
                //     _buildMonthFilterDropdown(theme),
                //     _buildCampusSelector(theme),
                //     _buildFilterDropdown(
                //       'Alumno',
                //       studentsList,
                //       selectedStudent,
                //       (value) {
                //         setState(() {
                //           selectedStudent = value;
                //         });
                //       },
                //       theme,
                //       icon: Icons.person,
                //     ),
                //   ],
                // ),
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
                              (value) {
                                setState(() {
                                  selectedGrade = value;
                                  _filterGroupsByGrade(value);
                                });
                              },
                              theme,
                              icon: Icons.school,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFilterDropdown(
                              'Grupo',
                              _filteredGroups.isEmpty && selectedGrade == null
                                  ? groupsList
                                  : _filteredGroups,
                              selectedGroup,
                              (value) {
                                setState(() {
                                  selectedGroup = value;
                                  _filterStudentsByGradeAndGroup(
                                      selectedGrade, value);
                                });
                              },
                              theme,
                              icon: Icons.group,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFilterDropdown(
                              'Alumno',
                              _filteredStudents.isEmpty &&
                                      (selectedGrade == null ||
                                          selectedGroup == null)
                                  ? studentsList
                                  : _filteredStudents,
                              selectedStudent,
                              (value) {
                                setState(() {
                                  selectedStudent = value;
                                });
                              },
                              theme,
                              icon: Icons.person,
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
    Function(String?) onChanged,
    ThemeData theme, {
    IconData? icon,
  }) {
    return SizedBox(
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
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
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
            child: SearchableDropdown(
              items: items,
              label: label,
              // value: value,
              onSelected: onChanged,
              hint: '$label...',
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
    // Placeholder for your actual data table implementation
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
            'Seleccione los filtros para ver los datos',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajuste los criterios y presione el botón de refrescar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  dynamic fetchInitialData() async {
    await fetchFiltersData(currentUser!.claUn!, currentCycle!.claCiclo!);
  }

  Future<dynamic> fetchFiltersData(String campus, String cycle) async {
    try {
      Set<String> uniqueGrades = {};
      Set<String> uniqueGroups = {};
      Set<String> uniqueStudents = {};

      await getFodac59List(campus, cycle).then((value) {
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

  void _filterGroupsByGrade(String? grade) {
    if (grade == null) {
      setState(() {
        _filteredGroups = [];
        selectedGroup = null;
        _filteredStudents = [];
        selectedStudent = null;
      });
      return;
    }

    // Find all groups that match the selected grade
    Set<String> groups = {};
    for (var item in _rawData) {
      if (item['grade'] == grade) {
        groups.add(item['groupL']);
      }
    }

    setState(() {
      _filteredGroups = groups.toList()..sort();
      selectedGroup = null; // Reset group selection
      _filteredStudents = []; // Clear student filter
      selectedStudent = null; // Reset student selection
    });
  }

  void _filterStudentsByGradeAndGroup(String? grade, String? group) {
    if (grade == null || group == null) {
      Set<String> students = {};
      for (var item in _rawData) {
        if (item['grade'] == grade && item['groupL'] == group) {
          students.add(item['student']);
        }
      }
      setState(() {
        _filteredStudents = students.toList()..sort();
        selectedStudent = null;
      });
      // return;
    }

    // Find all students that match the selected grade and group
    Set<String> students = {};
    for (var item in _rawData) {
      if (item['grade'] == grade && item['groupL'] == group) {
        students.add(item['student']);
      }
    }

    setState(() {
      _filteredStudents = students.toList()..sort();
      selectedStudent = null; // Reset student selection
    });
  }

  // Future<dynamic> fetchFiltersData(String campus, String cycle) async {
  //   try {
  //     Set<String> uniqueGrades = {};
  //     Set<String> uniqueGroups = {};
  //     Set<String> uniqueStudents = {};
  //     await getFodac59List(campus, cycle).then((value) {
  //       for (var element in value) {
  //         uniqueStudents.add(element['student']);
  //         uniqueGrades.add(element['grade']);
  //         uniqueGroups.add(element['groupL']);
  //         gradeSeqList.add(element['seq']);
  //       }
  //       setState(() {
  //         studentsList = uniqueStudents.toList();
  //         gradesList = uniqueGrades.toList();
  //         groupsList = uniqueGroups.toList();
  //         studentsList.sort();
  //         gradesList.sort();
  //         groupsList.sort();
  //         selectedGrade = uniqueGrades.first;
  //         selectedGroup = uniqueGroups.first;
  //         selectedStudent = uniqueStudents.first;
  //       });
  //       return value;
  //     }).onError((error, stackTrace) {
  //       print('Error fetching data: $error');
  //       Get.snackbar(
  //         'Error',
  //         'No se pudo obtener la información. Inténtalo de nuevo más tarde.',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //     });
  //   } catch (e) {
  //     print('Error in fetchFiltersData: $e');
  //     Get.snackbar(
  //       'Error',
  //       'No se pudo obtener la información. Inténtalo de nuevo más tarde.',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }
}
