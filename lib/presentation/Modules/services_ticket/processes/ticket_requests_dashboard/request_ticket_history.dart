import 'package:flutter/material.dart';

class RequestTicketHistory extends StatelessWidget {
  const RequestTicketHistory({super.key, required this.history});
  final List<Map<String, Object>> history;

  @override
  Widget build(BuildContext context) {
    final List<DataRow> rows = [];


    for (var item in history ) {
      rows.add(
        DataRow(
          cells: [
            DataCell(Text(item['idReqSerDepto'].toString())),
            DataCell(Text(item['Estatus'].toString().trim())),
            DataCell(Text(item['Observaciones'].toString().trim())),
            DataCell(Text(item['NoEmpleado'].toString().trim())),
            DataCell(Text(item['FechaMov'].toString().trim())),
          ],
        ),
      );
    }



    List<DataColumn> columns = [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('Estatus')),
      DataColumn(label: Text('observaciones')),
      DataColumn(label: Text('Número de empleado')),
      DataColumn(label: Text('Fecha de movimiento')),
    ];

    

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: DataTable(columns: columns, rows: rows),
      ),
      );
  }
}