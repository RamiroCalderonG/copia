
import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/core/utils/searchable_drop_down.dart';
import 'package:oxschool/data/Models/Student.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

class CreateDisciplineScreen extends StatefulWidget {
  const CreateDisciplineScreen({super.key});

  @override
  State<CreateDisciplineScreen> createState() => _CreateDisciplineScreenState();
}

class _CreateDisciplineScreenState extends State<CreateDisciplineScreen> {
  DateTime? selectedDateTime;
  final Set<int> _selectedChips = {};
  Set<String> selectedCausesId = {};
  int? kindOfReportValue = 0;
  late Future<dynamic> studentsList;
  List<Student> students = [];
  List<String> studentsNames = [];
  List<dynamic> teachers = [];
  Student? selectedStudent;
  List<Map<String, dynamic>> filteredTeachers = [];
  String? selectedTeacherId;
  List<Map<dynamic, dynamic>> causesList = [];
  Map<dynamic, dynamic> auxCausesList = {};
  dynamic responseBackend;
  TextEditingController observationsController = TextEditingController();
  Map<String, dynamic>? selectedTeacher;
  String? selectedSubject;
  int? selectedSubjectId;
  Map<String, dynamic> body = {};

  @override
  void initState() {
    studentsList = handleReload(currentCycle!.claCiclo!);
    super.initState();
  }

  @override
  void dispose() {
    students.clear();
    _selectedChips.clear();
    studentsNames.clear();
    studentsList = Future.value(null);
    observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    final List<String> kindOfReportList = [
      'Menor', //0
      'Mayor', //1
      'Notificación 1', //2
      'Notificación 2', //3
      'Notificación 3', //4
      'Aviso Sana Conducta', //5
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme, isSmallScreen, kindOfReportList),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        'Nuevo Reporte Disciplinario',
        style: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody(
      ThemeData theme, bool isSmallScreen, List<String> kindOfReportList) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: SafeArea(
        child: FutureBuilder(
          future: studentsList,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(theme);
            } else if (snapshot.hasError) {
              return _buildErrorState(theme, 'Error loading data');
            } else if (!snapshot.hasData) {
              return _buildErrorState(theme, 'No students found');
            }
            return _buildMainContent(theme, isSmallScreen, kindOfReportList);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando estudiantes...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      ThemeData theme, bool isSmallScreen, List<String> kindOfReportList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          if (isSmallScreen)
            _buildMobileLayout(theme, kindOfReportList)
          else
            _buildDesktopLayout(theme, kindOfReportList),
          const SizedBox(height: 24),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, List<String> kindOfReportList) {
    return Column(
      children: [
        _buildStudentSelectionCard(theme),
        const SizedBox(height: 16),
        _buildReportTypeCard(theme, kindOfReportList),
        const SizedBox(height: 16),
        _buildDateTimeCard(theme),
        const SizedBox(height: 16),
        _buildTeacherSelectionCard(theme),
        const SizedBox(height: 16),
        _buildCausesCard(theme),
        const SizedBox(height: 16),
        _buildObservationsCard(theme),
      ],
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, List<String> kindOfReportList) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildStudentSelectionCard(theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildReportTypeCard(theme, kindOfReportList)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDateTimeCard(theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildTeacherSelectionCard(theme)),
          ],
        ),
        const SizedBox(height: 16),
        _buildCausesCard(theme),
        const SizedBox(height: 16),
        _buildObservationsCard(theme),
      ],
    );
  }

  Widget _buildStudentSelectionCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.person_search,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Seleccionar Estudiante',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStudentSelector(),
        ],
      ),
    );
  }

  Widget _buildStudentSelector() {
    return SearchableDropdown(
      items: studentsNames,
      label: 'Buscar estudiante por nombre',
      onSelected: (selectedName) {
        final student = students.firstWhere((s) => s.nombre == selectedName);
        setState(() {
          selectedStudent = student;
          filteredTeachers = teachers
              .where((teacher) =>
                  teacher['ClaUN'].toString().trim() == student.claUn &&
                  teacher['Gradosecuencia'] == student.gradoSecuencia &&
                  teacher['Grupo'] == student.grupo)
              .toList()
              .cast<Map<String, dynamic>>();
          selectedTeacherId = null;
        });
      },
      hint: 'Buscar estudiante por nombre',
    );
  }

  Widget _buildReportTypeCard(ThemeData theme, List<String> kindOfReportList) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.report_problem,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Tipo de Reporte',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _buildReportTypeChips(theme, kindOfReportList),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReportTypeChips(
      ThemeData theme, List<String> kindOfReportList) {
    return List<Widget>.generate(6, (int index) {
      final isSelected = kindOfReportValue == index;
      return FilterChip(
        label: Text(
          kindOfReportList[index],
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            kindOfReportValue = selected ? index : null;
          });
        },
        backgroundColor: theme.colorScheme.surfaceVariant,
        selectedColor: theme.colorScheme.primary,
        checkmarkColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    });
  }

  Widget _buildDateTimeCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Fecha y Hora',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDateTimePicker(theme),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker(ThemeData theme) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Selecciona fecha y hora',
        hintText: 'dd/mm/aaaa hh:mm',
        prefixIcon: Icon(
          Icons.calendar_today,
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
      ),
      readOnly: true,
      controller: TextEditingController(
        text: selectedDateTime != null
            ? "${selectedDateTime!.day.toString().padLeft(2, '0')}/"
                "${selectedDateTime!.month.toString().padLeft(2, '0')}/"
                "${selectedDateTime!.year} "
                "${selectedDateTime!.hour.toString().padLeft(2, '0')}:"
                "${selectedDateTime!.minute.toString().padLeft(2, '0')}"
            : '',
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDateTime ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: selectedDateTime != null
                ? TimeOfDay.fromDateTime(selectedDateTime!)
                : TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              selectedDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }
        }
      },
    );
  }

  Widget _buildTeacherSelectionCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.school,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Docente y Materia',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredTeachers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Seleccione un estudiante para ver los docentes disponibles',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            _buildTeacherSelector(theme),
        ],
      ),
    );
  }

  Widget _buildTeacherSelector(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: filteredTeachers.any((t) =>
              '${t['NoEmpleado']}_${t['NomMateria']}' == selectedTeacherId)
          ? selectedTeacherId
          : null,
      items: filteredTeachers.asMap().entries.map((entry) {
        final teacher = entry.value;
        final value = '${teacher['NoEmpleado']}_${teacher['NomMateria']}';
        final display =
            '${teacher['teacher'].toString().trim()}  | ${teacher['NomMateria']?.toString().trim()}';
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            display,
            style: theme.textTheme.bodyMedium,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedTeacher = filteredTeachers.firstWhere(
            (teacher) =>
                teacher['NoEmpleado'].toString().trim() ==
                    value!.split('_')[0] &&
                teacher['NomMateria'] == value.split('_')[1],
            orElse: () => {},
          );
          selectedSubject = value!.split('_')[1].trim();
          selectedSubjectId = selectedTeacher!['ClaMateria'];
          selectedTeacherId = value;
          handleDisciplinaryReport(
              kindOfReportValue! + 1, selectedStudent!.gradoSecuencia!);
        });
      },
      decoration: InputDecoration(
        labelText: 'Selecciona Docente y Materia',
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
      ),
    );
  }

  Widget _buildCausesCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.list_alt,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Causas del Reporte',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _buildCauseMultiSelector(theme),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCauseMultiSelector(ThemeData theme) {
    if (causesList.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Seleccione un docente para ver las causas disponibles',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }
    return List<Widget>.generate(causesList.length, (int index) {
      final isSelected = _selectedChips.contains(index);
      return FilterChip(
        label: Text(
          '${causesList[index]['NomCausa']}',
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onSecondary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedChips.add(index);
              final cause = (responseBackend as List).firstWhere(
                (item) =>
                    item['NomCausa'].toString().trim() ==
                    causesList[index]['NomCausa'].toString().trim(),
                orElse: () => null,
              );
              if (cause != null) {
                selectedCausesId.add(cause['clacausa'].toString().trim());
              }
            } else {
              _selectedChips.remove(index);
              final cause = (responseBackend as List).firstWhere(
                (item) =>
                    item['NomCausa'].toString().trim() ==
                    causesList[index]['NomCausa'].toString().trim(),
                orElse: () => null,
              );
              if (cause != null) {
                selectedCausesId.remove(cause['clacausa'].toString().trim());
              }
            }
          });
        },
        backgroundColor: theme.colorScheme.surfaceVariant,
        selectedColor: theme.colorScheme.secondary,
        checkmarkColor: theme.colorScheme.onSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    });
  }

  Widget _buildObservationsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.notes,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Observaciones',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Observaciones adicionales',
              hintText: 'Describa detalles adicionales del incidente...',
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
            ),
            controller: observationsController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: _handleSaveReport,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Reporte'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSaveReport() {
    if (selectedStudent == null ||
        selectedTeacher == null ||
        selectedSubject == null) {
      showErrorFromBackend(context, 'Campo(s) vacio(s)');
      return;
    }

    showConfirmationDialog(
      context,
      'Confirmar Reporte Disciplinario',
      'Alumno: ${selectedStudent!.nombre} \nMaestro: ${selectedTeacher!['teacher']} \nMateria: $selectedSubject',
    ).then((response) {
      if (response == 1) {
        try {
          composeBody(
            selectedCausesId,
            selectedStudent!.matricula!,
            kindOfReportValue! + 1,
            selectedDateTime!.year.toString() +
                selectedDateTime!.month.toString().padLeft(2, '0') +
                selectedDateTime!.day.toString().padLeft(2, '0'),
            selectedTeacher!['NoEmpleado'],
            '${selectedDateTime!.hour}:${selectedDateTime!.minute}',
            observationsController.text,
            selectedSubjectId!,
            selectedStudent!.gradoSecuencia!,
            selectedStudent!.claUn!,
          );
          handleCreateDisciplinaryReport();
        } catch (e) {
          if (mounted) {
            showErrorFromBackend(context, e.toString());
          }
        }
      }
    });
  }

  Future<dynamic> handleReload(String cycle) async {
    try {
      var response = await getSimpleStudentsByCycle(cycle);
      var teachersList = await getTeachersListByCycle(cycle);
      setState(() {
        if (studentsNames.isNotEmpty) {
          studentsNames.clear();
        }
        if (students.isNotEmpty) {
          students.clear();
        }
        students = response;
        teachers = teachersList;
        for (var element in students) {
          studentsNames.add(element.nombre!);
        }
      });
      if (response.isEmpty) {
        return [];
      }
      return response;
    } catch (e) {
      return null;
    }
  }

  void handleDisciplinaryReport(int kindOfReport, int gradeSequence) {
    populateDisciplinaryReport(kindOfReport, gradeSequence)
        .onError((error, stackTrace) {
      if (mounted) {
        showErrorFromBackend(context, error.toString());
      }
    });
  }

  Future<dynamic> populateDisciplinaryReport(
      int kindOfReport, int gradeSequence) async {
    try {
      await getDisciplinaryCausesToPopulateScreen(kindOfReport, gradeSequence)
          .then((response) {
        if (response != null) {
          responseBackend = response;
          Map<dynamic, String> causes = {};
          for (var item in response) {
            causes.addAll({
              item['idcausa']: item['NomCausa'].toString().trim(),
            });
          }

          setState(() {
            causesList = causes.entries
                .map((entry) => {
                      'idcausa': entry.key,
                      'NomCausa': entry.value,
                    })
                .toList();
          });
        } else {
          throw Exception('Server returned null value');
        }
      }).onError((error, stackTrace) {
        throw Future.error(error.toString());
      });
    } catch (e) {
      throw Future.error(e.toString());
    }
  }

  void handleCreateDisciplinaryReport() async {
    await createDisciplinaryReportF(body).then((response) {
      clearForm();
      Navigator.pop(context);
      showInformationDialog(context, "Éxito",
          "Registro creado con éxito, reporte numero: ${response['record']}");
      clearForm();
    }).onError((error, stackTrace) {
      showErrorFromBackend(context, error.toString());
    });
  }

  void clearForm() {
    setState(() {
      selectedStudent = null;
      selectedTeacher = null;
      selectedSubject = null;
      selectedTeacherId = null;
      selectedSubjectId = null;
      selectedDateTime = null;
      observationsController.clear();
      _selectedChips.clear();
      selectedCausesId.clear();
      kindOfReportValue = 0;
    });
  }

  void composeBody(
      Set<String> causes,
      String studentId,
      int kindOfReport,
      String date,
      int teacherNumber,
      String time,
      String observations,
      int subjectId,
      int gradeSeq,
      String campus) {
    try {
      showIsLoadingAlertDialog(context);
      setState(() {
        body.clear();
        body.addAll({
          'causes': causes.toList(),
          'studentId': studentId,
          'kindOfReport': kindOfReport,
          'date': date,
          'teacherNumber': teacherNumber,
          'time': time,
          'observations': observations,
          'subjectId': subjectId,
          'gradeSequence': gradeSeq,
          'campus': campus
        });
      });
    } catch (e) {
      throw Error.safeToString(e);
    }
  }
}
