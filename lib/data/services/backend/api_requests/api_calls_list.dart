import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/extensions/api_call_error_message.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/data/services/backend/api_requests/status_code_manager.dart';

import 'package:requests/requests.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> loginUser(var jsonBody) async {
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/auth/login',
        json: jsonBody,
        persistCookies: false,
        timeoutSeconds: 25);

    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    // String errorMessage;
    insertErrorLog(e.toString(), '/login/userlogin/');
    if (e is HTTPException) {
      var statusCode = e.response.statusCode;
      var message = '';
      if (statusCode == 403) {
        message = "User not authorized, verify with system admin";
      } else {
        message = e.toString();
      }
      return Future.error(message);
    } else {
      return Future.error(e.toString());
    }
    // if (e is Exception) {
    //   errorMessage = e.getErrorMessage();
    //   return Future.error(errorMessage);
    // } else {
    //   Future.error(e.toString()); //?Why is this here?
    // }
  }
}

Future<void> logOutUser(String token, String employee) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? device = prefs.getString('device');
  String? ipAddres = prefs.getString('ip');

  var apiCall = await Requests.post(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/auth/logout',
      headers: {
        //'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
        'Authorization': currentUser!.token,
      },
      json: {'device': device, 'ip': ipAddres, 'employee': employee},
      persistCookies: false,
      timeoutSeconds: 10);
  apiCall.raiseForStatus();
}

Future<dynamic> getCycle(int month) async {
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/cycles/status',
      headers: {
        'Authorization': currentUser!.token,
        'Content-Type': 'application/json',
      },
      queryParameters: {"status": month},
      timeoutSeconds: 10,
    );
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), '/cycle/status/');
    String errorMessage;
    if (e is Exception) {
      errorMessage = e.getErrorMessage();
      return Future.error(errorMessage);
    } else {
      e;
    }
  }
}

// Future<dynamic> getCycle(
//   int month,
// ) async {
//   String response;
//   if (month == 0) {
//     try {
//       var apiCall = await Requests.get(
//           '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/cycles/1',
//           headers: {
//             //'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
//             'Authorization': currentUser!.token,
//           },
//           persistCookies: false,
//           timeoutSeconds: 12);
//       apiCall.raiseForStatus();
//       response = apiCall.content();
//       return response;
//     } catch (e) {
//       insertErrorLog(e.toString(), '/api/cycles/1');
//       throw FormatException(e.toString());
//     }
//   } else {
//     try {
//       var apiCall = await Requests.get(
//           '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/cycles/',
//           headers: {
//             'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
//             'Auth': currentUser!.token,
//           },
//           persistCookies: false,
//           timeoutSeconds: 12);
//       apiCall.raiseForStatus();
//       response = apiCall.content();
//       return response;
//     } catch (e) {
//       insertErrorLog(e.toString(), '/api/cycles/$month');
//       throw FormatException(e.toString());
//     }
//   }
// }

//Function to post new visit from a student to nursery
Future<dynamic> postNurseryVisit(Map<String, dynamic> jsonBody) async {
  // var postResponse;
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/nursery-visit/',
        json: jsonBody, //We use a json style as body
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token,
          'employeeNum': currentUser!.employeeNumber!.toString()
        },
        persistCookies: false,
        timeoutSeconds: 7);

    apiCall.raiseForStatus();
    // postResponse = apiCall.content();

    return apiCall.statusCode;
  } catch (e) {
    return e.toString();
    // ErrorDescription(e.toString());
  }
  // return postResponse;
}

Future<String> searchEmployee(String employeeNumber) async {
  String postResponse;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/employee/${employeeNumber.trim()}',
        headers: {
          "Content-Type": "application/json",
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token,
          'employeeNum': currentUser!.employeeNumber!.toString()
        },
        persistCookies: false,
        timeoutSeconds: 7);

    apiCall.raiseForStatus();

    postResponse = apiCall.content();
    return postResponse;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

// Function to delete an allowed medicine from a student
Future<int> deleteMedicineStudent(var idValue) async {
  int responseCode;
  try {
    var apiCall = await Requests.put(
        // ignore: prefer_interpolation_to_compose_strings
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/student-meds/' +
            idValue,
        // json: jsonBody, //We use a json style as body
        //queryParameters: {'id': idValue},
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token,
          'employeeNum': currentUser!.employeeNumber!.toString()
        },
        persistCookies: false,
        timeoutSeconds: 7);

    apiCall.raiseForStatus();

    responseCode = apiCall.statusCode;
    return responseCode;
  } catch (e) {
    throw FormatException(e.toString());
  }
  // return responseCode;
}

// Future<dynamic> getEvents(String? param) async {
//   String responseCode;

//   if (param == null) {
//     try {
//       var apiCall = await Requests.get(
//           '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/events',
//           headers: {
//             'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
//             'Auth': currentUser!.token
//           },
//           persistCookies: false,
//           timeoutSeconds: 8);

//       apiCall.raiseForStatus();
//       responseCode = apiCall.content();
//       return responseCode;
//     } catch (e) {
//       throw FormatException(e.toString());
//     }
//   } else {
//     try {
//       var apiCall = await Requests.get(
//           '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/events',
//           headers: {
//             'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
//             'Auth': currentUser!.token
//           },
//           queryParameters: {'detail': param},
//           persistCookies: false,
//           timeoutSeconds: 8);

//       apiCall.raiseForStatus();
//       responseCode = apiCall.content();
//       return responseCode;
//     } catch (e) {
//       throw FormatException(e.toString());
//     }
//   }
// }

Future<dynamic> modifyActiveOfEventRole(
    int eventId, bool roleEventValue, int roleSelected) async {
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/events/role-auth/$eventId',
        headers: {
          'Authorization': currentUser!.token,
          'Content-Type': 'application/json',
        },
        json: {'value': roleEventValue, 'role': roleSelected},
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getRolesList() async {
  // String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/all',
        headers: {
          'Authorization': currentUser!.token,
          'Content-Type': 'application/json',
        },
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    // response = apiCall.content();
    return apiCall;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getRole(String roleName) async {
  String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/role',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        persistCookies: false,
        timeoutSeconds: 8);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getEventsByRole(int? roleID) async {
  try {
    var apiCal = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/events/roles/$roleID',
        headers: {
          'Authorization': currentUser!.token,
          'Content-Type': 'application/json',
        },
        bodyEncoding: RequestBodyEncoding.JSON,
        persistCookies: false,
        timeoutSeconds: 20);
    apiCal.raiseForStatus();
    return apiCal;
  } catch (e) {
    throw Future.error(e.toString());
  }
}

Future<dynamic> getModulesListDetailed() async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/modules/detail',
        headers: {
          'Authorization': currentUser!.token,
          'Content-Type': 'application/json',
        },
        persistCookies: true);
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    insertErrorLog(e.toString(), 'getModulesAndEvents() apiCall');
    return Future.error(e.toString());
  }
}

Future<dynamic> getEventsAndModulesCall() async {
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/events/modules/detail',
      headers: {
        'Authorization': currentUser!.token,
        'Content-Type': 'application/json',
      },
      persistCookies: true,
    );
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    insertErrorLog(e.toString(), 'getEventsAndModulesCall() apiCall');
    return Future.error(e.toString());
  }
}

Future<dynamic> editRole(
    int roleID, Map<String, dynamic> bodyObject, int? type) async {
  String response;
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/$roleID',
        headers: {
          'Authorization': currentUser!.token,
          'Content-Type': 'application/json',
        },
        queryParameters: {'type': type},
        json: bodyObject,
        persistCookies: false,
        timeoutSeconds: 8);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw Future.error(e.toString());
  }
}

Future<dynamic> deleteRole(int roleID) async {
  String response;
  try {
    var apiCall = await Requests.delete(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/role/$roleID',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        persistCookies: false,
        timeoutSeconds: 8);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> createRole(Map<String, dynamic> bodyObject) async {
  String response;
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/role',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        json: bodyObject,
        persistCookies: false,
        timeoutSeconds: 8);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> createUser(Map<String, dynamic> newUser) async {
  int response;
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/',
        json: newUser,
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        // body: {
        //   'nombre_gafete': newUser.employeeName,
        //   'role': newUser.role,
        //   'claUn': newUser.claUn,
        //   'noempleado': newUser.employeeNumber,
        //   'useremail': newUser.userEmail
        // },
        persistCookies: false,
        timeoutSeconds: 8);
    apiCall.raiseForStatus();
    response = apiCall.statusCode;
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> editUser(Map<String, dynamic> bodyObject, String userID) async {
  int response;
  // var apiBody = {};
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/$userID',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        json: bodyObject,
        // body: bodyObject,
        persistCookies: false,
        timeoutSeconds: 7);
    apiCall.raiseForStatus();
    response = apiCall.statusCode;
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> editUserRole(String roleName, int userID) async {
  String response;
  try {
    var apiCall = await Requests.patch(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/role',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        body: {'role': roleName.toString(), 'userID': userID.toString()},
        persistCookies: true,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getUsers() async {
  String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/all',
        headers: {'Authorization': currentUser!.token},
        persistCookies: false,
        timeoutSeconds: 30);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> deleteUser(String id) async {
  int response;
  try {
    var apiCall = await Requests.delete(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/$id',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    response = apiCall.statusCode;
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getUserDetail(String userId) async {
  String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/detail',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        queryParameters: {'id': userId},
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getAllModules() async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/modules',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getCampuseList() async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/campus',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        persistCookies: true,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getWorkDepartments() async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/departments',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> sendUserPasswordToMail(
    //This was the old way to send a recovery password
    String employeeNumber,
    String deviceInfo,
    String deviceIP) async {
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/login/forgot-password/$employeeNumber',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'device': deviceInfo,
          'ip_address': deviceIp.toString()
        },
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return 200;
  } catch (e) {
    return e;
  }
}

Future<dynamic> sendRecoveryToken(String userMail, String deviceInfo) async {
  http.Response apiCall;
  try {
    apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/auth/lost-password',
        headers: {
          "Content-Type": "application/json"
          // 'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          // 'device': deviceInfo,
          // 'ip_address': deviceIp.toString()
        },
        json: {"email": userMail, "device": deviceInfo},
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    return e;
  }
}

Future<dynamic> updateUserPasswordByToken(
    //This is for the recovery password at login screen (when user click on forgot password)
    String token,
    String newPassword) async {
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/auth/password',
        headers: {"Content-Type": "application/json"},
        json: {"token": token, "password": newPassword},
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), '/auth/password');
    if (e is TimeoutException) {
      var firstWord = getMessageToDisplay(e.toString());
      return throw firstWord;
    } else {
      return throw e;
    }
  }
}

Future<dynamic> updateUserPasswordCall(String password) async {
  //To use when the current user logged in can be switched
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/password',
        headers: {
          "Content-Type": "application/json",
          "Authorization": currentUser!.token,
          // "User-Agent": "$deviceInformation",
        },
        json: {
          "password": password,
        },
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall.success;
  } catch (e) {
    insertErrorLog(e.toString(), '/api/user/password');
    Future.error(e);
  }
} //This is for the user to change his password

Future<dynamic> validateToken(
    String token, String userMail, String devivce) async {
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/auth/recovery-token',
        headers: {"Content-Type": "application/json"},
        json: {"email": userMail, "device": devivce},
        queryParameters: {"token": token},
        persistCookies: false,
        timeoutSeconds: 15);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), '/auth/recovery-token');
    return throw Exception(e.toString());
  }
}

// TODO: CONTINUE PATCH FOR STUDENT-GRADES
// Future<dynamic> updateStudentsGrades(
//   dynamic body
// ) async {
//   try {
//     var apiCall = await Requests.patch(
//       '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/student/grades'
//     )
//   } catch (e) {

//   }
// }

Future<dynamic> getTeacherGradeAndCourses(
    var employee, var year, int month, bool isAdmin, String? campus) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/teacher-grades',
        headers: {
          'Authorization': currentUser!.token,
          'Content-Type': 'application/json',
        },
        queryParameters: {
          'employee': currentUser!.employeeNumber,
          "cycle": currentCycle!.claCiclo,
          "month": month,
          "flag": isAdmin,
          "campus": campus
        },
        persistCookies: false,
        timeoutSeconds: 40);
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    if (e is TimeoutException) {
      insertErrorLog(e.toString(), 'acad/teacher/start-student-rating');
      var firstWord = getMessageToDisplay(e.toString());
      return throw firstWord;
    }
    return Future.error(e);
  }
}

Future<dynamic> getTeacherGradeAndCoursesAsAdmin(
    int month, bool isAdmin, String? campus, String? cycle) async {
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/teacher-grades',
      headers: {
        'Authorization': currentUser!.token,
        'Content-Type': 'application/json',
      },
      queryParameters: {
        "cycle": cycle,
        "month": month,
        "flag": isAdmin,
        "campus": campus,
        "employee": currentUser!.employeeNumber
      },
      bodyEncoding: RequestBodyEncoding.JSON,
      persistCookies: true,
      timeoutSeconds: 25,
    );
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), 'getTeacherGradeAndCoursesAsAdmin()');
    throw Future.error(e.toString());
  }
}

Future<dynamic> getStudentsToGrade(String assignature, String group,
    String grade, String? cycle, String? campus, String month) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/students-evaluation-subject',
        headers: {'Authorization': currentUser!.token},
        queryParameters: {
          "grade": grade,
          "group": group,
          "subject": assignature,
          "cycle": cycle,
          "campus": campus,
          "month": month
        },
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), '/academic/students-evaluation');
    if (e is TimeoutException) {
      return throw TimeoutException(e.toString());
    }
    return throw FormatException(e.toString());
  }
}

Future<dynamic> getStudentsGrades(
    //This gets data for grades_per_student.dart
    String? assignature,
    group,
    grade,
    cycle,
    campus,
    month) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/grades-subject',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'ip_address': deviceIp.toString(),
          'Auth': currentUser!.token
        },
        queryParameters: {
          "grade": grade,
          "group": group,
          "assignature": assignature,
          "cycle": cycle,
          "campus": campus,
          "month": month
        },
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

//getSubjectsAndGradeByStuent will get based on the current teacher consuming the API.
Future<dynamic> getSubjectsAndGradeByStuent(
    String? group, grade, cycle, campus, month) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student-evaluation-student',
        headers: {'Authorization': currentUser!.token},
        queryParameters: {
          "grade": grade,
          "group": group,
          "cycle": cycle,
          "campus": campus,
          "month": month,
          "history":
              0, //0 means all students, if history : 1 , will return all history from a single student and youll need to send studenID as param
          "assignature": "null", //Set null to return all subjects
          "value": "all" //set all to return all students by cycle and
        },
        timeoutSeconds: 20,
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    if (e is TimeoutException) {
      insertErrorLog(e.toString(), 'academic/student-evaluation-student');
      var firstWord = getMessageToDisplay(e.toString());
      return throw TimeoutException(firstWord.toString());
    }
    return Future.error(e.toString());
  }
}

Future<dynamic> patchStudentsGrades(
    List<Map<String, dynamic>> requestBody, bool isByStudent) async {
  try {
    if (requestBody.isEmpty) {
      return throw const FormatException("No data to send");
    } else {
      var apiCall = await Requests.patch(
          '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/grades',
          headers: {
            //'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
            //'ip_address': deviceIp.toString(),
            'Authorization': currentUser!.token
          },
          // queryParameters: {
          //   "studentEval": isByStudent.toString(),
          //   "cycle": currentCycle!.claCiclo
          // },
          persistCookies: false,
          timeoutSeconds: 25,
          json: requestBody);
      apiCall.raiseForStatus();
      return apiCall.statusCode;
    }
  } catch (e) {
    return Future.error(e.toString());
  }
}

Future<dynamic> getStudentsGradesComments(
    int grade, bool searchById, String? id, int? month) async {
  http.Response response;
  try {
    if (searchById) {
      var apiCall = await Requests.get(
          '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/comments',
          headers: {
            'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
            // 'ip_address': deviceIp.toString(),
            'Auth': currentUser!.token
          },
          queryParameters: {
            "student": id,
            "cycle": currentCycle!.claCiclo,
            "month": month
          },
          timeoutSeconds: 20,
          persistCookies: false);
      apiCall.raiseForStatus();
      response = apiCall;
    } else {
      var apiCall = await Requests.get(
          '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/school-rating/comments',
          headers: {
            'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
            // 'ip_address': deviceIp.toString(),
            'Auth': currentUser!.token
          },
          queryParameters: {"grade": grade},
          persistCookies: false);
      apiCall.raiseForStatus();
      response = apiCall;
    }
    return response;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

Future<dynamic> putStudentEvaluationsComments(
    int evaluationId, commentID, bool ValueToUpdate) async {
  try {
    var apiCall = await Requests.patch(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/comments',
      headers: {
        'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
        'Auth': currentUser!.token
      },
      json: {
        'comment': commentID,
        'evaluation': evaluationId,
        'value': ValueToUpdate,
      },
      persistCookies: false,
    );
    apiCall.raiseForStatus();
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

//NOT USING FOR NOW
Future<dynamic> validateUser(
  int employeeNumber,
  dynamic keyTovalidate,
) async {
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/validate',
      headers: {
        'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
        'Auth': currentUser!.token
      },
      json: {'detail': keyTovalidate, 'user': employeeNumber},
      persistCookies: false,
    );
    apiCall.raiseForStatus();
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

Future<dynamic> getStudentsByRole(String cycle) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/fodac27/students',
        headers: {'Authorization': currentUser!.token},
        queryParameters: {'cycle': cycle},
        persistCookies: false,
        timeoutSeconds: 25);

    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    return Future.error(e);
  }
}

//Can be used to get more than one student if needed
Future<dynamic> getStudentFodac27History(
    String cycle, String? studentID, bool isByStudent) async {
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/fodac27/history',
      headers: {
        // 'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
        'Authorization': currentUser!.token,
      },
      queryParameters: {
        'cycle': cycle.toString(),
        'student': studentID!.trim()
      },
      persistCookies: false,
    );
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    return Future.error(e.toString());
  }
}

//To obtains only subject_name, can be user for more data in future
Future<dynamic> getStudentSubjects(String studentID, String cycle) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/subjects',
        headers: {'Authorization': currentUser!.token},
        timeoutSeconds: 18,
        persistCookies: false,
        queryParameters: {'student': studentID, 'cycle': cycle});
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    return Future.error(e.toString());
  }
}

Future<dynamic> postFodac27Record(DateTime date, String studentID, String cycle,
    String observations, int employeeNumber, int subject) async {
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/fodac27',
        headers: {'Authorization': currentUser!.token},
        json: {
          'date': date.toIso8601String(),
          'student': studentID.toString(),
          'cycle': cycle.toString(),
          'observation': observations.toString(),
          'employee': employeeNumber,
          'subject': subject
        },
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall.statusCode;
  } catch (e) {
    return Future.error(e.toString());
  }
}

Future<int> editFodac27Record(Map<String, dynamic> body) async {
  try {
    var apiCall = await Requests.patch(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/fodac27',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        json: body,
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall.statusCode;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

Future<dynamic> getActualDate() async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/evaluation-date',
        headers: {'Authorization': currentUser!.token},
        //queryParameters: {'field': 1},
        timeoutSeconds: 20,
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    if (e is HTTPException) {
      var reasonPhrase = returnsMessageToDisplay(e.response.statusCode);
      var displayMessage = getMessageToDisplay(reasonPhrase);
      return throw FormatException(displayMessage);
    } else if (e is TimeoutException) {
      insertErrorLog(e.toString(), 'api/date');
      var firstWord = getMessageToDisplay(e.toString());
      return throw firstWord;
    } else {
      return Future.error(e);
    }

    // Check if error response contains a message

    // if (e is HTTPException) {
    //   var displayMessage;
    //   insertErrorLog(e.toString(), 'api/date');
    //   if (e.response.body.contains('Outdated')) {
    //     displayMessage = getMessageToDisplay('Outdated');
    //   } else {
    //     displayMessage =
    //         getMessageToDisplay(e.response.reasonPhrase.toString());
    //   }

    //   try {
    //     var errorResponse = jsonDecode(e.response.body);
    //     if (errorResponse.containsKey('message')) {
    //       print(errorResponse);
    //       return errorResponse['message']; // Return only the message
    //     } else {
    //       return throw displayMessage; // Default message if no 'message' key
    //     }
    //   } catch (jsonError) {
    //     return throw Exception(jsonError);
    //   }
    // } else if (e is TimeoutException) {
    //   insertErrorLog(e.toString(), 'api/date');
    //   var firstWord = getMessageToDisplay(e.toString());
    //   return throw firstWord;
    // } else {
    //   return 'Request failed: ${e.toString()}'; // General error handling
    // }
  }
}

Future<int> deleteFodac27Record(int fodac27ID) async {
  try {
    var apiCall = await Requests.delete(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/fodac27',
        headers: {'Authorization': currentUser!.token},
        queryParameters: {'fodac27': fodac27ID},
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall.statusCode;
  } catch (e) {
    return Future.error(e);
  }
}

Future<dynamic> getGlobalGradesAndGroups(String cyle) async {
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/globalg&g',
      headers: {
        'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
        'Auth': currentUser!.token
      },
      queryParameters: {'cycle': cyle},
      persistCookies: true,
    );
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

Future<dynamic> getStudentsForFodac27(
    String grade, String group, String campus, String cycle) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/fodac27/students-list',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        queryParameters: {
          'grade': grade,
          'group': group,
          'campus': campus,
          'cycle': cycle
        },
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

Future<dynamic> validateIfUserIsCoordinator(int user) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/coordination/validate',
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
        queryParameters: {'user': user.toString()},
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

Future<dynamic> checkForUpdates() async {
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/updates',
      persistCookies: false,
      timeoutSeconds: 20,
    );
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), "UPDATER CALL ERROR: ");
    return Future.error(e.toString());
  }
}

Future<dynamic> getCurrentUserData(String token) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/me',
        headers: {
          //'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Authorization': 'Bearer $token'
        },
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    String errorMessage;
    insertErrorLog(e.toString(), '/users/me/');
    if (e is Exception) {
      errorMessage = e.getErrorMessage();
      return Future.error(errorMessage);
    } else {
      e;
    }
  }
}

Future<dynamic> getUserCafeteriaConsumptionHistory() async {
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/cafeteria/user/history',
      headers: {'Authorization': currentUser!.token},
      queryParameters: {
        'employee': currentUser!.employeeNumber,
      },
      persistCookies: false,
    );
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), "CAFETERIA HISTORY CALL ERROR: ");
    return Future.error(e.toString());
  }
}

//*
//To retrive all events from the server
// */
Future<dynamic> getEventsListRequest() async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/events/all',
        headers: {'Authorization': currentUser!.token},
        queryParameters: {'filter': 'true'},
        persistCookies: true,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), "EVENTS LIST CALL ERROR: ");
    return Future.error(e.toString());
  }
}

Future<dynamic> getScreenListByRoleId(int id) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/modules/$id',
        headers: {
          'Authorization': currentUser!.token,
          'Content-Type': 'application/json'
        },
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), "SCREEN LIST BY ROLE ID CALL ERROR: ");
    return Future.error(e.toString());
  }
}

Future<dynamic> updateModuleAccessByRole(
    String moduleName, int roleId, bool access) async {
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/modules',
        headers: {
          'Authorization': currentUser!.token,
          'Content-Type': 'application/json'
        },
        json: {'module': moduleName, 'role': roleId, 'access': access},
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(),
        "UPDATE MODULE ACCESS BY ROLE CALL | body{ module: $moduleName, roleId: $roleId, access: $access}");
    return Future.error(e.toString());
  }
}

Future<http.Response> getUserRoleAndAcces(int roleId) async {
  try {
    Uri address = Uri(
        scheme: 'http',
        host: dotenv.env['HOST'],
        port: int.parse(dotenv.env['PORT']!),
        path: '/roles/me',
        queryParameters: {'role': roleId.toString()});
    var response = http.get(address, headers: {
      "Content-Type": "application/json",
      'Authorization': currentUser!.token,
    });
    userEvents = response;
    return response;
  } catch (e) {
    insertErrorLog(e.toString(), '/roles/me');
    // String errorMessage;
    if (e is Exception) {
      final errorMessage = e.getErrorMessage();
      return Future.error(errorMessage);
    } else {
      return Future.error(e.toString());
    }
  }
}

// Future<dynamic> getUserEvents(int userId) async {
//   var response;
//   try {
//     var apiCall = await Requests.get(
//         dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/user/events/',
//         headers: {
//           'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
//           'token': currentUser!.token
//         },
//         queryParameters: {'id': '${userId.toString()}'},
//         persistCookies: false,
//         timeoutSeconds: 10);
//     apiCall.raiseForStatus();
//     response = apiCall.content();
//     return response;
//   } catch (e) {
//     throw FormatException(e.toString());
//   }
// }

// Future<http.Response> getUserPermissions(int userId) async {
//   try {
//     Uri address = Uri(
//         scheme: 'http',
//         host: dotenv.env['HOST'],
//         port: 8080,
//         path: '/api/user/events',
//         queryParameters: {'user': userId.toString()});
//     var response = http.get(address, headers: {
//       'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
//       'Auth': currentUser!.token
//     });
//     userEvents = response;
//     return response;
//   } catch (e) {
//     insertErrorLog(e.toString(), '/api/user/events');
//     return throw FormatException(e.toString());
//   }
// }
