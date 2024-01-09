import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:oxschool/Models/Cause.dart';
import 'package:oxschool/constants/Student.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/reusable_methods/causes_methods.dart';
import 'package:oxschool/reusable_methods/nursery_methods.dart';

import '../backend/api_requests/api_calls.dart';
import '../backend/api_requests/api_manager.dart';

class NewStudentNurseryVisit extends StatefulWidget {
  const NewStudentNurseryVisit({super.key});

  @override
  State<NewStudentNurseryVisit> createState() => _NewStudentNurseryVisitState();
}

List<String> causesLst = [];
List<String> painsList = [];
List<String> woundsList = [];
List<String> accidentType = [];

class _NewStudentNurseryVisitState extends State<NewStudentNurseryVisit> {
  late var _date = TextEditingController();
  late var _studentId = TextEditingController();
  late var _studentname = TextEditingController();
  late var _visitMotive = TextEditingController();
  late var _tx = TextEditingController();
  late var _valoration = TextEditingController();
  late var _accidentType = TextEditingController();

  ApiCallResponse? apiResultxgr;
  bool causesFetched = false; // Track whether causes are fetched

  String? selectedPain;
  String? selectedLesion;
  String? selectedCause;
  String? selectedAccidentType;

  @override
  void initState() {
    super.initState();
    // Call getCauses only if causes are not fetched yet
    if (!causesFetched) {
      fetchData();
      if (causesLst.isNotEmpty) {
        causesFetched = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // getCauses();
    // List<dynamic> causesList = studentNewVisit(causess);
    _studentId.text = selectedStudent!.matricula!;
    _studentname.text = selectedStudent!.nombre!;

    MultiSelectDialogField painsSelector = MultiSelectDialogField(
      items:
          painsList.map((pain) => MultiSelectItem<String>(pain, pain)).toList(),
      itemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).primaryText,
          ),
      selectedItemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).tertiary,
          ),
      title: Text("Tipo dolor"),
      selectedColor: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.all(Radius.circular(40)),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      // buttonIcon: Icon(
      //   Icons.health_and_safety,
      //   color: Colors.blue,
      // ),
      buttonText: Text("Tipo de dolor",
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Sora',
                color: FlutterFlowTheme.of(context).primaryText,
              )),
      onConfirm: (results) {
        //_selectedAnimals = results;
      },
    );

    MultiSelectDialogField kindOfLesion = MultiSelectDialogField(
      items: woundsList
          .map((pain) => MultiSelectItem<String>(pain, pain))
          .toList(),
      itemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).primaryText,
          ),
      selectedItemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).tertiary,
          ),
      title: Text("Tipo de herida"),
      selectedColor: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.all(Radius.circular(40)),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      // buttonIcon: Icon(
      //   Icons.health_and_safety,
      //   color: Colors.blue,
      // ),
      buttonText: Text("Tipo de herida",
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Sora',
                color: FlutterFlowTheme.of(context).primaryText,
              )),
      onConfirm: (results) {
        //_selectedAnimals = results;
      },
    );

    MultiSelectDialogField causes = MultiSelectDialogField(
      items: causesLst!
          .map((pain) => MultiSelectItem<String>(pain, pain))
          .toList(),
      itemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).primaryText,
          ),
      selectedItemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).tertiary,
          ),
      //causess.map((pain) => MultiSelectItem<String>(pain, pain)).toList(),
      title: Text("Otras Causas"),
      selectedColor: Colors.blue,
      searchable: true,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.all(Radius.circular(40)),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      // buttonIcon: Icon(
      //   Icons.health_and_safety,
      //   color: Colors.blue,
      // ),
      buttonText: Text("Otras Causas",
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Sora',
                color: FlutterFlowTheme.of(context).primaryText,
              )),
      onConfirm: (results) {
        //_selectedAnimals = results;
      },
    );

    MultiSelectDialogField accidentTypes = MultiSelectDialogField(
      items: accidentType!
          .map((pain) => MultiSelectItem<String>(pain, pain))
          .toList(),
      itemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).primaryText,
          ),
      selectedItemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).tertiary,
          ),
      //causess.map((pain) => MultiSelectItem<String>(pain, pain)).toList(),
      title: Text("Tipo de Accidente"),
      selectedColor: Colors.blue,
      searchable: true,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.all(Radius.circular(40)),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      buttonText: Text("Tipo de Accidente",
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Sora',
                color: FlutterFlowTheme.of(context).primaryText,
              )),
      onConfirm: (results) {
        //_selectedAnimals = results;
      },
    );

    return SingleChildScrollView(
        child: Container(
      width: MediaQuery.of(context).size.width * 2 / 2,
      // height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: painsSelector),
              SizedBox(width: 6),
              Expanded(child: kindOfLesion),
              SizedBox(width: 6),
              Expanded(child: causes)
            ],
          ),
          Divider(thickness: 3),
          TextFormField(
            controller: _studentId,
            enableSuggestions: false,
            decoration: InputDecoration(
              label: Text('Matricula'),
              prefixIcon: const Icon(Icons.numbers),
              suffixIcon: _studentId.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _studentId.clear();
                        });
                      },
                      icon: Icon(Icons.clear_rounded),
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
            textInputAction: TextInputAction.next,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          TextFormField(
            controller: _studentname,
            enableSuggestions: false,
            decoration: InputDecoration(
                label: Text('Nombre del alumno'),
                prefixIcon: const Icon(Icons.person_pin_rounded),
                suffixIcon: _studentname.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _studentname.clear();
                          });
                        },
                        icon: Icon(Icons.clear_rounded))
                    : null),
            onChanged: (value) {
              setState(() {});
            },
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: _visitMotive,
            enableSuggestions: true,
            decoration: InputDecoration(
                label: Text('Motivo de visita'),
                prefixIcon: const Icon(Icons.abc),
                suffixIcon: _visitMotive.text.length > 0
                    ? IconButton(
                        onPressed: _visitMotive.clear,
                        icon: Icon(Icons.clear_rounded))
                    : null),
            // textInputAction: TextInputAction.next,
            autofocus: true,
            maxLines: 3,
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _valoration,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                      label: Text('Valoracion'),
                      prefixIcon: const Icon(Icons.abc),
                      suffixIcon: _visitMotive.text.length > 0
                          ? IconButton(
                              onPressed: _visitMotive.clear,
                              icon: Icon(Icons.clear_rounded))
                          : null),
                  // textInputAction: TextInputAction.next,
                  maxLines: 2,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextFormField(
                  controller: _tx,
                  decoration: InputDecoration(
                      label: Text('Tratamiento'),
                      prefixIcon: const Icon(Icons.abc),
                      suffixIcon: _visitMotive.text.length > 0
                          ? IconButton(
                              onPressed: _visitMotive.clear,
                              icon: Icon(Icons.clear_rounded))
                          : null),
                  // textInputAction: TextInputAction.next,
                  maxLines: 2,
                ),
              )
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: accidentTypes),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tx,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                      label: Text('Observaciones Generales'),
                      prefixIcon: const Icon(Icons.abc),
                      suffixIcon: _visitMotive.text.length > 0
                          ? IconButton(
                              onPressed: _visitMotive.clear,
                              icon: Icon(Icons.clear_rounded))
                          : null),
                  // textInputAction: TextInputAction.next,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.save_outlined),
                    label: Text('Guardar')),
              )
            ],
          )
        ],
      ),
    ));
  }

  fetchData() async {
    causesLst = await getCauses(15);
    painsList = await getPainList('none');
    woundsList = await getWoundsList('none');
  }
}

dynamic studentNewVisit(List<dynamic> jsonList) {
  if (jsonList.isEmpty) {
    return null; // Return null if the list is empty
  } else if (jsonList.length == 1) {
    // If there's only one item in the list, return a single Student object
    var item = jsonList[0];
    String claCause = item['claCausa'];
    String nomCause = item['nomCausa'];
    int area = item['ClaArea'];
    int isactive = item['Bajalogicasino'];
    return Cause(
      claCause, nomCause,
      //  area, isactive
    );
  } else {
    // If there are multiple items in the list, return a List<Student>
    List<Cause> causeList = [];
    for (var item in jsonList) {
      String claCause = item['claCausa'];
      String nomCause = item['nomCausa'];
      int area = item['ClaArea'];
      int isactive = item['Bajalogicasino'];

      causeList.add(Cause(
        claCause, nomCause,
        //  area, isactive
      ));
    }
    return causeList;
  }
}
