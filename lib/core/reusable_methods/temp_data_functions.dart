import 'dart:convert';

import 'package:oxschool/core/constants/screens.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/utils/temp_data.dart';
import 'package:oxschool/data/DataTransferObjects/Role_module_relationship_dto.dart';
import 'package:oxschool/data/Models/Event.dart';
import 'package:oxschool/data/Models/Module.dart';
import 'package:oxschool/data/Models/Role.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/backend/api_requests/api_calls_list.dart';

void clearTempData() {
  listOfUsersForGrid.clear();
  //usersTrinaRowList.clear();
  selectedUser = null;
  tempUserId = null;
  tempSelectedUsr = null;
  userRows.clear();
  tmpRolesList.clear();
  userRoles.clear();
  uniqueItems.clear();
  SharedPreferences.getInstance().then((prefs) {
    prefs.remove('isUserAdmin');
    prefs.remove('idSession');
    prefs.remove('ip');
    prefs.remove('device');
    prefs.remove('token');
    prefs.remove('currentUserEmail');
  });
}

List<Map<String, List<String>>> getUniqueItems(
    List<Map<String, dynamic>> moduleScreenList,
    List<Map<String, dynamic>> screenEventList) {
  // Initialize the uniqueItemsList
  List<Map<String, List<String>>> uniqueItemsList = [];

  // Create a temporary map to accumulate unique items per key
  Map<String, Set<String>> tempMap = {};

  // Iterate over moduleScreenList
  for (var module in moduleScreenList) {
    // Assuming the structure of the map is like { "key": "value" }
    module.forEach((key, value) {
      // Initialize a set for this key if it doesn't exist
      if (!tempMap.containsKey(key)) {
        tempMap[key] = Set<String>();
      }
      // Add value to the set (sets automatically handle duplicates)
      tempMap[key]?.add(value);
    });
  }

  // Iterate over screenEventList to add values to the uniqueItemsList
  for (var event in screenEventList) {
    event.forEach((key, value) {
      // If the key exists in tempMap, we add this value to the set
      if (tempMap.containsKey(key)) {
        tempMap[key]?.add(value);
      }
    });
  }

  // Convert the map to a List<Map<String, List<String>>>
  tempMap.forEach((key, value) {
    uniqueItemsList.add({key: value.toList()});
  });

  return uniqueItemsList;
}

//Function that retrieves user permissions and add them into currentUser.userRole
Future<void> getRoleListOfPermissions(Map<String, dynamic> jsonuserInfo) async {
  try {
    getRolePermissions().then((onValue) {
      Map<String, dynamic> jsonResponse =
          json.decode(utf8.decode(onValue.bodyBytes));

      //Create Role object to then insert it into currentUser.userRole
      Role userRole = Role(
          roleID: jsonuserInfo['userRole']['id'],
          roleName: jsonuserInfo['userRole']['softName'],
          roleDescription: jsonuserInfo['userRole']['description'],
          isActive: jsonuserInfo['userRole']['isActive']);

      List<dynamic> moduleScreenListMap = jsonResponse['moduleScreen'];
      List<dynamic> eventScreenListMap = jsonResponse['screenEvents'];

      // Get unique moduleScreen relations and screenEvents relations
      uniqueItems = getUniqueItems(
          moduleScreenListMap
              .map((item) => Map<String, dynamic>.from(item))
              .toList(),
          eventScreenListMap
              .map((item) => Map<String, dynamic>.from(item))
              .toList());

      // Assign the unique items to the userRole
      userRole.moduleScreenList = uniqueItems;

      currentUser!.userRole = userRole; // Insert Role into currentUser.userRole
      return;
    }).onError((error, stackTrace) {
      insertErrorLog(error.toString(), 'getRolePermissions');
      throw Future.error(error.toString());
    });
  } catch (e) {
    insertErrorLog(e.toString(), 'getRoleListOfPermissions() | ');
    throw Future.error(e.toString());
  }
}

Future<void> getUserAccessRoutes() async {
  var response = await getScreenAccessRoutes();
  var tmpResponse = json.decode(utf8.decode((response.bodyBytes)));
  for (var item in tmpResponse) {
    accessRoutes.add(item);
  }

  //accessRoutes = json.decode(response);

  //accessRoutes = tempResponse.;
  return;
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
      List<RoleModuleRelationshipDto> roleDetailedList = [];
      for (var item in jsonList) {
        RoleModuleRelationshipDto roleDetails =
            RoleModuleRelationshipDto.fromJSON(item);
        roleDetailedList.add(roleDetails);
      }
      return roleDetailedList;
    } else {
      return Future.error('Value is null');
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'fetchEventsByRole()');
    Future.error(e.toString());
  }
}

Future<List<RoleModuleRelationshipDto>> fetchScreensByRoleId(int roleId) async {
  List<RoleModuleRelationshipDto> screensList = [];
  try {
    await getScreenListByRoleId(roleId).then((response) {
      var jsonList = json.decode(utf8.decode(response.bodyBytes));
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
    return screensList;
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
