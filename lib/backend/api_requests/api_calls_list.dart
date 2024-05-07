import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:oxschool/constants/User.dart';
import 'package:oxschool/constants/connection.dart';

import 'package:requests/requests.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

Future<dynamic> loginUser(var jsonBody) async {
  String response;

  var apiCall = await Requests.post(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/login/userlogin/',
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
  String response;
  if (month == 0) {
    try {
      var apiCall = await Requests.get(
          '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/cycles/1',
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
          '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/cycles/',
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
Future<dynamic> postNurseryVisit(Map<String, dynamic> jsonBody) async {
  // var postResponse;
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/nursery-visit/',
        json: jsonBody, //We use a json style as body
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token,
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
  int responseCode;
  try {
    var apiCall = await Requests.put(
        // ignore: prefer_interpolation_to_compose_strings
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/student-meds/' +
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

Future<dynamic> getEvents(String? param) async {
  String responseCode;

  if (param == null) {
    try {
      var apiCall = await Requests.get(
          '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/events',
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
  } else {
    try {
      var apiCall = await Requests.get(
          '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/events',
          headers: {
            'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
            'token': currentUser!.token
          },
          queryParameters: {'detail': param},
          persistCookies: false,
          timeoutSeconds: 8);

      apiCall.raiseForStatus();
      responseCode = apiCall.content();
      return responseCode;
    } catch (e) {
      throw FormatException(e.toString());
    }
  }
}

Future<dynamic> modifyActiveOfEventRole(
    int eventId, bool roleEventValue, int roleSelected) async {
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/event-role/$eventId',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
        },
        json: {
          'type': eventId,
          'role_event_active': roleEventValue,
          'role': roleSelected
        },
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getRolesList() async {
  String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/role',
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
  String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/role',
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

Future<dynamic> getEventsByRole(int? roleID) async {
  try {
    var apiCal = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/role/events',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
        },
        queryParameters: {'role': roleID},
        persistCookies: false,
        timeoutSeconds: 8);
    apiCal.raiseForStatus();
    return apiCal.content();
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> editRole(int roleID, Map<String, dynamic> bodyObject) async {
  String response;
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/role/$roleID',
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
  String response;
  try {
    var apiCall = await Requests.delete(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/role/$roleID',
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
  String response;
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/role',
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

Future<dynamic> createUser(Map<String, dynamic> newUser) async {
  int response;
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/',
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
  String response;
  try {
    var apiCall = await Requests.patch(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/role',
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
  String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user',
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
  int response;
  try {
    var apiCall = await Requests.delete(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/$id',
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
  String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/user/detail',
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
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/modules',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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

Future<dynamic> getWorkDepartments() async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/work-dept',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
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
    String employeeNumber, String deviceInfo, String deviceIP) async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/login/forgot-password/$employeeNumber',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
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
        host: '10.0.0.36',
        port: 8080,
        path: '/api/user/events',
        queryParameters: {'id': userId.toString()});
    var response = http.get(address, headers: {
      'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
      'token': currentUser!.token
    });
    userEvents = response;
    return response;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}
