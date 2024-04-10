import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/constants/connection.dart';

import 'package:requests/requests.dart';

import 'package:http/http.dart' as http;

Future<dynamic> loginUser(var jsonBody) async {
  var response;

  var apiCall = await Requests.post(
      dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/login/userlogin/',
      json: jsonBody,
      headers: {
        'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
      },
      persistCookies: false,
      timeoutSeconds: 7);
  try {
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    if (apiCall.statusCode == 200) {
      response = apiCall.body;
      return response;
    } else {
      return apiCall;
    }
  }
}

Future<dynamic> getCycle(
  int month,
) async {
  var response;
  if (month == 0) {
    try {
      var apiCall = await Requests.get(
          dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/cycles/1',
          headers: {
            'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
            'token': currentUser!.token,
          },
          persistCookies: false,
          timeoutSeconds: 7);
      apiCall.raiseForStatus();
      response = apiCall.content();
      return response;
    } catch (e) {
      throw FormatException(e.toString());
    }
  } else {
    try {
      var apiCall = await Requests.get(
          dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/cycles/',
          headers: {
            'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
            'token': currentUser!.token,
          },
          persistCookies: false,
          timeoutSeconds: 7);
      apiCall.raiseForStatus();
      response = apiCall.content();
      return response;
    } catch (e) {
      throw FormatException(e.toString());
    }
  }
}

//Function to post new visit from a student to nursery
Future<int> postNurseryVisit(Map<String, dynamic> jsonBody) async {
  var postResponse;
  try {
    var apiCall = await Requests.post(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/nursery-visit/',
        json: jsonBody, //We use a json style as body
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token,
          'employeeNum': currentUser!.employeeNumber!.toString()
        },
        persistCookies: false,
        timeoutSeconds: 7);

    apiCall.raiseForStatus();
    postResponse = apiCall.content();

    return postResponse;
  } catch (e) {
    ErrorDescription(e.toString());
  }
  return postResponse;
}

Future<String> searchEmployee(String employeeNumber) async {
  var postResponse;
  try {
    var apiCall = await Requests.get(
        dotenv.env['HOSTURL']! +
            dotenv.env['PORT']! +
            '/api/employee/' +
            employeeNumber.trim(),
        headers: {
          "Content-Type": "application/json",
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token,
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
  var responseCode;
  try {
    var apiCall = await Requests.put(
        dotenv.env['HOSTURL']! +
            dotenv.env['PORT']! +
            '/api/student-meds/' +
            idValue,
        // json: jsonBody, //We use a json style as body
        //queryParameters: {'id': idValue},
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token,
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

Future<dynamic> getEvents() async {
  var responseCode;
  try {
    var apiCall = await Requests.get(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/events',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
        },
        persistCookies: false,
        timeoutSeconds: 8);

    apiCall.raiseForStatus();
    responseCode = apiCall.content();
    return responseCode;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> modifyActiveOfEventRole(
    int eventId, bool role_event_value, int role_selected) async {
  var body = {
    'type': eventId,
    'role_event_active': role_event_value,
    'role': role_selected
  };
  try {
    var apiCall = await Requests.put(
        dotenv.env['HOSTURL']! +
            dotenv.env['PORT']! +
            '/api/event-role/' +
            eventId.toString(),
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
        },
        json: body,
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getRolesList() async {
  var response;
  try {
    var apiCall = await Requests.get(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/role',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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

Future<dynamic> getRole(String roleName) async {
  var response;
  try {
    var apiCall = await Requests.get(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/role',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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

Future<dynamic> editRole(int roleID, Map<String, dynamic> bodyObject) async {
  var response;
  try {
    var apiCall = await Requests.put(
        dotenv.env['HOSTURL']! +
            dotenv.env['PORT']! +
            '/api/role/' +
            roleID.toString(),
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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

Future<dynamic> deleteRole(int roleID) async {
  var response;
  try {
    var apiCall = await Requests.delete(
        dotenv.env['HOSTURL']! +
            dotenv.env['PORT']! +
            '/api/role/' +
            roleID.toString(),
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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
  var response;
  try {
    var apiCall = await Requests.post(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/role',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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

Future<dynamic> createUser(var newUser) async {
  var response;
  try {
    var apiCall = await Requests.post(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/user/',
        json: newUser,
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> editUser(Map<String, dynamic> bodyObject, String userID) async {
  var response;
  // var apiBody = {};
  try {
    var apiCall = await Requests.put(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/user/' + userID,
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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
  var response;
  try {
    var apiCall = await Requests.patch(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/user/role',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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
  var response;
  try {
    var apiCall = await Requests.get(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/user',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
        },
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> deleteUser(String id) async {
  var response;
  try {
    var apiCall = await Requests.delete(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/user/' + id,
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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
  var response;
  try {
    var apiCall = await Requests.get(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/user/detail',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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
  var response;
  try {
    var apiCall = await Requests.get(
        dotenv.env['HOSTURL']! + dotenv.env['PORT']! + '/api/modules',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
        },
        persistCookies: true,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    throw FormatException(e.toString());
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

Future<http.Response> getUserPermissions(int userId) async {
  try {
    Uri address = Uri(
        scheme: 'http',
        host: 'localhost',
        port: 8080,
        path: '/api/user/events',
        queryParameters: {'id': '${userId.toString()}'});
    var response = http.get(address, headers: {
      'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
      'token': currentUser!.token
    });
    userEvents = response;
    return response;
  } catch (e) {
    print(e.toString());
    return throw FormatException(e.toString());
  }
}
