
import 'dart:convert';

import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:pluto_grid/pluto_grid.dart';

Future<List<PlutoRow>> getServiceTicketsByDate(String fromDate) async{
  List<PlutoRow> newRows = [];
  try {
    final response = await getAllServiceTickets(fromDate);
    if (response.statusCode == 200) {
      List<dynamic> decodedResponse = json.decode(utf8.decode(response.bodyBytes));

        newRows = decodedResponse.map((item) {
        return PlutoRow(cells: {
          'id': PlutoCell(value: item['idReqServ']),
          'reportedBy': PlutoCell(value: item['reportedBy'].toString().trim().toTitleCase),
          'departmentWhoRequest': PlutoCell(value: item['requestFromDept'].toString().trim().toTitleCase),
          'capturedBy': PlutoCell(value: item['capturedBy'].toString().trim().toTitleCase),
          'depRequestIsMadeTo': PlutoCell(value: item['requestToDept'].toString().trim().toTitleCase),
          'assignedTo': PlutoCell(value: item['assignedTo'].toString().trim().toTitleCase),
          'campus': PlutoCell(value: item['campus'].toString().trim().toTitleCase),
          'requestCreationDate': PlutoCell(value: item['serviceCreationDate']),
          'requesDate': PlutoCell(value: item['serviceRequestDate']),
          'deadline': PlutoCell(value: item['deadLine']),
          'closureDate': PlutoCell(value: item['closureDate']),
          'description': PlutoCell(value: item['description'].toString().trim().toTitleCase),
          'observations': PlutoCell(value: item['observations'].toString().trim().toTitleCase),
          'status': PlutoCell(value: item['status']),
        });
      }).toList();
      return newRows;
    } else {
      return newRows;
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'getServiceTicketsByDate($fromDate)');
    throw Future.error(e.toString());
  }
  
  


}