import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/services_functions.dart';

class CreateServiceTicket extends StatefulWidget {
  const CreateServiceTicket({super.key});

  @override
  State<CreateServiceTicket> createState() => _CreateServiceTicketState();
}

class _CreateServiceTicketState extends State<CreateServiceTicket> {
  final _formKey = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _descriptionController = TextEditingController();
  final _observationsController = TextEditingController();
  List<String> employeeList = <String>[];
  String? deptSelected;
  late Future<dynamic> usersListFuture;
  List<String> deptsList = <String>[];
  String campusSelected = '';
  DateTime? finalDateTime;
  String whoRequest = '';

  Map<int, dynamic> deptsMap = {};
  List<Map<String, dynamic>> usersMapsL = [];

  @override
  void dispose() {
    _date.dispose();
    _descriptionController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    fetchUsersList(1, '');
    super.initState();
  }

  void fetchUsersList(int filter, String item) {
    usersListFuture = getUsersList(filter, item).then((value) {
      usersMapsL = value;
      getEmployeesNames(value);
      getDepartments().then((onValue) {
        deptsMap = onValue;
        deptsMap.forEach((key, value) {
          setState(() {
            deptsList.add(value);
          });
        });
      }).onError((error, StackTrace) {
        insertErrorLog(error.toString(), 'getDepartments()');
        throw Future.error(error.toString());
      });
    }).onError((error, stacktrace) {
      insertErrorLog(error.toString(),
          'Error al obtener la lista de empleados | fetchUsersList()');
    });
  }

  void getEmployeesNames(List<Map<String, dynamic>> usersLists) {
    setState(() {
      employeeList.clear();
      for (var element in usersLists) {
        if (element['name'] != null) {
          employeeList.add(element['name'].toString());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const List<String> campusList = <String>[
      'Anahuac',
      'Barragan',
      'Concordia',
      'HighSchool',
      'Sendero'
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.surface,
              colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: FutureBuilder(
          future: usersListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(theme, snapshot.error.toString());
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(theme);
            } else {
              return _buildMainContent(theme, colorScheme, campusList);
            }
          },
        ),
      ),
    );
  }

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.black87,
    backgroundColor: Colors.grey[300],
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar datos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => setState(() {
                  fetchUsersList(1, '');
                }),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando datos...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
      ThemeData theme, ColorScheme colorScheme, List<String> campusList) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          backgroundColor:
              FlutterFlowTheme.of(context).primary, //Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Crear Ticket de Servicio',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          floating: true,
          snap: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Ticket',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Campus Selection
                      _buildDropdownField(
                        theme,
                        label: 'Campus',
                        value: campusSelected.isEmpty ? null : campusSelected,
                        items: campusList,
                        onChanged: (value) =>
                            setState(() => campusSelected = value ?? ''),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor selecciona un campus'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Department Selection
                      _buildDropdownField(
                        theme,
                        label: 'Departamento',
                        value: deptSelected,
                        items: deptsList,
                        onChanged: (value) =>
                            setState(() => deptSelected = value),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor selecciona un departamento'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Employee Selection
                      _buildDropdownField(
                        theme,
                        label: 'Empleado Solicitante',
                        value: whoRequest.isEmpty ? null : whoRequest,
                        items: employeeList,
                        onChanged: (value) =>
                            setState(() => whoRequest = value ?? ''),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor selecciona un empleado'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Date Field
                      TextFormField(
                        controller: _date,
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          hintText: 'Selecciona una fecha',
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                          border: const OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor selecciona una fecha'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción del Problema',
                          hintText:
                              'Describe detalladamente el problema o solicitud',
                          prefixIcon: Icon(Icons.description_rounded),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Por favor ingresa una descripción'
                                : null,
                      ),

                      const SizedBox(height: 16),

                      // Observations Field
                      TextFormField(
                        controller: _observationsController,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones (Opcional)',
                          hintText: 'Agrega cualquier observación adicional',
                          prefixIcon: Icon(Icons.note_add_rounded),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _clearForm,
                            child: const Text('Limpiar'),
                          ),
                          const SizedBox(width: 16),
                          FilledButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.send_rounded),
                            label: const Text('Crear Ticket'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    ThemeData theme, {
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String?> validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.arrow_drop_down_circle_rounded),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        finalDateTime = picked;
        _date.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _clearForm() {
    setState(() {
      _date.clear();
      _descriptionController.clear();
      _observationsController.clear();
      campusSelected = '';
      deptSelected = null;
      whoRequest = '';
      finalDateTime = null;
    });
    _formKey.currentState?.reset();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement form submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ticket creado exitosamente'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
