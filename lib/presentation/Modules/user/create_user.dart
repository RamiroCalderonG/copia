// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';

import '../../../data/services/backend/api_requests/api_calls_list.dart';
import '../../../core/config/flutter_flow/flutter_flow_util.dart';
import '../../../core/utils/loader_indicator.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

// List<String> areaList = [];
String areaSelector = ''; //areaList.first;
List<String> roleNames = [];
String roleSelector = ''; //roleNames.first;
String? _selectedGender;
DateTime? _selectedBirthdate;
DateTime? _creationDate;


class _NewUserScreenState extends State<NewUserScreen> {
  // final _formKey = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _userEmail = TextEditingController();
  final _userCampus = TextEditingController();
  final _employeeNumber = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthdateController = TextEditingController();

  bool isTeacher = false;
  bool isLoading = false;
  String campuseSelector = ''; //= campuseList.first;
  bool sendPasswordToEmail = true;
  bool canUpdatePassword = false;
  bool _obscureText = true;
  String password = '';
  bool createAPassword = true; //When false, send '' so the backend will asign a random password.
  int roleIdSelected = 0;


  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    roleNames = tmpRolesList.map((role) => role["softName"].toString()).toList();
    roleNames.first;
    campuseSelector = campuseList.first.trim();
    areaSelector = areaList.first;
    roleSelector = roleNames.first;
    _selectedBirthdate = null;
    _creationDate = null;
    _creationDate = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _userName.dispose();
    _userEmail.dispose();
    _userCampus.dispose();
    _employeeNumber.dispose();
    _pageController.dispose();
    _passwordController.dispose();
    _birthdateController.dispose();
    tmpRoleObjectslist.clear();
    super.dispose();
  }

  void _nextPage() {
    setState(() {
      if (_currentPageIndex < 2) {
        _currentPageIndex++;
      }
    });
    _pageController.animateToPage(
      _currentPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }


  

  @override
  Widget build(BuildContext context) {



void handleSave() async {
    if (_userName.text.isEmpty ||
                      _employeeNumber.text.isEmpty ||
                      campuseSelector.isEmpty ||
                      _userEmail.text.isEmpty ||
                      _selectedBirthdate.toString().isEmpty) {
                    showEmptyFieldAlertDialog(context, 'Verificar que no existan campos vacios');
                    return;
                  } else {
                    if (!createAPassword) {
                      password = '';
                    }
                    Map<String, dynamic> newUser = {
                      'employeeNumber': int.parse(_employeeNumber.text),
                      'fullName': _userName.text,
                      'claun': campuseSelector.toUpperCase(),
                      'roleId': roleIdSelected,
                      'email': _userEmail.text,
                      'genre': 'NULL',
                      'bajalogicasino': 1,
                      'workDepartment': areaSelector,
                      'workPosition': '',
                      'birthDate': _selectedBirthdate!.toIso8601String(),
                      'createdBy': currentUser!.employeeNumber,
                      'sendPasswordToEmail' : sendPasswordToEmail, 
                      'canUpdatePassword' : canUpdatePassword, 
                      'isTeacher': currentUser!.employeeNumber ,
                      'password' : password 
                    };
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      createUser(newUser).then((response){
                        setState(() {
                          isLoading = false;
                          _userName.clear();
                          _userEmail.clear();
                          _userCampus.clear();
                          _employeeNumber.clear();
                          _selectedBirthdate = null;
                        });
                        Navigator.of(context).pop();
                        showInformationDialog(context, 'Éxito', 'Usuario creado exitosamente');
                      }).onError((error, stackTrace){
                        setState(() {
                          isLoading = false;
                          showErrorFromBackend(context, error.toString());
                        });
                      });
                    } catch (e) {
                      throw Exception(e.toString());
                    }
                  }
                }


    Widget userCanUpdateOwnPassword = SwitchListTile(
                                  title: Text(
                                    canUpdatePassword
                                        ? 'Puede cambiar su contraseña'
                                        : 'No puede cambiar su contraseña',
                                        style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.bold)
                                    //style: const TextStyle(fontFamily: 'Sora'),
                                  ),
                                  value: canUpdatePassword,
                                  onChanged: (value) {
                                    setState(() {
                                      canUpdatePassword = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                );



    Widget userisTeacher =
      SwitchListTile(
                                  title: Text(
                                    isTeacher
                                        ? 'Es maestro'
                                        : 'No es maestro',
                                        style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.bold)
                                    //style: const TextStyle(fontFamily: 'Sora'),
                                  ),
                                  value: isTeacher,
                                  onChanged: (value) async {
                                    setState(() {
                                      isTeacher = value;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                );

TextFormField usrPasswordField = TextFormField(
                                  textInputAction: TextInputAction.next,
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.password),
                                      labelText: 'Contraseña',
                                      border: const UnderlineInputBorder(),
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
                                  onChanged: (value) {
                                    setState(() {
                                      password = value;
                                    });
                                  },
                                );
    
TextFormField birthDateField = TextFormField(
                      controller: _birthdateController,
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      onTap: () {
                        showDatePicker(
                              context: context,
                              initialDate: _selectedBirthdate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ).then((selectedDate) {
                              if (selectedDate != null) {
                                setState(() {
                                  _selectedBirthdate = selectedDate;
                                  _birthdateController.text = DateFormat('yyyy-MM-dd')
                                .format(_selectedBirthdate!);
                                });
                              }
                            });
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.cake),
                                      labelText: 'Fecha de nacimiento',
                                      border: const UnderlineInputBorder(),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                        },
                                        child: Icon(Icons.date_range),
                                      )),
                    );
    
    SwitchListTile customPasswordSwitcher = SwitchListTile(
      title: createAPassword ? Text('Asignar contraseña', style: TextStyle(fontWeight: FontWeight.bold),) : Text('Asignar contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
      value: createAPassword, 
      onChanged: (value) {
        setState(() {
          createAPassword = value;
        });
      });

      SwitchListTile sendPasswordToMailSwitch = SwitchListTile(
        title: Text('Envìar contraseña al correo'),
        value: sendPasswordToEmail, onChanged: (value){
        setState(() {
          sendPasswordToEmail = value;
        });
      }); 


  


    final campuseSelectorField = DropdownButton<String>(
      value: campuseSelector,
      hint: const Text('Campus'),
      borderRadius: BorderRadius.circular(15),
      elevation: 6,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).primaryText,
          ),
      underline: Container(
        height: 2,
        color: Colors.grey,
      ),
      items: campuseList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          campuseSelector =
              value!; // Update the state variable with the selected value
        });
      },
    );

    final areaSelectorField = DropdownButton<String>(
      value: areaSelector, //?? areaList.first,
      hint: const Text('Departamento'),
      borderRadius: BorderRadius.circular(15),
      // icon: Icon(Icons.),
      elevation: 6,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).primaryText,
          ),
      underline: Container(
        height: 2,
        color: Colors.grey,
      ),
      items: areaList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          areaSelector = value!;
          areaSelector = value;
        });
      },
    );

    final roleSelectorField = DropdownButton<String>(
      value: roleSelector,
      hint: const Text('Rol asignado '),
      borderRadius: BorderRadius.circular(15),

      // icon: Icon(Icons.person),
      elevation: 6,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).primaryText,
          ),
      underline: Container(
        height: 2,
        color: Colors.grey,
      ),
      items: roleNames.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          roleSelector = value!;
          roleIdSelected = tmpRoleObjectslist.firstWhere((item) => item.roleName.trim().toTitleCase == value.trim().toTitleCase).roleID;
        });
      },
    );

    final genderSelection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Genero',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
          ),
        ),
        RadioListTile<String>(
          title: const Text('Male'),
          value: 'male',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Female'),
          value: 'female',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Other'),
          value: 'other',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        const SizedBox(height: 16.0),
        // Text(
        //   'Selected gender: $_selectedGender',
        //   style: TextStyle(fontSize: 16.0),
        // ),
      ],
    );

    final secondFormScreen = SingleChildScrollView(
      child: Placeholder(
        child: ElevatedButton(
          onPressed: _nextPage,
          child: const Text('Next'),
        ),
      ),
    );

    final List<Widget> forms = [
      //Form1
      SingleChildScrollView(
        child: Column(
          children: [
            
            Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _userName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo no puede estar vacio';
                      }
                      return null;
                    },
                    decoration:
                        const InputDecoration(labelText: "Nombre completo", icon: Icon(Icons.people)),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(
                  width: 25
                ,
                ),
                Expanded(
                    child: TextFormField(
                  controller: _userEmail,
                  decoration:
                      const InputDecoration(labelText: "Correo electrónico", icon: Icon(Icons.email)),
                )),
                const SizedBox(
                  width: 25,
                ),
                Expanded(
                  child: customPasswordSwitcher
                ),
                 Expanded(
                  child: createAPassword ?  usrPasswordField : Text('Se asignará una contraseña genérica')
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                /* IconButton(
                    onPressed: () {
                      // TODO: IMPLEMENT EMPLOYEE NUMBER GENERATOR
                    },
                    icon: const Icon(Icons.refresh)), */
                Expanded(
                    child: TextFormField(
                  controller: _employeeNumber,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.numbers),
                      labelText: 'Número de empleado'),
                  enabled: true,
                )),
                const SizedBox(width: 30),
                const Text(
                  'Rol asignado   ',
                  style: TextStyle(fontSize: 13),
                ),
                Expanded(child: roleSelectorField)
              ],
            ),
            const SizedBox(height: 30),
            const Row(
              children: [
                Expanded(
                    child: Text(
                  'Campus',
                  style: TextStyle(fontSize: 13),
                )),
                Expanded(
                    child: Text(
                  'Area / Depto',
                  style: TextStyle(fontSize: 13),
                ))
              ],
            ),
            Row(
              children: [
                Expanded(child: campuseSelectorField),
                const SizedBox(width: 20),
                Expanded(child: areaSelectorField)
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Row(
              children: [
                
                Expanded(
                  child: userisTeacher,
                ),
                Expanded(child: userCanUpdateOwnPassword)
              ],
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child:birthDateField
                ),
                Expanded(child: sendPasswordToMailSwitch)
              ],
            ),

            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SaveItemButton(onPressed: handleSave)
              ],
            ),
            /*ElevatedButton(
                onPressed: () async {
                  handleSave();
                },
                child: const Text('Guardar')), */
            const SizedBox(height: 32),

            //IN CASE NEEDS TO ADD ANOTHER FORM
           /*  ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Continuar'),
            ), */
          ],
        ),
      ),
      secondFormScreen
    ];

    return 
    Stack(
      children: [
        Container(
            margin: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 600) {
                return PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: forms);
              } else {
                return  SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _userName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo no puede estar vacio';
                      }
                      return null;
                    },
                    decoration:
                        const InputDecoration(labelText: "Nombre completo", icon: Icon(Icons.people)),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: _userEmail,
                  decoration:
                      const InputDecoration(labelText: "Correo electrónico", icon: Icon(Icons.email)),
                )),
              ]
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                 Expanded(
                  child: customPasswordSwitcher
                ),
              ]
            ),
            Row(
              children: [
                Expanded(
                  child: createAPassword ?  usrPasswordField : Container(
                    padding: EdgeInsets.all(6),
                    child: Text('Se asignará una contraseña genérica', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                  ) 
                )
              ],
            ),
            Row(
              children: [
               /*  IconButton(
                    onPressed: () {
                      // TODO: IMPLEMENT EMPLOYEE NUMBER GENERATOR
                    },
                    icon: const Icon(Icons.refresh)), */
                Expanded(
                    child: TextFormField(
                  controller: _employeeNumber,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.numbers),
                      labelText: 'Número de empleado'),
                  enabled: true,
                )),
              ],
            ),
            const SizedBox( height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Rol asignado   ',
                  style: TextStyle(fontSize: 13),
                ),
                Expanded(
                  flex: 2,
                  child: roleSelectorField)
              ],
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: const Text(
                  'Campus',
                  style: TextStyle(fontSize: 13),
                )), 
                Expanded(
                  flex: 2,
                  child: campuseSelectorField),
                
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                    child: const Text(
                  'Area / Depto',
                  style: TextStyle(fontSize: 13),
                )), 
                Expanded(
                  flex: 2,
                  child: areaSelectorField)
              ]
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                Expanded(
                  child: birthDateField,
                )
                
              ],
            ),
            SizedBox(height: 8,),
            
            Row(
              children: [
                Expanded(
                  child: userisTeacher,
                ),
                
              ],
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                Expanded(child: userCanUpdateOwnPassword)
              ]
            ), 
            Row(
              children: [
                Expanded(child: sendPasswordToMailSwitch)
                
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SaveItemButton(onPressed: handleSave)
              ],
            )
            

            
                    ],
                  ),
                );
              }
            })
            ),
        if (isLoading) CustomLoadingIndicator()
      ],
    );
  }
}

