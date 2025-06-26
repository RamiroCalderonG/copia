// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';

import 'package:oxschool/data/Models/Event.dart';
import 'package:oxschool/data/Models/Module.dart';
import 'package:oxschool/data/Models/Role.dart';
import 'package:oxschool/presentation/Modules/user/user_events_manager.dart';

import 'package:oxschool/presentation/Modules/login_view/login_view_widget.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

import '../../../data/services/backend/api_requests/api_calls_list.dart';

class RolesAndProfilesScreen extends StatefulWidget {
  const RolesAndProfilesScreen({super.key});

  @override
  State<RolesAndProfilesScreen> createState() => _RolesAndProfilesScreenState();
}

class _RolesAndProfilesScreenState extends State<RolesAndProfilesScreen> {
  int selectedCardIndex = -1;
  late Future<dynamic> rolesList;
  List<Module> modulesList = [];
  List<Role> rolesListData = [];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    tmpeventsList.clear();
    // checkboxValues.clear();
    // roleCanAcces.clear();
    tmpRolesList.clear();
    rolesListData.clear();
    super.dispose();
  }

  void _fetchData() async {
    setState(() {
      isLoading = true;
      rolesListData.clear();
    });
    modulesList = await fetchModulesAndEventsDetailed();
    getRolesTempList().whenComplete(() {
      setState(() {
        for (var item in tmpRolesList) {
          Role role = Role.fromJson(item);
          rolesListData.add(role);
        }
        for (var jsonevent in tmpeventsList) {
          Event event = Event.fromJSON(jsonevent);
          for (var i = 0; i < rolesListData.length; i++) {
            if (rolesListData[i].roleID == event.roleID) {
              rolesListData[i].events?.add(event);
            }
          }
        }
      });
    }).catchError((onError) {
      insertErrorLog(onError.toString(), 'getRolesTempList()');
      showErrorFromBackend(context, onError.toString());
    });
  }

  dynamic handleDeleteRole(int index) async {
    var response = await showConfirmationDialog(context, 'Confirmar',
        '¿Eliminar el rol ${rolesListData[index].roleName}?');
    if (response == 1) {
      insertActionIntoLog('DELETE ROLE ACTION >> ',
          'User : ${currentUser!.employeeName}  deleted the role ${rolesListData[index].roleName}');
      int roleId = rolesListData[index].roleID;
      await deleteRole(roleId).then((value) {
        setState(() {
          tmpRolesList.removeAt(index);
          // isLoading = false;
        });
        showInformationDialog(context, 'Exito', 'Rol eliminado exitosamente');
      });
    } else {
      insertActionIntoLog('DELETE ROLE ACTION CANCELED >> ',
          'User : ${currentUser!.employeeName} canceled the action of deleting the role ${rolesListData[index].roleName}');
      // Navigator.pop(context);
    }
  }

  Widget roleContainerCard(int index) {
    ListView resultItems = ListView();
    if (rolesListData[index].events != null) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: rolesListData[index].events!.length,
          itemBuilder: (context, eventIndex) {
            return SwitchListTile(
              title: Text(rolesListData[index].events![eventIndex].eventName),
              value: rolesListData[index].events![eventIndex].canAcces,
              onChanged: (value) async {
                setState(() {
                  rolesListData[index].events![eventIndex].canAcces = value;
                  isLoading = true;
                });
                await modifyActiveOfEventRole(
                    rolesListData[index].events![eventIndex].eventID,
                    value,
                    rolesListData[index].events![eventIndex].roleID);
                setState(() {
                  isLoading = false;
                  rolesListData[index].events![eventIndex].isActive = value;
                });
              },
              controlAffinity: ListTileControlAffinity.trailing,
            );
          });
    } else {
      return resultItems;
    }
  }

  Future<void> _showEditRoleScreen(
      BuildContext context, int index, bool isActive) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditRoleScreen(
          role: rolesListData[index].roleName,
          description: rolesListData[index].roleDescription,
          isActive: isActive, // Pass the isActive value
          roleCanAcces: rolesListData[index].isActive,
          roleSelected: rolesListData[index],
        ),
      ),
    );
    if (result != null &&
        result.containsKey('softName') &&
        result.containsKey('description')) {
      setState(() {
        rolesListData[index].roleName = result['softName'];
        rolesListData[index].roleDescription = result['description'];
        // role_id[index] = result['role_id'];
      });
    }
  }

  void _showAddRoleScreen(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEditRoleScreen(),
      ),
    );
    if (result != null &&
        result.containsKey('softName') &&
        result.containsKey('description')) {
      // setState(() {
      //   roles.add(result['softName']);
      //   description.add(result['description']);
      //   isActive.add(result['isActive']);
      //   // role_id.add(result['role_id']);
      // });
    }
  }

  Future<void> deleteRole(int roleId) async {
    try {
      await deleteRoleCall(roleId);
    } catch (e) {
      insertErrorLog(e.toString(), 'deleteRole($roleId)');
      throw Future.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 600) {
              return _buildMobileLayout(theme, colorScheme);
            } else {
              return _buildDesktopLayout(theme, colorScheme);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tablet_android_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Vista de Escritorio Requerida',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'La administración de roles requiere una pantalla más grande para una mejor experiencia.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, ColorScheme colorScheme) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Administración de Roles',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            FilledButton.tonalIcon(
              onPressed: () => _showAddRoleScreen(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo Rol'),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
            ),
            const SizedBox(width: 16),
          ],
          floating: true,
          snap: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lista de Roles del Sistema',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Chip(
                          avatar: Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          label: Text('${rolesListData.length} roles'),
                          backgroundColor: colorScheme.secondaryContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    if (rolesListData.isEmpty)
                      _buildEmptyState(theme, colorScheme)
                    else
                      _buildRolesList(theme, colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.security_rounded,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay roles disponibles',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza creando tu primer rol del sistema',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddRoleScreen(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear Primer Rol'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesList(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: List.generate(
        rolesListData.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: rolesListData[index].isActive
                          ? colorScheme.primaryContainer
                          : colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      rolesListData[index].isActive
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: rolesListData[index].isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onErrorContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rolesListData[index].roleName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          rolesListData[index].roleDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      rolesListData[index].isActive ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: rolesListData[index].isActive
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: rolesListData[index].isActive
                        ? colorScheme.primaryContainer
                        : colorScheme.errorContainer,
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        icon: Icons.security_rounded,
                        label: 'Permisos',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoliciesScreen(
                              roleID: rolesListData[index].roleID,
                              roleName: rolesListData[index].roleName,
                              roleListData: rolesListData,
                            ),
                          ),
                        ),
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.edit_rounded,
                        label: 'Editar',
                        onPressed: () => _showEditRoleScreen(
                          context,
                          index,
                          rolesListData[index].isActive,
                        ),
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                      if (!rolesListData[index].isActive)
                        _buildActionButton(
                          icon: Icons.play_arrow_rounded,
                          label: 'Activar',
                          onPressed: () => _toggleRoleStatus(index, true),
                          theme: theme,
                          color: colorScheme.primary,
                        )
                      else
                        _buildActionButton(
                          icon: Icons.pause_rounded,
                          label: 'Desactivar',
                          onPressed: () => _toggleRoleStatus(index, false),
                          theme: theme,
                          color: colorScheme.error,
                        ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Eliminar',
                        onPressed: () => _deleteRole(index),
                        theme: theme,
                        color: colorScheme.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
    Color? color,
  }) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: color != null
          ? FilledButton.styleFrom(
              foregroundColor: color,
            )
          : null,
    );
  }

  void _toggleRoleStatus(int index, bool isActive) async {
    setState(() {
      isLoading = true;
    });

    try {
      var roleId = rolesListData[index].roleID;
      var bodyEdit = {'isActive': isActive};
      await editRole(roleId, bodyEdit, 3);
      _fetchData();
    } catch (e) {
      showErrorFromBackend(context, e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _deleteRole(int index) async {
    try {
      await handleDeleteRole(index);
      _fetchData();
    } catch (e) {
      showErrorFromBackend(context, e.toString());
    }
  }
}

class AddEditRoleScreen extends StatefulWidget {
  final String? role;
  final String? description;
  final bool? isActive;
  final bool? roleCanAcces;
  final Role? roleSelected;

  const AddEditRoleScreen(
      {super.key,
      this.role,
      this.description,
      this.isActive,
      this.roleCanAcces,
      this.roleSelected});

  @override
  _AddEditRoleScreenState createState() => _AddEditRoleScreenState();
}

class _AddEditRoleScreenState extends State<AddEditRoleScreen> {
  late TextEditingController _roleController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  Map<int, bool> roleEventActive = {};
  bool isRoleAdmin = false;
  bool isRoleAcademicCoord = false;
  int? selectedRoleChipValue;
  Map<String, dynamic>? roleDetailedData;

  @override
  void initState() {
    _roleController = TextEditingController(text: widget.role ?? '');
    _descriptionController =
        TextEditingController(text: widget.description ?? '');
    _isActive = widget.isActive ?? false;

    if (widget.role != null) {
      getRoleDetail(widget.roleSelected!.roleID);
    }
    super.initState();
  }

  @override
  void dispose() {
    _roleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void getRoleDetail(int roleId) async {
    await getRoleDetailCall(roleId).then(
      (value) {
        var response = json.decode(value);
        setState(() {
          selectedRoleChipValue = response!['value'];
        });
      },
    ).onError((handleError, stackTrace) {
      insertErrorLog(handleError.toString(), 'getRoleDetail($roleId)');
      showErrorFromBackend(context, handleError.toString());
    });
  }

  Future<void> _updateRole(BuildContext context, int roleID) async {
    // Prepare JSON data for update
    final jsonData = {
      'name': _roleController.text,
      'description': _descriptionController.text,
      'isActive': _isActive,
      'roleValue': selectedRoleChipValue,
    };
    var updatedRole = [
      _roleController.text,
      _descriptionController.text,
      _isActive,
    ];
    setState(() {
      isLoading = true;
    });

    await editRole(roleID, jsonData, 4);
    setState(() {
      tmpRolesList.removeAt(roleID);
      tmpRolesList.add(updatedRole);
      isLoading = false;
    });
  }

  //Function to create a new Role at DB, this does not work with Events yet
  Future<void> _addRole(BuildContext context) async {
    try {
      final jsonData = {
        'roleName': _roleController.text,
        'roleDescription': _descriptionController.text,
        'roleActive': _isActive,
        'roleValue': selectedRoleChipValue,
      };
      await createRole(jsonData);
    } catch (e) {
      insertErrorLog(e.toString(), '_addRole() | roles_screen: 465');
      throw Future.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    List<String> kindOfRole = [
      'Administrador del sistema',
      'Coordinador académico',
      'Ninguno de los anteriores'
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
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              surfaceTintColor: Colors.transparent,
              title: Text(
                widget.role != null ? 'Editar Rol' : 'Crear Rol',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Rol',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Role Name Field
                        TextFormField(
                          controller: _roleController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del Rol',
                            hintText: 'Ingresa el nombre del rol',
                            prefixIcon: Icon(Icons.badge_rounded),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description Field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            hintText: 'Describe las responsabilidades del rol',
                            prefixIcon: Icon(Icons.description_rounded),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        // Status Section
                        Text(
                          'Estado del Rol',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Activo'),
                              selected: _isActive,
                              onSelected: (selected) {
                                setState(() {
                                  _isActive = selected;
                                });
                              },
                              selectedColor: colorScheme.primaryContainer,
                              checkmarkColor: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Inactivo'),
                              selected: !_isActive,
                              onSelected: (selected) {
                                setState(() {
                                  _isActive = !selected;
                                });
                              },
                              selectedColor: colorScheme.errorContainer,
                              checkmarkColor: colorScheme.onErrorContainer,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Role Type Section
                        Text(
                          'Tipo de Rol',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: List<Widget>.generate(3, (int index) {
                            return ChoiceChip(
                              label: Text(kindOfRole[index]),
                              selected: selectedRoleChipValue == index,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedRoleChipValue =
                                      selected ? index : null;
                                });
                              },
                              selectedColor: colorScheme.secondaryContainer,
                              checkmarkColor: colorScheme.onSecondaryContainer,
                            );
                          }),
                        ),

                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 16),
                            FilledButton.icon(
                              onPressed: _submitRole,
                              icon: Icon(widget.role != null
                                  ? Icons.save_rounded
                                  : Icons.add_rounded),
                              label: Text(widget.role != null
                                  ? 'Actualizar Rol'
                                  : 'Crear Rol'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRole() async {
    // Validation
    if (_roleController.text.trim().isEmpty) {
      showEmptyFieldAlertDialog(context, 'El nombre del rol es requerido');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      showEmptyFieldAlertDialog(context, 'La descripción del rol es requerida');
      return;
    }

    if (selectedRoleChipValue == null) {
      showEmptyFieldAlertDialog(context, 'Selecciona el tipo de rol');
      return;
    }

    try {
      if (widget.role != null) {
        // Update existing role
        int roleId = widget.roleSelected!.roleID;
        if (roleId != 0) {
          await _updateRole(context, roleId);
          showInformationDialog(
              context, 'Éxito', 'Rol actualizado correctamente');
          Navigator.of(context).pop();
        }
      } else {
        // Create new role
        await _addRole(context);
        showInformationDialog(context, 'Éxito', 'Rol creado correctamente');
        Navigator.of(context).pop();
      }
    } catch (e) {
      insertErrorLog(e.toString(), 'Submit role | roles_screen');
      showErrorFromBackend(context, e.toString());
    }
  }
}

int getRoleIdValue(List<dynamic> rolesList, String roleName) {
  for (var role in rolesList) {
    if (role["softName"] == roleName) {
      return role["id"];
    }
  }
  return 0; // Role not found
}

List<String> getEventNamesForRole(String roleName, List<dynamic> json) {
  List<String> eventNames = [];
  for (var item in json) {
    if (item['RoleName'] == roleName) {
      eventNames.add(item['EventName']);
    }
  }
  return eventNames;
}
