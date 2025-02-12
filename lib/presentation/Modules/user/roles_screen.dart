// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';

import 'package:oxschool/data/Models/Event.dart';
import 'package:oxschool/data/Models/Module.dart';
import 'package:oxschool/data/Models/Role.dart';
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
                  _isloading = true;
                });
                await modifyActiveOfEventRole(
                    rolesListData[index].events![eventIndex].eventID,
                    value,
                    rolesListData[index].events![eventIndex].roleID);
                setState(() {
                  _isloading = false;
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
            roleCanAcces: rolesListData[index].isActive),
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
                      AddItemButton(onPressed: () {
                        _showAddRoleScreen(context);
                      }),
                      const SizedBox(width: 20),
                      RefreshButton(onPressed: _fetchData)
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
                          rolesListData.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.grey.shade300)),
                              // height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ExpansionTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        rolesListData[index].roleName,
                                        style: const TextStyle(
                                            fontFamily: 'Sora',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (!rolesListData[index]
                                          .isActive) // Conditionally show red dot
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left:
                                                  5), // Adjust margin as needed
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(
                                      rolesListData[index].roleDescription),
                                  children: [
                                    roleContainerCard(index),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const SizedBox(width: 5),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline),
                                            tooltip:
                                                'Eliminar Rol (Proximamente)',
                                            onPressed: () async {
                                              //TODO: VERIFY IF ITS NEEDED, OR ONLY LOGIC
                                            },
                                          ),
                                          if (!rolesListData[index].isActive)
                                            IconButton(
                                              onPressed: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                var roleId =
                                                    rolesListData[index].roleID;
                                                var bodyEdit = {
                                                  'isActive': true
                                                };
                                                await editRole(
                                                    roleId, bodyEdit, 3);
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                _fetchData();
                                              },
                                              icon: const Icon(
                                                  Icons.arrow_circle_up),
                                              tooltip: 'Activar Rol',
                                            ),
                                          if (rolesListData[index].isActive)
                                            IconButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  var roleId =
                                                      rolesListData[index]
                                                          .roleID;
                                                  var bodyEdit = {
                                                    'isActive': false
                                                  };
                                                  await editRole(
                                                      roleId, bodyEdit, 3);
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                  _fetchData();
                                                },
                                                tooltip: 'Desactivar rol',
                                                icon: const Icon(Icons
                                                    .arrow_circle_down_outlined)),
                                          const SizedBox(width: 5),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'Editar Rol',
                                            onPressed: () async {
                                              await _showEditRoleScreen(
                                                  context,
                                                  index,
                                                  rolesListData[index]
                                                      .isActive);
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PoliciesScreen(
                                                            roleID:
                                                                rolesListData[
                                                                        index]
                                                                    .roleID,
                                                            roleName:
                                                                rolesListData[
                                                                        index]
                                                                    .roleName,
                                                            roleListData:
                                                                rolesListData,
                                                          )));
                                            },
                                            icon: const Icon(Icons.security),
                                            tooltip: 'Administrar Políticas',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]

                                  // ],
                                  ),
                              // roleContainerCard(
                              //     rolesListData[index].roleName,
                              //     rolesListData[index].roleDescription,
                              //     index),
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
                        rolesListData[selectedCardIndex].roleDescription,
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
    _roleController = TextEditingController(text: widget.role ?? '');
    _descriptionController =
        TextEditingController(text: widget.description ?? '');
    _isActive = widget.isActive ?? false;
    _events = tmpeventsList.map((e) {
      bool isActive = e['event_name'] == widget.role && e['event_active'];
      return Event(e['event_id'], e['event_name'], isActive, e['module_name'],
          e['role_id'], e['can_access']);
    }).toList();
    super.initState();
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
                'role_event_active': e.roleID,
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
                        if (_roleController.text.isNotEmpty &&
                            _descriptionController.text.isNotEmpty) {
                          _addRole(context);
                          _isloading = false;
                        } else {
                          showEmptyFieldAlertDialog(
                              context, 'Favor de no dejar ningun campo vacio');
                        }
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
