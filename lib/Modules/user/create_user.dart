import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

import '../../flutter_flow/flutter_flow_util.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

List<String> campuseList = [
  'Barragan',
  'Anahuac',
  'Sendero',
  'Prepa',
  'Concordia'
];
String? campuseSelector = campuseList.first;

List<String> areaList = ['Academic', 'Sports', 'Library', 'Other'];
String? areaSelector = areaList.first;

List<String> roleList = ['Admin', 'Maestro', 'IT Support', 'Analista calidad'];
String? roleSelector = roleList.first;

String? _selectedGender;
DateTime? _selectedBirthdate;

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _userEmail = TextEditingController();
  final _userCampus = TextEditingController();
  final _employeeNumber = TextEditingController();
  final _isTeacher = TextEditingController();
  final _genre = String;

  int _currentPageIndex = 0;
  PageController _pageController = PageController();

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
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (picked != null && picked != _selectedBirthdate) {
        setState(() {
          _selectedBirthdate = picked;
        });
      }
    }

    final campuseSelectorField = DropdownButton<String>(
      value: campuseSelector, // Use the current value here
      hint: Text('Campus'),
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
              value; // Update the state variable with the selected value
        });
      },
    );

    final areaSelectorField = DropdownButton<String>(
      value: areaSelector ?? areaList.first,
      hint: Text('Departamento'),
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
      value: roleSelector ??
          roleList.first, // Set default value to the first item,
      hint: Text('Rol asignado '),
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
      items: roleList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          roleSelector = value!;
          roleSelector = value;
        });
      },
    );

    final genderSelection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Genero',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
          ),
        ),
        RadioListTile<String>(
          title: Text('Male'),
          value: 'male',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('Female'),
          value: 'female',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        RadioListTile<String>(
          title: Text('Other'),
          value: 'other',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        SizedBox(height: 16.0),
        Text(
          'Selected gender: $_selectedGender',
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    );

    final secondFormScreen = SingleChildScrollView(
      child: Placeholder(
        child: ElevatedButton(
          onPressed: _nextPage,
          child: Text('Next'),
        ),
      ),
    );

    final List<Widget> forms = [
      //Form1
      SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Datos de acceso',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                )
              ],
            ),
            Row(
              children: [
                SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _userName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        setState(() {
                          _userName.text = 'Please enter a username!';
                        });
                      }
                    },
                    decoration: InputDecoration(labelText: "Nombre completo"),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                    child: TextFormField(
                  controller: _userEmail,
                  decoration: InputDecoration(labelText: "Correo electrónico"),
                ))
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      // TODO: IMPLEMENT EMPLOYEE NUMBER GENERATOR
                    },
                    icon: Icon(Icons.refresh)),
                Expanded(
                    child: TextFormField(
                  controller: _employeeNumber,
                  decoration:
                      InputDecoration(labelText: 'Generar número de empleado'),
                  enabled: true,
                )),
                SizedBox(width: 30),
                Text(
                  'Rol asignado   ',
                  style: TextStyle(fontSize: 11),
                ),
                Expanded(child: roleSelectorField)
              ],
            ),
            SizedBox(height: 30),
            Row(
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
                SizedBox(width: 20),
                Expanded(child: areaSelectorField)
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
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
                            : Text(''),
                        Divider(thickness: 1),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: Text('Seleccionar fecha de nacimiento'),
                        ),
                        SizedBox(width: 16.0),
                      ],
                    ),
                  ],
                )),
              ],
            ),
            ElevatedButton(
              onPressed: _nextPage,
              child: Text('Continuar'),
            ),
          ],
        ),
      ),
      secondFormScreen
    ];

    return Stack(
      children: [
        Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 600) {
                return PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: forms);
              } else {
                return Placeholder();
              }
            }))
      ],
    );
  }
}
