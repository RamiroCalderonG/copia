import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Processes extends StatefulWidget {
  const Processes({super.key});

  @override
  State<Processes> createState() => _ProcessesState();
}

final _dateController = TextEditingController();

const List<String> serviceListStatus = <String>[
  'Todos',
  'Capturado',
  'Asignado',
  'En proceso',
  'Terminado',
  'Evaluado',
  'Cerrado',
  'Cancelado'
];
String? serviceStatusSelected;

enum SingingCharacter { madeBySomeOneElse, madeByMe }

class _ProcessesState extends State<Processes> {
  SingingCharacter? _character = SingingCharacter.madeBySomeOneElse;

  int selectedOption = 1;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        width: MediaQuery.of(context).size.width,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [_activeServices()],
                  )
                ],
              ),
            );
          } else {
            //TODO: CREATE A VERSION FOR SMALLER SCREENS
            return const Placeholder();
          }
        }),
      )
    ]);
  }

  Widget _activeServices() {
    return Expanded(
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(
                height: 10,
              )
            ],
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 15),
              IconButton.outlined(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(
                width: 5,
              ),
              IconButton.outlined(
                  onPressed: () {},
                  icon: const FaIcon(FontAwesomeIcons.fileExcel)),
              const SizedBox(width: 5),
              IconButton.outlined(
                  onPressed: () {}, icon: const Icon(Icons.print))
            ],
          ),
          const Divider(
            thickness: 1,
          ),
          Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Tickets desde',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
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
                        setState(() {
                          _dateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                      return DateTime.now();
                    });
                  },
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                  // flex: 2,
                  child: DropdownMenu<String>(
                      initialSelection: serviceListStatus.first,
                      label: const Text('Estatus'),
                      onSelected: (String? value) {
                        setState(() {
                          serviceStatusSelected = value;
                        });
                      },
                      dropdownMenuEntries: serviceListStatus
                          .map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList())),
              // SizedBox(width: 30),
              const Text(
                'Tipo de servicio:',
                style:
                    TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.bold),
              ),
              Expanded(
                  child: Container(
                width: 250,
                height: 50,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(0, 255, 255, 255),
                    // border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                    title: const Text('Que me reportaron'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.madeBySomeOneElse,
                      groupValue: _character,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                          _character = value;
                        });
                      },
                    )),
              )),
              Expanded(
                  child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(0, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                    title: const Text('Que reporté'),
                    leading: Radio<SingingCharacter>(
                      value: SingingCharacter.madeByMe,
                      groupValue: _character,
                      onChanged: (SingingCharacter? value) {
                        setState(() {
                          _character = value;
                        });
                      },
                    )),
              )),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          const Align(
            alignment: Alignment.bottomLeft,
            child: Text('  Servicios',
                style: TextStyle(fontFamily: 'Sora', fontSize: 18)),
          ),
          const Divider(
            thickness: 1,
          ),
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              height: constraints.maxWidth,
              width: constraints.maxWidth,
              child: Table(
                border: TableBorder.all(),
                children: const [
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(child: Text('Cell 1')),
                      ),
                      TableCell(
                        child: Center(child: Text('Cell 2')),
                      ),
                      TableCell(
                        child: Center(child: Text('Cell 3')),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(child: Text('Cell 4')),
                      ),
                      TableCell(
                        child: Center(child: Text('Cell 5')),
                      ),
                      TableCell(
                        child: Center(child: Text('Cell 6')),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(child: Text('Cell 7')),
                      ),
                      TableCell(
                        child: Center(child: Text('Cell 8')),
                      ),
                      TableCell(
                        child: Center(child: Text('Cell 9')),
                      ),
                    ],
                  ),
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}
