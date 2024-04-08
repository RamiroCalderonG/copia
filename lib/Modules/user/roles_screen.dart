import 'package:flutter/material.dart';
import 'package:oxschool/Models/Event.dart';
import 'package:oxschool/Modules/user/user_events_manager.dart';
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
  // List<int> role_id = [];
  List<bool> isActive = [];
  int selectedCardIndex = -1;

  @override
  void initState() {
    for (var item in tmpRolesList) {
      roles.add(item['Role']);
      description.add(item['Description']);
      isActive.add(item['Active']);
      // role_id.add(item['role_id']);
    }

    super.initState();
  }

  Widget roleContainerCard(String role, String desc, int index) {
    List<String> roleEvents = getEventNamesForRole(role, tmpeventsList);

    return ExpansionTile(
      title: Row(
        children: [
          Text(
            role,
            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.bold),
          ),
          if (!isActive[index]) // Conditionally show red dot
            Container(
              margin: EdgeInsets.only(left: 5), // Adjust margin as needed
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
        ],
      ),
      subtitle: Text(desc),
      children: [
        for (var eventName in roleEvents)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(eventName),
                Checkbox(
                  activeColor: Colors.green.shade300,
                  value: true, // Change this to the actual value
                  onChanged: (value) {
                    // Implement your logic here
                  },
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Text('Active: ${isActive[index]}'),
              SizedBox(width: 5),
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () async {
                  // Implement your delete logic here
                },
              ),
              SizedBox(width: 5),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  await _showEditRoleScreen(context, index);
                },
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.add)),
              // ElevatedButton.icon(
              //     onPressed: () {},
              //     icon: Icon(Icons.add),
              //     label: Text('Agregar eventos a rol'))
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
        // role_id[index] = result['role_id'];
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
        // role_id.add(result['role_id']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin. de rol de usuario',
            style: TextStyle(color: Colors.white)),
        backgroundColor: FlutterFlowTheme.of(context)
            .primary, // Assuming FlutterFlowTheme is not available
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
                      SizedBox(width: 20),
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PoliciesScreen() // UserEventsManagerDataTable(
                                  //   eventsList: eventsLisToShow,
                                  // )

                                  ));
                        },
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
                  SizedBox(height: 16),
                  Divider(thickness: 1),
                  Text(
                    'Listado de roles',
                    style: TextStyle(fontFamily: 'Sora'),
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
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.role ?? '');
    _descriptionController =
        TextEditingController(text: widget.description ?? '');
    _isActive = widget.isActive ?? false;
    _events = tmpeventsList
        .map((e) =>
            Event(e.EventId, e.eventName, _isActive, e.moduleName, e.moduleID))
        .toList();
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
    };
    var updatedRole = [
      _roleController.text,
      _descriptionController.text,
      _isActive
    ];
    setState(() {
      isLoading = true;
    });

    await editRole(roleID, jsonData);
    setState(() {
      tmpRolesList.removeAt(roleID);
      tmpRolesList.add(updatedRole);
      isLoading = false;
    });
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
        title: Text(widget.role != null ? 'Editar Rol' : 'Agregar Rol',
            style: TextStyle(color: Colors.white)),
        backgroundColor: FlutterFlowTheme.of(context).primary,
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
                        // setState(() {
                        //   _isloading = true;
                        // });
                        await _updateRole(context, roleId);
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

List<String> getEventNamesForRole(String roleName, List<dynamic> json) {
  List<String> eventNames = [];
  for (var item in json) {
    if (item['RoleName'] == roleName) {
      eventNames.add(item['EventName']);
    }
  }
  return eventNames;
}
