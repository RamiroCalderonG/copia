// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:oxschool/data/Models/Family.dart';
import 'package:oxschool/data/Models/Medicines.dart';
import 'package:oxschool/data/Models/NurseryHistory.dart';
import 'package:oxschool/data/Models/Student.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list_dio.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/core/constants/Student.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/presentation/Modules/enfermeria/no_data_avalibre.dart';
import 'package:oxschool/presentation/Modules/enfermeria/student_history_grid.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/presentation/Modules/main_window/main_window_widget.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:trina_grid/trina_grid.dart';

import 'expandable_fab.dart';

class NurseryMainScreen extends StatefulWidget {
  const NurseryMainScreen({super.key});

  @override
  State<NurseryMainScreen> createState() => _NurseryMainScreenState();
}

class _NurseryMainScreenState extends State<NurseryMainScreen>
    with TickerProviderStateMixin {
  final GlobalKey<_NurseryMainScreenState> key =
      GlobalKey<_NurseryMainScreenState>();

  TextEditingController searchController = TextEditingController();
  bool isSearching = false; // Add a state variable to track search status
  bool isLoading = false;
  ApiCallResponse? apiResultxgr;
  bool _showClearButton = true;
  List<String> listOfStudents = [];
  final List<TrinaRow> nurseryHistoryRows = [];
  late final TabController _tabController;

  late String dropdownValue;
  late final TrinaGridStateManager stateManager;
  late AnimationController controller;

  late List<TrinaRow> nurseryHRows;

  bool isSateManagerActive = false;

  onTap() {
    // isSearching = false;
    // if (_isDisabled[_tabController.index]) {
    //   int index = _tabController.previousIndex;
    //   setState(() {
    //     _tabController.index = index;
    //   });
    // }
  }

  final List<TrinaColumn> columns = <TrinaColumn>[
    TrinaColumn(
      title: 'Relacion',
      field: 'Relacion',
      type: TrinaColumnType.text(),
      enableRowChecked: true,
    ),
    TrinaColumn(
      title: 'Nombre',
      field: 'Nombre',
      type: TrinaColumnType.text(),
    ),
    TrinaColumn(
      title: 'Tutor',
      field: 'Tutor',
      type: TrinaColumnType.number(),
    ),
    TrinaColumn(
      title: 'Fecha de Alta',
      field: 'Fecha de Alta',
      type: TrinaColumnType.date(),
    ),
    TrinaColumn(
      title: 'Celular',
      field: 'Celular',
      type: TrinaColumnType.text(),
    ),
  ];

  final List<TrinaRow> rows = [];

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
    _tabController.addListener(onTap);
    searchController.addListener(() {
      setState(() {
        _showClearButton = searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    controller.dispose();
    searchController.dispose();

    if (nurseryStudent != null) {
      nurseryStudent!.clear();
    }
    if (selectedStudent != null) {
      clearStudentData;
    }

    super.dispose();
  }

  void _refreshCard() {
    // Add items dynamically to the dropdown
    setState(() {
      isSearching = true;
    });
  }

  // void _clearText() {
  //   setState(() {
  //     searchController.clear();
  //     _showClearButton = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = screenHeight / 1.0;
    double cardWidth =
        MediaQuery.of(context).size.width * 0.9; // 90% of screen width

    // void reloadCurrentScreen(BuildContext context) {
    //   selectedStudent = null;
    //   nurseryHistoryStudent = null;
    //   selectedFamily = null;
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (BuildContext context) {
    //       return FichaDeSalud();
    //     }),
    //   );
    // }

    void rebuildView() {
      setState(() {
        selectedStudent = null;
        nurseryHistoryStudent = null;
        selectedFamily = null;
        isSearching = false;
      });
    }

    final nurseryStudentMedicines = Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
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
              if (studentAllowedMedicines != null)
                ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  itemCount: studentAllowedMedicines.length,
                  itemBuilder: (BuildContext context, int index) {
                    // ignore: unused_local_variable
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
                          onPressed: () async {
                            int deleteMedFromStudent =
                                await showDeleteConfirmationAlertDialog(
                                    context);
                            if (deleteMedFromStudent == 1) {
                              var idValue = studentAllowedMedicines[index].id;

                              var response = await deleteMedicineStudent(
                                  idValue.toString());
                              if (response == 200) {
                                setState(() {
                                  studentAllowedMedicines.removeAt(index);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                          ('Error: $response').toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Roboto',
                                                color: const Color(0xFF130C0D),
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        duration:
                                            const Duration(milliseconds: 5000),
                                        backgroundColor: Colors.amber));
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_forever),
                          color: Colors.black,
                        ),
                        title: Text(
                          studentAllowedMedicines[index].nomMedicamento,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              if (studentAllowedMedicines == null ||
                  studentAllowedMedicines.isEmpty)
                const Placeholder(
                  child: Text('Sin informacion disponible'),
                )
              // Placeholder or message
            ],
          ))
      ],
    );

/*     final studentDataTab = Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                      controller: searchController,
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value == ' ') {
                          return 'Please enter some text';
                        }
                        return null; // Return null to indicate no validation errors
                      },
                      decoration: InputDecoration(
                        helperText:
                            'Apellido Paterno + Apellido materno + Nombres',
                        suffixIcon: _showClearButton
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.text = '';

                                  rebuildView();
                                })
                            : null,
                        hintText: 'Buscar alumno',
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (query) async {
                        if (query.trim().isEmpty) {
                          showEmptyFieldAlertDialog(
                              context, 'Campo vacio, verificar');
                          // Show an error message or perform any action for empty input
                          return;
                        }
                        // rebuildView();

                        // apiResultxgr = null;
                        // selectedStudent = null;
                        // selectedFamily = null;
                        // nurseryHistoryStudent = null;

                        setState(() {
                          isLoading = true;
                        });
                        List<String> substrings =
                            searchController.text.split(RegExp(' '));

                        // Look for student -------------------------------
                        apiResultxgr = await NurseryStudentCall.call(
                                apPaterno: substrings[0].capitalize(),
                                apMaterno: substrings[1].capitalize(),
                                nombre: substrings[2].capitalize(),
                                claUn: currentUser!.claUn,
                                claCiclo: currentCycle!.claCiclo)
                            .timeout(const Duration(seconds: 15));
                        if ((apiResultxgr?.succeeded ?? true)) {
                          List<dynamic> jsonList =
                              json.decode(apiResultxgr!.response!.body);
                          selectedStudent = studentNursery(jsonList);
                          // jsonList.clear();

                          if (jsonList.length == 1) {
                            jsonList.clear();
                            // Get student family details --------------------------------
                            apiResultxgr = await FamilyCall.call(
                                    claFam:
                                        selectedStudent.claFamilia.toString())
                                .timeout(const Duration(milliseconds: 9000));
                          } else {
                            jsonList.clear();
                            apiResultxgr = await FamilyCall.call(
                                    claFam: selectedStudent[0]
                                        .claFamilia
                                        .toString())
                                .timeout(const Duration(milliseconds: 9000));
                          }
                          if ((apiResultxgr?.succeeded ?? true)) {
                            List<dynamic> jsonList =
                                json.decode(apiResultxgr!.response!.body);
                            selectedFamily = familyFromJSON(jsonList);
                            jsonList.clear();
                            for (var line in selectedFamily) {
                              rows.add(
                                TrinaRow(
                                  cells: {
                                    'Relacion':
                                        TrinaCell(value: line.relationship),
                                    'Nombre': TrinaCell(
                                        value: line.name +
                                            ' ' +
                                            line.firstLastName +
                                            ' ' +
                                            line.secondLastName),
                                    'Tutor': TrinaCell(value: line.isParent),
                                    'Fecha de Alta':
                                        TrinaCell(value: line.registrationDate),
                                    'Celular':
                                        TrinaCell(value: line.cellPhoneNumber),
                                    // 'Email': TrinaCell(value: line.email)
                                  },
                                ),
                              );
                            }
                            apiResultxgr = null;
                            //Get student Nursery History
                            /* apiResultxgr = await NurseryHistoryCall.call(
                                    matricula:
                                        selectedStudent.matricula.toString())
                                .timeout(const Duration(milliseconds: 7000));
                            if ((apiResultxgr?.succeeded ?? true)) {
                              List<dynamic> jsonList =
                                  json.decode(apiResultxgr!.response!.body);
                              nurseryHistoryStudent =
                                  studentHistoryFromJSON(jsonList);

                              for (var line in nurseryHistoryStudent) {
                                nurseryHistoryRows.add(
                                  TrinaRow(
                                    cells: {
                                      'idReporteEnfermeria':
                                          TrinaCell(value: line.idReport),
                                      'Matricula':
                                          TrinaCell(value: line.studentId),
                                      'Fecha': TrinaCell(value: line.date),
                                      'Alumno':
                                          TrinaCell(value: line.studentName),
                                      'Causa': TrinaCell(value: line.cause),
                                      'Hora': TrinaCell(value: line.time),
                                      'Gradosecuencia':
                                          TrinaCell(value: line.grade),
                                      'ClaUn': TrinaCell(value: line.campuse),
                                      'Grupo': TrinaCell(value: line.group),
                                      'valoracionenfermeria':
                                          TrinaCell(value: line.diagnosis),
                                      'obsGenerales':
                                          TrinaCell(value: line.observations),
                                      'irconmedico':
                                          TrinaCell(value: line.canalization),
                                      'envioclinica':
                                          TrinaCell(value: line.hospitalize),
                                      'tx': TrinaCell(value: line.tx)
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
                                            color: const Color(0xFF130C0D),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    duration:
                                        const Duration(milliseconds: 5000),
                                    backgroundColor: Colors.amber),
                              );

                              isLoading = false;
                            }
                            nurseryHRows = nurseryHistoryRows;
                            // Get student medicines
                            apiResultxgr = await NurseryStudentMedication.call(
                                    matricula:
                                        selectedStudent.matricula.toString())
                                .timeout(const Duration(milliseconds: 9000));
                            if (apiResultxgr!.response!.body.isNotEmpty) {
                              if ((apiResultxgr?.succeeded ?? true)) {
                                jsonList =
                                    json.decode(apiResultxgr!.response!.body);
                              }
                              isLoading = false;
                            } else {
                              isLoading = false;
                            }
                            studentAllowedMedicines =
                                getMedicinesFromJSON(jsonList);
                          }
                          setState(() {
                            isSearching = true;
                            isSateManagerActive = true;
                          });
                          _refreshCard();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                (apiResultxgr?.jsonBody ?? '').toString(),
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Roboto',
                                      color: const Color(0xFF130C0D),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              duration: const Duration(milliseconds: 8000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).secondary,
                            ),
                          );
                          isLoading = false;
                          searchController.clear();
                        } */
                      }),
                ],
              ),
            ),
            if (isSearching)
              Expanded(
                  child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Nombre del estudiante: ',
                            style:
                                TextStyle(fontSize: 22.0, fontFamily: 'Sora')),
                        Text(
                          selectedStudent.nombre,
                          style: const TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        const Text('Datos del alumno:',
                            style:
                                TextStyle(fontSize: 18.0, fontFamily: 'Sora')),
                        const SizedBox(height: 8.0),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Matricula: ',
                              style:
                                  TextStyle(fontSize: 16.0, fontFamily: 'Sora'),
                            ),
                            Text(
                              selectedStudent.matricula,
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Campus: ',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: 'Sora')),
                            Text(
                              selectedStudent.claUn,
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Grado: ',
                              style:
                                  TextStyle(fontSize: 16.0, fontFamily: 'Sora'),
                            ),
                            Text(
                              selectedStudent.grado,
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Grupo: ',
                              style:
                                  TextStyle(fontSize: 16.0, fontFamily: 'Sora'),
                            ),
                            Text(selectedStudent.grupo,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
              ))
          ],
        ),
        if (isLoading) Center(child: CustomLoadingIndicator())
      ],
    );
 */
    final emergencyContacts = Column(
      children: [
        const Padding(
            padding: EdgeInsets.all(16.0),
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
              width: cardWidth,
              height: cardHeight,
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Nombre del estudiante',
                            style: TextStyle(fontSize: 22.0)),
                        Text(
                          selectedStudent.nombre,
                          style: const TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(height: 8.0),
                        const Text('Datos de contacto',
                            style: TextStyle(fontSize: 18.0)),
                        const SizedBox(height: 8.0),
                        const Divider(),
                        Expanded(
                            child: TrinaGrid(
                          // configuration: const TrinaGridConfiguration.dark(),
                          columns: columns,
                          mode: TrinaGridMode.readOnly,
                          rows: rows,
                          onLoaded: (TrinaGridOnLoadedEvent event) {
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
          key: key,
          length: 4,
          child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  labelColor: Colors.white,
                  controller: _tabController,
                  tabs: const <Widget>[
                    Tab(
                      icon: Icon(Icons.person, color: Colors.white),
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
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MainWindowWidget()));
                      },
                      icon: const Icon(Icons.home))
                ],
                backgroundColor: FlutterFlowTheme.of(context).primary,
                title: const Text('Enfermeria',
                    style: TextStyle(color: Colors.white)
                    // FlutterFlowTheme.of(context).headlineSmall,
                    ),
              ),
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  //studentDataTab,
                  emergencyContacts,
                  if (nurseryHistoryStudent != null) const StudentHistoryGrid(),
                  if (nurseryHistoryStudent == null) const NoDataAvailble(),
                  // nurseryHistoryGrid,
                  if (studentAllowedMedicines != null) nurseryStudentMedicines,
                  if (studentAllowedMedicines == null) const NoDataAvailble()
                ],
              ),
              floatingActionButton: const ExpandableFABNursery(),
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
    int gradoSecuencia = item['GradoSecuencia'];

    return Student(matricula, clafam, alumno, claUn, grupo, nomGradoEscolar,
        gradoSecuencia);
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
      int gradoSecuencia = item['gradoSecuencia'];

      studentsList.add(Student(matricula, clafam, alumno, claUn, grupo,
          nomGradoEscolar, gradoSecuencia));
    }
    return studentsList;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
