import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/temp/users_temp_data.dart';

class UserEventsManagerDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> eventsList;

  UserEventsManagerDataTable({required this.eventsList});

  @override
  _UserEventsManagerDataTableState createState() =>
      _UserEventsManagerDataTableState();
}

class _UserEventsManagerDataTableState
    extends State<UserEventsManagerDataTable> {
  late List<Map<String, dynamic>> _eventsList;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _eventsList = List.from(widget.eventsList);
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic>) getField,
      int columnIndex, bool ascending) {
    _eventsList.sort((a, b) {
      if (!ascending) {
        final temp = a;
        a = b;
        b = temp;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
  }

  void _addNewEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController eventNameController = TextEditingController();
        String selectedRoleName =
            _eventsList.isNotEmpty ? _eventsList.first['RoleName'] : '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: selectedRoleName,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRoleName = newValue!;
                        });
                      },
                      items: _eventsList
                          .map((event) {
                            return DropdownMenuItem<String>(
                              value: event['RoleName'].toString(),
                              child: Text(event['RoleName'].toString()),
                            );
                          })
                          .toSet()
                          .toList(),
                    ),
                    TextField(
                      controller: eventNameController,
                      decoration: InputDecoration(labelText: 'Event Name'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _eventsList.add({
                        'id': _eventsList.length + 1,
                        'role_id': _eventsList.firstWhere((element) =>
                            element['RoleName'] == selectedRoleName)['role_id'],
                        'RoleName': selectedRoleName,
                        'EventName': eventNameController.text,
                        'isActive': true,
                      });
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: Text('Rol'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _sort<String>((event) => event['RoleName'].toString(),
                      columnIndex, ascending);
                });
              },
            ),
            DataColumn(
              label: Text('Evento'),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _sort<String>((event) => event['EventName'].toString(),
                      columnIndex, ascending);
                });
              },
            ),
            DataColumn(label: Text('¿Activo?')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: _eventsList.map((event) {
            return DataRow(cells: [
              DataCell(Text(event['RoleName'].toString())),
              DataCell(Text(event['EventName'].toString())),
              DataCell(Center(
                child: Checkbox(
                  value: event['isActive'] as bool,
                  onChanged: (value) {
                    setState(() {
                      event['isActive'] = value;
                    });
                  },
                ),
              )),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Implement edit logic
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _eventsList.remove(event);
                      });
                    },
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewEvent();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
