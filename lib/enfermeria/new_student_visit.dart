import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewStudentNurseryVisit extends StatefulWidget {
  const NewStudentNurseryVisit({super.key});

  @override
  State<NewStudentNurseryVisit> createState() => _NewStudentNurseryVisitState();
}

class _NewStudentNurseryVisitState extends State<NewStudentNurseryVisit> {
  final _date = TextEditingController();
  final _studentId = TextEditingController();
  final _studentname = TextEditingController();
  final _visitMotive = TextEditingController();
  final _tx = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 2 / 4,
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
          SizedBox(height: 15.0),
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
              //Make API call to get student data
              setState(() {});
            },
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 15),
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
            textInputAction: TextInputAction.next,
          )
        ],
      ),
    );
  }
}
