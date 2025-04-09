import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestTicketHistory extends StatelessWidget {
  const RequestTicketHistory({super.key, required this.history});
  final List<Map<String, dynamic>> history;

  @override
  Widget build(BuildContext context) {
    final List<DataRow> rows = [];


    for (var item in history ) {
      var date = DateFormat('yyyy-MM-dd').format(DateTime.parse(item['FechaMov']));
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Center(
                child: Text(item['idReqSerDepto'].toString(), style: TextStyle(
              fontSize: 12,
              fontFamily: 'Sora',
            ),textAlign: TextAlign.center),
              )
              ),
            DataCell(
              Center(
                child:
                Text(item['Estatus'].toString().trim(), style: TextStyle(
              fontSize: 12,
              fontFamily: 'Sora',
            ), textAlign: TextAlign.center, )
              ),
              ),
           DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 350, maxHeight: 300),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(padding: const EdgeInsets.only(top: 6, bottom: 6), child: Text(
                item['Observaciones'].toString().trim(),
                overflow: TextOverflow.visible, 
                softWrap: true, 
                style: const TextStyle(fontSize: 12), 
              ) ,)
            ), 
          ),
        ),
            DataCell(
              Center(child: Text(item['NoEmpleado'].toString().trim(), style: TextStyle(
              fontSize: 12,
              fontFamily: 'Sora',
            ),textAlign: TextAlign.center))
              ),
            DataCell(Text( date, style: TextStyle(
              fontSize: 12,
              fontFamily: 'Sora',
            ),textAlign: TextAlign.center), ),
          ],
        ),
      );
    }



    List<DataColumn> columns = [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('Estatus')),
      DataColumn(label: Text('Observaciones') ),
      DataColumn(label: Text('No. Empleado')),
      DataColumn(label: Text('Fecha')),
    ];

    

    return Padding(
      padding: const EdgeInsets.all(8),
      child:  SingleChildScrollView(
        child: DataTable(
          columns: columns, 
          rows: rows,

          columnSpacing: 25,
          dataRowMaxHeight: 130,
          dataTextStyle: TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),)
          
          ),
      )
      
    
      );
  }
}