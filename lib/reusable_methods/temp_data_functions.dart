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
}

Future getEventsList() async {
  try {
    var apiResponse = await getEvents(null);
    List<dynamic> jsonList = json.decode(apiResponse);
    tmpeventsList = jsonList;
    eventsLisToShow =
        tmpeventsList.map((item) => Map<String, dynamic>.from(item)).toList();
  } catch (e) {
    throw FormatException(e.toString());
  }
}
