// ignore_for_file: prefer_final_fields, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:oxschool/data/Models/Cause.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list_dio.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/core/constants/Student.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/reusable_methods/nursery_methods.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';

import '../../../data/services/backend/api_requests/api_calls.dart';
import '../../../data/services/backend/api_requests/api_manager.dart';
import '../../../core/constants/user_consts.dart';
import '../../../core/reusable_methods/employees_methods.dart';
import '../../../core/utils/temp_data.dart';

class NewStudentNurseryVisit extends StatefulWidget {
  const NewStudentNurseryVisit({super.key});

  @override
  State<NewStudentNurseryVisit> createState() => _NewStudentNurseryVisitState();
}

List<String> causesLst = [];
List<String> painsList = [];
List<String> woundsList = [];
List<String> accidentType = [];
List<String> teachersList = [];

class _NewStudentNurseryVisitState extends State<NewStudentNurseryVisit> {
  late var _date = TextEditingController();
  late var _studentId = TextEditingController();
  late var _studentname = TextEditingController();
  late var _visitMotive = TextEditingController();
  late var _tx = TextEditingController();
  late var _valoration = TextEditingController();
  late var _kindOfPain = TextEditingController();
  late var _kindOfWound = TextEditingController();
  late var _otherCauses = TextEditingController();
  late var _observations = TextEditingController();
  late var _accidentTypes = TextEditingController();
  late String _teacherResponsable = '';
  late DateTime selectedDateTime;
  var apiCallResponseResult;

  bool isNoAplicaSelected = false;
  bool isLoading = false;

  String? teacherDropDownValue = teachersList.first;
  // String? _accidentTypes;

  bool? _isClinicChecked = false;
  bool? _isDoctorConsultChecked = false;
  bool? _isPhoneNotChecked = false;
  bool? _isPersonalNotifChecked = false;
  bool? _isReportNotifChecked = false;

  ApiCallResponse? apiResultxgr;
  var resultID;

  String? selectedPain;
  String? selectedLesion;
  String? selectedCause;
  String? selectedAccidentType;

  @override
  void dispose() {
    _date.dispose();
    _studentId.dispose();
    _studentname.dispose();
    _visitMotive.dispose();
    _tx.dispose();
    _valoration.dispose();
    _kindOfPain.dispose();
    _kindOfWound.dispose();
    _otherCauses.dispose();
    _observations.dispose();
    _accidentTypes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

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
      title: const Text("Tipo de dolor"),
      selectedColor: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(40)),
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
        _kindOfPain.text = results.toString();
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
      title: const Text("Tipo de herida"),
      selectedColor: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(40)),
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
        _kindOfWound.text = results.toString();

        //_selectedAnimals = results;
      },
    );

    MultiSelectDialogField causes = MultiSelectDialogField(
      items:
          causesLst.map((pain) => MultiSelectItem<String>(pain, pain)).toList(),
      itemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).primaryText,
          ),
      selectedItemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Sora',
            color: FlutterFlowTheme.of(context).tertiary,
          ),
      //causess.map((pain) => MultiSelectItem<String>(pain, pain)).toList(),
      title: const Text("Otras Causas"),
      selectedColor: Colors.blue,
      searchable: true,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(40)),
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
        _otherCauses.text = results.toString();
        //_selectedAnimals = results;
      },
    );

    MultiSelectDialogField accidentTypes = MultiSelectDialogField(
      items: accidentType
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
      // initialValue: [accidentType.first],
      title: const Text("Tipo de Accidente"),
      selectedColor: Colors.blue,
      searchable: true,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(40)),
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
        setState(() {
          isNoAplicaSelected = results.contains(' NO APLICA');
          _accidentTypes.text = results.toString();
        });

        //_selectedAnimals = results;
      },
    );

    Widget responsableTeacherWidget() {
      if (isNoAplicaSelected) {
        return DropdownButton<String>(
          value: teacherDropDownValue ??
              teachersList.first, // Set default value to the first item,
          hint: const Text('Maestro responsable'),
          borderRadius: BorderRadius.circular(15),
          icon: const Icon(Icons.person),
          elevation: 6,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Sora',
                color: FlutterFlowTheme.of(context).primaryText,
              ),
          underline: Container(
            height: 2,
            color: Colors.white,
          ),
          items: teachersList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              teacherDropDownValue = value!;
              _teacherResponsable = value;
            });
          },
        );
      } else {
        return Container();
      }
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 2 / 2,
            // height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: painsSelector),
                    const SizedBox(width: 6),
                    Expanded(child: kindOfLesion),
                    const SizedBox(width: 6),
                    Expanded(child: causes)
                  ],
                ),
                const Divider(thickness: 3),
                TextFormField(
                  controller: _studentId,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    label: const Text('Matricula'),
                    prefixIcon: const Icon(Icons.numbers),
                    suffixIcon: _studentId.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _studentId.clear();
                              });
                            },
                            icon: const Icon(Icons.clear_rounded),
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
                      label: const Text('Nombre del alumno'),
                      prefixIcon: const Icon(Icons.person_pin_rounded),
                      suffixIcon: _studentname.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _studentname.clear();
                                });
                              },
                              icon: const Icon(Icons.clear_rounded))
                          : null),
                  onChanged: (value) {
                    setState(() {});
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _visitMotive,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                      label: const Text('Motivo de visita'),
                      prefixIcon: const Icon(Icons.abc),
                      suffixIcon: _visitMotive.text.isNotEmpty
                          ? IconButton(
                              onPressed: _visitMotive.clear,
                              icon: const Icon(Icons.clear_rounded))
                          : null),
                  // textInputAction: TextInputAction.next,
                  autofocus: true,
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valoration,
                        enableSuggestions: true,
                        decoration: InputDecoration(
                            label: const Text('Valoracion'),
                            prefixIcon: const Icon(Icons.abc),
                            suffixIcon: _valoration.text.isNotEmpty
                                ? IconButton(
                                    onPressed: _valoration.clear,
                                    icon: const Icon(Icons.clear_rounded))
                                : null),
                        // textInputAction: TextInputAction.next,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _tx,
                        decoration: InputDecoration(
                            label: const Text('Tratamiento'),
                            prefixIcon: const Icon(Icons.abc),
                            suffixIcon: _tx.text.isNotEmpty
                                ? IconButton(
                                    onPressed: _tx.clear,
                                    icon: const Icon(Icons.clear_rounded))
                                : null),
                        // textInputAction: TextInputAction.next,
                        maxLines: 2,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: accidentTypes),
                    const SizedBox(width: 20),
                    Expanded(child: responsableTeacherWidget()),
                    // Expanded(child: responsableTeacher)
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _observations,
                        enableSuggestions: true,
                        decoration: InputDecoration(
                            label: const Text('Observaciones Generales'),
                            prefixIcon: const Icon(Icons.abc),
                            suffixIcon: _observations.text.isNotEmpty
                                ? IconButton(
                                    onPressed: _observations.clear,
                                    icon: const Icon(Icons.clear_rounded))
                                : null),
                        // textInputAction: TextInputAction.next,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.resolveWith(getColor),
                                value: _isClinicChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isClinicChecked = value!;
                                  });
                                },
                              ),
                              const Text('Se envió a clinica')
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.resolveWith(getColor),
                                value: _isDoctorConsultChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isDoctorConsultChecked = value!;
                                  });
                                },
                              ),
                              const Text('Molestias consulte a su Médico')
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tipo de notificación'),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.resolveWith(getColor),
                                value: _isPhoneNotChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isPhoneNotChecked = value!;
                                  });
                                }),
                            const Text('Telefono')
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.resolveWith(getColor),
                                value: _isPersonalNotifChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isPersonalNotifChecked = value!;
                                  });
                                }),
                            const Text('En persona')
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.resolveWith(getColor),
                                value: _isReportNotifChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isReportNotifChecked = value!;
                                  });
                                }),
                            const Text('Reporte')
                          ],
                        )
                      ],
                    )),
                    Expanded(
                        child: Column(
                      children: [
                        TextField(
                          controller: _date,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            labelText: "Fecha y hora",
                          ),
                          readOnly: true,
                          onTap: () async {
                            // ignore: unused_local_variable
                            DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101))
                                .then((pickedDate) {
                              if (pickedDate != null) {
                                selectedDateTime = DateTime.now();
                                showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now())
                                    .then((selectedTime) {
                                  // Handle the selected date and time here.
                                  if (selectedTime != null) {
                                    selectedDateTime = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  }
                                  setState(() {
                                    _date.text = selectedDateTime.toString();
                                  });
                                });
                              }
                              return null;
                            });
                          },
                        )
                      ],
                    ))

                    // Expanded(
                    //     child: ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              if (_kindOfPain.text.isNotEmpty ||
                                  _kindOfWound.text.isNotEmpty ||
                                  _otherCauses.text.isNotEmpty ||
                                  _date.text.isNotEmpty) {
                                //Get the type of notification

                                var notifType = 0;
                                if (_isPhoneNotChecked = true) {
                                  notifType = 1;
                                } else if (_isPersonalNotifChecked = true) {
                                  notifType = 2;
                                } else if (_isReportNotifChecked = true) {
                                  notifType = 3;
                                }

                                //Validate if there is a teacher selected
                                var responsableTeacherID;

                                if (_teacherResponsable != '') {
                                  responsableTeacherID =
                                      obtainEmployeeNumberbyName(
                                          tempTeachersList,
                                          _teacherResponsable);
                                } else {
                                  responsableTeacherID = '0';
                                }

                                //Get responable teacher ID

                                var nurseryapiBody = nurseryToJSON(
                                    currentUser!.employeeNumber!.toInt(),
                                    _kindOfPain.text
                                        .replaceAll(
                                          "[",
                                          "",
                                        )
                                        .replaceAll(
                                          "]",
                                          "",
                                        ),
                                    _kindOfWound.text
                                        .replaceAll(
                                          "[",
                                          "",
                                        )
                                        .replaceAll(
                                          "]",
                                          "",
                                        ),
                                    _otherCauses.text
                                        .replaceAll(
                                          "[",
                                          "",
                                        )
                                        .replaceAll(
                                          "]",
                                          "",
                                        ),
                                    _studentId.text,
                                    currentCycle!.claCiclo.toString(),
                                    _visitMotive.text,
                                    _valoration.text,
                                    _tx.text,
                                    _accidentTypes.text
                                        .replaceAll(
                                          "[",
                                          "",
                                        )
                                        .replaceAll(
                                          "]",
                                          "",
                                        ),
                                    _teacherResponsable,
                                    _observations.text,
                                    _isClinicChecked!,
                                    _isDoctorConsultChecked!,
                                    _isPhoneNotChecked!,
                                    _isPersonalNotifChecked!,
                                    _isReportNotifChecked!,
                                    selectedDateTime,
                                    notifType,
                                    deviceInformation.toString(),
                                    responsableTeacherID!);

                                apiCallResponseResult =
                                    await postNurseryVisit(nurseryapiBody);
                                // .whenComplete(() {
                                // Hide loading indicator when API call is complete
                                setState(() {
                                  isLoading = false;
                                });

                                if (apiCallResponseResult == 200) {
                                  // Navigate back to your main screen

                                  Navigator.of(context).pop();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                          'Exito al registrar visita de alumno',
                                          style: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Roboto',
                                                color: const Color(0xFF130C0D),
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        duration:
                                            const Duration(milliseconds: 12000),
                                        backgroundColor: Colors.green[200]),
                                  );
                                } else {
                                  showErrorFromBackend(context,
                                      apiCallResponseResult.toString());
                                }
                                // });
                              } else {
                                showEmptyFieldAlertDialog(
                                    context, 'Campo vacio, favor de verificar');
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Registrar visita')),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        if (isLoading) CustomLoadingIndicator()
      ],
    );
  }

  postNewStudentVisit(
      int employeeID,
      String? kindOfPain,
      String kindOfWound,
      String otherCauses,
      String studentId,
// String studentName,
      String reasonForVisit,
      String valoration,
      String treatment,
      String kindOfAccident,
      String? responsableTeacher,
      String? observations,
      bool sentToClinic,
      bool sentToDoctor,
      bool phoneNotif,
      bool personalNotif,
      bool reportNotif,
      DateTime dateAndTime,
      int notifType,
      String deviceInformation,
      String responsableTeacherID) async {
    try {
      //String result =
      /* await postNurseryStudent(
          employeeID,
          kindOfPain,
          kindOfWound,
          otherCauses,
          studentId,
// String studentName,
          reasonForVisit,
          valoration,
          treatment,
          kindOfAccident,
          responsableTeacher,
          observations,
          sentToClinic,
          sentToDoctor,
          phoneNotif,
          personalNotif,
          reportNotif,
          dateAndTime,
          notifType,
          deviceInformation,
          responsableTeacherID); */
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Exception(e.toString());
    }
  }

  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {},
  );
}

dynamic studentNewVisit(List<dynamic> jsonList) {
  if (jsonList.isEmpty) {
    return null; // Return null if the list is empty
  } else if (jsonList.length == 1) {
    // If there's only one item in the list, return a single Student object
    var item = jsonList[0];
    String claCause = item['claCausa'];
    String nomCause = item['nomCausa'];
    // int area = item['ClaArea'];
    // int isactive = item['Bajalogicasino'];
    return Cause(
      claCause, nomCause,
      //  area, isactive
    );
  } else {
    List<Cause> causeList = [];
    for (var item in jsonList) {
      String claCause = item['claCausa'];
      String nomCause = item['nomCausa'];
      // int area = item['ClaArea'];
      // int isactive = item['Bajalogicasino'];
      causeList.add(Cause(
        claCause, nomCause,
        //  area, isactive
      ));
    }
    return causeList;
  }
}
