import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/temp/users_temp_data.dart';

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

    User currentUser = User(claUn, employeeName, employeeNumber, role, userId,
        token, schoolEmail, usergenre, isActive);

    users.add(currentUser);
  }

  return users;
}

bool verifyUserAdmin(User currentUser) {
  if (currentUser.role == "Administrator") {
    return true;
  } else {
    return false;
  }
}

dynamic getSingleUser(String? userId) async {
  if (userId == null) {
    userId = tempUserId;
    selectedUser = await getUserDetail(userId!);
    List<dynamic> jsonList = json.decode(selectedUser);
    try {
      for (var i = 0; i < jsonList.length; i++) {
        var claUn = jsonList[i]['claun'];
        var employeeName = jsonList[i]['nombre_gafete'];
        var employeeNumber = jsonList[i]['noempleado'];
        var role = jsonList[i]['role_name'];
        var nwuserId = jsonList[i]['role_name'];
        var token = '';
        var userEmail = jsonList[i]['user_email'];
        var usergenre = jsonList[i]['genre'];
        var isActive = jsonList[i]['bajalogicasino'];
        var userId = 0;

        tempSelectedUsr = User(claUn, employeeName, employeeNumber, role,
            userId, token, userEmail, usergenre, isActive);
      }
      return tempSelectedUsr;
    } catch (e) {
      AlertDialog(
        title: Text("Error"),
        content: Text(e.toString()),
      );
    }

    // tempSelectedUsr = tempSelectedUsr!.fromJson(jsonList);
  } else {
    selectedUser = await getUserDetail(userId);
  }
}
