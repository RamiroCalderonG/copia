import 'dart:convert';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/Event.dart';
import 'package:oxschool/data/Models/Module.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';

import '../../data/services/backend/api_requests/api_calls_list.dart';

void clearTempData() {
  listOfUsersForGrid = null;
  usersPlutoRowList.clear();
  selectedUser = null;
  tempUserId = null;
  tempSelectedUsr = null;
  userRows.clear();
  tmpRolesList.clear();
  userRoles.clear();
}

Future<void> getEventsList() async {
  try {
    var apiResponse = await getUserRoleAndAcces(currentUser!.roleID!);
    List<dynamic> jsonList = json.decode(apiResponse.body);
    tmpeventsList = jsonList;
    eventsLisToShow =
        tmpeventsList.map((item) => Map<String, dynamic>.from(item)).toList();
  } catch (e) {
    throw Future.error(e.toString());
  }
}

int getEventIDbyName(String eventName) {
  var idValue;
  for (var item in tmpeventsList) {
    if ((item['name']).compareTo(eventName) == 0) {
      idValue = item['id'];
    }
  }
  return idValue;
}

Future<dynamic> getRolesTempList() async {
  try {
    var response = await getRolesList();
    tmpRolesList = json.decode(response.body);
    return tmpRolesList;
  } catch (e) {
    insertErrorLog(e.toString(), 'getRolesList()');
    return Future.error(e.toString());
  }
}

Future<void> getEventsTempList() async {
  try {
    var response = await getEventsListRequest();
    tmpeventsList = json.decode(response.body);
  } catch (e) {
    insertErrorLog(e.toString(), 'getEventsList()');
    throw Future.error(e.toString());
  }
}

Future<dynamic> fetchEventsByRole(int roleId) async {
  try {
    var eventsByRole = await getEventsByRole(roleId);
    if (eventsByRole != null) {
      var jsonList = json.decode(eventsByRole.body);
      return jsonList;
    } else {
      return Future.error('Value is null');
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'fetchEventsByRole()');
    Future.error(e.toString());
  }
}

Future<dynamic> fetchModulesAndEventsDetailed() async {
  try {
    List<Event> eventsList = [];
    getEventsAndModulesCall().then((apiResponse) {
      var eventsModule = json.decode(apiResponse);
      for (var item in eventsModule) {
        Event event = Event(item["event_id"], item["event_name"],
            item["event_active"], item['module_name'], true);
        eventsList.add(event);
      }
    }).catchError((error) {
      insertErrorLog(error.toString(), 'getEventsAndModulesCall()');
      Future.error(error);
    });

    List<Module> moduleList = [];
    await getModulesListDetailed().then((apiResponse) {
      var jsonList = json.decode(apiResponse);
      for (var item in jsonList) {
        Module module = Module.fromJson(item);
        moduleList.add(module);
      }
    }).catchError((onError) {
      insertErrorLog(onError.toString(), 'getModulesListDetailed()');
      Future.error(onError);
    });

    if (moduleList.isNotEmpty) {
      for (var item in moduleList) {
        //TODO: INSERT EVENTS INTO MODULE BY ID
      }
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'fetchModulesAndEventsDetailed()');
    return Future.error(e);
  }
}
