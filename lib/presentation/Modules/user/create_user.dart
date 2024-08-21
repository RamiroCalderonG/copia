// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/User.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';

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
// List<String> roleList = [
//   'Administrator',
//   'Maestro',
//   'IT Support',
//   'Analista calidad'
// ];

String? _selectedGender;
DateTime? _selectedBirthdate;
DateTime? _creationDate;
bool isLoading = false;
String campuseSelector = ''; //= campuseList.first;

class _NewUserScreenState extends State<NewUserScreen> {
  // final _formKey = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _userEmail = TextEditingController();
  final _userCampus = TextEditingController();
  final _employeeNumber = TextEditingController();
  final _isTeacher = TextEditingController();

  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    roleNames = tmpRolesList.map((role) => role["Role"] as String).toList();
    roleNames.first;
    campuseSelector = campuseList.first;
    areaSelector = areaList.first;
    roleSelector = roleNames.first;
    _selectedBirthdate = null;
    _creationDate = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
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
    // Future<DateTime> _selectDate(
    //     BuildContext context, DateTime? returnDate) async {
    //   final DateTime? picked = await showDatePicker(
    //     context: context,
    //     initialDate: DateTime.now(),
    //     firstDate: DateTime(1900),
    //     lastDate: DateTime.now(),
    //   );
    //   if (picked != null && picked != returnDate) {
    //     setState(() {
    //       returnDate = picked;
    //     });
    //     return picked;
    //   } else {
    //     return returnDate!;
    //   }
    // }

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
        color: Colors.white,
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
        color: Colors.white,
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
        color: Colors.white,
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
          // roleSelector = value;
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
            const Row(
              children: [
                Text(
                  'Datos de acceso',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                )
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 15),
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
                        const InputDecoration(labelText: "Nombre completo"),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                    child: TextFormField(
                  controller: _userEmail,
                  decoration:
                      const InputDecoration(labelText: "Correo electrónico"),
                ))
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      // TODO: IMPLEMENT EMPLOYEE NUMBER GENERATOR
                    },
                    icon: const Icon(Icons.refresh)),
                Expanded(
                    child: TextFormField(
                  controller: _employeeNumber,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Generar número de empleado'),
                  enabled: true,
                )),
                const SizedBox(width: 30),
                const Text(
                  'Rol asignado   ',
                  style: TextStyle(fontSize: 11),
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
              height: 20,
            ),
            const Row(
              children: [
                Text('Informacion personal',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
              ],
            ),
            Row(
              children: [
                Expanded(child: genderSelection),
                Expanded(
                    child: Column(
                  children: [
                    Column(
                      children: <Widget>[
                        _selectedBirthdate != null
                            ? Text(DateFormat('yyyy-MM-dd')
                                .format(_selectedBirthdate!))
                            : Text(_selectedBirthdate.toString()),
                        const Divider(thickness: 1),
                        ElevatedButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: _selectedBirthdate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ).then((selectedDate) {
                              if (selectedDate != null) {
                                setState(() {
                                  _selectedBirthdate = selectedDate;
                                });
                              }
                            });
                          },
                          child: const Text('Fecha de nacimiento'),
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Column(
                      children: <Widget>[
                        _creationDate != null
                            ? Text(
                                DateFormat('yyyy-MM-dd').format(_creationDate!))
                            : Text(_creationDate.toString()),
                        const Divider(thickness: 1),
                        ElevatedButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: _creationDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ).then((selectedDate) {
                              if (selectedDate != null) {
                                setState(() {
                                  _creationDate = selectedDate;
                                });
                              }
                            });
                          },
                          child: const Text('Fecha de alta'),
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                  ],
                )),
              ],
            ),
            ElevatedButton(
                onPressed: () async {
                  if (_userName.text.isEmpty ||
                      _employeeNumber.text.isEmpty ||
                      campuseSelector.isEmpty ||
                      _userEmail.text.isEmpty ||
                      _selectedBirthdate.toString().isEmpty ||
                      _selectedGender.toString().isEmpty) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Verificar que no existan campos vacios'),
                            actions: <Widget>[
                              TextButton(
                                style: TextButton.styleFrom(
                                  textStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                ),
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  } else {
                    Map<String, dynamic> newUser = {
                      'employeeNumber': int.parse(_employeeNumber.text),
                      'employeeName': _userName.text,
                      'claUn': campuseSelector,
                      'role': roleSelector,
                      'useremail': _userEmail.text,
                      'genre': _selectedGender,
                      'bajalogicasino': 1,
                      'department': areaSelector,
                      'position': '',
                      'birthdate': _selectedBirthdate!.toIso8601String(),
                      'creationDate': _creationDate!.toIso8601String(),
                      'createdBy': currentUser!.employeeNumber
                    };

                    try {
                      setState(() {
                        isLoading = true;
                      });
                      var statusCode = await createUser(newUser);

                      if (statusCode == 200) {
                        Navigator.of(context).pop();
                        setState(() {
                          isLoading = false;
                          _userName.clear();
                          _userEmail.clear();
                          _userCampus.clear();
                          _employeeNumber.clear();
                          _isTeacher.clear();
                          _selectedBirthdate = null;
                        });
                        // Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  icon: const Icon(Icons.done),
                                  iconColor: Colors.greenAccent,
                                  title: const Text('Exito'),
                                  content:
                                      const Text('Usuario creado exitosamente'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cerrar'),
                                    )
                                  ],
                                ));
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    } catch (e) {
                      throw Exception(e.toString());
                    }
                  }
                },
                child: const Text('Guardar')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
      secondFormScreen
    ];

    return Stack(
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
                return const Placeholder();
              }
            })),
        if (isLoading) CustomLoadingIndicator()
      ],
    );
  }
}
