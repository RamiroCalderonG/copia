import 'package:flutter/material.dart';

import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_util.dart';
import 'package:oxschool/core/constants/user_consts.dart';

class ReportType {
  final String title; //Title to display on the card
  final String description; //Description to display on the card
  final IconData icon; //Icon to display on the card
  final List<String> features; //List of features to display on the card
  final Color iconColor; //Color of the icon
  final String? route; //Route to navigate when the card is tapped
  final ReportParameters parameters; //Parameters required for the report
  final int idKey; //EventId

  ReportType({
    required this.title,
    required this.description,
    required this.icon,
    required this.features,
    required this.iconColor,
    this.route,
    this.parameters = const ReportParameters(),
    required this.idKey,
  });
}

class ReportParameters {
  final bool needsGrade;
  final bool needsGroup;
  final bool needsMonth;
  final bool needsStudent;
  final bool needsDeactivatedOption;
  final bool needCampus;
  final bool requireReportCard;
  final bool includeValidation;
  final bool applyFODAC05;

  const ReportParameters({
    this.needsGrade = false,
    this.needsGroup = false,
    this.needsMonth = false,
    this.needsStudent = false,
    this.needsDeactivatedOption = false,
    this.needCampus = false,
    this.requireReportCard = false,
    this.includeValidation = false,
    this.applyFODAC05 = false,
  });
}

class ReportSelectionScreen extends StatefulWidget {
  @override
  _ReportSelectionScreenState createState() => _ReportSelectionScreenState();
}

class _ReportSelectionScreenState extends State<ReportSelectionScreen>
    with TickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  int? selectedIndex;
  bool isGenerating = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  String? selectedGrade;
  String? selectedGroup;
  String? selectedMonth;
  String? selectedStudent;
  bool includeDeactivatedStudents = false;

  String? selectedDeactivatedOption;
  final List<String> deactivatedOptions = ['Sí', 'No'];

  String? selectedCampus;
  final List<String> campuses = [
    'ANAHUAC',
    'BARRAGAN',
    'CONCORDIA',
    'SENDERO',
  ];

  String? selectedReportCard;
  final List<String> reportCards = ['Sí', 'No'];

  String? selectedValidation;
  final List<String> validations = ['Sí', 'No'];

  String? selectedFODAC05;
  final List<String> FODAC05Options = ['Sí', 'No'];

  final List<String> grades = ['Kinder 1', 'Kinder 2', 'Kinder 3'];
  final List<String> groups = ['A', 'B', 'C'];
  final List<String> months = [
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
  final List<String> students = [
    'Todos',
    'Estudiante 1',
    'Estudiante 2',
    'Estudiante 3'
  ];

  final List<ReportType> reportTypes = [
    ReportType(
      title: 'FO-DAC-59 Kinder',
      description:
          'Generar reporte FO-DAC-59 para estudiantes de Kinder con información detallada sobre su desempeño académico y social.',
      icon: Icons.analytics,
      features: ['PDF', 'Excel', 'Print'],
      iconColor: Color(0xFF174C93),
      route: 'Fodac59',
      idKey: 30, //eventId
      parameters: ReportParameters(
        needsGrade: true,
        needsGroup: true,
        needsMonth: true,
        needsStudent: true,
        needsDeactivatedOption: true,
        needCampus: true,
        requireReportCard: true,
        includeValidation: true,
        applyFODAC05: true,
      ),
    ),
    ReportType(
      title: 'FO-DAC-60 y 04 Semestral',
      description:
          'Generar reporte FO-DAC-60 y 04 para estudiantes de Semestral con información detallada sobre su desempeño académico y social.',
      icon: Icons.bar_chart_rounded,
      features: ['PDF', 'Excel', 'Print'],
      iconColor: Color(0xFFEB3045),
      idKey: 0,
      parameters: ReportParameters(
        needsGrade: true,
        needsGroup: true,
        needsMonth: true,
        needsStudent: true,
        needsDeactivatedOption: true,
        needCampus: true,
        requireReportCard: true,
        includeValidation: true,
        applyFODAC05: true,
      ),
    ),
    ReportType(
      title: 'Faltantes Captura y Deudores',
      description:
          'Generar reporte de Faltantes Captura y Deudores con información detallada sobre el estado de los estudiantes.',
      icon: Icons.search_off,
      features: ['PDF', 'Excel', 'Print'],
      iconColor: Color(0xFF174C93),
      idKey: 0,
      parameters: ReportParameters(
        needsGrade: true,
        needsGroup: true,
        needsMonth: true,
        needsStudent: true,
        needsDeactivatedOption: true,
        needCampus: true,
        requireReportCard: true,
        includeValidation: true,
        applyFODAC05: true,
      ),
    ),
    ReportType(
      title: 'FO-DAC-15 Por Campus/Gdo/Alum.',
      description:
          'Generar reporte FO-DAC-15 para estudiantes por Campus/Gdo/Alum. con información detallada sobre su desempeño académico y social.',
      icon: Icons.palette,
      features: ['PDF', 'Excel', 'Print'],
      iconColor: Color(0xFFEB3045),
      idKey: 0,
      parameters: ReportParameters(
        needsGrade: true,
        needsGroup: true,
        needsMonth: true,
        needsStudent: true,
        needsDeactivatedOption: true,
        needCampus: true,
        requireReportCard: true,
        includeValidation: true,
        applyFODAC05: true,
      ),
    ),
    ReportType(
      title: 'FO-DAC-62 Anual',
      description:
          'Generar reporte FO-DAC-62 para estudiantes con información detallada sobre su desempeño académico y social.',
      icon: Icons.view_week_rounded,
      features: ['PDF', 'Excel', 'Print'],
      iconColor: Color(0xFF174C93),
      idKey: 0,
      parameters: ReportParameters(
        needsGrade: true,
        needsGroup: true,
        needsMonth: true,
        needsStudent: true,
        needsDeactivatedOption: true,
        needCampus: true,
        requireReportCard: true,
        includeValidation: true,
        applyFODAC05: true,
      ),
    ),
    ReportType(
      title: 'FO-DAC-29 y FO-DAC-31',
      description:
          'Generar reportes FO-DAC-29 y FO-DAC-31 con información detallada sobre el cumplimiento y auditoría de los estudiantes.',
      icon: Icons.workspace_premium_rounded,
      features: ['PDF', 'Excel', 'Print'],
      iconColor: Color(0xFFEB3045),
      idKey: 0,
      parameters: ReportParameters(
        needsGrade: true,
        needsGroup: true,
        needsMonth: true,
        needsStudent: true,
        needsDeactivatedOption: true,
        needCampus: true,
        requireReportCard: true,
        includeValidation: true,
        applyFODAC05: true,
      ),
    ),
    ReportType(
      title: 'FO-DAC-32  Gdo y Gpo',
      description:
          'Generar reporte FO-DAC-32 para estudiantes con información detallada sobre su desempeño académico y social.',
      icon: Icons.adjust_rounded,
      features: ['PDF', 'Excel', 'Print'],
      iconColor: Color(0xFF174C93),
      idKey: 0,
      parameters: ReportParameters(
        needsGrade: true,
        needsGroup: true,
        needsMonth: true,
        needsStudent: true,
        needsDeactivatedOption: true,
        needCampus: true,
        requireReportCard: true,
        includeValidation: true,
        applyFODAC05: true,
      ),
    ),
    ReportType(
      title: 'FO-DAC-57 por Alumno',
      description:
          'Generar reportes FO-DAC-57 con información detallada sobre el cumplimiento y auditoría de los estudiantes.',
      icon: Icons.workspace_premium_rounded,
      features: ['PDF', 'Excel', 'Print'],
      iconColor: Color(0xFFEB3045),
      idKey: 0,
      parameters: ReportParameters(
        needsGrade: true,
        needsGroup: true,
        needsMonth: true,
        needsStudent: true,
        needsDeactivatedOption: true,
        needCampus: true,
        requireReportCard: true,
        includeValidation: true,
        applyFODAC05: true,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardControllers = List.generate(
      reportTypes.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _cardAnimations = _cardControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
          ),
        )
        .toList();

    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildPreviewOption(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(value,
              style: TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 61, 138, 239))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reportes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF174C93),
              Color.fromARGB(164, 235, 48, 70),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header - make text size responsive
              FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Column(
                    children: [
                      Text(
                        'Generar reportes académicos',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Elige el tipo de reporte que te gustaría crear',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // // Date picker - make it responsive
              // FadeTransition(
              //   opacity: _fadeController,
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(
              //         horizontal: isSmallScreen ? 16 : 24, vertical: 8),
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: Colors.white.withOpacity(0.15),
              //         borderRadius: BorderRadius.circular(16),
              //       ),
              //       padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             'Periodo del reporte',
              //             style: TextStyle(
              //               fontSize: isSmallScreen ? 14 : 16,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.white,
              //             ),
              //           ),
              //           SizedBox(height: 12),
              //           // Convert to Column on very small screens
              //           if (screenSize.width < 400)
              //             _buildVerticalDatePickers()
              //           else
              //             _buildHorizontalDatePickers(),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              // Report Cards - improve responsiveness
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getGridCrossAxisCount(screenSize.width),
                      crossAxisSpacing: isSmallScreen ? 8 : 10,
                      mainAxisSpacing: isSmallScreen ? 8 : 10,
                      childAspectRatio: isSmallScreen ? 1.6 : 1.9,
                    ),
                    itemCount: reportTypes.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _cardAnimations[index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _cardAnimations[index].value,
                            child: ReportCard(
                              reportType: reportTypes[index],
                              isSelected: selectedIndex == index,
                              onTap: () => _selectReport(index),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              // Action Buttons - make responsive
              // SlideTransition(
              //   position: Tween<Offset>(
              //     begin: Offset(0, 1),
              //     end: Offset.zero,
              //   ).animate(CurvedAnimation(
              //     parent: _slideController,
              //     curve: Curves.easeOutCubic,
              //   )),
              //   child: Padding(
              //     padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              //     child: _buildResponsiveActionButtons(isSmallScreen),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to determine grid columns based on screen width
  int _getGridCrossAxisCount(double width) {
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  // Vertical date pickers for very small screens
  Widget _buildVerticalDatePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDatePickerButton(
          label: startDate != null
              ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
              : 'Fecha inicial',
          icon: Icons.calendar_today,
          iconColor: Color(0xFF174C93),
          onTap: () => _selectStartDate(context),
        ),
        SizedBox(height: 8),
        _buildDatePickerButton(
          label: endDate != null
              ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
              : 'Fecha final',
          icon: Icons.calendar_today,
          iconColor: Color(0xFFEB3045),
          onTap: () => _selectEndDate(context),
        ),
      ],
    );
  }

  // Horizontal date pickers for larger screens
  Widget _buildHorizontalDatePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePickerButton(
            label: startDate != null
                ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                : 'Fecha inicial',
            icon: Icons.calendar_today,
            iconColor: Color(0xFF174C93),
            onTap: () => _selectStartDate(context),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildDatePickerButton(
            label: endDate != null
                ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                : 'Fecha final',
            icon: Icons.calendar_today,
            iconColor: Color(0xFFEB3045),
            onTap: () => _selectEndDate(context),
          ),
        ),
      ],
    );
  }

  // Date picker button
  Widget _buildDatePickerButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: label.contains('/') ? Colors.black87 : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Responsive action buttons
  Widget _buildResponsiveActionButtons(bool isSmallScreen) {
    if (isSmallScreen) {
      // Stack buttons vertically on small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed:
                selectedIndex != null && !isGenerating ? _generateReport : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF174C93),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            child: isGenerating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Color(0xFF174C93),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('GENERANDO...'),
                    ],
                  )
                : Text(
                    'Generar Reporte',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          // SizedBox(height: 12),
          // Row(
          //   children: [
          //     // Expanded(
          //     //   child: OutlinedButton(
          //     //     onPressed: _showPreview,
          //     //     style: OutlinedButton.styleFrom(
          //     //       foregroundColor: Colors.white,
          //     //       side: BorderSide(color: Colors.white.withOpacity(0.5)),
          //     //       padding: EdgeInsets.symmetric(vertical: 16),
          //     //       shape: RoundedRectangleBorder(
          //     //         borderRadius: BorderRadius.circular(12),
          //     //       ),
          //     //     ),
          //     //     child: Text('PREVISUALIZAR'),
          //     //   ),
          //     // ),
          //     // SizedBox(width: 8),
          //     // Expanded(
          //     //   child: OutlinedButton.icon(
          //     //     onPressed:
          //     //         selectedIndex != null ? _showParametersPanel : null,
          //     //     style: OutlinedButton.styleFrom(
          //     //       foregroundColor: Colors.white,
          //     //       side: BorderSide(color: Colors.white.withOpacity(0.5)),
          //     //       padding: EdgeInsets.symmetric(vertical: 16),
          //     //       shape: RoundedRectangleBorder(
          //     //         borderRadius: BorderRadius.circular(12),
          //     //       ),
          //     //     ),
          //     //     icon: Icon(Icons.settings, size: 16),
          //     //     label: Text('PARÁMETROS'),
          //     //   ),
          //     // ),
          //   ],
          // ),
        ],
      );
    } else {
      // Row layout for larger screens
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: selectedIndex != null && !isGenerating
                  ? _generateReport
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF174C93),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF174C93),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('GENERANDO...'),
                      ],
                    )
                  : Text(
                      'Generar Reporte',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 16),
          // Expanded(
          //   child: OutlinedButton(
          //     onPressed: _showPreview,
          //     style: OutlinedButton.styleFrom(
          //       foregroundColor: Colors.white,
          //       side: BorderSide(color: Colors.white.withOpacity(0.5)),
          //       padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //     ),
          //     child: Text('PREVISUALIZAR'),
          //   ),
          // ),
          // SizedBox(width: 16),
          // Expanded(
          //   child: OutlinedButton.icon(
          //     onPressed: selectedIndex != null ? _showParametersPanel : null,
          //     style: OutlinedButton.styleFrom(
          //       foregroundColor: Colors.white,
          //       side: BorderSide(color: Colors.white.withOpacity(0.5)),
          //       padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //     ),
          //     icon: Icon(Icons.settings),
          //     label: Text('PARÁMETROS'),
          //   ),
          // ),
        ],
      );
    }
  }

  void _selectReport(int index) {
    setState(() {
      selectedIndex = index;

      // Reset parameters when changing reports
      if (reportTypes[index].parameters.needsGrade && selectedGrade == null) {
        selectedGrade = grades.first;
      }
      if (reportTypes[index].parameters.needsGroup && selectedGroup == null) {
        selectedGroup = groups.first;
      }
      if (reportTypes[index].parameters.needsMonth && selectedMonth == null) {
        selectedMonth = months[DateTime.now().month - 1];
      }
      if (reportTypes[index].parameters.needsStudent &&
          selectedStudent == null) {
        selectedStudent = students.first;
      }
    });
    // Valdiate if user has access to the report
    if (currentUser!.hasAccesToEventByName('Acceder  FODAC59')) {
      //Navigate to report screen
      context.pushNamed(
        '${reportTypes[index].route}',
        extra: <String, dynamic>{
          kTransitionInfoKey: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.leftToRight,
          ),
        },
      );
    } else {
      // Show access denied message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Text('No tienes acceso a este reporte.',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Navigator.pushNamed(
    //   context,
    //   reportTypes[index].route ?? '',
    // );

    // Show parameters panel
    // _showParametersPanel();
  }

  void _showParametersPanel() {
    if (selectedIndex == null) return;

    final reportParams = reportTypes[selectedIndex!].parameters;
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Skip if no parameters needed
    if (!reportParams.needsGrade &&
        !reportParams.needsGroup &&
        !reportParams.needsMonth &&
        !reportParams.needsStudent &&
        !reportParams.needsDeactivatedOption) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Main content in a scrollable container
                Flexible(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parámetros del Reporte',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            reportTypes[selectedIndex!].title,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 30),

                          // Parameter fields here
                          if (reportParams.needsGrade)
                            _buildParameterDropdown(
                              'Grado',
                              selectedGrade,
                              grades,
                              (value) {
                                setModalState(() {
                                  setState(() {
                                    selectedGrade = value;
                                  });
                                });
                              },
                              isSmallScreen: isSmallScreen,
                            ),

                          // Remaining parameters with isSmallScreen param
                          if (reportParams.needsGroup)
                            _buildParameterDropdown(
                              'Grupo',
                              selectedGroup,
                              groups,
                              (value) {
                                setModalState(() {
                                  setState(() {
                                    selectedGroup = value;
                                  });
                                });
                              },
                              isSmallScreen: isSmallScreen,
                            ),

                          if (reportParams.needsMonth)
                            _buildParameterDropdown(
                              'Mes',
                              selectedMonth,
                              months,
                              (value) {
                                setModalState(() {
                                  setState(() {
                                    selectedMonth = value;
                                  });
                                });
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                          if (reportParams.needsStudent)
                            _buildParameterDropdown(
                              'Alumno',
                              selectedStudent,
                              students,
                              (value) {
                                setModalState(() {
                                  setState(() {
                                    selectedStudent = value;
                                  });
                                });
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                          if (reportParams.needsDeactivatedOption)
                            _buildParameterDropdown(
                              'Incluir bajas',
                              selectedDeactivatedOption,
                              deactivatedOptions,
                              (value) {
                                setModalState(() {
                                  setState(() {
                                    selectedDeactivatedOption = value;
                                  });
                                });
                              },
                              isSmallScreen: isSmallScreen,
                            ),

                          if (reportParams.needCampus)
                            _buildParameterDropdown(
                              'Campus',
                              selectedCampus,
                              campuses,
                              (value) {
                                setModalState(() {
                                  setState(() {
                                    selectedCampus = value;
                                  });
                                });
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                          if (reportParams.requireReportCard)
                            _buildParameterDropdown(
                              'Boleta',
                              selectedReportCard,
                              reportCards,
                              (value) {
                                setModalState(() {
                                  setState(() {
                                    selectedReportCard = value;
                                  });
                                });
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                          if (reportParams.includeValidation)
                            _buildParameterDropdown(
                              'N.V.',
                              selectedValidation,
                              validations,
                              (value) {
                                setModalState(() {
                                  setState(() {
                                    selectedValidation = value;
                                  });
                                });
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                          if (reportParams.applyFODAC05)
                            _buildParameterDropdown(
                              'Sábana FODAC05',
                              selectedFODAC05,
                              FODAC05Options,
                              (value) {
                                setModalState(() {
                                  setState(() {
                                    selectedFODAC05 = value;
                                  });
                                });
                              },
                              isSmallScreen: isSmallScreen,
                            ),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Confirmation button - full width
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF174C93),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 14 : 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Confirmar parámetros',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParameterDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool isSmallScreen = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 0 : 2,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: isSmallScreen ? 20 : 24,
              underline: SizedBox(),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _generateReport() async {
    if (selectedIndex == null) return;

    // Validate date selection
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Por favor, selecciona un rango de fechas para el reporte'),
          backgroundColor: Color(0xFFEB3045),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Validate required parameters
    final params = reportTypes[selectedIndex!].parameters;
    if ((params.needsGrade && selectedGrade == null) ||
        (params.needsGroup && selectedGroup == null) ||
        (params.needsMonth && selectedMonth == null) ||
        (params.needsStudent && selectedStudent == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, configura todos los parámetros necesarios'),
          backgroundColor: Color(0xFFEB3045),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Show parameter panel
      _showParametersPanel();
      return;
    }

    setState(() {
      isGenerating = true;
    });

    // Simulate report generation
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isGenerating = false;
    });

    // Show success dialog with parameters
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final report = reportTypes[selectedIndex!];
    final params = report.parameters;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reporte Generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${report.title} ha sido generado con éxito.'),
            SizedBox(height: 8),
            Text(
              'Periodo: ${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (params.needsGrade)
              Text(
                'Grado: $selectedGrade',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            if (params.needsGroup)
              Text(
                'Grupo: $selectedGroup',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            if (params.needsMonth)
              Text(
                'Mes: $selectedMonth',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            if (params.needsStudent)
              Text(
                'Estudiante: $selectedStudent',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            if (params.needsDeactivatedOption)
              Text(
                'Incluir bajas: ${includeDeactivatedStudents ? "Sí" : "No"}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPreview() {
    if (selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona un tipo de reporte primero'),
          backgroundColor: Color(0xFFEB3045),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Validate date selection
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Por favor, selecciona un rango de fechas para el reporte'),
          backgroundColor: Color(0xFFEB3045),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Format date range for display
    final dateRangeText =
        '${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Previsualización del Reporte',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    reportTypes[selectedIndex!].title,
                    style: TextStyle(
                        fontSize: 16,
                        color: FlutterFlowTheme.of(context).primaryText),
                  ),
                  SizedBox(height: 30),
                  _buildPreviewOption('Date Range', dateRangeText),
                  _buildPreviewOption('Output Format', 'PDF'),
                  _buildPreviewOption('Template', 'Standard'),
                  _buildPreviewOption('Filters', 'All data'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF174C93),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        // If end date is before start date, update end date
        if (endDate == null || endDate!.isBefore(startDate!)) {
          endDate = startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFEB3045),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(Duration(milliseconds: 200));
    _slideController.forward();

    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      _cardControllers[i].forward();
    }
  }
}

class ReportCard extends StatefulWidget {
  final ReportType reportType;
  final bool isSelected;
  final VoidCallback onTap;

  const ReportCard({
    Key? key,
    required this.reportType,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  _ReportCardState createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );

    _elevationAnimation = Tween<double>(begin: 8.0, end: 16.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => _hoverController.forward(),
            onTapUp: (_) => _hoverController.reverse(),
            onTapCancel: () => _hoverController.reverse(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? Color(0xFFEB3045)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? Color(0xFFEB3045).withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon - make smaller on small screens
                    Container(
                      width: isSmallScreen ? 50 : 60,
                      height: isSmallScreen ? 50 : 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.reportType.iconColor,
                            widget.reportType.iconColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.reportType.icon,
                        color: Colors.white,
                        size: isSmallScreen ? 24 : 30,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // Title - responsive font size
                    Text(
                      widget.reportType.title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),

                    // Description - responsive font and fewer lines on small screens
                    Expanded(
                      child: Text(
                        widget.reportType.description,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: isSmallScreen ? 3 : null,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),

                    // Feature Tags - smaller on small screens
                    Wrap(
                      spacing: isSmallScreen ? 4 : 6,
                      runSpacing: isSmallScreen ? 2 : 4,
                      children: widget.reportType.features
                          .map((feature) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 6 : 8,
                                  vertical: isSmallScreen ? 2 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.reportType.iconColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 12,
                                    color: widget.reportType.iconColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
