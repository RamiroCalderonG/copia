// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';

import '../../../data/services/backend/api_requests/api_calls_list.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeNumberController =
      TextEditingController();
  var _userRole;
  String? _userDepartment;
  List<String> roleNames = [];
  List<String> departmentsList = [];

  var isActive;
  var genre;
  var password;
  Map<String, dynamic> dataToUpdate = {};
  var _userNameUpdated = <String, dynamic>{};
  var _emailUpdated = <String, dynamic>{};
  var _passwordUpdated = <String, dynamic>{};
  var _isActive = <String, dynamic>{};
  var _newUserRole = <String, dynamic>{};
  var newUserPosition = <String, dynamic>{};
  var newUserBirthDate = <String, dynamic>{};
  var _isUserTeacher = <String, bool>{};
  // final _newUserCampus = <String, dynamic>{};
  var _newEmployeeNumber = <String, dynamic>{};

  var newUserEmployeeNumber = <String, dynamic>{};

  bool isloading = false;
  bool isUserActive = false;
  bool isUserTeacher = false;

  bool _obscureText = true;

  @override
  void initState() {
    _emailController.text = tempSelectedUsr!.userEmail.toString();
    _nameController.text = tempSelectedUsr!.employeeName.toString();
    _employeeNumberController.text = tempSelectedUsr!.employeeNumber.toString();

    _userRole = tempSelectedUsr!.role.toString();
    _userDepartment = tempSelectedUsr!.work_area.toString();

    roleNames = tmpRolesList.map((role) => role["Role"] as String).toList();
    // departmentsList = areaList.map((e) => e["work_department"]).toList();
    if (tempSelectedUsr!.isActive == 1) {
      isUserActive = false;
    } else {
      isUserActive = true;
    }
    if (tempSelectedUsr!.isTeacher == false) {
      isUserTeacher = false;
    } else {
      isUserTeacher = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _employeeNumberController.dispose();
    roleNames.clear();
    departmentsList.clear();
    dataToUpdate.clear();
    _userDepartment = null;
    tempSelectedUsr?.clear();
    areaList.clear();
    tmpRolesList.clear();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    String dropdownValue = _userDepartment ?? 'Select Department';
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 600) {
                return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Row(
                            children: [
                              Expanded(
                                  child: Text(
                                'Nombre y correo del ususario',
                                style: TextStyle(
                                    fontFamily: 'Sora', color: Colors.grey),
                              ))
                            ],
                          ),
                          const Divider(
                            thickness: 2,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                  child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre del usuario',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo no puede estar vacío';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _userNameUpdated = {'nombre_gafete': value};
                                  dataToUpdate
                                      .addEntries(_userNameUpdated.entries);
                                },
                              )),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: TextFormField(
                                controller: _employeeNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Numero de empleado',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo no puede estar vacío';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _newEmployeeNumber = {'noempleado': value};
                                  dataToUpdate
                                      .addEntries(_newEmployeeNumber.entries);
                                },
                              )),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: _validateEmail,
                                  onChanged: (value) {
                                    _emailUpdated = {'user_email': value};
                                    dataToUpdate
                                        .addEntries(_emailUpdated.entries);
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                      labelText: 'Nueva contraseña',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        child: Icon(_obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                      )),
                                  obscureText: _obscureText,
                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return 'Por favor ingrese una contraseña';
                                  //   }
                                  //   return null;
                                  // },
                                  onChanged: (value) {
                                    _passwordUpdated = {'user_password': value};
                                    dataToUpdate
                                        .addEntries(_passwordUpdated.entries);
                                  },
                                ),
                              )
                            ],
                          ),
                          // SizedBox(height: 46.0),
                          // Row(
                          //   children: [
                          //     Text(
                          //       'Datos personales del ususario',
                          //       style: TextStyle(
                          //           fontFamily: 'Sora', color: Colors.grey),
                          //     )
                          //   ],
                          // ),
                          // Divider(
                          //   thickness: 2,
                          // ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  hint: const Text('Rol de ususario'),
                                  value: _userRole,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _userRole = newValue!;
                                      _newUserRole = {'role_name': newValue};
                                      dataToUpdate
                                          .addEntries(_newUserRole.entries);
                                    });
                                  },
                                  items: roleNames
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: SwitchListTile(
                                  title: Text(
                                    isUserActive
                                        ? 'Usuario activo'
                                        : 'Usuario desactivado',
                                    style: const TextStyle(fontFamily: 'Sora'),
                                  ),
                                  value: isUserActive,
                                  onChanged: (value) async {
                                    setState(() {
                                      isloading = true;
                                      tempSelectedUsr!.isActive = value ? 1 : 0;
                                      _isActive = {
                                        'bajalogicasino':
                                            tempSelectedUsr!.isActive
                                      };
                                      dataToUpdate
                                          .addEntries(_isActive.entries);
                                      isUserActive = value;
                                    });
                                    setState(() {
                                      isloading = false;
                                      isUserActive = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: SwitchListTile(
                                  title: Text(
                                    isUserTeacher
                                        ? 'Es maestro'
                                        : 'No es maestro',
                                    style: const TextStyle(fontFamily: 'Sora'),
                                  ),
                                  value: isUserTeacher,
                                  onChanged: (value) async {
                                    setState(() {
                                      isloading = true;
                                      tempSelectedUsr!.isTeacher =
                                          value ? true : false;
                                      _isUserTeacher = {'is_teacher': value};
                                      dataToUpdate
                                          .addEntries(_isUserTeacher.entries);
                                      isUserTeacher = value;
                                    });
                                    setState(() {
                                      isloading = false;
                                      isUserTeacher = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  value: areaList.contains(dropdownValue)
                                      ? dropdownValue
                                      : 'Select Department',
                                  hint: const Text('Departamento'),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _userDepartment = newValue!;
                                      newUserPosition = {
                                        'work_department': newValue
                                      };
                                      dataToUpdate
                                          .addEntries(newUserPosition.entries);
                                    });
                                  },
                                  items: areaList.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Expanded(
                              //   child: DropdownButton<String>(
                              //     value: areaList.contains(dropdownValue)
                              //         ? dropdownValue
                              //         : 'Select Department',
                              //     hint: const Text('Departamento'),
                              //     onChanged: (String? newValue) {
                              //       setState(() {
                              //         _userDepartment = newValue!;
                              //         newUserPosition = {'position': newValue};
                              //         dataToUpdate
                              //             .addEntries(newUserPosition.entries);
                              //       });
                              //     },
                              //     items: areaList.map<DropdownMenuItem<String>>(
                              //         (String value) {
                              //       return DropdownMenuItem<String>(
                              //         value: value,
                              //         child: Text(value),
                              //       );
                              //     }).toList(),
                              //   ),
                              // ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmación'),
                                    content: const Text('¿Realiar cambios?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          // context.goNamed(
                                          //   'UDashboard',
                                          //   extra: <String, dynamic>{
                                          //     kTransitionInfoKey:
                                          //         const TransitionInfo(
                                          //       hasTransition: true,
                                          //       transitionType:
                                          //           PageTransitionType
                                          //               .leftToRight,
                                          //     ),
                                          //   },
                                          // );
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (dataToUpdate.isEmpty) {
                                            return showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title:
                                                          const Text('Error'),
                                                      content: const Text(
                                                          'No se detectó ningun cambio'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                'Ok'))
                                                      ],
                                                    ));
                                          } else {
                                            try {
                                              // Navigator.of(context).pop();
                                              // Navigator.of(context).pop();
                                              setState(() {
                                                isloading = true;
                                              });
                                              var response = await editUser(
                                                  dataToUpdate,
                                                  tempSelectedUsr!
                                                      .employeeNumber
                                                      .toString());
                                              if (response == 200) {
                                                setState(() {
                                                  isloading = false;
                                                });
                                                Navigator.of(context).pop();

                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          icon: const Icon(
                                                              Icons.done),
                                                          iconColor: Colors
                                                              .greenAccent,
                                                          title: const Text(
                                                              'Exito'),
                                                          content: const Text(
                                                              'Usuario actualizado exitosamente'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'Cerrar'),
                                                            )
                                                          ],
                                                        ));
                                              }
                                            } catch (e) {
                                              setState(() {
                                                isloading = false;
                                              });
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        icon: const Icon(
                                                            Icons.error),
                                                        iconColor:
                                                            Colors.redAccent,
                                                        title:
                                                            const Text('Error'),
                                                        content:
                                                            Text(e.toString()),
                                                      ));
                                            }
                                            // setState(() {
                                            //   isloading = false;
                                            // });
                                            // Navigator.of(context).pop();
                                          }

                                          // Navigator.of(context).pop();}
                                          // Navigator.of(context).pop();
                                          // // Proceed with registration logic here
                                          // String email = _emailController.text;
                                          // String password =
                                          //     _passwordController.text;
                                          // print(
                                          //     'Email: $email, Password: $password');
                                        },
                                        child: const Text('Register'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: const Text('Actualizar'),
                          ),
                        ],
                      ),
                    ));
              } else {
                return const Placeholder();
              }
            },
          ),
        ),
        if (isloading) CustomLoadingIndicator()
      ],
    );
  }
}
