import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:oxschool/components/confirm_dialogs.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/login_view/login_view_widget.dart';
import 'package:oxschool/temp/users_temp_data.dart';
import 'package:oxschool/utils/loader_indicator.dart';

import '../../backend/api_requests/api_calls_list.dart';

class RolesAndProfilesScreen extends StatefulWidget {
  const RolesAndProfilesScreen({super.key});

  @override
  State<RolesAndProfilesScreen> createState() => _RolesAndProfilesScreenState();
}

bool _isloading = false;

class _RolesAndProfilesScreenState extends State<RolesAndProfilesScreen> {
  List<String> roles = [];
  List<String> description = [];
  List<bool> isActive = [];
  int selectedCardIndex = -1;

  @override
  void initState() {
    for (var item in tmpRolesList) {
      roles.add(item['Role']);
      description.add(item['Description']);
      isActive.add(item['Active']);
    }

    super.initState();
  }

  Widget roleContainerCard(String role, String desc, int index) {
    return ExpansionTile(
      title: Text(role),
      subtitle: Text(desc),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active: ${isActive[index]}'),
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () async {
                  var deleteItem =
                      await showDeleteConfirmationAlertDialog(context);

                  if (deleteItem == 1) {
                    var roleName = roles[index];
                    var roleIdValue = getRoleIdValue(tmpRolesList, roleName);
                    deleteRole(roleIdValue);
                    setState(() {
                      roles.removeAt(index);
                      description.removeAt(index);
                      isActive.removeAt(index);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showEditRoleScreen(BuildContext context, int index) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditRoleScreen(
          role: roles[index],
          description: description[index],
          isActive: isActive[index],
        ),
      ),
    );
    if (result != null &&
        result.containsKey('role') &&
        result.containsKey('desc')) {
      setState(() {
        roles[index] = result['role'];
        description[index] = result['desc'];
      });
    }
  }

  void _showAddRoleScreen(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditRoleScreen(),
      ),
    );
    if (result != null &&
        result.containsKey('role') &&
        result.containsKey('desc')) {
      setState(() {
        roles.add(result['role']);
        description.add(result['desc']);
        isActive.add(result['active']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin. de rol de usuario'),
        backgroundColor:
            Colors.blue, // Assuming FlutterFlowTheme is not available
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            return Card(
              child: Placeholder(),
            );
          } else {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          _showAddRoleScreen(context);
                        },
                        child: Text('Nuevo'),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.all(10)),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Todos los Roles'),
                                content: SizedBox(
                                  width: double.minPositive,
                                  height: 300,
                                  child: ListView.builder(
                                    itemCount: roles.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(roles[index]),
                                        subtitle: Text(description[index]),
                                        onTap: () {
                                          _showEditRoleScreen(context, index);
                                        },
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cerrar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Mostrar todos'),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.all(10)),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: () {},
                        child: Text('Administrar eventos'),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.all(10)),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 36),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: List.generate(
                        roles.length,
                        (index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 150,
                            width: 200,
                            child: roleContainerCard(
                              roles[index],
                              description[index],
                              index,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 36),
                  // Divider(thickness: 1),
                  if (selectedCardIndex != -1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        description[selectedCardIndex],
                        style: TextStyle(
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

  const AddEditRoleScreen(
      {Key? key, this.role, this.description, this.isActive})
      : super(key: key);

  @override
  _AddEditRoleScreenState createState() => _AddEditRoleScreenState();
}

class _AddEditRoleScreenState extends State<AddEditRoleScreen> {
  late TextEditingController _roleController;
  late TextEditingController _descriptionController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.role ?? '');
    _descriptionController =
        TextEditingController(text: widget.description ?? '');
    _isActive = widget.isActive ?? false;
  }

  @override
  void dispose() {
    _roleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateRole(BuildContext context, int roleID) async {
    // Prepare JSON data for update
    final jsonData = {
      'name': _roleController.text,
      'description': _descriptionController.text,
      'isActive': _isActive,
    };

    await editRole(roleID, jsonData);
    // Close the dialog
    // Navigator.of(context).pop();
  }

  void _addRole(BuildContext context) {
    // Prepare JSON data for adding role
    final jsonData = {
      'name': _roleController.text,
      'description': _descriptionController.text,
      'isActive': _isActive,
      // Add other fields as needed
    };

    // TODO: Perform API call to add role using jsonData

    // Close the dialog
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role != null ? 'Editar Rol' : 'Agregar Rol'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Row(
                  children: [
                    ChoiceChip(
                      selectedColor: Colors.green,
                      label: Text('Activo'),
                      selected: _isActive,
                      onSelected: (selected) {
                        setState(() {
                          _isActive = selected;
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    ChoiceChip(
                      selectedColor: Colors.red,
                      label: Text('Inactivo'),
                      selected: !_isActive,
                      onSelected: (selected) {
                        setState(() {
                          _isActive = !selected;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // setState(() {
                    //   _isloading = true;
                    // });
                    if (widget.role != null) {
                      String roleName = widget.role!;
                      int roleId = getRoleIdValue(tmpRolesList, roleName);
                      if (roleId != 0) {
                        setState(() {
                          _isloading = true;
                        });
                        _updateRole(context, roleId);
                      }

                      setState(() {
                        _isloading = false;
                      });

                      Navigator.of(context).pop();
                    } else {
                      _addRole(context);
                      _isloading = false;
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
    if (role["Role"] == roleName) {
      return role["Roleid"];
    }
  }
  return 0; // Role not found
}
