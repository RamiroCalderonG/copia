import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

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

List<String> areaList = ['Academic', 'Sports', 'Library', 'Other'];

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _userEmail = TextEditingController();
  final _userCampus = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget buildCampuseSelector() {
      String? campuseSelector = campuseList.first;
      return DropdownButton<String>(
        value: campuseSelector ??
            campuseList.first, // Set default value to the first item,
        hint: Text('Campus'),
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
        items: campuseList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            campuseSelector = value!;
            campuseSelector = value;
          });
        },
      );
    }

    Widget buildAreaSelector() {
      String? areaSelector = areaList.first;
      return DropdownButton<String>(
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
    }

    return Stack(
      children: [
        SingleChildScrollView(
            child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 100,
          padding: EdgeInsets.all(20),
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
                    decoration:
                        InputDecoration(labelText: "Correo electrónico"),
                  ))
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
                  Expanded(child: buildCampuseSelector()),
                  SizedBox(width: 20),
                  Expanded(child: buildAreaSelector())
                ],
              ),
              Divider(
                thickness: 3,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text('Informacion personal',
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
                ],
              )
            ],
          ),
        ))
      ],
    );
  }
}
