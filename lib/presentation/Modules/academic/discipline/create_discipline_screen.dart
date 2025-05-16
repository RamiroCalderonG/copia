import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/core/utils/searchable_drop_down.dart';
import 'package:oxschool/data/Models/Student.dart';

class CreateDisciplineScreen extends StatefulWidget {
  const CreateDisciplineScreen({super.key});

  @override
  State<CreateDisciplineScreen> createState() => _CreateDisciplineScreenState();
}

class _CreateDisciplineScreenState extends State<CreateDisciplineScreen> {
  DateTime? selectedDateTime;
  Set<int> _selectedChips = {};
  int? _value = 1;
  late Future<dynamic> studentsList;
  List<Student> students = [];
  List<String> studentsNames = [];

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
      onSelected: (p0) {
        // Handle the selected student
        print('Selected student: $p0');
      },
      hint: 'Buscar estudiante por nombre',
    );

    final kindOfReport = List<Widget>.generate(6, (int index) {
      return Padding(
          padding: const EdgeInsets.all(5.0),
          child: ChoiceChip(
            label: Text(kindOfReportList[index]),
            selectedColor: Colors.blue,
            selected: _value == index,
            onSelected: (bool selected) {
              setState(() {
                _value = selected ? index : null;
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

    final teacherSelector = DropdownButtonFormField(
      items: const [
        DropdownMenuItem(
          value: 'teacher1',
          child: Text('Teacher 1'),
        ),
        DropdownMenuItem(
          value: 'teacher2',
          child: Text('Teacher 2'),
        ),
      ],
      onChanged: (value) {},
      decoration: InputDecoration(
        labelText: 'Select Teacher',
        border: OutlineInputBorder(),
      ),
    );

    final causeMultiSelector = List<Widget>.generate(3, (int index) {
      return ChoiceChip(
        label: Text('Item $index'),
        selected: _selectedChips.contains(index),
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedChips.add(index);
            } else {
              _selectedChips.remove(index);
            }
          });
        },
      );
    }).toList();

    final observationsField = TextFormField();

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
                                boxShadow: [
                                  // BoxShadow(
                                  //   color: Colors.blue.shade100,
                                  //   blurRadius: 4.0,
                                  //   offset: const Offset(0, 2),
                                  // ),
                                ],
                              ),
                              child: studentSelector),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: FlutterFlowTheme.of(context).accent3),
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              // BoxShadow(
                              //   color: Colors.blue.shade100,
                              //   blurRadius: 4.0,
                              //   offset: const Offset(0, 2),
                              // ),
                            ],
                          ),
                          child: Wrap(
                            spacing: 8.0,
                            children: kindOfReport,
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
                                  boxShadow: [
                                    // BoxShadow(
                                    //   color: Colors.blue.shade100,
                                    //   blurRadius: 4.0,
                                    //   offset: const Offset(0, 2),
                                    // ),
                                  ],
                                ),
                                child: dateTimePicker)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: FlutterFlowTheme.of(context).accent3),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                // BoxShadow(
                                //   color: Colors.blue.shade100,
                                //   blurRadius: 4.0,
                                //   offset: const Offset(0, 2),
                                // ),
                              ],
                            ),
                            child: teacherSelector,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 30),
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
                          // style: TextStyle(fontFamily: 'Sora'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Wrap(
                          spacing: 8.0,
                          children: causeMultiSelector,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    observationsField,
                  ],
                ),
              ),
            );
          }),
    );
  }

  Future<dynamic> handleReload(String cycle) async {
    var response = await getSimpleStudentsByCycle(cycle);
    setState(() {
      studentsNames.clear();
      students = response;
      for (var element in students) {
        studentsNames.add(element.nombre!);
      }
    });
    if (response == null) {
      return [];
    }
    return response;
  }
}
