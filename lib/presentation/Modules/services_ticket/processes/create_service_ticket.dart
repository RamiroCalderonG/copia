import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/services_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/core/utils/searchable_drop_down.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';

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
  List<String> employeeList = <String>[];
  bool displayError = false;
  String? errorMessage;
  String? deptSelected;
  late Future<dynamic> usersListFuture;
  List<String> deptsList = <String>[];

  Map<int,dynamic> deptsMap = {};

  bool _isDescriptionFieldEmpty = false;
  bool _isObservationsFieldEmpty = false;
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
  void initState() {
    fetchUsersList();
    _isDescriptionFieldEmpty = false;
    _isObservationsFieldEmpty = false;
    super.initState();
  }

  void fetchUsersList() {
    usersListFuture = getUsersList().then((value) {
      getEmployeesNames(value);
      getDepartments().then((onValue){
        deptsMap = onValue;
        deptsMap.forEach((key,value){
          setState(() {
            deptsList.add(value);
          });
        });
      }).onError((error, StackTrace){
        insertErrorLog(error.toString(), 'getDepartments()');
        throw Future.error(error.toString());
      });
      

    }).onError((error, stacktrace) {
      insertErrorLog(error.toString(),
          'Error al obtener la lista de empleados | fetchUsersList()');
    });
  }

  void getEmployeesNames(List<Map<String, dynamic>> usersLists) {
    setState(() {
      employeeList.clear();
      for (var element in usersLists) {
        if (element['name'] != null) {
          employeeList.add(element['name'].toString());
        }
      }
    });
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

    String? dropDownValue;

    final descriptionField = TextFormField(
      controller: _descriptionController,
      // expands: true,
      maxLines: 4,
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
      maxLines: 4,
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

    return SizedBox(
        width: MediaQuery.of(context).size.width * 3 / 5,
        child: FutureBuilder(
            future: usersListFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CustomLoadingIndicator());
              } else {
                return Scaffold(
                  appBar: AppBar(
                    title:  Text('Crear Ticket de Servicio', style: TextStyle(color: FlutterFlowTheme.of(context).info ),),
                    backgroundColor: FlutterFlowTheme.of(context).secondary,
                  ),
                  body: SingleChildScrollView(
                      child: SafeArea(
                          child: Padding(
                    padding: const EdgeInsets.only(
                        top: 30, bottom: 10, left: 10, right: 10),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              child: SearchableDropdown(
                                items: employeeList,
                                label: 'Nombre de quien solicita',
                                onSelected: (String? value) {
                                  setState(() {
                                    dropDownValue = value!;
                                  });
                                },
                                hint :'Nombre'
                              ),
                            ),
                            Flexible(child: campusSelectorDropDown),
                            Flexible(child: SearchableDropdown(
                                items: deptsList,
                                label: 'Departamento al que solicita',
                                onSelected: (String? value) {
                                  setState(() {
                                    deptSelected = value!;
                                  });
                                },
                                hint :'Departamento al que solicita'
                              ),
        ),
                            Flexible(
                              child: dateAndTimeField,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                CancelActionButton(onPressed: (){Navigator.pop(context);})
                              ],
                            )),
                            Flexible(
                                child: Column(
                              children: [
                                SaveItemButton(onPressed: (){})
                              ],
                            )),
                          ],
                        ),
                      ],
                    ),
                  ))),
                );
              }
            }));
  }

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
