import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:oxschool/constants/Student.dart';

class NewStudentNurseryVisit extends StatefulWidget {
  const NewStudentNurseryVisit({super.key});

  @override
  State<NewStudentNurseryVisit> createState() => _NewStudentNurseryVisitState();
}

class _NewStudentNurseryVisitState extends State<NewStudentNurseryVisit> {
  late var _date = TextEditingController();
  late var _studentId = TextEditingController();
  late var _studentname = TextEditingController();
  late var _visitMotive = TextEditingController();
  late var _tx = TextEditingController();
  late var _valoration = TextEditingController();

  List<String> painsList = ['Dolor', 'Dolor2', 'Dolor3', 'Dolor4'];
  String? selectedPain;
  List<String> lesionList = ['Caída', 'Golpe' 'Zape', 'Zape2'];
  String? selectedLesion;
  List<String> causesList = ['Corria', 'Brincaba', 'etc'];
  String? selectedCause;

  @override
  Widget build(BuildContext context) {
    _studentId.text = selectedStudent!.matricula!;
    _studentname.text = selectedStudent!.nombre!;

    MultiSelectDialogField painsSelector = MultiSelectDialogField(
      items:
          painsList.map((pain) => MultiSelectItem<String>(pain, pain)).toList(),
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
      buttonText: Text(
        "Tipo de dolor",
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 16,
        ),
      ),
      onConfirm: (results) {
        //_selectedAnimals = results;
      },
    );

    MultiSelectDialogField kindOfLesion = MultiSelectDialogField(
      items: lesionList
          .map((pain) => MultiSelectItem<String>(pain, pain))
          .toList(),
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
      buttonText: Text(
        "Tipo de herida",
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 16,
        ),
      ),
      onConfirm: (results) {
        //_selectedAnimals = results;
      },
    );

    MultiSelectDialogField causes = MultiSelectDialogField(
      items: causesList
          .map((pain) => MultiSelectItem<String>(pain, pain))
          .toList(),
      title: Text("Otras Causas"),
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
      buttonText: Text(
        "Otras Causas",
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 16,
        ),
      ),
      onConfirm: (results) {
        //_selectedAnimals = results;
      },
    );

    // final DropdownMenu kindOfLesion = DropdownMenu<String>(
    //     initialSelection: lesionList.first,
    //     label: Text('Tipo de Herida'),
    //     onSelected: (String? value) {
    //       setState(() {
    //         selectedLesion = value;
    //       });
    //     },
    //     dropdownMenuEntries:
    //         lesionList.map<DropdownMenuEntry<String>>((String value) {
    //       return DropdownMenuEntry<String>(value: value, label: value);
    //     }).toList());

    // final DropdownMenu causes = DropdownMenu<String>(
    //     initialSelection: causesList.first,
    //     label: Text("Otras Causas"),
    //     onSelected: (value) {
    //       setState(() => selectedCause = value);
    //     },
    //     dropdownMenuEntries:
    //         causesList.map<DropdownMenuEntry<String>>((String value) {
    //       return DropdownMenuEntry<String>(value: value, label: value);
    //     }).toList());

    return SingleChildScrollView(
        child: Container(
      width: MediaQuery.of(context).size.width * 2 / 2,
      // height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
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
            maxLines: 4,
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: painsSelector),
              Expanded(child: kindOfLesion),
              Expanded(child: causes)
            ],
          ),
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
              )
            ],
          )
        ],
      ),
    ));
  }
}
