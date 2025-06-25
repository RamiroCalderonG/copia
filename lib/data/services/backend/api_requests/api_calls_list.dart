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

//* Post a login request, send into body devide details
Future<dynamic> loginUser(var jsonBody) async {
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/auth/login', // Host addres from .env file
        json: jsonBody, // body as json
        persistCookies:
            false, // not using cookies for any of the rest request for now
        timeoutSeconds:
            12); // timeout before it cancels the request if the server doesnt respond and throw TimeOutException error

    apiCall.raiseForStatus(); // Perform the call request
    return apiCall; // return the Request class instance
  } catch (e) {
    insertErrorLog(
        e.toString(), '/login/userlogin/'); //Insert into log the error
    if (e is HTTPException) {
      // Validate if the error is a HTTPException class type
      var statusCode = e.response.statusCode;
      var message = returnsMessageToDisplay(
          statusCode); // get a friendly message for user
      return Future.error(message); //Return error message
    } else {
      return Future.error(e
          .toString()); // Returns a Future.error() that contains the error message
    }
  }
}

Future<void> logOutUser(String token, String employee) async {
  SharedPreferences prefs = await SharedPreferences
      .getInstance(); //Init SharedPreferences to get an instance
  String? device =
      prefs.getString('device'); //Gets device details from prefs instance
  String? ipAddres = prefs.getString('ip'); // Gets ipAddres from prefs instance

  var apiCall = await Requests.post(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/auth/logout',
      headers: {
        'Authorization': prefs.getString('token')!,
      },
      json: {'device': device, 'ip': ipAddres, 'employee': employee},
      persistCookies: false,
      timeoutSeconds: 10);
  apiCall.raiseForStatus();
  prefs.clear(); // Deletes prefs instance
}

Future<dynamic> getCycle(int month) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/cycles/status',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
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

//!Not using this function for now
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

//!Not using for now
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

//!Not ussing for now
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

//Function to activate/deactive an event by role
Future<dynamic> modifyActiveOfEventRole(
    int eventId, bool roleEventValue, int roleSelected) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/events/role-auth/$eventId',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
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

//Function to fetch all roles
Future<dynamic> getRolesList() async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  // String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/all',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
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

//!Not using for now
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

//Function to fetch events by role
Future<dynamic> getEventsByRole(int? roleID) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCal = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/events/roles/$roleID',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
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

//Function to fetch a detailed list of modules
Future<dynamic> getModulesListDetailed() async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/modules/detail',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
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
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/events/modules/detail',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
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

//Function to edit a role
Future<dynamic> editRole(
    int roleID, Map<String, dynamic> bodyObject, int? type) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  String response;
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/$roleID',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
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

//Function to retrieve a single role, returns a simple list, not all details from Role
Future<dynamic> getRoleDetailCall(int roleId) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/$roleId',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    insertErrorLog(e.toString(), 'getRoleDetail() | $roleId');
    throw Future.error(e.toString());
  }
}

Future<dynamic> createRole(Map<String, dynamic> bodyObject) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json'
        },
        json: bodyObject,
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    insertErrorLog(e.toString(), 'createRole() | $bodyObject');
    throw FormatException(e.toString());
  }
}

//Function to delete a userRole
Future<dynamic> deleteRoleCall(int roleId) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.delete(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/$roleId',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json'
        },
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    insertErrorLog(e.toString(), 'deleteRole() | $roleId');
    throw FormatException(e.toString());
  }
}

//Function to POST a new user
Future<dynamic> createUser(Map<String, dynamic> newUser) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/auth/signup',
        json: newUser,
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json'
        },
        persistCookies: false,
        timeoutSeconds: 15);
    apiCall.raiseForStatus();
    return apiCall.statusCode;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

//Function to edit a user
Future<dynamic> editUser(
    Map<String, dynamic> bodyObject, int employeeNumber, int? field) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/detail/$employeeNumber',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json'
        },
        queryParameters: {'field': field},
        json: bodyObject,
        persistCookies: false,
        timeoutSeconds: 18);
    apiCall.raiseForStatus();
    return apiCall.statusCode;
  } catch (e) {
    throw Future.error(e.toString());
  }
}

//!Not using for now
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

//Function to fetch all users
Future<dynamic> getUsers() async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  String response;
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/all',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
        },
        persistCookies: false,
        timeoutSeconds: 30);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

//!Not using for now
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

//Function to get detail from a user
Future<dynamic> getUserDetailCall(int userId) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/$userId',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        // queryParameters: {'id': userId},
        persistCookies: false,
        timeoutSeconds: 15);
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    insertErrorLog(e.toString(), 'getUserDetail() | $userId');
    throw Future.error(e.toString());
  }
}

//!Not using for now
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

//Function to get all campuses
Future<dynamic> getCampuseList() async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/campus/all',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        persistCookies: true,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall.content();
  } catch (e) {
    throw FormatException(e.toString());
  }
}

//Function to get all departments
Future<dynamic> getWorkDepartments() async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/department/all',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          "Content-Type": "application/json"
        },
        persistCookies: false,
        timeoutSeconds: 15);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    throw Future.error(e.toString());
  }
}

//!Not using for now
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

//Function to send request for a token to recover password
Future<dynamic> sendRecoveryToken(String userMail, String deviceInfo) async {
  http.Response apiCall;
  try {
    apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/auth/lost-password',
        headers: {"Content-Type": "application/json"},
        json: {"email": userMail, "device": deviceInfo},
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    if (e is HTTPException) {
      var message = e.response.body;
      return Future.error(message.toString());
    }
    return Future.error(e.toString());
    //return Future.error(e.toString());
  }
}

//Function to send new updated password
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

//Function to update user password not by recovery token, but by the admin or the user itself logged in
Future<dynamic> updateUserPasswordCall(String password) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  //To use when the current user logged in can be switched
  try {
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/password',
        headers: {
          "Content-Type": "application/json",
          'Authorization': devicePrefs.getString('token')!,
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

//Function to send the token caputred from user at recovery password that returns if token is valid
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

//Function to retrieve all grades and subjects/courses from a teacher
//Validates if the user is admin or not by user role using isAdmin flag
Future<dynamic> getTeacherGradeAndCourses(var employee, var year, int month,
    bool isAdmin, bool isAcademicCoordinator, String? campus) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/teacher-grades',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        queryParameters: {
          'employee': currentUser!.employeeNumber,
          "cycle": currentCycle!.claCiclo,
          "month": month,
          "flag": isAdmin,
          "campus": campus,
          "flag2": isAcademicCoordinator,
        },
        persistCookies: false,
        timeoutSeconds: 40);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    if (e is TimeoutException) {
      insertErrorLog(e.toString(), 'acad/teacher/start-student-rating');
      var firstWord = getMessageToDisplay(e.toString());
      return throw firstWord;
    }
    return Future.error(e);
  }
}

//Fucntion to get grades and courses if user is admin
Future<dynamic> getTeacherGradeAndCoursesAsAdmin(int month, bool isAdmin,
    String? campus, String? cycle, bool isAcademicCoord) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/teacher-grades',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      queryParameters: {
        "cycle": cycle,
        "month": month,
        "flag": isAdmin,
        "campus": campus,
        "employee": currentUser!.employeeNumber,
        "flag2": isAcademicCoord
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

//Function to get all students grades/evaluations value by group, subjects, grades, month and cycle
Future<dynamic> getStudentsToGrade(
    String assignature,
    String group,
    String grade,
    String? cycle,
    String? campus,
    String month,
    bool isAdmin,
    bool isAcademicCoord,
    int? teacher) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/students-evaluation-subject',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        queryParameters: {
          "grade": grade,
          "group": group,
          "subject": assignature,
          "cycle": cycle,
          "campus": campus,
          "month": month,
          "flag1": isAdmin,
          "flag2": isAcademicCoord,
          "teacher": teacher
        },
        persistCookies: false,
        timeoutSeconds: 25);
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

//!Not using for now
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
Future<dynamic> getSubjectsAndGradeByStuent(String? group, grade, cycle, campus,
    month, bool isAdmin, bool isAcademicCoord, int? teacher) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student-evaluation-student',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        queryParameters: {
          "grade": grade,
          "group": group,
          "cycle": cycle,
          "campus": campus,
          "month": month,
          "history":
              0, //0 means all students, if history : 1 , will return all history from a single student and youll need to send studenID as param
          "assignature": "null", //Set null to return all subjects
          "value": "all", //set all to return all students by cycle and
          "flag1": isAdmin,
          "flag2": isAcademicCoord,
          "teacher": teacher
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

//Function to update studens grades/evaluations
Future<dynamic> patchStudentsGrades(
    List<Map<String, dynamic>> requestBody, bool isByStudent) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    if (requestBody.isEmpty) {
      return throw const FormatException("No data to send");
    } else {
      var apiCall = await Requests.patch(
          '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/grades',
          headers: {
            'Authorization': devicePrefs.getString('token')!,
            'Content-Type': 'application/json',
          },
          // queryParameters: {
          //   "studentEval": isByStudent.toString(),
          //   "cycle": currentCycle!.claCiclo
          // },
          persistCookies: false,
          timeoutSeconds: 35,
          json: requestBody);
      apiCall.raiseForStatus();
      return apiCall.statusCode;
    }
  } catch (e) {
    insertErrorLog(e.toString(),
        'patchStudentsGrades() | isByStudent : $isByStudent , | body: $requestBody');
    return Future.error(e.toString());
  }
}

//* Function to get evaluations comments by gradeSequence
// Used to get all available comments for a grade
Future<dynamic> getStudentsGradesComments(int grade) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/evaluations/comments/',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        queryParameters: {"grade": grade},
        persistCookies: false);
    apiCall.raiseForStatus();
    if (apiCall.statusCode == 200) {
      return json.decode(utf8.decode(apiCall
          .bodyBytes)); //* Returns data formated and decoded using utf8 encoding for latin and spanish characteres
    } else {
      throw Future.error(apiCall.body);
    }
  } catch (e) {
    throw FormatException(e.toString());
  }
}

//!Not using for now
Future<dynamic> putStudentEvaluationsComments(
    int evaluationId, commentID, bool ValueToUpdate) async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  int? idSesion = devicePrefs.getInt("idSession");

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
        'idSesion': idSesion
      },
      persistCookies: false,
    );
    apiCall.raiseForStatus();
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

//!NOT USING FOR NOW
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

//Function to get a list of students name and id by role to use on fodac27 screen
Future<dynamic> getStudentsByRole(String cycle) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/fodac27/students',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        queryParameters: {'cycle': cycle},
        persistCookies: false,
        timeoutSeconds: 25);

    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    return Future.error(e);
  }
}

//Function to get history of comments at fodac27
//Can be used to get more than one student if needed
Future<dynamic> getStudentFodac27History(
    String cycle, String? studentID, bool isByStudent) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/fodac27/history',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
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

//Function to get a list of subjects that a student holds on selected cycle
Future<dynamic> getStudentSubjects(String studentID, String cycle) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/subjects',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        timeoutSeconds: 18,
        persistCookies: false,
        queryParameters: {'student': studentID, 'cycle': cycle});
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    return Future.error(e.toString());
  }
}

//Function to create a new fodac27 record
Future<dynamic> postFodac27Record(DateTime date, String studentID, String cycle,
    String observations, int employeeNumber, int subject) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.post(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/fodac27',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
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

//!Not using for now
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

//Function to get date from server side
Future<dynamic> getActualDate() async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/evaluation-date',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
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
  }
}

//Function to delete a fodac27 record
Future<int> deleteFodac27Record(int fodac27ID) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.delete(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/student/fodac27',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        queryParameters: {'fodac27': fodac27ID},
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall.statusCode;
  } catch (e) {
    return Future.error(e);
  }
}

//!Not using for now
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

//!Not using for now
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

//!Not using for now
//TODO: USE WHEN NEED TO VALIDATE IS USER IS COORDINATOR
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

//!Not using for now
//TODO:  USE THIS FUNCTION WHEN APP UODATES IS IMPLEMENTED
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

//Function to get current user details, as username, role, etc..
Future<dynamic> getCurrentUserData(String token) async {
  try {
    // SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    // var token = devicePrefs.getString('token')!;
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/me',
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        persistCookies: false);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    String errorMessage;
    insertErrorLog(e.toString(), '/users/me/');
    if (e is Exception) {
      // errorMessage = e.getErrorMessage();
      return Future.error(e.toString());
    } else {
      return Future.error(e.toString());
    }
  }
}

//Function to get user comsunption from cafeteria that is pending to pay
Future<dynamic> getUserCafeteriaConsumptionHistory() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/cafeteria/user/history',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
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
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/events/all',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
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

//Function to get a list from all screens that the user can acces
Future<dynamic> getScreenListByRoleId(int id) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/modules/$id',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
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

//Function to update is a module can be accesed by a role
Future<dynamic> updateModuleAccessByRole(
    int roleId, int flag, bool status, int item) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/modules',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        json: {'item': item, 'role': roleId, 'status': status, 'flag': flag},
        persistCookies: false,
        timeoutSeconds: 20);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(),
        "UPDATE MODULE ACCESS BY ROLE CALL | body{ item: $item, roleId: $roleId, access: $status, flag : $flag}");
    return Future.error(e.toString());
  }
}

//Function to get the permissions from the role, this returns modules, screens and events
Future<dynamic> getRolePermissions() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/me',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        persistCookies: false,
        timeoutSeconds: 15);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), "getRolepermissions()");
    return Future.error(e.toString());
  }
}

//Function to retrieve access routes for screens by token
Future<dynamic> getScreenAccessRoutes() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/roles/routes/',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        persistCookies: false,
        timeoutSeconds: 15);
    apiCall.raiseForStatus();
    return apiCall.body;
  } catch (e) {
    insertErrorLog(e.toString(), 'getScreenAccessRoutes()');
    return Future.error(e.toString());
  }
}

//* Retrieves latest app version
Future<dynamic> getLatestAppVersion() async {
  try {
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/api/version',
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), 'getLatestAppVersion()');
    return Future.error(e.toString());
  }
}

//* Fetch for all support tickets,
/*
* toFetch = initial date to fetch
* statusVal = status of ticket to fetch
* byWho =  1 = I Made ; 2 = I Was Reported
* params: { from : idLogin from currentUser}
*/
Future<dynamic> getAllServiceTickets(
    String toFetch, int statusVal, int byWho) async {
  String startDate = toFetch.replaceAll('-', '');
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/services/ticket/',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        queryParameters: {
          'toFetch': startDate.toString(),
          'from': currentUser!.idLogin,
          'status': statusVal,
          'flag': byWho
        },
        persistCookies: true,
        timeoutSeconds: 120);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), 'getAllServiceTickets $toFetch');
    return Future.error(e.toString());
  }
}

//* Retrieves history of support ticket request
Future<dynamic> getRequestticketHistory(int ticketId) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/services/ticket/$ticketId',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        persistCookies: true,
        timeoutSeconds: 35);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), 'getAllServiceTickets $ticketId');
    return Future.error(e.toString());
  }
}

//* Update support by kind of flag, can be status or assignated to a user
Future<dynamic> updateSupportTicket(Map<String, dynamic> body, int flag) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.put(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/services/ticket/',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        queryParameters: {"update": flag},
        json: body,
        persistCookies: true,
        timeoutSeconds: 35);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), 'updateSupportTicket()');
    return e;
  }
}

//* Retrieves users and idLogin, to be used when assign support ticket to an user
Future<dynamic> getUsersForTicket(int filter, String dept) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/ticket/users',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      queryParameters: {'filter': filter, 'item': dept},
      persistCookies: false,
      timeoutSeconds: 10,
    );
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    insertErrorLog(e.toString(), 'getUsersForTicket()');
    return Future.error(e.toString());
  }
}

//Function to validate a detail from an user
//* dept, campus
Future<dynamic> getUsersListByDeptCall(int loginId, String param) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
        '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/users/detail/$param',
        headers: {
          'Authorization': devicePrefs.getString('token')!,
          'Content-Type': 'application/json',
        },
        queryParameters: {"user": loginId},
        persistCookies: false,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    return apiCall;
  } catch (e) {
    rethrow;
  }
}

//*Creates a support ticket
Future<dynamic> createNewTicketServices(Map<String, dynamic> body) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.post(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/services/ticket',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      json: body,
      persistCookies: false,
      timeoutSeconds: 15,
    );
    apiCall.raiseForStatus();
    if (apiCall.statusCode == 200) {
      return apiCall;
    } else {
      insertErrorLog(apiCall.body, 'createNewTicketServices()');
      throw Future.error(apiCall.body);
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'createNewTicketServices()');
    throw e.toString();
  }
}

//* Retrieves a list of disciplinary reports by date
// TODO: Edit cycle parameter to be dynamic
Future<dynamic> getDisciplinaryReportsByDate(
    String cycle, String initialDate, String finalDate) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/discipline/reports/',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      queryParameters: {
        'initialDate': initialDate,
        'finalDate': finalDate,
        'cycle': "2022-2023" //cycle
      },
      persistCookies: true,
      timeoutSeconds: 20,
    );
    apiCall.raiseForStatus();
    if (apiCall.statusCode == 200) {
      return json.decode(utf8.decode(apiCall
          .bodyBytes)); //* Returns data formated and decoded using utf8 encoding for latin and spanish characteres
    } else {
      insertErrorLog(apiCall.body, 'getDisciplinaryReportsByDate()');
      throw Future.error(apiCall.body);
    }
  } catch (e) {
    insertErrorLog(e.toString(),
        'getDisciplinaryReportsByDate($cycle, $initialDate, $finalDate)');
    throw e.toString();
  }
}

//* Retrieves students by dynamic params
Future<dynamic> getStudentsByDynamicParam(
    String paramkey, String paramValue) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/students/all/simple',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      queryParameters: {
        'Param': paramkey,
        'param2': paramValue,
      },
      persistCookies: false,
      timeoutSeconds: 20,
    );
    apiCall.raiseForStatus();
    if (apiCall.statusCode == 200) {
      return json.decode(utf8.decode(apiCall
          .bodyBytes)); //* Returns data formated and decoded using utf8 encoding for latin and spanish characteres
    } else {
      insertErrorLog(apiCall.body, 'getStudentsByDynamicParam()');
      throw Future.error(apiCall.body);
    }
  } catch (e) {
    insertErrorLog(
        e.toString(), 'getStudentsByDynamicParam($paramkey, $paramValue)');
    throw e.toString();
  }
}

//* gets teachers name,subject,grade and group by cycle to be used on disciplinary reports
Future<dynamic> getTeachersGradeGroupSubjectsByCycle(
  String cycle,
) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/teachers/list/$cycle',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      persistCookies: false,
      timeoutSeconds: 20,
    );
    apiCall.raiseForStatus();
    if (apiCall.statusCode == 200) {
      return json.decode(utf8.decode(apiCall
          .bodyBytes)); //* Returns data formated and decoded using utf8 encoding for latin and spanish characteres
    } else {
      insertErrorLog(
          apiCall.body, 'getTeachersGradeGroupSubjectsByCycle($cycle)');
      throw Future.error(apiCall.body);
    }
  } catch (e) {
    insertErrorLog(
        e.toString(), 'getTeachersGradeGroupSubjectsByCycle($cycle)');
    throw e.toString();
  }
}

Future<dynamic> getDisciplinaryCauses(
    int gradeSequence, int kindOfReport) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/discipline/causes/',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      queryParameters: {"grade": gradeSequence, "report": kindOfReport},
      persistCookies: false,
      timeoutSeconds: 20,
    );
    apiCall.raiseForStatus();
    if (apiCall.statusCode == 200) {
      return json.decode(utf8.decode(apiCall
          .bodyBytes)); //* Returns data formated and decoded using utf8 encoding for latin and spanish characteres
    } else {
      insertErrorLog(apiCall.body,
          'getDisciplinaryCauses( Kind of report: $kindOfReport , grade: $gradeSequence)');
      throw Future.error(apiCall.body);
    }
  } catch (e) {
    insertErrorLog(e.toString(),
        'getDisciplinaryCauses( Kind of report: $kindOfReport , grade: $gradeSequence)');
    throw e.toString();
  }
}

Future<dynamic> getFodac59FiltersData(String campus, String cycle,
    bool? includeNonActive, bool? noValidates) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/fodac59/filters/',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      queryParameters: {
        'campus': campus,
        'cycle': cycle,
        'noActive': includeNonActive.toString(),
        'noValidates': noValidates.toString(),
      },
      persistCookies: false,
      timeoutSeconds: 20,
    );
    apiCall.raiseForStatus();
    if (apiCall.statusCode == 200) {
      return json.decode(utf8.decode(apiCall.bodyBytes));
    } else {
      insertErrorLog(apiCall.body, 'getFodac59List($campus, $cycle)');
      throw Future.error(apiCall.body);
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'getFodac59List($campus, $cycle)');
    throw e.toString();
  }
}

Future<dynamic> getFodac59Response(
    String cycle,
    String campus,
    int gradeSeq,
    String group,
    int month,
    int idSesion,
    String computerName,
    bool includeNonActive) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    String device = devicePrefs.getString('device')!;

    // Parse the device string as JSON
    Map<String, dynamic> deviceData = json.decode(device);
    String computerName = deviceData['computerName'] ?? 'Unknown';

    var apiCall = await Requests.get(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/fodac59/result',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      body: {
        'cycle': cycle,
        'campus': campus,
        'gradeSeq': gradeSeq,
        'group': group,
        'month': month,
        'idSesion': devicePrefs.getInt('idSession'),
        'computerName': computerName,
        'includeNonActive': includeNonActive.toString(),
      },
      bodyEncoding: RequestBodyEncoding.JSON,
      persistCookies: false,
      timeoutSeconds: 20,
    );
    apiCall.raiseForStatus();
    if (apiCall.statusCode == 200) {
      return json.decode(utf8.decode(apiCall.bodyBytes));
    } else {
      insertErrorLog(apiCall.body, 'getFodac59Response()');
      throw Future.error(apiCall.body);
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'getFodac59Response()');
    throw e.toString();
  }
}

Future<dynamic> createDisciplinaryReport(Map<String, dynamic> body) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var apiCall = await Requests.post(
      '${dotenv.env['HOSTURL']!}${dotenv.env['PORT']!}/academic/discipline/report',
      headers: {
        'Authorization': devicePrefs.getString('token')!,
        'Content-Type': 'application/json',
      },
      bodyEncoding: RequestBodyEncoding.JSON,
      body: body,
      persistCookies: false,
      timeoutSeconds: 20,
    );
    apiCall.raiseForStatus();
    if (apiCall.statusCode == 200) {
      return json.decode(utf8.decode(apiCall
          .bodyBytes)); //* Returns data formated and decoded using utf8 encoding for latin and spanish characteres
    } else {
      insertErrorLog(apiCall.body, 'createDisciplinaryReport($body)');
      throw Future.error(apiCall.body);
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'createDisciplinaryReport($body)');
    throw e.toString();
  }
}

//!Not using for now
//Function to get a list of acces items by a role
/* Future<http.Response> getUserRoleAndAcces(int roleId) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    Uri address = Uri(
        scheme: 'http',
        host: dotenv.env['HOST'],
        port: int.parse(dotenv.env['PORT']!),
        path: '/roles/me',
        queryParameters: {'role': roleId.toString()});
    var response = http.get(address, headers: {
      "Content-Type": "application/json",
      'Authorization': devicePrefs.getString('token')!,
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
} */

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
