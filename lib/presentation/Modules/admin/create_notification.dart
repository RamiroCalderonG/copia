import 'package:flutter/material.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/presentation/components/rich_text_editor_widget.dart';
import 'package:oxschool/data/Models/RichTextContent.dart';
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

  RichTextContent? _richContent;
  DateTime? _expirationDate;
  String _selectedPriority = 'NORMAL';
  String _selectedType = 'ANNOUNCEMENT';
  bool _isLoading = false;

  final List<String> _priorityOptions = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];
  final List<String> _typeOptions = [
    'ANNOUNCEMENT',
    'ALERT',
    'INFO',
    'WARNING'
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

  void _onRichContentChanged(RichTextContent content) {
    setState(() {
      _richContent = content;
    });
  }

  Future<void> _createNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_expirationDate == null) {
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
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'content': _richContent?.toJson(),
        'expirationDateTime': _expirationDate!.toIso8601String(),
        'priority': _selectedPriority,
        'type': _selectedType,
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
      _richContent = null;
      _expirationDate = null;
      _selectedPriority = 'NORMAL';
      _selectedType = 'ANNOUNCEMENT';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notification'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.add_alert,
                                color: colorScheme.onPrimaryContainer,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'New Notification',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a new notification with rich text content that will be displayed to users.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer
                                  .withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Basic Information Section
                    _buildSectionTitle('Basic Information', Icons.info_outline,
                        theme, colorScheme),
                    const SizedBox(height: 16),

                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title *',
                        hintText: 'Enter notification title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Title must be at least 3 characters';
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
                              labelText: 'Type',
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
                              labelText: 'Priority',
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

                    const SizedBox(height: 20),

                    // Expiration Date
                    InkWell(
                      onTap: _selectExpirationDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Expiration Date & Time *',
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _expirationDate != null
                              ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year} at ${_expirationDate!.hour.toString().padLeft(2, '0')}:${_expirationDate!.minute.toString().padLeft(2, '0')}'
                              : 'Tap to select date and time',
                          style: TextStyle(
                            color: _expirationDate != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Message Content Section
                    _buildSectionTitle(
                        'Message Content', Icons.edit_note, theme, colorScheme),
                    const SizedBox(height: 16),

                    // Plain text message (fallback)
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Plain Text Message *',
                        hintText:
                            'Enter fallback message (displayed if rich text fails)',
                        prefixIcon: const Icon(Icons.message),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Plain text message is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Message must be at least 10 characters';
                        }
                        return null;
                      },
                      maxLength: 500,
                    ),

                    const SizedBox(height: 24),

                    // Rich Text Editor Section
                    _buildSectionTitle('Rich Text Content', Icons.format_paint,
                        theme, colorScheme),
                    const SizedBox(height: 8),
                    Text(
                      'Use the rich text editor below to format your notification with bold, italic, colors, and different font sizes.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rich Text Editor
                    RichTextEditorWidget(
                      onContentChanged: _onRichContentChanged,
                      hintText: 'Enter your rich text message here...',
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
                            label: const Text('Cancel'),
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
                            label: const Text('Create Notification'),
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
