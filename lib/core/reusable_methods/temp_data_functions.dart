import 'dart:convert';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
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
    var apiResponse = await getUserRoleAndAcces(currentUser!.role);
    List<dynamic> jsonList = json.decode(apiResponse.body);
    tmpeventsList = jsonList;
    eventsLisToShow =
        tmpeventsList.map((item) => Map<String, dynamic>.from(item)).toList();
  } catch (e) {
    throw Future.error(e.toString());
  }
}

int getEventIDbyName(String eventName) {
  // ignore: prefer_typing_uninitialized_variables
  var idValue;
  for (var item in tmpeventsList) {
    if ((item['EventName'] as String).compareTo(eventName) == 0) {
      idValue = item['id'];
    }
  }
  return idValue;
}

Future<void> getRolesTempList() async {
  try {
    var response = await getRolesList();
    tmpRolesList = json.decode(response.body);
  } catch (e) {
    insertErrorLog(e.toString(), 'getRolesList()');
    throw Future.error(e.toString());
  }
}
