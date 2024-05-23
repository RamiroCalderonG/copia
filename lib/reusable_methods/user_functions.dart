import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/Models/Role.dart';
import 'package:oxschool/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/temp/users_temp_data.dart';

import '../Models/Event.dart';
import '../Models/User.dart';

List<User> parseUsersFromJSON(List<dynamic> jsonList) {
  List<User> users = [];

  for (var item in jsonList) {
    int employeeNumber = item['noempleado'];
    String employeeName = item['nombre_gafete'];
    String claUn = item['claun'];
    String role = item['role_name'];
    int userId = item['id'];
    String token = 'null';
    String schoolEmail = item['user_email'];
    String usergenre = item['genre'];
    int isActive = item['bajalogicasino'];
    String? workArea = item['work_department'];
    String? workPosition = item['work_positon'];
    String? creationDate = item['creation'];
    String? birthdate = item['birthdate'];

    User currentUser = User(
        claUn,
        employeeName,
        employeeNumber,
        role,
        userId,
        token,
        schoolEmail,
        usergenre,
        isActive,
        workArea,
        workPosition,
        creationDate,
        birthdate);

    users.add(currentUser);
  }

  return users;
}

bool verifyUserAdmin(User currentUser) {
  if (currentUser.role == "Administrador") {
    return true;
  } else {
    return false;
  }
}

dynamic getSingleUser(String? userId) async {
  if (userId == null) {
    userId = tempUserId.toString();
    selectedUser = await getUserDetail(userId);
    List<dynamic> jsonList = json.decode(selectedUser);
    try {
      for (var i = 0; i < jsonList.length; i++) {
        var claUn = jsonList[i]['claun'];
        var employeeName = jsonList[i]['nombre_gafete'];
        var employeeNumber = jsonList[i]['noempleado'];
        var role = jsonList[i]['role_name'];
        // var nwuserId = jsonList[i]['role_name'];
        var token = '';
        var userEmail = jsonList[i]['user_email'];
        var usergenre = jsonList[i]['genre'];
        var isActive = jsonList[i]['bajalogicasino'];
        var userId = 0;
        String? workArea = jsonList[i]['department'];
        String? workPosition = jsonList[i]['positon'];
        String? creationDate = jsonList[i]['createdAt'];
        String? birthdate = jsonList[i]['birthdate'];

        tempSelectedUsr = User(
            claUn,
            employeeName,
            employeeNumber,
            role,
            userId,
            token,
            userEmail,
            usergenre,
            isActive,
            workArea,
            workPosition,
            creationDate,
            birthdate);
      }
      return tempSelectedUsr;
    } catch (e) {
      AlertDialog(
        title: const Text("Error"),
        content: Text(e.toString()),
      );
    }

    // tempSelectedUsr = tempSelectedUsr!.fromJson(jsonList);
  } else {
    selectedUser = await getUserDetail(userId);
  }
}

// ignore: non_constant_identifier_names
dynamic EventFromJSON(List<dynamic> jsonData) {
  List<Event> eventList = [];
  if (jsonData.isEmpty) {
    return null;
  } else {
    for (var item in jsonData) {
      int idEvento = item['id'];
      String eventName = item['event_name'];
      bool isActive = item['active'];
      String moduleName = item['module_name'];
      // int moduleID = item['module_id'];
      bool eventCanAccesModule = item['event_can_acces_module'];
      // int roleID = item['role_id'];

      eventList.add(Event(
          idEvento, eventName, isActive, moduleName, eventCanAccesModule));
    }
    return eventList;
  }
}

// ignore: non_constant_identifier_names
dynamic RoleFromJSON(List<dynamic> jsonData) {
  List<Role> roleList = [];
  if (jsonData.isEmpty) {
    return null;
  } else {
    for (var item in jsonData) {
      int roleID = item['role_id'];
      String roleName = item['role_name'];
      String roleDescription = item['role_description'];
      bool isActive = item['is_active'];

      roleList.add(Role(roleID, roleName, roleDescription, isActive, null));
    }
    return roleList;
  }
}

dynamic activateUser(String employeeNum, int activeValue) async {
  var body = {'bajalogicasino': activeValue};
  try {
    var response = await editUser(body, employeeNum);
    return response;
  } catch (e) {
    return ErrorDescription(e.toString());
  }
}
