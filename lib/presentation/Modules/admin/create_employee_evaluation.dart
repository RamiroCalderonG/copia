import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/reusable_methods/device_functions.dart';
import 'package:oxschool/data/Models/Employee.dart';
import 'package:oxschool/data/Models/EmployeePerformanceEvaluation.dart';

class CreateEmployeeEvaluationScreen extends StatefulWidget {
  const CreateEmployeeEvaluationScreen({super.key});

  @override
  State<CreateEmployeeEvaluationScreen> createState() =>
      _CreateEmployeeEvaluationScreenState();
}

class _CreateEmployeeEvaluationScreenState
    extends State<CreateEmployeeEvaluationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isDeviceMobile = false;
  bool isLoading = false;

  // Form fields
  String? selectedEmployeeId;
  String? selectedPeriod;
  DateTime? evaluationDate;
  DateTime? dueDate;

  // Performance metrics
  double technicalSkills = 3.0;
  double communicationSkills = 3.0;
  double teamwork = 3.0;
  double leadership = 3.0;
  double problemSolving = 3.0;
  double reliability = 3.0;
  double initiative = 3.0;
  double qualityOfWork = 3.0;

  // Text controllers
  final TextEditingController _strengthsController = TextEditingController();
  final TextEditingController _improvementController = TextEditingController();
  final TextEditingController _developmentController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  // Mock data
  List<Employee> employees = [];
  List<String> periods = [
    'Q1 2024',
    'Q2 2024',
    'Q3 2024',
    'Q4 2024',
    'Annual 2024',
    'Mid-Year 2024'
  ];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _strengthsController.dispose();
    _improvementController.dispose();
    _developmentController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    isDeviceMobile = await isCurrentDeviceMobile();
    _loadMockData();
    setState(() {
      evaluationDate = DateTime.now();
      dueDate = DateTime.now().add(const Duration(days: 30));
    });
  }

  void _loadMockData() {
    // Mock employees - replace with actual API call
    employees = [
      Employee('1', 'John', 'Doe', 'Smith', DateTime(1990, 1, 1), 'IT',
          'Developer', false, 'M'),
      Employee('2', 'Jane', 'Smith', 'Johnson', DateTime(1985, 5, 15), 'HR',
          'Manager', false, 'F'),
      Employee('3', 'Mike', 'Johnson', 'Brown', DateTime(1992, 8, 20), 'Sales',
          'Representative', false, 'M'),
      Employee('4', 'Sarah', 'Wilson', 'Davis', DateTime(1988, 3, 10),
          'Marketing', 'Specialist', false, 'F'),
      Employee('5', 'Robert', 'Brown', 'Miller', DateTime(1987, 12, 5),
          'Finance', 'Analyst', false, 'M'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: _buildAppBar(theme),
      body: isLoading
          ? _buildLoadingView(theme)
          : isDeviceMobile
              ? _buildMobileLayout(theme)
              : _buildDesktopLayout(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(FlutterFlowTheme theme) {
    return AppBar(
      backgroundColor: theme.primary,
      foregroundColor: theme.primaryBackground,
      title: Row(
        children: [
          const FaIcon(FontAwesomeIcons.plus, size: 20),
          const SizedBox(width: 12),
          const Text(
            'New Performance Evaluation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saveEvaluation,
          child: Text(
            'Save',
            style: TextStyle(
              color: theme.primaryBackground,
              fontWeight: FontWeight.w600,
            ),
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
            'Saving evaluation...',
            style: TextStyle(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(FlutterFlowTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(theme),
            const SizedBox(height: 24),
            _buildPerformanceMetricsSection(theme),
            const SizedBox(height: 24),
            _buildQualitativeSection(theme),
            const SizedBox(height: 32),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(FlutterFlowTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildBasicInfoSection(theme),
                  const SizedBox(height: 24),
                  _buildPerformanceMetricsSection(theme),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildQualitativeSection(theme),
                  const SizedBox(height: 32),
                  _buildActionButtons(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(FlutterFlowTheme theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 20),
            _buildEmployeeDropdown(theme),
            const SizedBox(height: 16),
            _buildPeriodDropdown(theme),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildDateField(
                        theme,
                        'Evaluation Date',
                        evaluationDate,
                        (date) => setState(() => evaluationDate = date))),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildDateField(theme, 'Due Date', dueDate,
                        (date) => setState(() => dueDate = date))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeDropdown(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employee *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedEmployeeId,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: 'Select an employee',
          ),
          validator: (value) =>
              value == null ? 'Please select an employee' : null,
          items: employees.map((employee) {
            return DropdownMenuItem(
              value: employee.employeeID,
              child: Text(
                  '${employee.name} ${employee.firstLastName} - ${employee.workPosition}'),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedEmployeeId = value),
        ),
      ],
    );
  }

  Widget _buildPeriodDropdown(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evaluation Period *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedPeriod,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: 'Select evaluation period',
          ),
          validator: (value) => value == null ? 'Please select a period' : null,
          items: periods.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(period),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedPeriod = value),
        ),
      ],
    );
  }

  Widget _buildDateField(FlutterFlowTheme theme, String label, DateTime? date,
      Function(DateTime) onChanged) {
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
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null) {
              onChanged(pickedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select date',
                  style: TextStyle(
                      color: date != null ? theme.primaryText : Colors.grey),
                ),
                const FaIcon(FontAwesomeIcons.calendar, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetricsSection(FlutterFlowTheme theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rate each area from 1 (Poor) to 5 (Excellent)',
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _buildSliderField(theme, 'Technical Skills', technicalSkills,
                (value) => setState(() => technicalSkills = value)),
            _buildSliderField(
                theme,
                'Communication Skills',
                communicationSkills,
                (value) => setState(() => communicationSkills = value)),
            _buildSliderField(theme, 'Teamwork', teamwork,
                (value) => setState(() => teamwork = value)),
            _buildSliderField(theme, 'Leadership', leadership,
                (value) => setState(() => leadership = value)),
            _buildSliderField(theme, 'Problem Solving', problemSolving,
                (value) => setState(() => problemSolving = value)),
            _buildSliderField(theme, 'Reliability', reliability,
                (value) => setState(() => reliability = value)),
            _buildSliderField(theme, 'Initiative', initiative,
                (value) => setState(() => initiative = value)),
            _buildSliderField(theme, 'Quality of Work', qualityOfWork,
                (value) => setState(() => qualityOfWork = value)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Average Score:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText,
                    ),
                  ),
                  Text(
                    _calculateAverageScore().toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderField(FlutterFlowTheme theme, String label, double value,
      Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.primaryText,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1.0,
          max: 5.0,
          divisions: 8,
          activeColor: theme.primary,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildQualitativeSection(FlutterFlowTheme theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Qualitative Assessment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextArea(theme, 'Strengths', _strengthsController,
                'Describe the employee\'s key strengths...'),
            const SizedBox(height: 16),
            _buildTextArea(
                theme,
                'Areas for Improvement',
                _improvementController,
                'Identify areas where the employee can improve...'),
            const SizedBox(height: 16),
            _buildTextArea(theme, 'Development Plan', _developmentController,
                'Outline development goals and action items...'),
            const SizedBox(height: 16),
            _buildTextArea(theme, 'Additional Comments', _commentsController,
                'Any additional feedback or comments...'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextArea(FlutterFlowTheme theme, String label,
      TextEditingController controller, String hint) {
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
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: hint,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(FlutterFlowTheme theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.secondaryText),
              foregroundColor: theme.secondaryText,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveEvaluation,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Evaluation'),
          ),
        ),
      ],
    );
  }

  double _calculateAverageScore() {
    final scores = [
      technicalSkills,
      communicationSkills,
      teamwork,
      leadership,
      problemSolving,
      reliability,
      initiative,
      qualityOfWork,
    ];
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  Future<void> _saveEvaluation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create evaluation object
      final evaluation = EmployeePerformanceEvaluation(
        evaluationId: DateTime.now().millisecondsSinceEpoch.toString(),
        employeeId: selectedEmployeeId,
        period: selectedPeriod,
        evaluationDate: evaluationDate,
        dueDate: dueDate,
        status: 'Completed',
        overallScore: _calculateAverageScore(),
        technicalSkills: technicalSkills,
        communicationSkills: communicationSkills,
        teamwork: teamwork,
        leadership: leadership,
        problemSolving: problemSolving,
        reliability: reliability,
        initiative: initiative,
        qualityOfWork: qualityOfWork,
        strengths: _strengthsController.text,
        areasForImprovement: _improvementController.text,
        developmentPlan: _developmentController.text,
        comments: _commentsController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual API call
      // await saveEmployeeEvaluation(evaluation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Evaluation saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(evaluation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving evaluation: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
