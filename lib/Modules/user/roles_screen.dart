import 'package:flutter/material.dart';
import 'package:oxschool/components/confirm_dialogs.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

class RolesAndProfilesScreen extends StatefulWidget {
  const RolesAndProfilesScreen({super.key});

  @override
  State<RolesAndProfilesScreen> createState() => _RolesAndProfilesScreenState();
}

class _RolesAndProfilesScreenState extends State<RolesAndProfilesScreen> {
  List<String> roles = [
    'Admin',
    'User',
    'Second',
    'Item',
    'Role5',
    'Role6',
    'Role7',
    'Role8',
  ];
  List<String> description = [
    'Admins',
    'Mortals',
    'Other description',
    'Another description to use',
    'Another description',
    'Another description',
    'Another description',
    'Role new description'
  ];
  int selectedCardIndex = -1;

  Widget roleContainerCard(String role, String desc, int index) {
    return Card(
      color: Colors.cyan[50],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '  ' + role,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.black,
                ),
                onPressed: () async {
                  var deleteItem =
                      await showDeleteConfirmationAlertDialog(context);

                  if (deleteItem == 1) {
                    setState(() {
                      roles.removeAt(index);
                      description.removeAt(index);
                    });
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  selectedCardIndex = index;
                });
              },
              icon: Icon(Icons.arrow_forward),
              label: Text('Ver Detalle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditRoleScreen(BuildContext context, int index) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditRoleScreen(
          role: roles[index],
          description: description[index],
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin. de rol de ususario'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
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
                        child: Text('Nuevo '),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
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
                              MaterialStateProperty.all<Color>(Colors.white),
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
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        roles.length,
                        (index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 100,
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
                  Divider(thickness: 1),
                  if (selectedCardIndex != -1) ...[
                    SizedBox(height: 10),
                    Text(
                      'Detalle del Rol Seleccionado:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Rol: ${roles[selectedCardIndex]}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Descripción: ${description[selectedCardIndex]}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
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

  const AddEditRoleScreen({Key? key, this.role, this.description})
      : super(key: key);

  @override
  _AddEditRoleScreenState createState() => _AddEditRoleScreenState();
}

class _AddEditRoleScreenState extends State<AddEditRoleScreen> {
  late TextEditingController _roleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.role ?? '');
    _descriptionController =
        TextEditingController(text: widget.description ?? '');
  }

  @override
  void dispose() {
    _roleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role != null ? 'Editar Rol' : 'Agregar Rol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              onPressed: () {
                //TODO: INSER FUNCTION TO CREATE OR EDIT
                // Save or update role logic
                Navigator.of(context).pop();
              },
              child:
                  Text(widget.role != null ? 'Actualizar Rol' : 'Agregar Rol'),
            ),
          ],
        ),
      ),
    );
  }
}
