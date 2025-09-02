import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/presentation/components/quill_rich_text_editor_widget.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list_dio.dart';

class CreateNotificationScreen extends StatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  State<CreateNotificationScreen> createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _richContentJson; // Quill Delta JSON string
  DateTime? _expirationDate;
  String _selectedPriority = 'NORMAL';
  String _selectedType = 'ANUNCIO';
  bool _isLoading = false;
  bool _canExpire = true;

  final List<String> _priorityOptions = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];
  final List<String> _typeOptions = [
    'ANUNCIO',
    'ALERTA',
    'INFO',
    'ADVERTENCIA'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select expiration date',
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'Select expiration time',
      );

      if (time != null) {
        setState(() {
          _expirationDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _onRichContentChanged(String quillDeltaJson) {
    setState(() {
      _richContentJson = quillDeltaJson;
    });
  }

  int _getPriorityValue(String priority) {
    switch (priority) {
      case 'LOW':
        return 0;
      case 'NORMAL':
        return 1;
      case 'HIGH':
        return 2;
      case 'URGENT':
        return 3;
      default:
        return 1; // Default to NORMAL
    }
  }

  int _getTypeValue(String type) {
    switch (type) {
      case 'ANUNCIO':
      case 'ANNOUNCEMENT':
        return 1; // anuncio
      case 'ALERTA':
      case 'ALERT':
        return 2; // alerta
      case 'INFO':
        return 3; // info
      case 'ADVERTENCIA':
      case 'WARNING':
        return 4; // advertencia
      default:
        return 1; // Default to ANUNCIO
    }
  }

  Future<void> _createNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_canExpire && _expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expiration date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notificationData = {
        'header': _titleController.text.trim(),
        'body': '',
        'creationDate': null,
        'createdBy': currentUser!.employeeNumber,
        'expires': _canExpire,
        'content': _richContentJson, // Send Quill Delta JSON directly
        'expirationDate':
            _canExpire ? _expirationDate?.toIso8601String() : null,
        'priority': _getPriorityValue(_selectedPriority),
        'notifType': _getTypeValue(_selectedType),
        'isActive': true,
      };

      await createNotification(notificationData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      insertErrorLog(
          e.toString(), 'CreateNotificationScreen._createNotification()');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating notification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _messageController.clear();
    setState(() {
      _richContentJson = null;
      _expirationDate = null;
      _selectedPriority = 'NORMAL';
      _selectedType = 'ANUNCIO';
      _canExpire = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva Notificación',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _resetForm,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Form',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: colorScheme.primaryContainer,
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       // Row(
                    //       //   children: [
                    //       //     Icon(
                    //       //       Icons.add_alert,
                    //       //       color: colorScheme.onPrimaryContainer,
                    //       //       size: 28,
                    //       //     ),
                    //       //     const SizedBox(width: 12),
                    //       //     Text(
                    //       //       'Nueva Notificación',
                    //       //       style: theme.textTheme.headlineSmall?.copyWith(
                    //       //         color: colorScheme.onPrimaryContainer,
                    //       //         fontWeight: FontWeight.bold,
                    //       //       ),
                    //       //     ),
                    //       //   ],
                    //       // ),
                    //       // const SizedBox(height: 8),
                    //       // Text(
                    //       //   'Crea una nueva notificación que se mostrará a los usuarios.',
                    //       //   style: theme.textTheme.bodyMedium?.copyWith(
                    //       //     color: colorScheme.onPrimaryContainer
                    //       //         .withOpacity(0.8),
                    //       //   ),
                    //       // ),
                    //     ],
                    //   ),
                    // ),

                    const SizedBox(height: 12),

                    // Basic Information Section
                    _buildSectionTitle('Información Básica', Icons.info_outline,
                        theme, colorScheme),
                    const SizedBox(height: 16),

                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Título *',
                        hintText: 'Ingrese el título de la notificación',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El título es obligatorio';
                        }
                        if (value.trim().length < 3) {
                          return 'El título debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                      maxLength: 100,
                    ),

                    const SizedBox(height: 20),

                    // Type and Priority Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              labelText: 'Tipo',
                              prefixIcon: const Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _typeOptions.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.toTitleCase),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            decoration: InputDecoration(
                              labelText: 'Prioridad',
                              prefixIcon: const Icon(Icons.priority_high),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _priorityOptions.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getPriorityIcon(priority),
                                      size: 16,
                                      color: _getPriorityColor(priority),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(priority.toTitleCase),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Expiration Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notificación puede expirar',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Activar para establecer una fecha de expiración',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _canExpire,
                            onChanged: (value) {
                              setState(() {
                                _canExpire = value;
                                if (!value) {
                                  _expirationDate = null;
                                }
                              });
                            },
                            activeColor: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Expiration Date
                    InkWell(
                      onTap: _canExpire ? _selectExpirationDate : null,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText:
                              'Fecha y Hora de Expiración ${_canExpire ? '*' : ''}',
                          prefixIcon: Icon(
                            Icons.schedule,
                            color: _canExpire
                                ? null
                                : colorScheme.onSurface.withOpacity(0.38),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabled: _canExpire,
                        ),
                        child: Text(
                          _canExpire
                              ? (_expirationDate != null
                                  ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year} at ${_expirationDate!.hour.toString().padLeft(2, '0')}:${_expirationDate!.minute.toString().padLeft(2, '0')}'
                                  : 'Toca para seleccionar fecha y hora')
                              : 'Esta notificación no expirará',
                          style: TextStyle(
                            color: _canExpire
                                ? (_expirationDate != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface.withOpacity(0.6))
                                : colorScheme.onSurface.withOpacity(0.38),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Message Content Section
                    // _buildSectionTitle('Contenido del Mensaje', Icons.edit_note,
                    //     theme, colorScheme),
                    // const SizedBox(height: 16),

                    // // Plain text message (fallback)
                    // TextFormField(
                    //   controller: _messageController,
                    //   decoration: InputDecoration(
                    //     labelText: 'Mensaje de Texto Plano *',
                    //     hintText:
                    //         'Ingrese un mensaje de respaldo (se muestra si el texto enriquecido falla)',
                    //     prefixIcon: const Icon(Icons.message),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    //   maxLines: 3,
                    //   validator: (value) {
                    //     if (value == null || value.trim().isEmpty) {
                    //       return 'El mensaje de texto plano es obligatorio';
                    //     }
                    //     if (value.trim().length < 10) {
                    //       return 'El mensaje debe tener al menos 10 caracteres';
                    //     }
                    //     return null;
                    //   },
                    //   maxLength: 500,
                    // ),

                    const SizedBox(height: 10),

                    // Rich Text Editor Section
                    _buildSectionTitle('Editor de Contenido Avanzado (Quill)',
                        Icons.edit_note, theme, colorScheme),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Editor avanzado: Seleccione texto para aplicar formato, use la barra de herramientas para estilos y funciones avanzadas.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rich Text Editor
                    QuillRichTextEditorWidget(
                      onContentChanged: _onRichContentChanged,
                      hintText: 'Ingrese el contenido aquí...',
                      maxLines: 8,
                      textStyle: theme.textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _createNotification,
                            icon: const Icon(Icons.send),
                            label: const Text('Crear Notificación'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(
      String title, IconData icon, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'LOW':
        return Icons.keyboard_arrow_down;
      case 'NORMAL':
        return Icons.remove;
      case 'HIGH':
        return Icons.keyboard_arrow_up;
      case 'URGENT':
        return Icons.warning;
      default:
        return Icons.remove;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'LOW':
        return Colors.green;
      case 'NORMAL':
        return Colors.blue;
      case 'HIGH':
        return Colors.orange;
      case 'URGENT':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
