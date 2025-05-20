import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/core/utils/searchable_drop_down.dart';
import 'package:oxschool/data/Models/Student.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';

class CreateDisciplineScreen extends StatefulWidget {
  const CreateDisciplineScreen({super.key});

  @override
  State<CreateDisciplineScreen> createState() => _CreateDisciplineScreenState();
}

class _CreateDisciplineScreenState extends State<CreateDisciplineScreen> {
  DateTime? selectedDateTime;
  Set<int> _selectedChips = {};
  Set<String> selectedCausesId = {};
  int? kindOfReportValue = 0;
  late Future<dynamic> studentsList;
  List<Student> students = [];
  List<String> studentsNames = [];
  List<dynamic> teachers = [];
  Student? selectedStudent;
  List<Map<String, dynamic>> filteredTeachers = [];
  String? selectedTeacherId;
  List<Map<dynamic, dynamic>> causesList = [];
  Map<dynamic, dynamic> auxCausesList = {};
  dynamic responseBackend;
  TextEditingController observationsController = TextEditingController();
  Map<String, dynamic>? selectedTeacher;
  String? selectedSubject;
  int? selectedSubjectId;
  Map<String, dynamic> body = {};

  @override
  void initState() {
    studentsList = handleReload(currentCycle!.claCiclo!);
    super.initState();
  }

  @override
  void dispose() {
    students.clear();
    _selectedChips.clear();
    studentsNames.clear();
    studentsList = Future.value(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> kindOfReportList = [
      'Menor', //0
      'Mayor', //1
      'Notificación 1', //2
      'Notificación 2', //3
      'Notificación 3', //4
      'Aviso Sana Conducta', //5
    ];

    final studentSelector = SearchableDropdown(
      items: studentsNames,
      label: 'Buscar estudiante por nombre',
      onSelected: (selectedName) {
        final student = students.firstWhere((s) => s.nombre == selectedName);
        setState(() {
          selectedStudent = student;
          filteredTeachers = teachers
              .where((teacher) =>
                  teacher['ClaUN'].toString().trim() == student.claUn &&
                  teacher['Gradosecuencia'] == student.gradoSecuencia &&
                  teacher['Grupo'] == student.grupo)
              .toList()
              .cast<Map<String, dynamic>>();
          selectedTeacherId = null;
        });
      },
      hint: 'Buscar estudiante por nombre',
    );

    final kindOfReport = List<Widget>.generate(6, (int index) {
      return Padding(
          padding: const EdgeInsets.all(5.0),
          child: ChoiceChip(
            label: Text(kindOfReportList[index]),
            selectedColor: Colors.blue,
            selected: kindOfReportValue == index,
            onSelected: (bool selected) {
              setState(() {
                kindOfReportValue = selected ? index : null;
              });
            },
          ));
    });

    final dateTimePicker = TextFormField(
      decoration: InputDecoration(
        labelText: 'Selecciona fecha y hora',
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: selectedDateTime != null
            ? "${selectedDateTime!.day.toString().padLeft(2, '0')}/"
                "${selectedDateTime!.month.toString().padLeft(2, '0')}/"
                "${selectedDateTime!.year} "
                "${selectedDateTime!.hour.toString().padLeft(2, '0')}:"
                "${selectedDateTime!.minute.toString().padLeft(2, '0')}"
            : '',
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode()); // Prevent keyboard
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDateTime ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: selectedDateTime != null
                ? TimeOfDay.fromDateTime(selectedDateTime!)
                : TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              selectedDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }
        }
      },
    );

    final teacherSelector = DropdownButtonFormField<String>(
      value: filteredTeachers.any((t) =>
              '${t['NoEmpleado']}_${t['NomMateria']}' == selectedTeacherId)
          ? selectedTeacherId
          : null,
      items: filteredTeachers.asMap().entries.map((entry) {
        final idx = entry.key;
        final teacher = entry.value;
        // Combine NoEmpleado and NomMateria to make a unique value
        final value = '${teacher['NoEmpleado']}_${teacher['NomMateria']}';
        final display =
            '${teacher['teacher'].toString().trim() ?? ''}  | ${teacher['NomMateria']?.toString().trim() ?? ''}';
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            display,
            style: TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedTeacher = filteredTeachers.firstWhere(
            (teacher) =>
                teacher['NoEmpleado'].toString().trim() ==
                    value!.split('_')[0] &&
                teacher['NomMateria'] == value.split('_')[1],
            orElse: () => {},
          );
          selectedSubject = value!.split('_')[1].trim();
          selectedSubjectId = selectedTeacher!['ClaMateria'];

          selectedTeacherId = value;
          handleDisciplinaryReport(
              kindOfReportValue! + 1, selectedStudent!.gradoSecuencia!);
        });
      },
      decoration: InputDecoration(
        labelText: 'Selecciona Docente',
        border: OutlineInputBorder(),
      ),
    );

    List<Widget> buildCauseMultiSelector() {
      if (causesList.isEmpty) {
        return [
          Placeholder(
            fallbackHeight: 50,
            color: Colors.transparent,
            child: const Center(
              child: Text(
                'No hay causas disponibles, seleccione un docente.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ];
      }
      return List<Widget>.generate(causesList.length, (int index) {
        return ChoiceChip(
          label: Text('${causesList[index]['NomCausa']}'),
          selected: _selectedChips.contains(index),
          selectedColor: Colors.blue,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedChips.add(index);
                // Find the cause in responseBackend by NomCausa
                final cause = (responseBackend as List).firstWhere(
                  (item) =>
                      item['NomCausa'].toString().trim() ==
                      causesList[index]['NomCausa'].toString().trim(),
                  orElse: () => null,
                );
                if (cause != null) {
                  selectedCausesId.add(cause['clacausa'].toString().trim());
                }
              } else {
                _selectedChips.remove(index);
                // Remove the cause from selectedCausesId
                final cause = (responseBackend as List).firstWhere(
                  (item) =>
                      item['NomCausa'].toString().trim() ==
                      causesList[index]['NomCausa'].toString().trim(),
                  orElse: () => null,
                );
                if (cause != null) {
                  selectedCausesId.remove(cause['clacausa'].toString().trim());
                }
              }
            });
          },
        );
      });
    }

    final observationsField = TextFormField(
      decoration: InputDecoration(
        labelText: 'Observaciones',
        border: OutlineInputBorder(),
      ),
      controller: observationsController,
      maxLines: 3,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Captura reporte disciplinario',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
      body: FutureBuilder(
          future: studentsList,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            } else if (!snapshot.hasData || snapshot.data! == null) {
              return const Center(child: Text('No students found'));
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).accent3),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Selecciona estudiante',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  studentSelector
                                ],
                              )),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: FlutterFlowTheme.of(context).accent3),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Selecciona tipo de reporte',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: kindOfReport,
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          FlutterFlowTheme.of(context).accent3),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: dateTimePicker)),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).accent3),
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [],
                              ),
                              child: filteredTeachers.isEmpty
                                  ? const Text(
                                      'No hay docentes para este grupo, por favor seleccione un estudiante.',
                                      style: TextStyle(fontFamily: 'Sora'),
                                    )
                                  : teacherSelector),
                        )
                      ],
                    ),
                    // const SizedBox(height: 30),
                    Divider(
                      color: FlutterFlowTheme.of(context).accent3,
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Causas que aplican en el reporte',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: buildCauseMultiSelector()),
                    const SizedBox(height: 16),
                    Divider(
                      color: FlutterFlowTheme.of(context).accent3,
                      thickness: 2,
                    ),
                    const SizedBox(height: 5),
                    observationsField,
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SaveItemButton(onPressed: () {
                          if (selectedStudent == null ||
                              selectedTeacher == null ||
                              selectedSubject == null) {
                            showErrorFromBackend(context, 'Campo(s) vacio(s)');
                            return;
                          } else {
                            showConfirmationDialog(
                                    context,
                                    'Seguro(a) Generar Reporte Disciplinario',
                                    'Alumno: ${selectedStudent!.nombre} \nMaestro: ${selectedTeacher!['teacher']} \nMateria: $selectedSubject')
                                .then((response) {
                              if (response == 1) {
                                try {
                                  composeBody(
                                      selectedCausesId,
                                      selectedStudent!.matricula!,
                                      kindOfReportValue! + 1,
                                      selectedDateTime!.year.toString() +
                                          selectedDateTime!.month
                                              .toString()
                                              .padLeft(2, '0') +
                                          selectedDateTime!.day
                                              .toString()
                                              .padLeft(2, '0'),
                                      selectedTeacher!['NoEmpleado'],
                                      '${selectedDateTime!.hour}:${selectedDateTime!.minute}',
                                      observationsController.text,
                                      selectedSubjectId!,
                                      selectedStudent!.gradoSecuencia!,
                                      selectedStudent!.claUn!);
                                  handleCreateDisciplinaryReport();
                                } catch (e) {
                                  if (mounted) {
                                    showErrorFromBackend(context, e.toString());
                                  }
                                }
                              }
                            });
                          }
                        }),
                        CancelActionButton(onPressed: () {
                          Navigator.pop(context);
                        })
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }

  Future<dynamic> handleReload(String cycle) async {
    try {
      var response = await getSimpleStudentsByCycle(cycle);
      var teachersList = await getTeachersListByCycle(cycle);
      setState(() {
        if (studentsNames.isNotEmpty) {
          studentsNames.clear();
        }
        if (students.isNotEmpty) {
          students.clear();
        }
        students = response;
        teachers = teachersList;
        for (var element in students) {
          studentsNames.add(element.nombre!);
        }
      });
      if (response == null) {
        return [];
      }
      return response;
    } catch (e) {
      // Handle error
      // print('Error fetching students: $e');
      return null;
    }
  }

  void handleDisciplinaryReport(int kindOfReport, int gradeSequence) {
    populateDisciplinaryReport(kindOfReport, gradeSequence)
        .onError((error, stackTrace) {
      if (mounted) {
        showErrorFromBackend(context, error.toString());
      }
    });
  }

  Future<dynamic> populateDisciplinaryReport(
      int kindOfReport, int gradeSequence) async {
    try {
      await getDisciplinaryCausesToPopulateScreen(kindOfReport, gradeSequence)
          .then((response) {
        if (response != null) {
          responseBackend = response;
          Map<dynamic, String> causes = {};
          for (var item in response) {
            causes.addAll({
              item['idcausa']: item['NomCausa'].toString().trim() ?? '',
            });
          }

          setState(() {
            causesList = causes.entries
                .map((entry) => {
                      'idcausa': entry.key,
                      'NomCausa': entry.value,
                    })
                .toList();
          });
        } else {
          throw Exception('Server returned null value');
        }
      }).onError((error, stackTrace) {
        throw Future.error(error.toString());
      });
    } catch (e) {
      throw Future.error(e.toString());
    }
  }

  void handleCreateDisciplinaryReport() async {
    await createDisciplinaryReportF(body).then((response) {
      clearForm();
      Navigator.pop(context);
      showInformationDialog(context, "Éxito",
          "Registro creado con éxito, reporte numero: ${response['record']}");
      clearForm();
    }).onError((error, stackTrace) {
      showErrorFromBackend(context, error.toString());
    });
  }

  void clearForm() {
    setState(() {
      selectedStudent = null;
      selectedTeacher = null;
      selectedSubject = null;
      selectedTeacherId = null;
      selectedSubjectId = null;
      selectedDateTime = null;
      observationsController.clear();
      _selectedChips.clear();
      selectedCausesId.clear();
      kindOfReportValue = 0;
    });
  }

  void composeBody(
      Set<String> causes,
      String studentId,
      int kindOfReport,
      String date,
      int teacherNumber,
      String time,
      String observations,
      int subjectId,
      int gradeSeq,
      String campus) {
    try {
      showIsLoadingAlertDialog(context);
      setState(() {
        body.clear();
        body.addAll({
          'causes': causes.toList(),
          'studentId': studentId,
          'kindOfReport': kindOfReport,
          'date': date,
          'teacherNumber': teacherNumber,
          'time': time,
          'observations': observations,
          'subjectId': subjectId,
          'gradeSequence': gradeSeq,
          'campus': campus
        });
      });
    } catch (e) {
      throw Error.safeToString(e);
    }
  }
}
