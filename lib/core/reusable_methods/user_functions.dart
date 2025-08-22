import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/DataTransferObjects/AttendanceHistory.dart';
import 'package:oxschool/data/Models/Cycle.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:http/http.dart' as http;

import '../../data/Models/User.dart';

//List<User> parseUsersFromJSON(List<dynamic> jsonList) {
//  List<User> users = [];
//
//  for (var item in jsonList) {
//    int employeeNumber = item['employeeNumber'];
//    String employeeName = item['name'];
//    String claUn = item['campus'];
//    String? role = item['roleName'];
//    int? userId = item['id'];
//    String? token = 'null';
//    String? schoolEmail = item['email'];
//    String? usergenre = item['genre'];
//    int isActive = item['isActive'];
//    String? workArea = item['department'];
//    String? workPosition = item['position'];
//    String? creationDate = item['creationDate'];
//    String? birthdate = item['birthdate'];
//    bool? isTeacher = item['isTeacher'];
//    bool? isAdmin = item['admin'];
//    int roleId = item['userRole']['id'];
//    bool canUpdatePassword = item['can']

//    User currentUser = User(
//        claUn.toTitleCase,
//        employeeName,
//        employeeNumber,
//        role!.toTitleCase,
//        userId!,
//        token,
//        schoolEmail,
//usergenre,
//        isActive,
//        workArea?.toTitleCase,
//        workPosition?.toTitleCase,
//        creationDate,
//        birthdate,
//        isTeacher,
//        isAdmin,
//        roleId,

//        );

//    users.add(currentUser);
//  }

//  return users;
//}

bool verifyUserAdmin(User currentUser) {
  return currentUser.isCurrentUserAdmin();
}

Future<dynamic> getSingleUser(int? userId) async {
  if (userId != null) {
    try {
      userId = tempUserId;
      selectedUser = await getUserDetailCall(userId!).then((response) {
        Map<String, dynamic> jsonList = json.decode(response);
        selectedUser = jsonList;

        tempSelectedUsr = User.fromJson(jsonList);
        return tempSelectedUsr;
      }).catchError((error) {
        insertErrorLog(
            error.toString(), "getSingleUser($userId) | user_functions :63 ");
      });
    } catch (e) {
      throw Future.error(e.toString());
    }
  } else {
    throw Future.error('No user selected');
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
  // insertActionIntoLog('User end session', employee.employeeNumber.toString());

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
      1,
      true,
      false,
      null,
      0000,
      null);
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

dynamic validateEventStatus(int eventValue) async {
  //! THIS FUNCTIONS NEEDS TO BE REFACTORIZED, VALIDATE EVENT STSATUS FROM BACKEND, NOT FROM LOCAL
  bool status = false;

  for (var element in currentUser!.userRole!.roleModuleRelationships!) {
    if (element.eventId == eventValue) {
      status = element.canAccessEvent!;
    }
  }

  var deptMembers = await geDeptMembers(currentUser!.idLogin!);
  print(deptMembers);
  return deptMembers;
}

Future<dynamic> geDeptMembers(int idlogin) async {
  var members = await getUsersListByDeptCall(idlogin, "dept");
  return json.decode(utf8.decode(members.bodyBytes));
}

Future<dynamic> updateUserIdLoginProcedure(int employeeNumber) async {
  try {
    var response =
        await getIdLoginByUser(employeeNumber).then((response) async {
      if (response != null) {
        Map<String, dynamic> body = {
          'loginId': int.parse(response),
        };
        await editUser(body, employeeNumber, 3);
      }
    });
    return response;
  } catch (e) {
    insertErrorLog(
        e.toString(), 'updateUserIdLoginProcedure() | $employeeNumber');
    return Future.error(e.toString());
  }
}

Future<dynamic> getUserAttendanceHistoryByDates(
    String initialDate, String finalDate) async {
  var response = await getEmployeeAttendanceHistory(initialDate, finalDate);
  if (response != null) {
    List<AttendanceHistory> attendanceHistory = [];
    for (var item in response) {
      attendanceHistory.add(AttendanceHistory.fromJson(item));
    }
    return attendanceHistory;
  } else {
    insertErrorLog('Error al obtener el historial de asistencia',
        'getUserAttendanceHistoryByDates()');
    return Future.error('Error al obtener el historial de asistencia');
  }
}
