// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/reusable_methods/device_functions.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/Employee.dart';
import 'package:oxschool/data/Models/EmployeePerformanceEvaluation.dart';
import 'package:oxschool/presentation/Modules/admin/create_employee_evaluation.dart';
import 'package:oxschool/core/utils/evaluation_data_exporter.dart';

class EmployeePerformanceEvaluationDashboard extends StatefulWidget {
  const EmployeePerformanceEvaluationDashboard({super.key});

  @override
  State<EmployeePerformanceEvaluationDashboard> createState() =>
      _EmployeePerformanceEvaluationDashboardState();
}

class _EmployeePerformanceEvaluationDashboardState
    extends State<EmployeePerformanceEvaluationDashboard>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool isLoading = true;
  bool isDeviceMobile = false;

  // Dashboard data
  List<EmployeePerformanceEvaluation> evaluations = [];
  List<Employee> employees = [];
  Map<String, dynamic> dashboardStats = {};

  // Filter states
  String selectedPeriod = 'All';
  String selectedDepartment = 'All';
  String selectedStatus = 'All';
  bool showFilterPanel = false;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _initializeDashboard();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    try {
      isDeviceMobile = await isCurrentDeviceMobile();
      await _loadDashboardData();
      _fadeController.forward();
    } catch (e) {
      insertErrorLog(e.toString(), 'EmployeePerformanceEvaluationDashboard');
      if (mounted) {
        _showErrorSnackBar('Error loading dashboard: ${e.toString()}');
      }
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate API call - replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock data - replace with actual API calls
      evaluations = _generateMockEvaluations();
      employees = _generateMockEmployees();
      dashboardStats = _calculateDashboardStats();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      insertErrorLog(e.toString(),
          'EmployeePerformanceEvaluationDashboard._loadDashboardData');
      rethrow;
    }
  }

  Future<void> _refreshDashboard() async {
    _refreshController.forward();
    await _loadDashboardData();
    _refreshController.reset();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Helper methods for responsive design
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 2; // Mobile: 2 columns
    } else if (width < tabletBreakpoint) {
      return 3; // Tablet: 3 columns
    } else if (width < desktopBreakpoint) {
      return 4; // Small Desktop: 4 columns
    } else {
      return 4; // Large Desktop: 4 columns
    }
  }

  double _getGridAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 1.1; // Mobile: taller cards
    } else if (width < tabletBreakpoint) {
      return 1.3; // Tablet: balanced
    } else {
      return 1.4; // Desktop: wider cards
    }
  }

  bool _shouldShowFilterPanel(BuildContext context) {
    return _isDesktop(context) && showFilterPanel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: _buildAppBar(theme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isLoading
            ? _buildLoadingView(theme)
            : _buildResponsiveDashboardContent(theme),
      ),
      floatingActionButton: _buildFloatingActionButtons(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(FlutterFlowTheme theme) {
    return AppBar(
      backgroundColor: theme.primary,
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              const FaIcon(FontAwesomeIcons.chartLine,
                  size: 24, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isMobile(context)
                      ? 'Eval. desempeño'
                      : 'Evaluación de desempeño',
                  style: TextStyle(
                    fontSize: _isMobile(context) ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        if (_isDesktop(context)) ...[
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter,
                size: 20, color: Colors.white),
            onPressed: () => setState(() => showFilterPanel = !showFilterPanel),
            tooltip: 'Filters',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.fileExport,
                size: 20, color: Colors.white),
            onPressed: _exportData,
            tooltip: 'Export Data',
          ),
          const SizedBox(width: 8),
        ] else if (!_isMobile(context)) ...[
          // Tablet - show only export
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.fileExport,
                size: 20, color: Colors.white),
            onPressed: _exportData,
            tooltip: 'Export Data',
          ),
          const SizedBox(width: 8),
        ],
        RotationTransition(
          turns: _refreshController,
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate,
                size: 20, color: Colors.white),
            onPressed: _refreshDashboard,
            tooltip: 'Refresh',
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildLoadingView(FlutterFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading performance data...',
            style: TextStyle(
              color: theme.secondaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveDashboardContent(FlutterFlowTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_isMobile(context)) {
          return _buildMobileLayout(theme);
        } else {
          return _buildDesktopLayout(theme);
        }
      },
    );
  }

  Widget _buildMobileLayout(FlutterFlowTheme theme) {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      color: theme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileActions(theme),
            const SizedBox(height: 16),
            _buildResponsiveStatsGrid(theme),
            const SizedBox(height: 20),
            _buildRecentEvaluations(theme, isMobile: true),
            const SizedBox(height: 20),
            _buildPerformanceTrends(theme, isMobile: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(FlutterFlowTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            if (_shouldShowFilterPanel(context)) ...[
              _buildFilterPanel(theme),
              const VerticalDivider(width: 1),
            ],
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshDashboard,
                color: theme.primary,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(_isMobile(context) ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResponsiveStatsGrid(theme),
                      const SizedBox(height: 24),
                      _buildResponsiveEvaluationsAndTrends(theme, constraints),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveEvaluationsAndTrends(
      FlutterFlowTheme theme, BoxConstraints constraints) {
    final availableWidth =
        constraints.maxWidth - (_shouldShowFilterPanel(context) ? 280 : 0);

    if (availableWidth < tabletBreakpoint) {
      // Stack vertically for smaller screens
      return Column(
        children: [
          _buildRecentEvaluations(theme, isMobile: false),
          const SizedBox(height: 16),
          _buildPerformanceTrends(theme, isMobile: false),
        ],
      );
    } else {
      // Side by side for larger screens
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildRecentEvaluations(theme, isMobile: false),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildPerformanceTrends(theme, isMobile: false),
          ),
        ],
      );
    }
  }

  Widget _buildResponsiveStatsGrid(FlutterFlowTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stats = [
          StatCard(
            title: 'Total Evaluations',
            value: '${dashboardStats['totalEvaluations'] ?? 0}',
            icon: FontAwesomeIcons.clipboardList,
            color: Colors.blue,
            trend: '+12%',
            isPositive: true,
          ),
          StatCard(
            title: 'Pending Reviews',
            value: '${dashboardStats['pendingReviews'] ?? 0}',
            icon: FontAwesomeIcons.clock,
            color: Colors.orange,
            trend: '-5%',
            isPositive: false,
          ),
          StatCard(
            title: 'Average Score',
            value: '${dashboardStats['averageScore'] ?? 0.0}',
            icon: FontAwesomeIcons.star,
            color: Colors.green,
            trend: '+3.2%',
            isPositive: true,
          ),
          StatCard(
            title: 'Completed This Month',
            value: '${dashboardStats['completedThisMonth'] ?? 0}',
            icon: FontAwesomeIcons.checkCircle,
            color: Colors.purple,
            trend: '+18%',
            isPositive: true,
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getGridColumns(context),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: _getGridAspectRatio(context),
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _buildStatCard(theme, stats[index]),
        );
      },
    );
  }

  Widget _buildMobileActions(FlutterFlowTheme theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createNewEvaluation,
                    icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                    label: const Text('New Evaluation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportData,
                    icon: const FaIcon(FontAwesomeIcons.fileExport, size: 16),
                    label: const Text('Export'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.primary),
                      foregroundColor: theme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showMobileFilters(theme),
              icon: const FaIcon(FontAwesomeIcons.filter, size: 16),
              label: const Text('Filters & Settings'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.secondaryText),
                foregroundColor: theme.secondaryText,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(FlutterFlowTheme theme, StatCard stat) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              stat.color.withOpacity(0.1),
              stat.color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FaIcon(
                  stat.icon,
                  color: stat.color,
                  size: 24,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stat.isPositive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stat.trend,
                    style: TextStyle(
                      color: stat.isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              stat.value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
            Text(
              stat.title,
              style: TextStyle(
                fontSize: 14,
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEvaluations(FlutterFlowTheme theme,
      {required bool isMobile}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Evaluations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: _viewAllEvaluations,
                  child: Text(
                    'View All',
                    style: TextStyle(color: theme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...evaluations.take(isMobile ? 3 : 5).map(
                  (eval) => _buildEvaluationListItem(theme, eval),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationListItem(
      FlutterFlowTheme theme, EmployeePerformanceEvaluation evaluation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.alternate),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                _getStatusColor(evaluation.effectiveStatus).withOpacity(0.2),
            child: FaIcon(
              FontAwesomeIcons.user,
              color: _getStatusColor(evaluation.effectiveStatus),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evaluation.employeeName ?? 'Unknown Employee',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  evaluation.department ?? 'Unknown Department',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(evaluation.effectiveStatus)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  evaluation.effectiveStatus,
                  style: TextStyle(
                    color: _getStatusColor(evaluation.effectiveStatus),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (evaluation.overallScore != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.star,
                      color: Colors.amber,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      evaluation.overallScore!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrends(FlutterFlowTheme theme,
      {required bool isMobile}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: isMobile ? 200 : 300,
              decoration: BoxDecoration(
                color: theme.alternate.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.chartLine,
                      color: theme.secondaryText,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chart Integration Coming Soon',
                      style: TextStyle(
                        color: theme.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(FlutterFlowTheme theme) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(right: BorderSide(color: theme.alternate)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          _buildFilterDropdown(
              theme,
              'Period',
              selectedPeriod,
              ['All', 'This Month', 'Last Month', 'This Quarter', 'This Year'],
              (value) => setState(() => selectedPeriod = value)),
          const SizedBox(height: 16),
          _buildFilterDropdown(
              theme,
              'Department',
              selectedDepartment,
              ['All', 'HR', 'IT', 'Sales', 'Marketing', 'Finance'],
              (value) => setState(() => selectedDepartment = value)),
          const SizedBox(height: 16),
          _buildFilterDropdown(
              theme,
              'Status',
              selectedStatus,
              ['All', 'Completed', 'Pending', 'In Progress', 'Overdue'],
              (value) => setState(() => selectedStatus = value)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _clearFilters,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primary),
                foregroundColor: theme.primary,
              ),
              child: const Text('Clear All'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    FlutterFlowTheme theme,
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (newValue) => onChanged(newValue!),
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButtons(FlutterFlowTheme theme) {
    if (_isMobile(context)) {
      return FloatingActionButton(
        onPressed: _createNewEvaluation,
        backgroundColor: theme.primary,
        child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
      );
    }
    return null;
  }

  // Action methods
  void _createNewEvaluation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEmployeeEvaluationScreen(),
      ),
    );

    if (result != null) {
      // Refresh dashboard with new evaluation
      _refreshDashboard();
    }
  }

  void _exportData() {
    EvaluationDataExporter.showExportDialog(context, evaluations);
  }

  void _viewAllEvaluations() {
    // TODO: Navigate to all evaluations screen
    _showSuccessSnackBar('Navigate to all evaluations');
  }

  void _applyFilters() {
    // TODO: Apply filters and refresh data
    _refreshDashboard();
    _showSuccessSnackBar('Filters applied');
  }

  void _clearFilters() {
    setState(() {
      selectedPeriod = 'All';
      selectedDepartment = 'All';
      selectedStatus = 'All';
    });
    _refreshDashboard();
    _showSuccessSnackBar('Filters cleared');
  }

  void _showMobileFilters(FlutterFlowTheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFilterPanel(theme),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Mock data generators
  List<EmployeePerformanceEvaluation> _generateMockEvaluations() {
    return [
      EmployeePerformanceEvaluation(
        evaluationId: '1',
        employeeName: 'John Doe',
        department: 'IT',
        status: 'Completed',
        overallScore: 4.5,
        evaluationDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      EmployeePerformanceEvaluation(
        evaluationId: '2',
        employeeName: 'Jane Smith',
        department: 'HR',
        status: 'Pending',
        overallScore: null,
        evaluationDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      EmployeePerformanceEvaluation(
        evaluationId: '3',
        employeeName: 'Mike Johnson',
        department: 'Sales',
        status: 'In Progress',
        overallScore: null,
        evaluationDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      EmployeePerformanceEvaluation(
        evaluationId: '4',
        employeeName: 'Sarah Wilson',
        department: 'Marketing',
        status: 'Completed',
        overallScore: 4.2,
        evaluationDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
      EmployeePerformanceEvaluation(
        evaluationId: '5',
        employeeName: 'Robert Brown',
        department: 'Finance',
        status: 'Pending',
        overallScore: null,
        evaluationDate: DateTime.now().subtract(const Duration(days: 14)),
        dueDate: DateTime.now()
            .subtract(const Duration(days: 2)), // This will make it overdue
      ),
    ];
  }

  List<Employee> _generateMockEmployees() {
    // Mock employees data
    return [];
  }

  Map<String, dynamic> _calculateDashboardStats() {
    final totalEvaluations = evaluations.length;
    final pendingReviews =
        evaluations.where((e) => e.status == 'Pending').length;
    final completedEvaluations =
        evaluations.where((e) => e.status == 'Completed').toList();

    final scoresWithValue = completedEvaluations
        .map((e) => e.overallScore)
        .where((score) => score != null && score > 0.0)
        .cast<double>()
        .toList();

    final averageScore = scoresWithValue.isNotEmpty
        ? scoresWithValue.reduce((a, b) => a + b) / scoresWithValue.length
        : 0.0;

    final completedThisMonth = completedEvaluations
        .where((e) =>
            e.evaluationDate != null &&
            e.evaluationDate!.month == DateTime.now().month &&
            e.evaluationDate!.year == DateTime.now().year)
        .length;

    return {
      'totalEvaluations': totalEvaluations,
      'pendingReviews': pendingReviews,
      'averageScore': averageScore,
      'completedThisMonth': completedThisMonth,
    };
  }
}

// Helper class for dashboard statistics
class StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;

  StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
  });
}
