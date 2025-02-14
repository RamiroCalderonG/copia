import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/Cycle.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:http/http.dart' as http;

import '../../data/Models/User.dart';

List<User> parseUsersFromJSON(List<dynamic> jsonList) {
  List<User> users = [];

  for (var item in jsonList) {
    int employeeNumber = item['employeeNumber'];
    String employeeName = item['name'];
    String claUn = item['campus'];
    String? role = item['roleName'];
    int? userId = item['id'];
    String? token = 'null';
    String? schoolEmail = item['email'];
    String? usergenre = item['genre'];
    int isActive = item['isActive'];
    String? workArea = item['department'];
    String? workPosition = item['position'];
    String? creationDate = item['creationDate'];
    String? birthdate = item['birthdate'];
    bool? isTeacher = item['isTeacher'];
    bool? isAdmin = item['admin'];
    int roleId = item['userRole']['id'];

    User currentUser = User(
        claUn.toTitleCase,
        employeeName,
        employeeNumber,
        role!.toTitleCase,
        userId!,
        token,
        schoolEmail,
        //usergenre,
        isActive,
        workArea?.toTitleCase,
        workPosition?.toTitleCase,
        creationDate,
        birthdate,
        isTeacher,
        isAdmin,
        roleId);

    users.add(currentUser);
  }

  return users;
}

bool verifyUserAdmin(User currentUser) {
  return currentUser.isCurrentUserAdmin();
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
        var role = jsonList[i]['userRole']['name'];
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
        bool isAdmin = jsonList[i]['userRole']['isAdmin'];
        int roleId = jsonList[i]['userRole']['id'];

        tempSelectedUsr = User(
            claUn,
            employeeName,
            employeeNumber,
            role,
            userId,
            token,
            userEmail,
            //usergenre,
            isActive,
            workArea,
            workPosition,
            creationDate,
            birthdate,
            isTeacher,
            isAdmin,
            roleId);
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

dynamic changeUserActiveStatus(int employeeNum, int activeValue) async {
  var body = {'active': activeValue};
  try {
    var response = await editUser(body, employeeNum, 1);
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

Future<void> logOutCurrentUser(User employee) async {
  insertActionIntoLog('User end session', employee.employeeNumber.toString());

  await logOutUser(employee.token, employee.employeeNumber.toString());
}

Future<bool> updateUserPassword(String newPassword) async {
  try {
    bool finalVlue = false;
    var response = await updateUserPasswordCall(newPassword);
    if (response) {
      finalVlue = true;
    } else {
      finalVlue = false;
      // showErrorFromBackend(context, 'Error al actualizar la contraseña');
    }
    return finalVlue;
  } catch (e) {
    insertErrorLog(e.toString(), 'updateUserPassword() @user_view_screen');
    rethrow;
  }
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
      //'Male',
      1,
      'Technology',
      'Developer',
      '01/01/1999',
      '01/01/2000',
      false,
      true,
      1);
  currentUser = user;
  var exampleEvents = [
    {
      'module_name': 'Academico',
      'screenclass': 'GradesMainScreen()',
      'event_name': 'Capturar calificaciones',
      'is_active': true
    },
    {
      'module_name': 'Academico',
      'screenclass': 'FoDac27()',
      'event_name': 'Configuracion Academica',
      'is_active': true
    },
    {
      'module_name': 'Academico',
      'screenclass': 'FoDac27()',
      'event_name': 'Acceder fodac27',
      'is_active': true
    },
    // {
    //   'module_name': 'Academico',
    //   'screenclass': 'Calificaciones',
    //   'event_name': 'Configuracion Academica',
    //   'is_active': true
    // },
    // {
    //   'module_name': 'Academico',
    //   'screenclass': 'Calificaciones',
    //   'event_name': 'Capturar calificaciones',
    //   'is_active': true
    // },
    // {
    //   'module_name': 'Academico',
    //   'screenclass': 'Calificaciones',
    //   'event_name': '',
    //   'is_active': true
    // },
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
