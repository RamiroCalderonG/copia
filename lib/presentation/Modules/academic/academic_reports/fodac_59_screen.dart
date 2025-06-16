import 'package:flutter/material.dart';
import 'package:oxschool/data/Models/Student.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';

class Fodac59Screen extends StatefulWidget {
  final List<Student> studentsList;
  final Map<int?, String?> gardesGroups; // GradeSequence : gradeName
  final Map<int?, String?> gradeSeqGroup; // GradeSequence : groupName

  const Fodac59Screen(
      {super.key,
      required this.studentsList,
      required this.gardesGroups,
      required this.gradeSeqGroup});

  @override
  State<Fodac59Screen> createState() => _Fodac59ScreenState();
}

class _Fodac59ScreenState extends State<Fodac59Screen> {
  bool? includeDeactivatedStudent = false;
  List<DropdownMenuItem<String>> groups = [];
  bool? includeValidation = false;
  String? selectedGrade;
  String? selectedGroup;
  String? selectedStudent;
  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedGrade = widget.gardesGroups.values.first;
      // selectedGroup = widget.gradeSeqGroup.values.first;
      selectedStudent = ' ';
      selectedMonth = 'Enero';
      var groupsList = widget.gradeSeqGroup.values.toSet().toList();

      groups = groupsList
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item ?? ''),
              ))
          .toList();
      // selectedGroup = groups.first.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final headerRow = Padding(
        padding:
            const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 10),
        child: Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  isError: false,
                  tristate: false,
                  value: includeDeactivatedStudent,
                  onChanged: (bool? value) {
                    setState(() {
                      includeDeactivatedStudent = value;
                    });
                  },
                ),
                Text('Incluir Bajas'),
              ],
            ),
            const SizedBox(width: 25),
            Column(
              // crossAxisAlignment: CrossAxisAlignment,
              children: [
                Checkbox(
                  isError: false,
                  tristate: false,
                  value: includeValidation,
                  onChanged: (bool? value) {
                    setState(() {
                      includeValidation = value;
                    });
                  },
                ),
                Text('No Validar'),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                DropdownButton<String>(
                  value: selectedGrade,
                  hint: Text('Grado...'),
                  items: widget.gardesGroups.keys
                      .toSet() // Convert to Set to get unique values
                      .map((item) => DropdownMenuItem<String>(
                            value: item?.toString(),
                            child: Text(widget.gardesGroups[item] ?? ''),
                          ))
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedGrade = value;
                    });
                  },
                ),
                Text('Grado'),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                DropdownButton<String>(
                  value: '',
                  hint: Text('Grupo...'),
                  items: groups,
                  // widget.gradeSeqGroup.values
                  //     .toSet() // Convert to Set to get unique values
                  //     .toList() // Convert back to List
                  //     .map((item) => DropdownMenuItem<String>(
                  //           value: item,
                  //           child: Text(item ?? ''),
                  //         ))
                  //     .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedGroup = value;
                    });
                  },
                ),
                Text('Grupo'),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: selectedMonth,
                  hint: Text('Al mes de...'),
                  items: [
                    'Enero',
                    'Febrero',
                    'Marzo',
                    'Abril',
                    'Mayo',
                    'Junio',
                    'Julio',
                    'Agosto',
                    'Septiembre',
                    'Octubre',
                    'Noviembre',
                    'Diciembre'
                  ]
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedMonth = value;
                    });
                    // selectedMonth = value;
                  },
                ),
                Text('Al mes de'),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                DropdownButton<String>(
                  value: selectedStudent,
                  hint: Text('Alumno...'),
                  items:
                      [' ', ...widget.studentsList.map((s) => s.nombre ?? '')]
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ))
                          .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedStudent = value;
                    });
                  },
                ),
                Text('Alumno'),
              ],
            ),
            const SizedBox(width: 25),
            Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [RefreshButton(onPressed: () {})],
            ),
            Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [ExcelActionButton(onPressed: () {})],
            ),
            Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [PrintButton(onPressed: () {})],
            )
          ],
        ));

    return Placeholder(
        color: Colors.transparent,
        child: Column(
          children: [headerRow, Divider()],
        ));
  }
}
