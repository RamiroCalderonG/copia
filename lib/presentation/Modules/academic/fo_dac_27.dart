import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:oxschool/core/constants/User.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';

import 'package:oxschool/presentation/components/custom_icon_button.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../data/datasources/temp/studens_temp.dart';
import '../../../data/datasources/temp/teacher_grades_temp.dart';
import '../../../data/services/backend/api_requests/api_calls_list.dart';
import '../../components/confirm_dialogs.dart';

import 'fodac_27_dropdownmenu.dart';
import '../../components/plutogrid_export_options.dart';
import '../../components/save_and_cancel_buttons.dart';
import '../../../core/reusable_methods/academic_functions.dart';
import '../../../core/utils/loader_indicator.dart';

class FoDac27 extends StatefulWidget {
  const FoDac27({super.key});

  @override
  State<FoDac27> createState() => _FoDac27State();
}

class _FoDac27State extends State<FoDac27> {
  // List<dynamic> simplifiedStudentsList = [];
  List<PlutoRow> fodac27HistoryRows = [];
  late PlutoGridStateManager stateManager;

  final TextEditingController studentSelectorController =
      TextEditingController();

  String selectedStudent = '';
  String? selectedstudentId;
  String selectedSubjectNameToEdit = '';
  String selectedStudentIdToEdit = '';

  bool isLoading = true;
  bool isUserAdmin = false;

  int selectedEvalID = 0;
  String selectedCommentToEdit = '';
  String selectedDateToEdit = '';

  @override
  void initState() {
    isUserAdmin = verifyUserAdmin(currentUser!);
    populateStudentsDropDownMenu();
    super.initState();
  }

  @override
  void dispose() {
    tempStudentMap.clear();
    fodac27HistoryRows.clear();
    super.dispose();
  }

  // final exportToExcel = IconButton.outlined(
  //   onPressed: () {},
  //   icon: const FaIcon(FontAwesomeIcons.solidFileExcel),
  //   tooltip: 'Exportar a Excel',
  // );

  final List<PlutoColumn> fodac27Columns = [
    PlutoColumn(
        title: 'id',
        field: 'fodac27',
        type: PlutoColumnType.number(),
        readOnly: true,
        sort: PlutoColumnSort.ascending,
        enableColumnDrag: true,
        width: 68),
    PlutoColumn(
      title: 'Fecha',
      field: 'date',
      type: PlutoColumnType.text(),
      readOnly: true,
    ),
    PlutoColumn(
      title: 'Matricula',
      field: 'studentID',
      type: PlutoColumnType.text(),
      readOnly: true,
    ),
    PlutoColumn(
        title: 'Obs',
        field: 'Obs',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          return Tooltip(
            message: rendererContext.cell.value,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                rendererContext.cell.value,
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // You can adjust this as needed
                style: const TextStyle(
                  fontSize: 14, // Adjust font size as needed
                  color: Colors.black, // Set the text color to black
                ),
              ),
            ),
          );
        },
        readOnly: true),
    PlutoColumn(
        title: 'Materia',
        field: 'subject',
        type: PlutoColumnType.text(),
        readOnly: true),
    PlutoColumn(
        title: 'Maestro',
        field: 'teacher',
        type: PlutoColumnType.text(),
        readOnly: true),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (isLoading) {
            return CustomLoadingIndicator();
          } else {
            return Column(
              children: [
                buildStudentSelector(),
                Expanded(child: buildPlutoGrid()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildStudentSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expanded widget to make the Fodac27MenuSelector occupy as much space as needed
          const Expanded(
            child: Fodac27MenuSelector(),
          ),
          const SizedBox(
              width: 20), // Space between the dropdowns and the button
          // A fixed-width button
          Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  RefreshButton(onPressed: handleRefresh),
                  const SizedBox(height: 10),
                  AddItemButton(onPressed: handleAddItem),
                  const SizedBox(height: 10),
                  if (isUserAdmin)
                    DeleteItemButton(onPressed: () async {
                      if (selectedEvalID == 0) {
                        const AlertDialog(
                          title: Text('Error'),
                          content: Text(
                              'Primero seleccionar un registro para editar'),
                        );
                      } else {
                        int confirmation =
                            await showDeleteConfirmationAlertDialog(context);
                        if (confirmation == 1) {
                          int response = await deleteAction(selectedEvalID);
                          if (response == 200) {
                            if (mounted) {
                              await showConfirmationDialog(
                                  context, 'Realizado', 'Registro eliminado');
                              handleRefresh();
                            }
                          }
                        }
                      }
                    })

                  //                 DeleteItemButton(
                  //                   onPressed: () async {
                  //                     if (selectedEvalID == 0) {
                  //                       const AlertDialog(
                  //                         title: Text('Error'),
                  //                         content: Text(
                  //                             'Primero selecciona un registro para editar'),
                  //                       );
                ],
              )),
        ],
      ),
    );
    // Padding(
    //   padding: const EdgeInsets.only(left: 2, right: 30, top: 20, bottom: 10),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //     children: [
    //       Column
    //       const Fodac27MenuSelector(),
    //       const Spacer(), // add a spacer to push the RefreshButton to the end
    //       Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //
    //         ],
    //       ),
    //     ],
    //   ),
    // );

    //       Padding(
    //     padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: [
    //         Flexible(
    //           child: DropdownMenu<String>(
    //             controller: studentSelectorController,
    //             enableFilter: true,
    //             requestFocusOnTap: true,
    //             leadingIcon: const Icon(Icons.search),
    //             // trailingIcon: IconButton(
    //             //   onPressed: studentSelectorController.clear,
    //             //   icon: const Icon(Icons.clear),
    //             // ),
    //             label: const Text('Alumno'),
    //             inputDecorationTheme: const InputDecorationTheme(
    //               filled: true,
    //               contentPadding: EdgeInsets.symmetric(vertical: 5.0),
    //             ),
    //             onSelected: (student) {
    //               if (student != null) {
    //                 setState(() {
    //                   selectedStudent = student;
    //                   selectedstudentId = getStudentIdByName(student);
    //                   if (selectedstudentId != null) {
    //                     populateGrid(
    //                         selectedstudentId!, currentCycle!.claCiclo!, true);
    //                   }
    //                 });
    //               }
    //             },
    //             dropdownMenuEntries: simplifiedStudentsList
    //                 .map<DropdownMenuEntry<String>>((e) => DropdownMenuEntry(
    //                     leadingIcon: const Icon(Icons.circle, size: 5),
    //                     value: e['name'],
    //                     label: e['name']
    //                     // +
    //                     //     '  |  ' +
    //                     //     e['grade'].toString() +
    //                     //     e['group'] +
    //                     //     '  |  ' +
    //                     //     e['campus'],
    //                     ))
    //                 .toList(),
    //           ),
    //         ),
    //         Flexible(
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.end,
    //             children: [
    //               AddItemButton(onPressed: handleAddItem),
    //               EditItemButton(
    //                 onPressed: () {
    //                   if (selectedEvalID == 0) {
    //                     const AlertDialog(
    //                       title: Text('Error'),
    //                       content:
    //                           Text('Primero selecciona un registro para editar'),
    //                     );
    //                   } else {
    //                     showDialog(
    //                         context: context,
    //                         builder: (BuildContext context) {
    //                           return EditCommentScreen(
    //                             id: selectedEvalID,
    //                             comment: selectedCommentToEdit,
    //                             date: selectedDateToEdit,
    //                             selectedSubject: selectedSubjectNameToEdit,
    //                             studentID: selectedStudentIdToEdit,
    //                           );
    //                         });
    //                   }
    //                 },
    //               ),
    //               // exportToExcel,
    //               RefreshButton(onPressed: handleRefresh),
    //               if (isUserAdmin)
    //                 DeleteItemButton(
    //                   onPressed: () async {
    //                     if (selectedEvalID == 0) {
    //                       const AlertDialog(
    //                         title: Text('Error'),
    //                         content: Text(
    //                             'Primero selecciona un registro para editar'),
    //                       );
    //                     } else {
    //                       int confirmation =
    //                           await showDeleteConfirmationAlertDialog(context);

    //                       if (confirmation == 1) {
    //                         int response = await deleteAction(selectedEvalID);
    //                         if (response == 200) {
    //                           if (mounted) {
    //                             await showConfirmationDialog(
    //                                 context, 'Realizado', 'Registro eliminado');
    //                           }
    //                         }
    //                       }
    //                     }
    //                   },
    //                 ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
  }

  Widget buildPlutoGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: PlutoGrid(
        mode: PlutoGridMode.selectWithOneTap,
        columns: fodac27Columns,
        rows: fodac27HistoryRows,
        onLoaded: (event) {
          event.stateManager.setSelectingMode(PlutoGridSelectingMode.cell);
          stateManager = event.stateManager;
        },
        onSelected: handleSelectedCell,
        createHeader: (stateManager) =>
            PlutoGridHeader(stateManager: stateManager),
        configuration: const PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
            enableColumnBorderVertical: false,
            enableCellBorderVertical: false,
          ),
        ),
      ),
    );
  }

  void handleAddItem() {
    if (selectedTempStudent == null) {
      showEmptyFieldAlertDialog(context, 'Favor de seleccionar un alumno');
    } else {
      handleRefresh();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Agregar comentario a:\n$selectedTempStudent'),
            content: NewFODAC27CommentDialog(
              selectedstudentId: selectedstudentId!,
              employeeNumber: currentUser!.employeeNumber!,
            ),
          );
        },
      );
    }
  }

  void handleRefresh() {
    for (var map in tempStudentMap) {
      if (map.containsKey('name') && map['name'] == selectedTempStudent) {
        selectedstudentId = map['studentID'];
        break;
      }
    }
    if (selectedstudentId != null) {
      populateGrid(selectedstudentId!, currentCycle!.claCiclo!, true);
    }
  }

  void handleSelectedCell(PlutoGridOnSelectedEvent event) {
    var selectedRow = event.row;
    selectedEvalID = selectedRow?.cells['fodac27']?.value;
    selectedCommentToEdit = selectedRow?.cells['Obs']?.value;
    selectedDateToEdit = selectedRow?.cells['date']?.value;
    selectedSubjectNameToEdit = selectedRow?.cells['subject']?.value;
    selectedStudentIdToEdit = selectedRow?.cells['studentID']?.value;
  }

  String? getStudentIdByName(String name) {
    return simplifiedStudentsList
        .firstWhere((student) => student["name"] == name)["studentID"];
  }

  Future<void> populateGrid(
      String studentID, String cycle, bool isByStudent) async {
    var apiResponse = await getFodac27History(cycle, studentID, isByStudent)
        .onError((error, stackTrace) => stateManager.removeAllRows());
    if (apiResponse != null) {
      var decodedResponse = json.decode(apiResponse) as List;
      List<PlutoRow> newRows = decodedResponse.map((item) {
        return PlutoRow(cells: {
          'date': PlutoCell(value: item['date']),
          'studentID': PlutoCell(value: item['student']),
          'Obs': PlutoCell(value: item['observation']),
          'subject': PlutoCell(value: item['subject']),
          'teacher': PlutoCell(value: item['teacher']),
          'fodac27': PlutoCell(value: int.parse(item['fodac27'])),
        });
      }).toList();

      setState(() {
        fodac27HistoryRows = newRows;
        stateManager.removeAllRows();
        stateManager.appendRows(newRows);
      });
    }
  }

  Future<void> populateStudentsDropDownMenu() async {
    String userRole = currentUser!.role;

    simplifiedStudentsList = await getStudentsByTeacher(
      currentUser!.employeeNumber!,
      currentCycle!.claCiclo!,
      userRole,
    );

    if (simplifiedStudentsList.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<int> deleteAction(int fodac27ID) async {
    var response = await deleteFodac27Record(fodac27ID);
    return response;
  }
}

class EditCellDialog extends StatelessWidget {
  final PlutoCell cell;
  final Function(String) onSave;

  const EditCellDialog({
    Key? key,
    required this.cell,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: cell.value);

    return AlertDialog(
      title: const Text('Editar celda'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Nuevo valor',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            onSave(controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class NewFODAC27CommentDialog extends StatefulWidget {
  final String selectedstudentId;
  final int employeeNumber;

  const NewFODAC27CommentDialog({
    Key? key,
    required this.selectedstudentId,
    required this.employeeNumber,
  });

  @override
  _NewFODAC27CommentDialogState createState() =>
      _NewFODAC27CommentDialogState();
}

class _NewFODAC27CommentDialogState extends State<NewFODAC27CommentDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  String? _selectedSubject;
  List<String> _materias = [];
  Map<String, dynamic> subjectsMap = {};
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void initState() {
    isLoading = true;
    getSubjects();
    // isLoading = false;

    super.initState();
    //_dateController.text = "22/07/2024"; // Initial date
  }

  void getSubjects() async {
    Map<String, dynamic> subjects = await populateSubjectsDropDownSelector(
        widget.selectedstudentId, currentCycle!.claCiclo!);

    _materias = subjects.keys.toList();
    subjectsMap = subjects;
    isLoading = false;
  }

  void _addNewComment() async {
    if (_formKey.currentState!.validate()) {
      var subjectID;

      if (subjectsMap.containsKey(_selectedSubject)) {
        subjectID = subjectsMap[_selectedSubject]!;
      } else {
        debugPrint('Does not exists the in the map');
      }

      var result = await createFodac27Record(
        _dateController.text,
        widget.selectedstudentId,
        currentCycle!.claCiclo!,
        _observacionesController.text,
        widget.employeeNumber,
        subjectID,
      );
      if (result == 'Succes') {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: const Text('Form submitted successfully!')),
        // );
        if (mounted) {
          int response = await showConfirmationDialog(
              context, 'Realizado', 'Comentario agregado!');
          if (response == 1) {
            Navigator.pop(context);
          }
        }
        _dateController.clear();
        _observacionesController.text = '';
      } else {
        showErrorFromBackend(context, result);
      }

      // Show a snackbar notification after function execution
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Fecha'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    readOnly: true,
                    onTap: () {
                      _selectDate(context);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, seleccione una fecha';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Materia'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                      });
                    },
                    items: _materias.map((String materia) {
                      return DropdownMenuItem<String>(
                        value: materia,
                        child: Text(materia),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, seleccione una materia';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Habitos',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Column(
                          children: [
                            Container(
                              color: Colors.grey[500],
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: const Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'Descripción',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  Text('Sel'),
                                ],
                              ),
                            ),
                            const Expanded(
                              child:
                                  Center(child: Text('< No existen Habitos >')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Conductas',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Column(
                          children: [
                            Container(
                              color: Colors.grey[500],
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: const Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'Descripción',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  Text('Sel'),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                  child: Text('< No existen Conductas >')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Observaciones Generales',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese observaciones';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomSaveButton(
                  onPressed: () {
                    _addNewComment();
                  },
                )

                    // ElevatedButton(
                    //   onPressed: () {
                    //     _addNewComment();
                    //   },
                    //   child: const Text('Guardar'),
                    // ),
                    ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(child: CustomCancelButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )

                    //  ElevatedButton(
                    //   style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => null) ),
                    //     onPressed: () => Navigator.pop(context),
                    //     child: const Text('Cancelar'))
                    )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class EditCommentScreen extends StatefulWidget {
  final int id;
  final String comment;
  final String date;
  final String selectedSubject;
  final String studentID;

  const EditCommentScreen({
    required this.id,
    required this.comment,
    required this.date,
    required this.selectedSubject,
    required this.studentID,
  });

  @override
  _EditCommentScreenState createState() => _EditCommentScreenState();
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  late TextEditingController _commentController;
  late TextEditingController _dateController;
  DateTime? _selectedDate;
  DateFormat format = DateFormat("d/M/y");
  DateTime? date;
  List<String> _subjects = [];
  String? _selectedSubject;

  Map<String, dynamic> subjectsMap = {};
  Map<String, dynamic> newObservation = {};
  Map<String, dynamic> newDate = {};
  Map<String, dynamic> newSubject = {};

  @override
  void initState() {
    date = format.parse(widget.date);
    getSubjects();
    _selectedSubject = widget.selectedSubject;
    _commentController = TextEditingController(text: widget.comment);
    _dateController = TextEditingController(text: widget.date);
    _selectedDate = date;
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _dateController.dispose();

    subjectsMap.clear();
    newObservation.clear();
    newDate.clear();
    newSubject.clear();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(picked);
        newDate.clear();
        newDate = {'date': _dateController.text};
      });
    }
  }

  void getSubjects() async {
    Map<String, dynamic> subjects = await populateSubjectsDropDownSelector(
        widget.studentID, currentCycle!.claCiclo!);
    setState(() {
      _subjects = subjects.keys.toList();
      subjectsMap = subjects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Materia'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              hint: const Text('Materia'),
              disabledHint: const Text('Materia'),
              value: _selectedSubject,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  newSubject.clear();
                  _selectedSubject = newValue;
                  var subjectID = subjectsMap[newValue];
                  newSubject = {'subject': subjectID};
                });
              },
              items: _subjects.map((String materia) {
                return DropdownMenuItem<String>(
                  value: materia,
                  child: Text(materia),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _commentController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Observacion',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                newObservation.clear();
                newObservation = {'observation': value};
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(),
              ),
              onTap: _selectDate,
              onChanged: (value) {
                newDate.clear();
                newDate = {'date': _dateController.text};
              },
            ),
          ],
        ),
      ),
      actions: [
        CustomCancelButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CustomSaveButton(onPressed: () async {
          Map<String, dynamic> id = {'id': widget.id};

          var bodyToEdit = validateEditedFields(
            id,
            newObservation,
            newDate,
            newSubject,
          );
          if (bodyToEdit != null) {
            int response = await updateFodac27Record(bodyToEdit);
            if (response == 200) {
              if (mounted) {
                int response = await showConfirmationDialog(
                    context, 'Realizado', 'Registro modificado exitosamente');
                if (response == 1) {
                  Navigator.pop(context);
                }
              }
            }
          } else {
            return;
          }
        }),
      ],
    );
  }

  Map<String, dynamic>? validateEditedFields(
      Map<String, dynamic> id,
      Map<String, dynamic> newObservation,
      Map<String, dynamic> newDate,
      Map<String, dynamic> newSubject) {
    // if (newObservation.isNotEmpty || newDate.isNotEmpty || newSubject.isNotEmpty) {
    Map<String, dynamic> body = {};
    body.addEntries(id.entries);
    if (newObservation.isNotEmpty) {
      body.addEntries(newObservation.entries);
    }
    if (newDate.isNotEmpty) {
      body.addEntries(newDate.entries);
    }
    if (newSubject.isNotEmpty) {
      body.addEntries(newSubject.entries);
    }
    return body;
  }
}
