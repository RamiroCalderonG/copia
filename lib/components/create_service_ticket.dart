import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateServiceTicket extends StatefulWidget {
  const CreateServiceTicket({super.key});

  @override
  State<CreateServiceTicket> createState() => _CreateServiceTicketState();
}

class _CreateServiceTicketState extends State<CreateServiceTicket> {
  final _name = TextEditingController();
  final _employeeNumber = TextEditingController();
  final _department = TextEditingController();
  final _dueDate = TextEditingController();
  final requirement = TextEditingController();

  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> list = <String>['One', 'Two', 'Three', 'Four'];
    String dropdownValue = list.first;
    return Container(
      width: MediaQuery.of(context).size.width * 3 / 4,
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: Text('Borrar campos')),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 25.0)),
          TextFormField(
              controller: _employeeNumber,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              enableSuggestions: false,
              decoration: InputDecoration(
                  label: Text('Numero de empleado'),
                  prefixIcon: const Icon(Icons.numbers),
                  suffixIcon: _employeeNumber.text.length > 0
                      ? GestureDetector(
                          onTap: _employeeNumber.clear,
                          child: Icon(Icons.clear_rounded))
                      : null),
              keyboardType: TextInputType.number,
              autofocus: true,
              textInputAction: TextInputAction.next),
          SizedBox(height: 15.0),
          TextFormField(
            controller: _department,
            decoration: InputDecoration(
                label: Text('Departamento al que solicita'),
                prefixIcon: Icon(Icons.other_houses_rounded),
                suffixIcon: _department.text.length > 0
                    ? GestureDetector(
                        onTap: _department.clear,
                        child: Icon(Icons.clear_rounded),
                      )
                    : null),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 15.0),
          DropdownButton<String>(
            value: dropdownValue,
            elevation: 16,
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Future<void> qualityPolitic(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Crear ticket de servicio',
              textAlign: TextAlign.center,
            ),
            content: const Text('Bla Bla Bla Bla aun mas Bla'),
            actions: <Widget>[
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.people),
                    suffixIcon: _name.text.length > 0
                        ? GestureDetector(
                            onTap: _name.clear,
                            child: Icon(Icons.clear_rounded),
                          )
                        : null),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
