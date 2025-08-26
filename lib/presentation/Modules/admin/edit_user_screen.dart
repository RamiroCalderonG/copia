// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';

import '../../../data/services/backend/api_requests/api_calls_list_dio.dart';

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
  final TextEditingController _campusController = TextEditingController();

  String? _selectedCampus;
  var _userRole;

  String? _userDepartment;
  List<String> roleNames = [];
  List<String> departmentsList = [];
  List<String> campusesList = ['ANAHUAC', 'BARRAGAN', 'CONCORDIA', 'SENDERO'];

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
  var _newEmployeeNumber = <String, int>{};

  var newUserEmployeeNumber = <String, dynamic>{};

  bool isloading = false;
  bool isUserActive = false;
  bool isUserTeacher = false;
  bool canUserChangePassword = false;

  bool _obscureText = true;

  @override
  void initState() {
    _emailController.text = tempSelectedUsr!.userEmail.toString();
    _nameController.text = tempSelectedUsr!.employeeName.toString();
    _employeeNumberController.text = tempSelectedUsr!.employeeNumber.toString();
    _userRole = tempSelectedUsr!.role.toString();
    _selectedCampus = tempSelectedUsr!.claUn;
    _userDepartment = tempSelectedUsr!.work_area.toString();
    _campusController.text = tempSelectedUsr!.claUn.toString();
    canUserChangePassword = tempSelectedUsr!.canUpdatePassword!;

    roleNames = tmpRolesList
        .map((role) => role["softName"].toString().trim().toTitleCase)
        .toList();
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

  void _updateUser() async {
    if (_formKey.currentState!.validate()) {
      await showConfirmationDialog(context, 'Confirmación', '¿Realiar cambios?')
          .then((response) async {
        if (response == 1) {
          //User selected YES
          if (dataToUpdate.isNotEmpty) {
            try {
              Key alertDialogKey = UniqueKey();
              setState(() {
                isloading = true;
              });

              /*  AlertDialog(
                key: alertDialogKey,
                icon: const Icon(Icons.hourglass_bottom_outlined),
                title: const Text('Actualizando usuario...'),
                content: const CustomLoadingIndicator()
              ); */
              await editUser(dataToUpdate, tempSelectedUsr!.employeeNumber!, 2)
                  .whenComplete(() {
                setState(() {
                  isloading = false;
                });

                //Navigator.of(context, rootNavigator: true).pop();
                showInformationDialog(context, 'Éxito', 'Cambios realizados!');
                return;
              }).catchError((onError) {
                throw Future.error(onError);
              });
            } catch (e) {
              setState(() {
                isloading = false;
              });
              showErrorFromBackend(context, e.toString());
              insertErrorLog(e.toString(),
                  '_updateUser() | $dataToUpdate ${tempSelectedUsr!.employeeNumber!}, | field: 2');
            }
          } else {
            throw Future.error('No data to update');
          }
        } else {
          //User selected NO
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String dropdownValue = _userDepartment ?? 'Select Department';
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(7),
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return Padding(
                      padding: const EdgeInsets.only(
                          top: 8, bottom: 16, left: 16, right: 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Divider(
                              thickness: 2,
                            ),
                            const SizedBox(height: 10),
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
                                    setState(() {
                                      _userNameUpdated = {'name': value};
                                      dataToUpdate
                                          .addEntries(_userNameUpdated.entries);
                                    });
                                  },
                                )),
                                const SizedBox(width: 15),
                                Expanded(
                                    child: TextFormField(
                                  controller: _employeeNumberController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
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
                                    setState(() {
                                      _newEmployeeNumber = {
                                        'employee_number':
                                            int.tryParse(value) ?? 0
                                      };
                                      dataToUpdate.addEntries(
                                          _newEmployeeNumber.entries);
                                    });
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
                                      setState(() {
                                        _emailUpdated = {'email': value};
                                        dataToUpdate
                                            .addEntries(_emailUpdated.entries);
                                      });
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
                                      setState(() {
                                        _passwordUpdated = {'password': value};
                                        dataToUpdate.addEntries(
                                            _passwordUpdated.entries);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('Campus:  ',
                                    style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontWeight: FontWeight.bold)),
                                Flexible(
                                    child: DropdownButton<String>(
                                  hint: const Text('Campus'),
                                  value: _selectedCampus,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCampus = value;
                                      var newUserCampus = {'campus': value};
                                      dataToUpdate
                                          .addEntries(newUserCampus.entries);
                                    });
                                  },
                                  items: campusesList
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                )),
                                Text(
                                  'Rol de ususario:',
                                  style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: DropdownButton<String>(
                                    hint: const Text('Rol de ususario'),
                                    value: _userRole,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _userRole = newValue!;
                                        _newUserRole = {'role': newValue};
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
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: SwitchListTile(
                                    title: Text(
                                        isUserActive
                                            ? 'Usuario activo'
                                            : 'Usuario desactivado',
                                        style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontWeight: FontWeight.bold)
                                        //style: const TextStyle(fontFamily: 'Sora'),
                                        ),
                                    value: isUserActive,
                                    onChanged: (value) async {
                                      setState(() {
                                        isloading = true;
                                        tempSelectedUsr!.isActive =
                                            value ? 1 : 0;
                                        _isActive = {
                                          'active': tempSelectedUsr!.isActive
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
                                Expanded(
                                  child: SwitchListTile(
                                    title: Text(
                                        isUserTeacher
                                            ? 'Es maestro'
                                            : 'No es maestro',
                                        style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontWeight: FontWeight.bold)
                                        //style: const TextStyle(fontFamily: 'Sora'),
                                        ),
                                    value: isUserTeacher,
                                    onChanged: (value) async {
                                      setState(() {
                                        isloading = true;
                                        tempSelectedUsr!.isTeacher =
                                            value ? true : false;
                                        _isUserTeacher = {'teacher': value};
                                        dataToUpdate
                                            .addEntries(_isUserTeacher.entries);
                                        isUserTeacher = value;
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                  ),
                                ),
                                Expanded(
                                  child: SwitchListTile(
                                    title: Text(
                                        canUserChangePassword
                                            ? 'Puede cambiar su propia contraseña'
                                            : 'No  puede cambiar su propia contraseña',
                                        style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontWeight: FontWeight.bold)
                                        //style: const TextStyle(fontFamily: 'Sora'),
                                        ),
                                    value: canUserChangePassword,
                                    onChanged: (value) async {
                                      setState(() {
                                        isloading = true;
                                        tempSelectedUsr!.canUpdatePassword =
                                            value ? true : false;
                                        var canUpdatePwdValue = {
                                          'canUpdatePwd': value
                                        };
                                        dataToUpdate.addEntries(
                                            canUpdatePwdValue.entries);
                                        canUserChangePassword = value;
                                      });
                                      setState(() {
                                        isloading = false;
                                        canUserChangePassword = value;
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('Departamento asignado:  ',
                                    style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: areaList.contains(dropdownValue)
                                        ? dropdownValue
                                        : null,
                                    hint: const Text('Departamento'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _userDepartment = newValue!;
                                        newUserPosition = {
                                          'department': newValue
                                        };
                                        dataToUpdate.addEntries(
                                            newUserPosition.entries);
                                      });
                                    },
                                    items: areaList
                                        .toSet()
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                //const SizedBox(width: 15),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  dataToUpdate.isNotEmpty
                                      ? SaveItemButton(onPressed: _updateUser)
                                      : Text(
                                          'No se ha detectado ningun cambio',
                                          style: TextStyle(color: Colors.amber),
                                        )
                                ])
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
      ),
    );
  }
}
