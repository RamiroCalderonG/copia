// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
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

dynamic handleDeleteRole(int index) async {
var response =
                                                    await showConfirmationDialog(
                                                        context,
                                                        'Confirmar',
                                                        '¿Eliminar el rol ${rolesListData[index].roleName}?');
                                                if (response == 1) {
                                                  insertActionIntoLog(
                                                      'DELETE ROLE ACTION >> ',
                                                      'User : ${currentUser!.employeeName}  deleted the role ${rolesListData[index].roleName}');
                                                  int roleId =
                                                      rolesListData[index]
                                                          .roleID;
                                                  await deleteRole(roleId)
                                                      .then((value) {
                                                    setState(() {
                                                      tmpRolesList
                                                          .removeAt(index);
                                                      // isLoading = false;
                                                    });
                                                    showInformationDialog(context, 'Exito', 'Rol eliminado exitosamente');
                                                  });
                                                } else {
                                                  insertActionIntoLog(
                                                      'DELETE ROLE ACTION CANCELED >> ',
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
                                                'Eliminar Rol',
                                            onPressed: () async {
                                              try {
                                                handleDeleteRole(index).then((value){
                                                  _fetchData();
                                                });
                                              } catch (e) {
                                                showErrorFromBackend(
                                                    context, e.toString());
                                              }
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
                                            tooltip: 'Administrar permisos',
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
  List<Event> _events = [];
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
    _events = tmpeventsList.map((e) {
      bool isActive = e['event_name'] == widget.role && e['event_active'];
      return Event(e['event_id'], e['event_name'], isActive, e['module_name'],
          e['role_id'], e['can_access']);
    }).toList();
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
    List<String> kindOfRole = [
      'Rol será administrador del sistema', //0
      'Rol será coordinador académico', //1
      'Ninguno de los anteriores' //2
    ];

    List<String> kindOfRoleIsActually = [
      'Rol es administrador del sistema', //0
      'Rol es coordinador académico', //1
      'Ninguno de los anteriores' //2
    ];

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estado del rol:   '),
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
                    labelText: 'Nombre del rol',
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
                Text(' Seleccione el tipo de rol: '),
                Wrap(
                    spacing: 5.0,
                    children: List<Widget>.generate(3, (int index) {
                      return ChoiceChip(
                        label: widget.role == null
                            ? Text(kindOfRole[index])
                            : Text(kindOfRoleIsActually[index]),
                        selected: selectedRoleChipValue == index,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedRoleChipValue = selected ? index : null;
                          });
                        },
                      );
                    }).toList()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (widget.role != null) {
                        //Update role
                        String roleName = widget.role!;
                        int roleId = widget.roleSelected!.roleID;
                        if (roleId != 0) {
                          try {
                            await _updateRole(context, roleId);
                            showInformationDialog(
                                context, 'Éxito', 'Rol actualizado con éxito');
                          } catch (e) {
                            insertErrorLog(e.toString(),
                                'roles_screen when: ${widget.role}');
                            showErrorFromBackend(context, e.toString());
                          }
                        }
                      } else {
                        //Create role
                        if (_roleController.text.isNotEmpty &&
                            _descriptionController.text.isNotEmpty &&
                            selectedRoleChipValue != null) {
                          try {
                            await _addRole(context);
                            showInformationDialog(
                                context, 'Éxito', 'Rol creado con éxito');
                          } catch (e) {
                            insertErrorLog(e.toString(),
                                'Create role | roles_screen:607 ');
                            showErrorFromBackend(context, e.toString());
                          }
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
                      widget.role != null ? 'Actualizar Rol' : 'Crear Rol'),
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
