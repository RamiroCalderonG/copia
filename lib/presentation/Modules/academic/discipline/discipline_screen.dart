import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/presentation/Modules/academic/discipline/discipline_history_grid.dart';
import 'package:oxschool/presentation/Modules/academic/discipline/create_discipline_screen.dart';

class DisciplineScreen extends StatefulWidget {
  const DisciplineScreen({super.key});

  @override
  State<DisciplineScreen> createState() => _DisciplineScreenState();
}

class _DisciplineScreenState extends State<DisciplineScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
        title: const Text('Reportes de Disciplina'),
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: FlutterFlowTheme.of(context).info,
        actions: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: IconButton.filled(
          //     icon: AnimatedIcon(
          //       icon: AnimatedIcons.menu_close,
          //       progress: _controller,
          //       color: Colors.white,
          //     ),
          //     onPressed: _toggleFilterPanel,
          //     tooltip: 'Filtros y opciones',
          //     style: IconButton.styleFrom(
          //       backgroundColor: Colors.white.withOpacity(0.2),
          //       foregroundColor: Colors.white,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: _buildMainContent(isSmallScreen, theme),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const CreateDisciplineScreen(),
      //       ),
      //     );
      //   },
      //   backgroundColor: theme.colorScheme.primaryContainer,
      //   foregroundColor: theme.colorScheme.onPrimaryContainer,
      //   elevation: 4,
      //   icon: const Icon(Icons.add),
      //   label: const Text('Nuevo Reporte'),
      // ),
    );
  }

  Widget _buildMainContent(bool isSmallScreen, ThemeData theme) {
    return Column(
      children: [
        // Filter Panel
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isFilterExpanded ? (isSmallScreen ? 200 : 150) : 0,
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
                // _buildSectionHeader(theme),
                const SizedBox(height: 8),
                Expanded(
                  child: DisciplineHistoryGrid(),
                ),
              ],
            ),
          ),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSectionTitle('Opciones de Filtrado', theme),
          const SizedBox(height: 12),
          if (isSmallScreen)
            Column(
              children: [
                _buildFilterRow1(theme),
                const SizedBox(height: 12),
                _buildFilterRow2(theme),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildFilterRow1(theme)),
                const SizedBox(width: 16),
                Expanded(child: _buildFilterRow2(theme)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterRow1(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown(
            'Período',
            ['Último mes', 'Últimos 3 meses', 'Último semestre', 'Todo el año'],
            null,
            (value) {},
            theme,
            icon: Icons.calendar_today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFilterDropdown(
            'Estado',
            ['Todos', 'Pendientes', 'Resueltos', 'En proceso'],
            null,
            (value) {},
            theme,
            icon: Icons.flag,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow2(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown(
            'Gravedad',
            ['Todas', 'Leve', 'Moderada', 'Grave'],
            null,
            (value) {},
            theme,
            icon: Icons.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFilterDropdown(
            'Grado',
            ['Todos', '1°', '2°', '3°', '4°', '5°', '6°'],
            null,
            (value) {},
            theme,
            icon: Icons.school,
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
          'Reportes de Disciplina',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.list_alt,
                  size: 16,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'Historial',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
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

  Widget _buildFilterDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?)? onChanged,
    ThemeData theme, {
    IconData? icon,
    bool isEnabled = true,
  }) {
    return Column(
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
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
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
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: isEnabled ? onChanged : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            dropdownColor: theme.colorScheme.surface,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
