import 'dart:convert';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/DataTransferObjects/RoleModuleRelationshipDto.Dart';
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
    if (eventsByRole != null && eventsByRole.body != '[]') {
      // var evenntsList = eventsByRole.body;
      var jsonList = json.decode(utf8.decode(eventsByRole.bodyBytes));
      return jsonList;
    } else {
      return Future.error('Value is null');
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'fetchEventsByRole()');
    Future.error(e.toString());
  }
}

Future<dynamic> fetchScreensByRoleId(int roleId) async {
  List<RoleModuleRelationshipDto> screensList = [];
  try {
    await getScreenListByRoleId(roleId).then((response) {
      var jsonList = json.decode(response.body);
      for (var item in jsonList) {
        RoleModuleRelationshipDto newItem =
            RoleModuleRelationshipDto.fromJSON(item);
        screensList.add(newItem);
      }
      return screensList;
    }).onError((error, stackTrace) {
      insertErrorLog(error.toString(), 'fetchScreensByRoleId($roleId)');
      return Future.error(error.toString());
    });
  } catch (e) {
    insertErrorLog(e.toString(), 'fetchScreensByRoleId($roleId)');
    return Future.error(e.toString());
  }
}

Future<List<Module>> fetchModulesAndEventsDetailed() async {
  List<Module> sortedModuleList = [];
  List<Module> moduleList = [];
  List<Event> eventsList = [];
  List<Module> preSortedModuleList = [];
  try {
    await getEventsAndModulesCall().then((apiResponse) {
      var eventsModule = json.decode(apiResponse);
      for (var item in eventsModule) {
        Event event = Event(
            item["event_id"],
            item["event_name"],
            item["event_active"],
            item['module_name'],
            item["role_id"],
            item['can_access']);
        eventsList.add(event);
      }

      return getModulesListDetailed().then((apiResponse) {
        var jsonList = json.decode(apiResponse);
        for (var item in jsonList) {
          Module module = Module.fromJsonWithoutEvents(item);
          moduleList.add(module);
        }

        if (moduleList.isNotEmpty && eventsList.isNotEmpty) {
          for (var moduleItem in moduleList) {
            for (var eventItem in eventsList) {
              if (moduleItem.name == eventItem.moduleName) {
                moduleItem.eventsList?.add(eventItem);
                if (sortedModuleList.isEmpty) {
                  sortedModuleList.add(moduleItem);
                } else {
                  bool exists = sortedModuleList
                      .any((element) => element.name == moduleItem.name);

                  if (!exists) {
                    sortedModuleList.add(moduleItem);
                  }
                }
              }
            }
          }
        }
        return sortedModuleList;
      });
    }).catchError((error) {
      insertErrorLog(error.toString(), 'getEventsAndModulesCall()');
      throw Future.error(error);
    });
  } catch (e) {
    insertErrorLog(e.toString(), 'fetchModulesAndEventsDetailed()');
    throw Future.error(e);
  }
  return sortedModuleList;
}
