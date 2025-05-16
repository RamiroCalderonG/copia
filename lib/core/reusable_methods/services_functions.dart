import 'dart:convert';

import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/ServiceTicketRequest.dart';
import 'package:oxschool/data/datasources/temp/services_temp.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:trina_grid/trina_grid.dart';

Future<List<TrinaRow>> getServiceTicketsByDate(
    String fromDate, int statusValue, int byWho) async {
  List<TrinaRow> newRows = [];
  try {
    final response = await getAllServiceTickets(fromDate, statusValue, byWho);
    if (response.statusCode == 200) {
      servicesTicketsDecodedResponse =
          json.decode(utf8.decode(response.bodyBytes));

      /* newRows = servicesTicketsDecodedResponse.map((item) {
        // Calculate if the service is still on time or overdue
        DateTime deadline =
            DateTime.parse(item['deadLine']); // Fecha compromiso
        DateTime requesttedDate = DateTime.parse(item['serviceRequestDate']);
        DateTime today = DateTime.now();

        bool isDeadLineOnTime = true;
        bool isRequesttedDateOnTime = true;

        if (today.isAfter(deadline) && item['status'] != 3) {
          //If the service is overdue
          isDeadLineOnTime = false;
        }
        if (today.isAfter(requesttedDate) && item['status'] != 3) {
          //If the service is overdue
          isRequesttedDateOnTime = false;
        }

        return TrinaRow(cells: {
          'id': TrinaCell(value: item['idReqServ']),
          'reportedBy': TrinaCell(
              value: item['reportedBy'].toString().trim().toTitleCase),
          'departmentWhoRequest': TrinaCell(
              value: item['requestFromDept'].toString().trim().toTitleCase),
          'capturedBy': TrinaCell(
              value: item['capturedBy'].toString().trim().toTitleCase),
          'depRequestIsMadeTo': TrinaCell(
              value: item['requestToDept'].toString().trim().toTitleCase),
          'assignedTo': TrinaCell(
              value: item['assignedTo'].toString().trim().toTitleCase),
          'campus':
              TrinaCell(value: item['campus'].toString().trim().toTitleCase),
          'requestCreationDate': TrinaCell(value: item['serviceCreationDate']),
          'requesDate': TrinaCell(value: item['serviceRequestDate']),
          'deadline': TrinaCell(value: item['deadLine']),
          'closureDate': TrinaCell(value: item['closureDate']),
          'description':
              TrinaCell(value: item['description'].toString().trim()),
          'observations':
              TrinaCell(value: item['observations'].toString().trim()),
          'status': TrinaCell(value: item['status']),
          'deadLineOnTime': TrinaCell(value: isDeadLineOnTime),
          'requesttedDateOnTime': TrinaCell(value: isRequesttedDateOnTime),
        });
      }).toList(); */

      servicesTicketsDecodedResponseList =
          await getServicesTickets(servicesTicketsDecodedResponse);
      refreshTicketsCuantity();
      return newRows;
    } else {
      return newRows;
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'getServiceTicketsByDate($fromDate)');
    throw Future.error(e.toString());
  }
}

Future<List<Serviceticketrequest>> getServicesTickets(
    List<dynamic> apiResponse) async {
  if (apiResponse.isNotEmpty) {
    List<Serviceticketrequest> servicesTickets = [];
    for (var item in apiResponse) {
      try {
        servicesTickets.add(Serviceticketrequest.fromJson(item));
      } catch (e) {
        insertErrorLog(
            e.toString(), 'getServicesTickets(${item['idReqServ']})');
        throw Future.error(e.toString());
      }
    }
    return servicesTickets;
  } else {
    return [];
  }
}

void refreshTicketsCuantity() {
  assignedTickets.clear();
  unassignedTickets.clear();
  onProgressTickets.clear();
  closedTickets.clear();
  overdueTickets.clear();
  totalTickets = 0;
  assigned = 0;
  onProgress = 0;
  closed = 0;
  overdue = 0;
  unassigned = 0;

  for (var item in servicesTicketsDecodedResponseList) {
    totalTickets++;
    // Calculate if the service is still on time or overdue
    DateTime today = DateTime.now();

    if (item.deadLine != null) {
      DateTime deadline = item.deadLine!;
      if (today.isAfter(deadline) && item.status != 3) {
        //If the service is overdue
        overdue++;
        overdueTickets.add(item);
      }
    }

    DateTime requesttedDate = item.serviceRequestDate;
    if (today.isAfter(requesttedDate) && item.status != 3) {
      //If the service is overdue
      overdue++;
      overdueTickets.add(item);
    }
      //Count items by status
    if (item.status == 0) {
      unassigned++;
      unassignedTickets.add(item);
    } else if (item.status == 1) {
      assigned++;
      assignedTickets.add(item);
    } else if (item.status == 2) {
      onProgress++;
      onProgressTickets.add(item);
    } else if (item.status == 3) {
      closed++;
      closedTickets.add(item);
    }
  }
}

Future<List<Map<String, dynamic>>> getRequestTicketHistory(int ticketId) async {
  try {
    var response = await getRequestticketHistory(ticketId);
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> history = [];
      var decodedResponse = json.decode(utf8.decode(response.bodyBytes));
      for (var item in decodedResponse) {
        history.add(item);
      }
      return history;
    } else {
      return [];
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'getRequestTicketHistory($ticketId)');
    throw Future.error(e.toString());
  }
}

Future<dynamic> getUsersList(int filter, String dept) async {
  try {
    var response = await getUsersForTicket(filter, dept);
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> usersList = [];
      var decodedResponse = json.decode(utf8.decode(response.bodyBytes));
      for (var item in decodedResponse) {
        usersList.add(item);
      }
      return usersList;
    } else {
      return [];
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'getUsersList()');
    throw Future.error(e.toString());
  }
}

Future<dynamic> getDepartments() async {
  try {
    var response = await getWorkDepartments();
    if (response.statusCode == 200) {
      Map<int, dynamic> deptsMap = {};
      var decoded = json.decode(utf8.decode(response.bodyBytes));
      for (var element in decoded) {
        deptsMap.addAll({element['id']: element['bureauName']});
      }
      return deptsMap;
    } else {
      throw Future.error(response.body.toString());
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'getDepartments()');
    throw Future.error(e.toString());
  }
}

Future<dynamic> createRequestTicket(Map<String, dynamic> body) async {
  try {
    var response = await createNewTicketServices(body);
    return json.decode(utf8.decode(response.bodyBytes));
  } catch (e) {
    insertErrorLog(e.toString(), 'createRequestTicket');
    throw e.toString();
  }
}

Future<dynamic> updateRequestTicket(
    Map<String, dynamic> contents, int flag) async {
  try {
    var response = await updateSupportTicket(contents, flag);
    return json.decode(utf8.decode(response.bodybytes));
  } catch (e) {
    insertErrorLog(e.toString(), 'updateRequestTicket');
    return e;
  }
}
