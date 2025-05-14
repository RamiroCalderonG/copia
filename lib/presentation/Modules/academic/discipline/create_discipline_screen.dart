import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
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

  @override
  void initState() {
    studentsList = handleReload(currentCycle!.claCiclo!);
    super.initState();
  }

  @override
  void dispose() {
    students.clear();
    _selectedChips.clear();
    studentsList = Future.value(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentSelector = DropdownButtonFormField(
      items: students.map((toElement) {
        return DropdownMenuItem(
          value: toElement.nombre,
          child: Text(toElement.nombre!),
        );
      }).toList(),
      // const [
      //   DropdownMenuItem(
      //     value: 'student1',
      //     child: Text('Student 1'),
      //   ),
      //   DropdownMenuItem(
      //     value: 'student2',
      //     child: Text('Student 2'),
      //   ),
      // ],
      onChanged: (value) {},
      decoration: InputDecoration(
        labelText: 'Selecciona estudiante',
        border: OutlineInputBorder(),
      ),
    );

    final kindOfReport = List<Widget>.generate(3, (int index) {
      return ChoiceChip(
        label: Text('Item $index'),
        selected: _value == index,
        onSelected: (bool selected) {
          setState(() {
            _value = selected ? index : null;
          });
        },
      );
    }).toList();

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
        title: const Text('Crear reporte disciplinario'),
        // backgroundColor: Colors.blue,
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
                          child: studentSelector,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Wrap(
                            spacing: 8.0,
                            children: kindOfReport,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    dateTimePicker,
                    const SizedBox(height: 16),
                    teacherSelector,
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      children: causeMultiSelector,
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
      students = response;
    });
    if (response == null) {
      return [];
    }
    return response;
  }
}
