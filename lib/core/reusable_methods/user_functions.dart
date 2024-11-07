import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/Cycle.dart';
import 'package:oxschool/data/Models/Role.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:http/http.dart' as http;

import '../../data/Models/Event.dart';
import '../../data/Models/User.dart';

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
    String? workPosition = item['work_position'];
    String? creationDate = item['creation_date'];
    String? birthdate = item['birthdate'];
    bool? isTeacher = item['is_teacher'];

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
        birthdate,
        isTeacher);

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
        String? workArea = jsonList[i]['work_department'];
        String? workPosition = jsonList[i]['work_position'];
        String? creationDate = jsonList[i]['createdAt'];
        String? birthdate = jsonList[i]['birthdate'];
        bool isTeacher = jsonList[i]['is_teacher'];

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
            birthdate,
            isTeacher);
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

dynamic changeUserActiveStatus(String employeeNum, int activeValue) async {
  var body = {'bajalogicasino': activeValue};
  try {
    var response = await editUser(body, employeeNum);
    return response;
  } catch (e) {
    return ErrorDescription(e.toString());
  }
}

bool isCurrentUserCoordinator(int employeeNumber) {
  var isCoordinator;
  var response;
  response = validateIfUserIsCoordinator(employeeNumber)
      .whenComplete(() => isCoordinator = jsonDecode(response));
  return isCoordinator['value'];
}

void logOutCurrentUser(User employee) async {
  insertActionIntoLog('User end session', employee.employeeNumber.toString());

  logOutUser(employee.token, employee.employeeNumber.toString());
}

void setUserDataForDebug() {
  var user = User(
      'Campus_Test',
      'User_test',
      12345678,
      'Administrador',
      202,
      '123456_Token',
      'correo@mail.com',
      'Male',
      1,
      'Technology',
      'Developer',
      '01/01/1999',
      '01/01/2000',
      false);
  currentUser = user;
  var exampleEvents = [
    {
      'module_name': 'Academico',
      'screenclass': 'Bajo rendimiento',
      'event_name': 'Capturar calificaciones',
      'is_active': true
    },
    {
      'module_name': 'Academico',
      'screenclass': 'Bajo rendimiento',
      'event_name': 'Configuracion Academica',
      'is_active': true
    },
    {
      'module_name': 'Academico',
      'screenclass': 'Bajo rendimiento',
      'event_name': 'Acceder fodac27',
      'is_active': true
    },
    {
      'module_name': 'Academico',
      'screenclass': 'Calificaciones',
      'event_name': 'Configuracion Academica',
      'is_active': true
    },
    {
      'module_name': 'Academico',
      'screenclass': 'Calificaciones',
      'event_name': 'Capturar calificaciones',
      'is_active': true
    },
    {
      'module_name': 'Academico',
      'screenclass': 'Calificaciones',
      'event_name': '',
      'is_active': true
    },
  ];

  var cycle = Cycle('2023-2024', '01/01/2023', '01/01/2024');

  Future<http.Response> populateExampleUserEvents() async {
    return http.Response(jsonEncode(exampleEvents), 200, headers: {
      'Content-Type': 'application/json',
    });
  }

  userEvents = populateExampleUserEvents();
  currentCycle = cycle;

  // (jsonEncode(exampleEvents), 200, headers : {
  //   'Content-Type': 'application/json',
  // });
}
