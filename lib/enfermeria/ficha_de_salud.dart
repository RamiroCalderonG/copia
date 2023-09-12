import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:oxschool/Models/Cycle.dart';
import 'package:oxschool/Models/Family.dart';
import 'package:oxschool/Models/Medicines.dart';
import 'package:oxschool/Models/NurseryHistory.dart';
import 'package:oxschool/Models/Student.dart';
import 'package:oxschool/backend/api_requests/api_calls.dart';
import 'package:oxschool/constants/Student.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/enfermeria/student_history_grid.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'expandable_fab.dart';
import 'nursery_history_grid.dart';

class FichaDeSalud extends StatefulWidget {
  const FichaDeSalud({super.key});

  @override
  State<FichaDeSalud> createState() => _FichaDeSaludState();
}

class _FichaDeSaludState extends State<FichaDeSalud>
    with TickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  bool isSearching = false; // Add a state variable to track search status
  ApiCallResponse? apiResultxgr;
  bool _showClearButton = true;
  List<String> listOfStudents = [];
  final List<PlutoRow> nurseryHistoryRows = [];
  late final TabController _tabController;

  late String dropdownValue;
  late final PlutoGridStateManager stateManager;
  late AnimationController controller;

  late List<PlutoRow> nurseryHRows;

  onTap() {
    isSearching = true;
    // if (_isDisabled[_tabController.index]) {
    //   int index = _tabController.previousIndex;
    //   setState(() {
    //     _tabController.index = index;
    //   });
    // }
  }

  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'Relacion',
      field: 'Relacion',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Nombre',
      field: 'Nombre',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Tutor',
      field: 'Tutor',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: 'Fecha de Alta',
      field: 'Fecha de Alta',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      title: 'Celular',
      field: 'Celular',
      type: PlutoColumnType.text(),
    ),
  ];

  final List<PlutoRow> rows = [];

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
    // _tabController = TabController(vsync: this, length: nurseryTabs.length);
    _tabController.addListener(onTap);
    searchController.addListener(() {
      setState(() {
        _showClearButton = searchController.text.isNotEmpty;
      });
    });
  }

  void dispose() {
    _tabController.dispose();
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _refreshCard() {
    // Add items dynamically to the dropdown
    setState(() {
      isSearching = true;
    });
  }

  void _clearText() {
    setState(() {
      searchController.clear();
      _showClearButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = screenHeight / 1.0;
    double cardWidth =
        MediaQuery.of(context).size.width * 0.8; // 80% of screen width
    // var familyList;
    // var selectedStudent;

    void reloadCurrentScreen(BuildContext context) {
      selectedStudent = null;
      nurseryHistoryStudent = null;
      selectedFamily = null;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) {
          return FichaDeSalud(); // Replace with the name of your current screen widget
        }),
      );
    }

    final nurseryStudentMedicines = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Medicinas autorizadas para el alumno'),
              Divider(),
            ],
          ),
        ),
        if (isSearching)
          SafeArea(
              child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                itemCount: studentAllowedMedicines.length,
                itemBuilder: (BuildContext context, int index) {
                  for (var item in studentAllowedMedicines) {
                    return ListTile(
                      key: Key('$index'),
                      tileColor:
                          index.isOdd ? Colors.blue[50] : Colors.blue[100],
                      leading: const Icon(
                        Icons.medication,
                        color: Colors.black38,
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          print(studentAllowedMedicines[index].nomMedicamento);
                        },
                        icon: Icon(Icons.delete_forever),
                        color: Colors.black,
                      ),
                      title: Text(
                        studentAllowedMedicines[index].nomMedicamento,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ],
          ))
      ],
    );

    final nurseryHistoryGrid = Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                //
              ],
              // ,
            )),
        if (isSearching) // Display the Card when searching

          Expanded(
            // child: Center(
            child: Container(
              width: cardWidth, // Set the card width here
              height: cardHeight,
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0, // Customize card elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Historial del alumno',
                            style: TextStyle(fontSize: 22.0)),
                        Text(
                          selectedStudent.nombre,
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 8.0),
                        Divider(),
                        Expanded(
                            child: PlutoGrid(
                          // configuration: const PlutoGridConfiguration.dark(),
                          columns: nurseryHistoryColumns,
                          rows: nurseryHistoryRows,
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            stateManager = event.stateManager;
                            stateManager.setShowColumnFilter(true);
                          },
                        ))
                      ],
                    )),
              ),
            ),
          )
      ],
    );

    final studentDataTab = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  helperText: 'Apellido Paterno + Apellido materno + Nombres',
                  suffixIcon: _showClearButton
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            reloadCurrentScreen(context);
                          })
                      : null,
                  hintText: 'Buscar alumno',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (query) async {
                  List<String> substrings =
                      searchController.text.split(RegExp(' '));

                  // Look for student -------------------------------
                  apiResultxgr = await NurseryStudentCall.call(
                          apPaterno: substrings[0],
                          apMaterno: substrings[1],
                          nombre: substrings[2],
                          claUn: currentUser.claUn,
                          claCiclo: '2022-2023')
                      .timeout(Duration(milliseconds: 9000));
                  if ((apiResultxgr?.succeeded ?? true)) {
                    List<dynamic> jsonList =
                        json.decode(apiResultxgr!.response!.body);
                    selectedStudent = studentNursery(jsonList);
                    // jsonList.clear();

                    if (jsonList.length == 1) {
                      jsonList.clear();
                      // Get student family details --------------------------------
                      apiResultxgr = await FamilyCall.call(
                              claFam: selectedStudent.claFamilia.toString())
                          .timeout(Duration(milliseconds: 9000));
                    } else {
                      jsonList.clear();
                      apiResultxgr = await FamilyCall.call(
                              claFam: selectedStudent[0].claFamilia.toString())
                          .timeout(Duration(milliseconds: 9000));
                    }
                    if ((apiResultxgr?.succeeded ?? true)) {
                      List<dynamic> jsonList =
                          json.decode(apiResultxgr!.response!.body);
                      selectedFamily = familyFromJSON(jsonList);
                      jsonList.clear();
                      for (var line in selectedFamily) {
                        rows.add(
                          PlutoRow(
                            cells: {
                              'Relacion': PlutoCell(value: line.relationship),
                              'Nombre': PlutoCell(
                                  value: line.name +
                                      ' ' +
                                      line.firstLastName +
                                      ' ' +
                                      line.secondLastName),
                              'Tutor': PlutoCell(value: line.isParent),
                              'Fecha de Alta':
                                  PlutoCell(value: line.registrationDate),
                              'Celular': PlutoCell(value: line.cellPhoneNumber),
                              // 'Email': PlutoCell(value: line.email)
                            },
                          ),
                        );
                      }
                      apiResultxgr = null;
                      //Get student Nursery History
                      apiResultxgr = await NurseryHistoryCall.call(
                              matricula: selectedStudent.matricula.toString())
                          .timeout(Duration(milliseconds: 9000));
                      if ((apiResultxgr?.succeeded ?? true)) {
                        List<dynamic> jsonList =
                            json.decode(apiResultxgr!.response!.body);
                        nurseryHistoryStudent =
                            studentHistoryFromJSON(jsonList);

                        for (var line in nurseryHistoryStudent) {
                          nurseryHistoryRows.add(
                            PlutoRow(
                              cells: {
                                'idReporteEnfermeria':
                                    PlutoCell(value: line.idReport),
                                'Matricula': PlutoCell(value: line.studentId),
                                'Fecha': PlutoCell(value: line.date),
                                'Alumno': PlutoCell(value: line.studentName),
                                'Causa': PlutoCell(value: line.cause),
                                'Hora': PlutoCell(value: line.time),
                                'Gradosecuencia': PlutoCell(value: line.grade),
                                'ClaUn': PlutoCell(value: line.campuse),
                                'Grupo': PlutoCell(value: line.group),
                                'valoracionenfermeria':
                                    PlutoCell(value: line.diagnosis),
                                'obsGenerales':
                                    PlutoCell(value: line.observations),
                                'irconmedico':
                                    PlutoCell(value: line.canalization),
                                'envioclinica':
                                    PlutoCell(value: line.hospitalize),
                                'tx': PlutoCell(value: line.tx)
                              },
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                (apiResultxgr?.jsonBody ?? '').toString(),
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Roboto',
                                      color: Color(0xFF130C0D),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              duration: Duration(milliseconds: 5000),
                              backgroundColor: Colors.amber),
                        );
                      }
                      nurseryHRows = nurseryHistoryRows;
                      // Get student medicines
                      apiResultxgr = await NurseryStudentMedication.call(
                              matricula: selectedStudent.matricula.toString())
                          .timeout(Duration(milliseconds: 9000));
                      if ((apiResultxgr?.succeeded ?? true)) {
                        jsonList = json.decode(apiResultxgr!.response!.body);
                      }
                      studentAllowedMedicines = getMedicinesFromJSON(jsonList);
                    }
                    setState(() {
                      isSearching = true;
                    });
                    _refreshCard();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          (apiResultxgr?.jsonBody ?? '').toString(),
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Roboto',
                                    color: Color(0xFF130C0D),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        duration: Duration(milliseconds: 8000),
                        backgroundColor: FlutterFlowTheme.of(context).secondary,
                      ),
                    );
                    searchController.clear();
                  }
                },
              ),
            ],
          ),
        ),
        if (isSearching)
          Expanded(
              child: Container(
            width: cardWidth,
            height: cardHeight,
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Nombre del estudiante',
                        style: TextStyle(fontSize: 22.0, fontFamily: 'Roboto')),
                    Text(
                      selectedStudent.nombre,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text('Datos del alumno',
                        style: TextStyle(fontSize: 18.0, fontFamily: 'Roboto')),
                    SizedBox(height: 8.0),
                    Divider(),
                    Text(
                      'Matricula',
                      style: TextStyle(fontSize: 16.0, fontFamily: 'Roboto'),
                    ),
                    Text(
                      selectedStudent.matricula,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text('Campus',
                        style: TextStyle(fontSize: 16.0, fontFamily: 'Roboto')),
                    Text(selectedStudent.claUn),
                    SizedBox(height: 10.0),
                    Text(
                      'Grado',
                      style: TextStyle(fontSize: 16.0, fontFamily: 'Roboto'),
                    ),
                    Text(selectedStudent.grado),
                    SizedBox(height: 10.0),
                    Text(
                      'Grupo',
                      style: TextStyle(fontSize: 16.0, fontFamily: 'Roboto'),
                    ),
                    Text(selectedStudent.grupo),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          ))
      ],
    );

    final emergencyContacts = Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                //
              ],
              // ,
            )),
        if (isSearching) // Display the Card when searching
          Expanded(
            // child: Center(
            child: Container(
              width: cardWidth, // Set the card width here
              height: cardHeight,
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0, // Customize card elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Nombre del estudiante',
                            style: TextStyle(fontSize: 22.0)),
                        Text(
                          selectedStudent.nombre,
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 8.0),
                        Text('Datos de contacto',
                            style: TextStyle(fontSize: 18.0)),
                        SizedBox(height: 8.0),
                        Divider(),
                        Expanded(
                            child: PlutoGrid(
                          // configuration: const PlutoGridConfiguration.dark(),
                          columns: columns,
                          rows: rows,
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            stateManager = event.stateManager;
                            stateManager.setShowColumnFilter(true);
                          },
                        ))
                      ],
                    )),
              ),
            ),
          )
        // )
      ],
    );

    return Material(
      child: DefaultTabController(
          length: 4,
          child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const <Widget>[
                    Tab(
                      icon: Icon(Icons.person),
                      text: 'Informacion del alumno',
                    ),
                    Tab(
                      icon: Icon(Icons.contact_emergency),
                      text: 'Contactos de emergencia',
                    ),
                    Tab(
                      icon: Icon(Icons.history),
                      text: 'Historial de visitas',
                    ),
                    Tab(
                      icon: Icon(Icons.medical_services),
                      text: 'Medicamentos',
                    )
                  ],
                  indicatorColor: Colors.blueAccent,
                ),
                backgroundColor: FlutterFlowTheme.of(context).primary,
                title: Text(
                  'Enfermeria',
                  style: FlutterFlowTheme.of(context).headlineSmall,
                ),
              ),
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  studentDataTab,
                  emergencyContacts,
                  StudentHistoryGrid(),
                  // nurseryHistoryGrid,
                  nurseryStudentMedicines,
                ],
              ),
              floatingActionButton: expandableFABWidget,
              floatingActionButtonLocation: ExpandableFab.location)),
    );
  }
}

dynamic studentNursery(List<dynamic> jsonList) {
  if (jsonList.isEmpty) {
    return null; // Return null if the list is empty
  } else if (jsonList.length == 1) {
    // If there's only one item in the list, return a single Student object
    var item = jsonList[0];
    String alumno = item['Alumno'];
    int clafam = item['claFamilia'];
    String matricula = item['Matricula'];
    String nomGradoEscolar = item['NomGradoEscolar'];
    String grupo = item['Grupo'];
    String claUn = item['ClaUn'];

    return Student(matricula, clafam, alumno, claUn, grupo, nomGradoEscolar);
  } else {
    // If there are multiple items in the list, return a List<Student>
    List<Student> studentsList = [];
    for (var item in jsonList) {
      String alumno = item['Alumno'];
      int clafam = item['claFamilia'];
      String matricula = item['Matricula'];
      String nomGradoEscolar = item['NomGradoEscolar'];
      String grupo = item['Grupo'];
      String claUn = item['ClaUn'];

      studentsList.add(
          Student(matricula, clafam, alumno, claUn, grupo, nomGradoEscolar));
    }
    return studentsList;
  }
}
