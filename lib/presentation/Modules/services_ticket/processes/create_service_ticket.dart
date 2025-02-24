import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/presentation/components/save_and_cancel_buttons.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';

class CreateServiceTicket extends StatefulWidget {
  const CreateServiceTicket({super.key});

  @override
  State<CreateServiceTicket> createState() => _CreateServiceTicketState();
}

class _CreateServiceTicketState extends State<CreateServiceTicket> {
  final _nameController = TextEditingController();
  final _employeeNumberController = TextEditingController();
  final _departmentController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _requirementController = TextEditingController();
  final _employeeNameController = TextEditingController();
  final _date = TextEditingController();
  final _descriptionController = TextEditingController();
  final _observationsController = TextEditingController();
  late DateTime selectedDateTime;

  // bool _showSearchIcon = false;
  bool _isDescriptionFieldEmpty = false;
  bool _isObservationsFieldEmpty = false;
  // bool _showSearchEmployee = false;
  // ignore: prefer_final_fields
  bool _isSearching = false;

  @override
  void dispose() {
    _nameController.dispose();
    _employeeNumberController.dispose();
    _departmentController.dispose();
    _dueDateController.dispose();
    _requirementController.dispose();
    _date.dispose();
    _employeeNameController.dispose();
    _descriptionController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const List<String> months = <String>[
      'Anahuac',
      'Barragan',
      'Concordia',
      'HighSchool',
      'Sendero'
    ];

    const List<String> deptsList = <String>[
      'IT',
      'Calidad',
      'Mantenimiento',
      'Coord Academica'
    ];
    const List<String> employeeList = <String>['Fulano', 'Mengano', 'Sutano'];

    // ignore: unused_local_variable
    String? dropDownValue;

    final DropdownMenu employeSelectorName = DropdownMenu<String>(
        initialSelection: employeeList.first,
        enableFilter: true,
        label: const Text('Nombre del empleado que solicita'),
        onSelected: (String? value) {
          setState(() {
            dropDownValue = value!;
          });
        },
        dropdownMenuEntries:
            employeeList.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final descriptionField = TextFormField(
      controller: _descriptionController,
      // expands: true,
      maxLines: 8,
      onChanged: (value) {
        setState(() {
          _isDescriptionFieldEmpty = true;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),

        label: const Text('Descripción del Reporte'),
        // prefixIcon: const Icon(Icons.person),
        suffixIcon: _isDescriptionFieldEmpty
            ? GestureDetector(
                onTap: () async {
                  setState(() {
                    _descriptionController.text = '';
                    _isDescriptionFieldEmpty = false;
                  });
                },
                child: const Icon(Icons.close),
              )
            : null,
      ),
    );

    final observationsField = TextFormField(
      controller: _observationsController,
      // expands: true,
      maxLines: 8,
      onChanged: (value) {
        setState(() {
          _isObservationsFieldEmpty = true;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        label: const Text('Observaciones'),
        // prefixIcon: const Icon(Icons.person),
        suffixIcon: _isObservationsFieldEmpty
            ? GestureDetector(
                onTap: () async {
                  setState(() {
                    _observationsController.text = '';
                    _isObservationsFieldEmpty = false;
                  });
                },
                child: const Icon(Icons.close),
              )
            : null,
      ),
    );

    final dateAndTimeField = TextField(
      controller: _date,
      decoration: InputDecoration(
        // icon: Icon(Icons.calendar_today),
        labelText: "Requerido para:",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
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
            // selectedDateTime = DateTime.now();
            setState(() {
              _date.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
          return null;
        });
      },
    );

    final DropdownMenu campusSelectorDropDown = DropdownMenu<String>(
        initialSelection: months.first,
        label: const Text('Campus'),
        onSelected: (String? value) {
          setState(() {
            dropDownValue = value;
          });
        },
        dropdownMenuEntries:
            months.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final DropdownMenu deptSelectorDropDown = DropdownMenu<String>(
        initialSelection: deptsList.first,
        label: const Text('Departamento al que solicita'),
        onSelected: (String? value) {
          setState(() {
            dropDownValue = value;
          });
        },
        dropdownMenuEntries:
            deptsList.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    return Stack(
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 3 / 4,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth < 600) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // crossAxisAlignment
                        children: [
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [Flexible(child: employeSelectorName)],
                          ),

                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: campusSelectorDropDown,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [Flexible(child: deptSelectorDropDown)],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: dateAndTimeField,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: descriptionField,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Flexible(child: observationsField),
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                  child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      )),
                                  Text('Cancelar')
                                ],
                              )),
                              Flexible(
                                  child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.save,
                                      )),
                                  Text('Guardar')
                                ],
                              )),
                            ],
                          ),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //   children: [

                          //   ],
                          // // )
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 0.0, vertical: 25.0),
                          //   child: Column(
                          //     children: [
                          //       const SizedBox(height: 15),
                          //       const SizedBox(height: 15),
                          //       const SizedBox(height: 15),
                          //       const SizedBox(height: 18),
                          //       const SizedBox(height: 20),
                          //       Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [

                          //         ],
                          //       )
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                      child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 25.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const SizedBox(width: 18),
                              employeSelectorName,
                              // _buildEmployeeNumberField(),
                              const SizedBox(width: 18),
                              campusSelectorDropDown,
                              const SizedBox(width: 18),
                              deptSelectorDropDown,
                              const SizedBox(width: 18),
                              dateAndTimeField
                            ],
                          ),
                          const Divider(thickness: 1),
                          const SizedBox(height: 18),
                          Row(
                            children: [descriptionField],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [observationsField],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomSaveButton(
                                onPressed: () {},
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              CustomCancelButton(onPressed: () {
                                Navigator.pop(context);
                              })
                            ],
                          )
                        ],
                      ),
                    )
                  ]));
                }
              },
            )),
        if (_isSearching)
          Center(
            child: CustomLoadingIndicator(),
          )
      ],
    );
  }

  //TODO: DO NOT DELETE, CAN BE USED  FOR SEARCHING EMPLOYEES
  // Widget _buildEmployeeNumberField() {
  //   return Expanded(
  //     flex: 5,
  //     child: TextFormField(
  //       controller: _employeeNumberController,
  //       onChanged: (value) {
  //         setState(() {
  //           _showSearchIcon = value.length >= 3;
  //         });
  //       },
  //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //       keyboardType: TextInputType.number,
  //       autofocus: true,
  //       // textInputAction: TextInputAction.next,
  //       onFieldSubmitted: (value) async {
  //         // ignore: unused_local_variable
  //         var apiResponse;
  //         setState(() {
  //           _isSearching = true;
  //         });
  //         apiResponse = await searchEmployee(_employeeNumberController.text)
  //             .whenComplete(() {
  //           setState(() {
  //             _isSearching = false;
  //           });
  //         });
  //       },
  //       decoration: InputDecoration(
  //         label: const Text('No. Empleado que solicita servicio'),
  //         prefixIcon: const Icon(Icons.numbers),
  //         suffixIcon: _showSearchIcon
  //             ? GestureDetector(
  //                 onTap: () async {
  //                   // ignore: unused_local_variable
  //                   var apiResponse;
  //                   setState(() {
  //                     _isSearching = true;
  //                   });
  //                   apiResponse =
  //                       await searchEmployee(_employeeNumberController.text)
  //                           .whenComplete(() {
  //                     setState(() {
  //                       _isSearching = false;
  //                     });
  //                   });
  //                 },
  //                 child: const Icon(Icons.search),
  //               )
  //             : null,
  //       ),
  //     ),
  //   );
  // }

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.black87,
    backgroundColor: Colors.grey[300],
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );
}
