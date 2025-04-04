
import 'dart:convert';

import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:pluto_grid/pluto_grid.dart';

Future<List<PlutoRow>> getServiceTicketsByDate(String fromDate, int statusValue, int byWho) async{
  List<PlutoRow> newRows = [];
  try {
    final response = await getAllServiceTickets(fromDate, statusValue, byWho);
    if (response.statusCode == 200) {
      List<dynamic> decodedResponse = json.decode(utf8.decode(response.bodyBytes));

        newRows = decodedResponse.map((item) {
          // Calculate if the service is still on time or overdue
          DateTime deadline = DateTime.parse(item['deadLine']); // Fecha compromiso
          DateTime requesttedDate = DateTime.parse(item['serviceRequestDate']);
          DateTime today = DateTime.now();

          bool isDeadLineOnTime = true;
          bool isRequesttedDateOnTime = true;

          if (today.isAfter(deadline) && item['status'] != 3) { //If the service is overdue
            isDeadLineOnTime = false;
          }
          if (today.isAfter(requesttedDate) && item['status'] != 3) { //If the service is overdue
            isRequesttedDateOnTime = false;
          }

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
          'description': PlutoCell(value: item['description'].toString().trim()),
          'observations': PlutoCell(value: item['observations'].toString().trim()),
          'status': PlutoCell(value: item['status']),
          'deadLineOnTime' : PlutoCell(value: isDeadLineOnTime ),
          'requesttedDateOnTime' : PlutoCell(value: isRequesttedDateOnTime),
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