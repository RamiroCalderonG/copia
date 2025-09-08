import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/data/datasources/temp/studens_temp.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

class NewFODAC27CommentDialog extends StatefulWidget {
  final String selectedstudentId;
  final int employeeNumber;
  final VoidCallback onDialogClose;

  const NewFODAC27CommentDialog({
    super.key,
    required this.selectedstudentId,
    required this.employeeNumber,
    required this.onDialogClose,
  });

  @override
  _NewFODAC27CommentDialogState createState() =>
      _NewFODAC27CommentDialogState();
}

class _NewFODAC27CommentDialogState extends State<NewFODAC27CommentDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  String? _selectedSubject;
  List<String> _materias = [];
  Map<String, dynamic> subjectsMap = {};
  bool isLoading = false;
  late Future<dynamic> loadingDone;
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void initState() {
    isLoading = true;
    loadingDone = getSubjects();
    // isLoading = false;

    super.initState();
    //_dateController.text = "22/07/2024"; // Initial date
  }

  @override
  void dispose() {
    tempStudentMap.clear();
    _dateController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> getSubjects() async {
    Map<String, dynamic> subjects = await populateSubjectsDropDownSelector(
        widget.selectedstudentId, currentCycle!.claCiclo!);

    _materias = subjects.keys.toList();
    subjectsMap = subjects;
    isLoading = false;
  }

  Future<void> _addNewComment() async {
    if (_formKey.currentState!.validate()) {
      var subjectID = subjectsMap[_selectedSubject];

      if (subjectID == null) {
        debugPrint('Subject does not exist in the map');
        return;
      }
      try {
        await createFodac27Record(
          _selectedDate!,
          widget.selectedstudentId,
          currentCycle!.claCiclo!,
          _observacionesController.text,
          widget.employeeNumber,
          subjectID,
        ).catchError((e) {
          return showErrorFromBackend(context, e.toString());
        }).whenComplete(() {
          return;
        });
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        return Future.error(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder(
      future: loadingDone,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomLoadingIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Cargando materias...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 32,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        } else {
          return _buildFormContent(theme, colorScheme);
        }
      },
    );
  }

  Widget _buildFormContent(ThemeData theme, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final spacing = isSmallScreen ? 12.0 : 16.0;

        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Subject Selection
                _buildDateAndSubjectSection(theme, colorScheme, isSmallScreen),
                SizedBox(height: spacing),
                // Habits and Conduct Section
                _buildHabitsAndConductSection(
                    theme, colorScheme, isSmallScreen),
                SizedBox(height: spacing),
                // Observations Section
                _buildObservationsSection(theme, colorScheme, isSmallScreen),
                SizedBox(height: spacing * 1.5),
                // Action Buttons
                _buildActionButtons(theme, colorScheme, isSmallScreen),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateAndSubjectSection(
      ThemeData theme, ColorScheme colorScheme, bool isSmallScreen) {
    final padding = isSmallScreen ? 12.0 : 16.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: colorScheme.primary,
                size: isSmallScreen ? 16 : 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Información del Registro',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          Flex(
            direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
            children: [
              Flexible(
                flex: isSmallScreen ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha *',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                        hintText: 'Seleccionar fecha',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, seleccione una fecha';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: isSmallScreen ? 0 : 16,
                height: isSmallScreen ? 16 : 0,
              ),
              Flexible(
                flex: isSmallScreen ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Materia *',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        hintText: 'Seleccionar materia',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSubject = newValue;
                        });
                      },
                      items: _materias.map((String materia) {
                        return DropdownMenuItem<String>(
                          value: materia,
                          child: Text(
                            materia,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, seleccione una materia';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsAndConductSection(
      ThemeData theme, ColorScheme colorScheme, bool isSmallScreen) {
    final padding = isSmallScreen ? 12.0 : 16.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: colorScheme.secondary,
                size: isSmallScreen ? 16 : 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Evaluación Socioemocional',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Flex(
            direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
            children: [
              Flexible(
                flex: isSmallScreen ? 0 : 1,
                child: _buildSectionCard(
                  theme: theme,
                  colorScheme: colorScheme,
                  title: 'Hábitos',
                  icon: Icons.star_outline,
                  isEmpty: true,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(
                width: isSmallScreen ? 0 : 16,
                height: isSmallScreen ? 12 : 0,
              ),
              Flexible(
                flex: isSmallScreen ? 0 : 1,
                child: _buildSectionCard(
                  theme: theme,
                  colorScheme: colorScheme,
                  title: 'Conductas',
                  icon: Icons.emoji_people_outlined,
                  isEmpty: true,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String title,
    required IconData icon,
    required bool isEmpty,
    required bool isSmallScreen,
  }) {
    final cardHeight = isSmallScreen ? 120.0 : 150.0;

    return Container(
      height: cardHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: isSmallScreen ? 14 : 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Sel',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: isSmallScreen ? 20 : 24,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'No existen $title',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildObservationsSection(
      ThemeData theme, ColorScheme colorScheme, bool isSmallScreen) {
    final padding = isSmallScreen ? 12.0 : 16.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final textFieldLines = isSmallScreen ? 4 : 6;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_outlined,
                color: colorScheme.tertiary,
                size: isSmallScreen ? 16 : 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Observaciones Generales *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          TextFormField(
            controller: _observacionesController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              hintText: 'Escriba sus observaciones aquí...',
              alignLabelWithHint: true,
            ),
            maxLines: textFieldLines,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese observaciones';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      ThemeData theme, ColorScheme colorScheme, bool isSmallScreen) {
    return Flex(
      direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
      children: [
        Flexible(
          flex: isSmallScreen ? 0 : 1,
          child: SizedBox(
            width: isSmallScreen ? double.infinity : null,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, size: isSmallScreen ? 16 : 18),
              label: Text(
                'Cancelar',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 10 : 12,
                  horizontal: isSmallScreen ? 16 : 24,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: isSmallScreen ? 0 : 16,
          height: isSmallScreen ? 12 : 0,
        ),
        Flexible(
          flex: isSmallScreen ? 0 : 1,
          child: SizedBox(
            width: isSmallScreen ? double.infinity : null,
            child: FilledButton.icon(
              onPressed: () {
                _addNewComment().then((_) {
                  if (mounted) {
                    Navigator.pop(context);
                    showSuccessDialog(
                        context, 'Éxito', 'Registro agregado exitosamente');
                  }
                }).onError((error, stackTrace) {
                  showErrorFromBackend(context, error.toString());
                });
              },
              icon: Icon(Icons.save, size: isSmallScreen ? 16 : 18),
              label: Text(
                'Guardar',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 10 : 12,
                  horizontal: isSmallScreen ? 16 : 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
