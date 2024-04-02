import 'dart:convert';

import 'package:oxschool/temp/users_temp_data.dart';

import '../backend/api_requests/api_calls_list.dart';

void clearTempData() {
  listOfUsersForGrid = null;
  usersPlutoRowList.clear();
  selectedUser = null;
  tempUserId = null;
  tempSelectedUsr = null;
  userRows.clear();
  tmpRolesList.clear();
  userRoles.clear();
//var
}

void getEventsList() async {
  try {
    var apiResponse = await getEvents();
    List<dynamic> jsonList = json.decode(apiResponse);
    eventsList = jsonList;
  } catch (e) {
    throw FormatException(e.toString());
  }
}
