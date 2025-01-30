// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';

import 'package:oxschool/data/Models/Event.dart';
import 'package:oxschool/presentation/Modules/user/user_events_manager.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';

import 'package:oxschool/presentation/Modules/login_view/login_view_widget.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';

import '../../../data/services/backend/api_requests/api_calls_list.dart';

class RolesAndProfilesScreen extends StatefulWidget {
  const RolesAndProfilesScreen({super.key});

  @override
  State<RolesAndProfilesScreen> createState() => _RolesAndProfilesScreenState();
}

bool _isloading = false;

class _RolesAndProfilesScreenState extends State<RolesAndProfilesScreen> {
  List<String> roles = [];
  List<String> description = [];
  // List<int> role_id = [];
  List<bool> isActive = [];
  List<bool> roleCanAcces = [];

  List<bool> checkboxValues = [];
  int selectedCardIndex = -1;
  late Future<dynamic> rolesList;

  @override
  void initState() {
    // rolesList = getRolesTempList();
    setState(() {
      Map<dynamic, dynamic> eventsAreActive = {};
      for (var item in tmpeventsList) {
        var eventName = item['name'];
        var isEventActive = item['event_active'];

        eventsAreActive[eventName] = isEventActive;

        checkboxValues.add(isEventActive);
        roleCanAcces.add(item['role_event_active']);
      }

      for (var item in tmpRolesList) {
        roles.add(item['softName']);
        description.add(item['description']);
        isActive.add(item['isActive']);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    tmpeventsList.clear();
    checkboxValues.clear();
    super.dispose();
  }

  void _handleRefresh() async {
    setState(() {
      isLoading = true;
      tmpeventsList.clear();
      checkboxValues.clear();
      roleCanAcces.clear();
      tmpRolesList.clear();
      roles.clear();
      description.clear();
      isActive.clear();
    });
    getEventsTempList().whenComplete(() async {
      await getRolesTempList().whenComplete(() {
        setState(() {
          Map<dynamic, dynamic> eventsAreActive = {};
          for (var item in tmpeventsList) {
            var eventName = item['name'];
            var isEventActive = item['event_active'];

            eventsAreActive[eventName] = isEventActive;

            checkboxValues.add(isEventActive);
            roleCanAcces.add(item['role_event_active']);
          }

          for (var item in tmpRolesList) {
            roles.add(item['softName']);
            description.add(item['description']);
            isActive.add(item['isActive']);
          }
        });
      }).catchError((onError) {
        insertErrorLog(onError.toString(), 'getRolesTempList()');
        showErrorFromBackend(context, onError.toString());
      });
    });
  }

  Widget roleContainerCard(String role, String desc, int index) {
    List events =
        tmpeventsList.where((event) => event['soft_name'] == role).toList();

    return ExpansionTile(
      title: Row(
        children: [
          Text(
            role,
            style: const TextStyle(
                fontFamily: 'Sora', fontWeight: FontWeight.bold),
          ),
          if (!isActive[index]) // Conditionally show red dot
            Container(
              margin: const EdgeInsets.only(left: 5), // Adjust margin as needed
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
        ],
      ),
      subtitle: Text(desc),
      children: [
        for (var event in events)
          SwitchListTile(
            title: Text(event['name']),
            value: event['role_event_active'],
            onChanged: (value) async {
              setState(() {
                _isloading = true;
              });
              await modifyActiveOfEventRole(event['id'], value, event['id']);
              setState(() {
                _isloading = false;
                event['event_active'] = value;
              });
            },
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 5),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar Rol (Proximamente)',
                onPressed: () async {
                  //TODO: VERIFY IF ITS NEEDED, OR ONLY LOGIC
                },
              ),
              if (tmpRolesList[index]['isActive'] == false)
                IconButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    var roleId = tmpRolesList[index]['id'];
                    var bodyEdit = {'isActive': true};
                    await editRole(roleId, bodyEdit, 3);
                    setState(() {
                      isLoading = false;
                    });
                    _handleRefresh();
                  },
                  icon: const Icon(Icons.arrow_circle_up),
                  tooltip: 'Activar Rol',
                ),
              if (tmpRolesList[index]['isActive'] == true)
                IconButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      var roleId = tmpRolesList[index]['id'];
                      var bodyEdit = {'isActive': false};
                      await editRole(roleId, bodyEdit, 3);
                      setState(() {
                        isLoading = false;
                      });
                      _handleRefresh();
                    },
                    tooltip: 'Desactivar rol',
                    icon: const Icon(Icons.arrow_circle_down_outlined)),
              const SizedBox(width: 5),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Editar Rol',
                onPressed: () async {
                  await _showEditRoleScreen(context, index, isActive[index]);
                },
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PoliciesScreen(
                                roleID: tmpRolesList[index]['id'],
                                roleName: tmpRolesList[index]['softName'],
                              )));
                },
                icon: const Icon(Icons.security),
                tooltip: 'Administrar Políticas',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showEditRoleScreen(
      BuildContext context, int index, bool isActive) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditRoleScreen(
            role: roles[index],
            description: description[index],
            isActive: isActive, // Pass the isActive value
            roleCanAcces: roleCanAcces[index]),
      ),
    );
    if (result != null &&
        result.containsKey('softName') &&
        result.containsKey('description')) {
      setState(() {
        roles[index] = result['softName'];
        description[index] = result['description'];
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
      setState(() {
        roles.add(result['softName']);
        description.add(result['description']);
        isActive.add(result['isActive']);
        // role_id.add(result['role_id']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin. de rol de usuario',
            style: TextStyle(color: Colors.white)),
        backgroundColor: FlutterFlowTheme.of(context)
            .primary, // Assuming FlutterFlowTheme is not available
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            return const Card(
              child: Placeholder(),
            );
          } else {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 20),
                      TextButton.icon(
                          onPressed: () {
                            _showAddRoleScreen(context);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Nuevo Rol')),
                      const SizedBox(width: 20),
                      RefreshButton(onPressed: _handleRefresh)
                      // TextButton.icon(
                      //     onPressed: () async {
                      //       setState(() {
                      //         isLoading = true;
                      //       });

                      //       await getEventsList();

                      //       var response = await getRolesList();
                      //       tmpRolesList = jsonDecode(response);
                      //       setState(() {
                      //         isLoading = false;
                      //       });

                      //       //TODO: REMOVE REPLACEMENT, REFRESH INSTEAD
                      //       Navigator.pushReplacement(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) =>
                      //                   const RolesAndProfilesScreen()));
                      //     },
                      //     icon: const Icon(Icons.refresh),
                      //     label: const Text('Refrescar'))
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const Text(
                    'Lista rápida de roles',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 18),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          roles.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.grey.shade300)),
                              // height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: roleContainerCard(
                                  roles[index], description[index], index),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 36),
                  // Divider(thickness: 1),
                  if (selectedCardIndex != -1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        description[selectedCardIndex],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class AddEditRoleScreen extends StatefulWidget {
  final String? role;
  final String? description;
  final bool? isActive;
  final bool? roleCanAcces;

  const AddEditRoleScreen(
      {super.key,
      this.role,
      this.description,
      this.isActive,
      this.roleCanAcces});

  @override
  _AddEditRoleScreenState createState() => _AddEditRoleScreenState();
}

class _AddEditRoleScreenState extends State<AddEditRoleScreen> {
  late TextEditingController _roleController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  List<Event> _events = [];
  Map<int, bool> roleEventActive = {};
  bool isRoleAdmin = false;

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.role ?? '');
    _descriptionController =
        TextEditingController(text: widget.description ?? '');
    _isActive = widget.isActive ?? false;
    _events = tmpeventsList.map((e) {
      bool isActive = e['soft_name'] == widget.role && e['event_active'];
      return Event(
          e['id'], e['name'], isActive, e['module_name'], e['event_active']);
    }).toList();
  }

  @override
  void dispose() {
    _roleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateRole(BuildContext context, int roleID) async {
    // Prepare JSON data for update
    final jsonData = {
      'name': _roleController.text,
      'description': _descriptionController.text,
      'isActive': _isActive,
      'admin': isRoleAdmin
      // 'events': _events
      //     .map((e) => {
      //           'id': e.eventID,
      //           'EventName': e.eventName,
      //           'role_event_active': e.eventCanAccesModule,
      //           'moduleName': e.moduleName,
      //         })
      //     .toList(),
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

  void _addRole(BuildContext context) {
    // Prepare JSON data for adding role
    final jsonData = {
      'roleName': _roleController.text,
      'description': _descriptionController.text,
      'isActive': _isActive,
      'events': _events
          .map((e) => {
                'id': e.eventID,
                'EventName': e.eventName,
                'role_event_active': e.eventCanAccesModule,
                'moduleName': e.moduleName,
              })
          .toList(),
    };
    createRole(jsonData);

    // Close the dialog
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Group events by moduleName
    Map<String, List<Event>> groupedEvents = {};
    // ignore: avoid_function_literals_in_foreach_calls
    _events.forEach((event) {
      if (!groupedEvents.containsKey(event.moduleName)) {
        groupedEvents[event.moduleName] = [];
      }
      groupedEvents[event.moduleName]!.add(event);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role != null ? 'Editar Rol' : 'Agregar Rol',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    ChoiceChip(
                      selectedColor: Colors.green,
                      label: const Text('Activo'),
                      selected: _isActive,
                      onSelected: (selected) {
                        setState(() {
                          _isActive = selected;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      selectedColor: Colors.red,
                      label: const Text('Inactivo'),
                      selected: !_isActive,
                      onSelected: (selected) {
                        setState(() {
                          _isActive = !selected;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _roleController,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Rol es administrador ?'),
                Switch(
                    value: isRoleAdmin,
                    onChanged: (bool value) {
                      setState(() {
                        isRoleAdmin = value;
                      });
                    }),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (widget.role != null) {
                        String roleName = widget.role!;
                        int roleId = getRoleIdValue(tmpRolesList, roleName);
                        if (roleId != 0) {
                          await _updateRole(context, roleId).whenComplete(() {
                            showConfirmationDialog(context, 'Éxito',
                                'Rol actualizado correctamente');
                          });
                        }
                        setState(() {
                          _isloading = false;
                        });
                        Navigator.of(context).pop();
                      } else {
                        _addRole(context);
                        _isloading = false;
                      }
                    } catch (e) {
                      insertErrorLog(
                          e.toString(), 'roles_screen when: ${widget.role}');
                    }
                  },
                  child: Text(
                      widget.role != null ? 'Actualizar Rol' : 'Agregar Rol'),
                ),
              ],
            ),
          ),
          if (_isloading) CustomLoadingIndicator()
        ],
      ),
    );
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
