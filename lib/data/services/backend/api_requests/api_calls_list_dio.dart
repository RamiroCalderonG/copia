/// API Calls using Dio HTTP Client
///
/// This file is a Dio-based version of the original api_calls_list.dart file.
///
/// Key differences from the original Requests package version:
/// - Uses Dio package instead of Requests for better error handling and features
/// - Includes automatic request/response logging via interceptors
/// - Better timeout management with separate connect, send, and receive timeouts
/// - Cleaner error handling with DioException instead of HTTPException
/// - Automatic Java exception message cleanup
/// - Support for self-signed certificates for HTTPS connections
/// - All function names are identical to the original for easy migration
///
/// Usage:
/// 1. Call ApiCallsDio.initialize() once in your app initialization
/// 2. Simply change your import statement from:
///    import 'package:oxschool/.../api_calls_list.dart';
///    to:
///    import 'package:oxschool/.../api_calls_list_dio.dart';
/// 3. All function calls remain exactly the same!
///
/// Benefits of using Dio:
/// - Better error handling and custom error messages
/// - Request/Response interceptors for logging and debugging
/// - Built-in request/response transformation
/// - Better timeout control
/// - Support for FormData, File uploads, and other advanced features
/// - Self-signed certificate support for development/testing environments
///
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/device_functions.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ApiCallsDio {
  static late Dio _dio;

  // Initialize Dio with default configuration
  static void initialize() {
    _dio = Dio();

    // Configure HTTP client adapter to allow self-signed certificates
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    // Add default headers
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Set default timeout
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Add interceptor for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          print(
              'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          handler.next(error);
        },
      ),
    );
  }

  // Helper method to get base URL
  static String get _baseUrl =>
      '${dotenv.env['HTTPSHOST']!}${dotenv.env['HTTPSPORT']!}';

  // Helper method to handle Dio errors and clean Java exception messages
  static String _cleanErrorMessage(String message) {
    if (message.contains(':')) {
      List<String> parts = message.split(':');
      if (parts.length > 1) {
        return parts.last.trim();
      }
    }
    return message;
  }

  // Helper method to handle Dio errors
  static Future<T> _handleDioError<T>(DioException error) async {
    insertErrorLog(error.toString(), error.requestOptions.path);

    if (error.response != null) {
      final response = error.response!;
      if (response.data is Map<String, dynamic>) {
        final errorData = response.data as Map<String, dynamic>;
        String currentMessage =
            errorData['detail'] ?? errorData['message'] ?? 'Unknown error';
        currentMessage = _cleanErrorMessage(currentMessage);
        return Future.error(currentMessage);
      } else if (response.data is String) {
        String message = _cleanErrorMessage(response.data);
        return Future.error(message);
      }
      return Future.error(
          'HTTP ${response.statusCode}: ${response.statusMessage}');
    } else {
      // Network error, timeout, etc.
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return Future.error(getMessageToDisplay('timeout'));
      }
      return Future.error(error.message ?? 'Network error');
    }
  }
}

//* Post a login request, send into body device details
Future<dynamic> loginUser(Map<String, dynamic> jsonBody) async {
  try {
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/auth/login',
      data: jsonBody,
      options: Options(
        sendTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

Future<void> logOutUser(String token, String employee) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? device = prefs.getString('device');
    String? ipAddress = prefs.getString('ip');

    await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/auth/logout',
      data: {'device': device, 'ip': ipAddress, 'employee': employee},
      options: Options(
        headers: {'Authorization': prefs.getString('token')!},
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    prefs.clear();
  } on DioException catch (e) {
    throw await ApiCallsDio._handleDioError(e);
  }
}

Future<dynamic> getCycle(int month) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/cycles/status',
      queryParameters: {"status": month},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//!Not using this function for now
//Function to post new visit from a student to nursery
Future<dynamic> postNurseryVisit(Map<String, dynamic> jsonBody) async {
  try {
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/api/nursery-visit/',
      data: jsonBody,
      options: Options(
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token,
          'employeeNum': currentUser!.employeeNumber!.toString()
        },
        sendTimeout: const Duration(seconds: 7),
        receiveTimeout: const Duration(seconds: 7),
      ),
    );

    return response.statusCode;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//!Not using for now
// Function to delete an allowed medicine from a student
Future<int> deleteMedicineStudent(var idValue) async {
  try {
    final response = await ApiCallsDio._dio.put(
      '${ApiCallsDio._baseUrl}/api/student-meds/$idValue',
      options: Options(
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token,
          'employeeNum': currentUser!.employeeNumber!.toString()
        },
        sendTimeout: const Duration(seconds: 7),
        receiveTimeout: const Duration(seconds: 7),
      ),
    );

    return response.statusCode!;
  } on DioException catch (e) {
    throw ApiCallsDio._handleDioError(e);
  }
}

//Function to activate/deactive an event by role
Future<dynamic> modifyActiveOfEventRole(
    int eventId, bool roleEventValue, int roleSelected) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.put(
      '${ApiCallsDio._baseUrl}/events/role-auth/$eventId',
      data: {'value': roleEventValue, 'role': roleSelected},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response.data;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to fetch all roles
Future<dynamic> getRolesList() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/roles/all',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to fetch events by role
Future<dynamic> getEventsByRole(int? roleID) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/events/roles/$roleID',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to fetch a detailed list of modules
Future<dynamic> getModulesListDetailed() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/modules/detail',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
      ),
    );
    return response.data;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getModulesAndEvents() apiCall');
    return ApiCallsDio._handleDioError(e);
  }
}

Future<dynamic> getEventsAndModulesCall() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/events/modules/detail',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getEventsAndModulesCall() apiCall');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to edit a role
Future<dynamic> editRole(
    int roleID, Map<String, dynamic> bodyObject, int? type) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.put(
      '${ApiCallsDio._baseUrl}/roles/$roleID',
      data: bodyObject,
      queryParameters: {'type': type},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    return response.data;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to retrieve a single role, returns a simple list, not all details from Role
Future<dynamic> getRoleDetailCall(int roleId) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/roles/$roleId',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getRoleDetail() | $roleId');
    return ApiCallsDio._handleDioError(e);
  }
}

Future<dynamic> createRole(Map<String, dynamic> bodyObject) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/roles/',
      data: bodyObject,
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response.data;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'createRole() | $bodyObject');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to delete a userRole
Future<dynamic> deleteRoleCall(int roleId) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.delete(
      '${ApiCallsDio._baseUrl}/roles/$roleId',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response.data;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'deleteRole() | $roleId');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to POST a new user
Future<dynamic> createUser(Map<String, dynamic> newUser) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/auth/signup',
      data: newUser,
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return response.statusCode;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to edit a user
Future<dynamic> editUser(
    Map<String, dynamic> bodyObject, int employeeNumber, int? field) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.put(
      '${ApiCallsDio._baseUrl}/users/detail/$employeeNumber',
      data: bodyObject,
      queryParameters: {'field': field},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 18),
        receiveTimeout: const Duration(seconds: 18),
      ),
    );
    return response.statusCode;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to fetch all users
Future<dynamic> getUsers() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/users/all',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

// Update idLogin from MSSQL TO PG
Future<dynamic> getIdLoginByUser(int employeeNumber) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/users/loginid/$employeeNumber',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response.data;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'updateIdLoginToPg() | $employeeNumber');
    return ApiCallsDio._handleDioError(e);
  }
}

// Function to retrieve idLogin
Future<dynamic> getIdLoginByEmployeeNumber(int employeeNumber) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/users/loginid/$employeeNumber',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response.data;
  } on DioException catch (e) {
    insertErrorLog(
        e.toString(), 'getIdLoginByEmployeeNumber() | $employeeNumber');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get detail from a user
Future<dynamic> getUserDetailCall(int userId) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/users/$userId',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return response.data;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getUserDetail() | $userId');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get all campuses
Future<dynamic> getCampuseList() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/campus/all',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response.data;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get all departments
Future<dynamic> getWorkDepartments() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/department/all',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to send request for a token to recover password
Future<dynamic> sendRecoveryToken(String userMail, String deviceInfo) async {
  try {
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/auth/lost-password',
      data: {"email": userMail, "device": deviceInfo},
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to send new updated password
Future<dynamic> updateUserPasswordByToken(
    String token, String newPassword) async {
  try {
    final response = await ApiCallsDio._dio.put(
      '${ApiCallsDio._baseUrl}/auth/password',
      data: {"token": token, "password": newPassword},
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), '/auth/password');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to update user password not by recovery token, but by the admin or the user itself logged in
Future<dynamic> updateUserPasswordCall(String password) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.put(
      '${ApiCallsDio._baseUrl}/users/password',
      data: {"password": password},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response.statusCode == 200;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), '/api/user/password');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to send the token captured from user at recovery password that returns if token is valid
Future<dynamic> validateToken(
    String token, String userMail, String device) async {
  try {
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/auth/recovery-token',
      data: {"email": userMail, "device": device},
      queryParameters: {"token": token},
      options: Options(
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), '/auth/recovery-token');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to retrieve all grades and subjects/courses from a teacher
//Validates if the user is admin or not by user role using isAdmin flag
Future<dynamic> getTeacherGradeAndCourses(var employee, var year, int month,
    bool isAdmin, bool isAcademicCoordinator, String? campus) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/teacher-grades',
      queryParameters: {
        'employee': currentUser!.employeeNumber,
        "cycle": currentCycle!.claCiclo,
        "month": month,
        "flag": isAdmin,
        "campus": campus,
        "flag2": isAcademicCoordinator,
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'acad/teacher/start-student-rating');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get grades and courses if user is admin
Future<dynamic> getTeacherGradeAndCoursesAsAdmin(int month, bool isAdmin,
    String? campus, String? cycle, bool isAcademicCoord) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/teacher-grades',
      queryParameters: {
        "cycle": cycle,
        "month": month,
        "flag": isAdmin,
        "campus": campus,
        "employee": currentUser!.employeeNumber,
        "flag2": isAcademicCoord
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getTeacherGradeAndCoursesAsAdmin()');
    return ApiCallsDio._handleDioError(e);
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
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/students-evaluation-subject',
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
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), '/academic/students-evaluation');
    return ApiCallsDio._handleDioError(e);
  }
}

//getSubjectsAndGradeByStuent will get based on the current teacher consuming the API.
Future<dynamic> getSubjectsAndGradeByStuent(String? group, grade, cycle, campus,
    month, bool isAdmin, bool isAcademicCoord, int? teacher) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/student-evaluation-student',
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
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'academic/student-evaluation-student');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to update students grades/evaluations
Future<dynamic> patchStudentsGrades(
    List<Map<String, dynamic>> requestBody, bool isByStudent) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    if (requestBody.isEmpty) {
      return Future.error("No data to send");
    }

    final response = await ApiCallsDio._dio.patch(
      '${ApiCallsDio._baseUrl}/academic/student/grades',
      data: requestBody,
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 35),
        receiveTimeout: const Duration(seconds: 35),
      ),
    );
    return response.statusCode;
  } on DioException catch (e) {
    insertErrorLog(e.toString(),
        'patchStudentsGrades() | isByStudent : $isByStudent , | body: $requestBody');
    return ApiCallsDio._handleDioError(e);
  }
}

//* Function to get evaluations comments by gradeSequence
// Used to get all available comments for a grade
Future<dynamic> getStudentsGradesComments(int grade) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/evaluations/comments/',
      queryParameters: {"grade": grade},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//!Not using for now
Future<dynamic> putStudentEvaluationsComments(
    int evaluationId, commentID, bool ValueToUpdate) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    int? idSesion = devicePrefs.getInt("idSession");

    final response = await ApiCallsDio._dio.patch(
      '${ApiCallsDio._baseUrl}/academic/student/comments',
      data: {
        'comment': commentID,
        'evaluation': evaluationId,
        'value': ValueToUpdate,
        'idSesion': idSesion
      },
      options: Options(
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
      ),
    );

    return response.statusCode;
  } on DioException catch (e) {
    throw ApiCallsDio._handleDioError(e);
  }
}

//Function to get a list of students name and id by role to use on fodac27 screen
Future<dynamic> getStudentsByRole(String cycle) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/fodac27/students',
      queryParameters: {'cycle': cycle},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get history of comments at fodac27
//Can be used to get more than one student if needed
Future<dynamic> getStudentFodac27History(
    String cycle, String? studentID, bool isByStudent) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/fodac27/history',
      queryParameters: {
        'cycle': cycle.toString(),
        'student': studentID!.trim()
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
      ),
    );
    return response.data;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get a list of subjects that a student holds on selected cycle
Future<dynamic> getStudentSubjects(String studentID, String cycle) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/student/subjects',
      queryParameters: {'student': studentID, 'cycle': cycle},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 18),
        receiveTimeout: const Duration(seconds: 18),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to create a new fodac27 record
Future<dynamic> postFodac27Record(DateTime date, String studentID, String cycle,
    String observations, int employeeNumber, int subject) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/academic/student/fodac27',
      data: {
        'date': date.toIso8601String(),
        'student': studentID.toString(),
        'cycle': cycle.toString(),
        'observation': observations.toString(),
        'employee': employeeNumber,
        'subject': subject
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
      ),
    );
    return response.statusCode;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get date from server side
Future<dynamic> getActualDate() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/evaluation-date',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response.data;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to delete a fodac27 record
Future<int> deleteFodac27Record(int fodac27ID) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.delete(
      '${ApiCallsDio._baseUrl}/academic/student/fodac27',
      queryParameters: {'fodac27': fodac27ID},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
      ),
    );
    return response.statusCode!;
  } on DioException catch (e) {
    throw await ApiCallsDio._handleDioError(e);
  }
}

Future<int> editFodac27Record(Map<String, dynamic> body) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.patch(
      '${ApiCallsDio._baseUrl}/academic/student/fodac27/',
      data: body,
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
      ),
    );
    return response.statusCode!;
  } on DioException catch (e) {
    throw ApiCallsDio._handleDioError(e);
  }
}

//!Not using for now
Future<dynamic> getGlobalGradesAndGroups(String cyle) async {
  try {
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/api/globalg&g',
      queryParameters: {'cycle': cyle},
      options: Options(
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
      ),
    );
    return response.data;
  } on DioException catch (e) {
    throw ApiCallsDio._handleDioError(e);
  }
}

//!Not using for now
Future<dynamic> getStudentsForFodac27(
    String grade, String group, String campus, String cycle) async {
  try {
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/fodac27/students-list',
      queryParameters: {
        'grade': grade,
        'group': group,
        'campus': campus,
        'cycle': cycle
      },
      options: Options(
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
      ),
    );
    return response.data;
  } on DioException catch (e) {
    throw ApiCallsDio._handleDioError(e);
  }
}

//!Not using for now
//TODO: USE WHEN NEED TO VALIDATE IS USER IS COORDINATOR
Future<dynamic> validateIfUserIsCoordinator(int user) async {
  try {
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/api/coordination/validate',
      queryParameters: {'user': user.toString()},
      options: Options(
        headers: {
          'X-Embarcadero-App-Secret': dotenv.env['APIKEY']!,
          'Auth': currentUser!.token
        },
      ),
    );
    return response.data;
  } on DioException catch (e) {
    throw ApiCallsDio._handleDioError(e);
  }
}

//Function to get current user details, as username, role, etc..
Future<dynamic> getCurrentUserData(String token) async {
  try {
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/users/me',
      options: Options(
        headers: {'Authorization': token},
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), '/users/me/');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get user consumption from cafeteria that is pending to pay
Future<dynamic> getUserCafeteriaConsumptionHistory() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/cafeteria/user/history',
      queryParameters: {
        'employee': currentUser!.employeeNumber,
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), "CAFETERIA HISTORY CALL ERROR: ");
    return ApiCallsDio._handleDioError(e);
  }
}

//To retrieve all events from the server
Future<dynamic> getEventsListRequest() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/events/all',
      queryParameters: {'filter': 'true'},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), "EVENTS LIST CALL ERROR: ");
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get a list from all screens that the user can access
Future<dynamic> getScreenListByRoleId(int id) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/roles/modules/$id',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), "SCREEN LIST BY ROLE ID CALL ERROR: ");
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to update if a module can be accessed by a role
Future<dynamic> updateModuleAccessByRole(
    int roleId, int flag, bool status, int item) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.put(
      '${ApiCallsDio._baseUrl}/roles/modules',
      data: {'item': item, 'role': roleId, 'status': status, 'flag': flag},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(),
        "UPDATE MODULE ACCESS BY ROLE CALL | body{ item: $item, roleId: $roleId, access: $status, flag : $flag}");
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to get the permissions from the role, this returns modules, screens and events
Future<dynamic> getRolePermissions() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/roles/me',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), "getRolePermissions()");
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to retrieve access routes for screens by token
Future<dynamic> getScreenAccessRoutes() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/roles/routes/',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getScreenAccessRoutes()');
    return ApiCallsDio._handleDioError(e);
  }
}

//* Retrieves latest app version
Future<dynamic> getLatestAppVersion() async {
  try {
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/api/version',
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getLatestAppVersion()');
    return ApiCallsDio._handleDioError(e);
  }
}

//* Fetch for all support tickets
Future<dynamic> getAllServiceTickets(
    String toFetch, int statusVal, int byWho) async {
  try {
    String startDate = toFetch.replaceAll('-', '');
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/services/ticket/',
      queryParameters: {
        'toFetch': startDate.toString(),
        'from': currentUser!.idLogin,
        'status': statusVal,
        'flag': byWho
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getAllServiceTickets $toFetch');
    return ApiCallsDio._handleDioError(e);
  }
}

//* Retrieves history of support ticket request
Future<dynamic> getRequestticketHistory(int ticketId) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/services/ticket/$ticketId',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 35),
        receiveTimeout: const Duration(seconds: 35),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getRequestticketHistory $ticketId');
    return ApiCallsDio._handleDioError(e);
  }
}

//* Update support by kind of flag, can be status or assigned to a user
Future<dynamic> updateSupportTicket(Map<String, dynamic> body, int flag) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.put(
      '${ApiCallsDio._baseUrl}/services/ticket/',
      data: body,
      queryParameters: {"update": flag},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 35),
        receiveTimeout: const Duration(seconds: 35),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'updateSupportTicket()');
    return ApiCallsDio._handleDioError(e);
  }
}

//* Retrieves users and idLogin, to be used when assign support ticket to an user
Future<dynamic> getUsersForTicket(int filter, String dept) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/users/ticket/users',
      queryParameters: {'filter': filter, 'item': dept},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response;
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getUsersForTicket()');
    return ApiCallsDio._handleDioError(e);
  }
}

//Function to validate a detail from an user
//* dept, campus
Future<dynamic> getUsersListByDeptCall(int loginId, String param) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/users/detail/$param',
      queryParameters: {"user": loginId},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return response;
  } on DioException catch (e) {
    return ApiCallsDio._handleDioError(e);
  }
}

//*Creates a support ticket
Future<dynamic> createNewTicketServices(Map<String, dynamic> body) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/services/ticket',
      data: body,
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      insertErrorLog(response.data.toString(), 'createNewTicketServices()');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'createNewTicketServices()');
    return ApiCallsDio._handleDioError(e);
  }
}

//* Retrieves a list of disciplinary reports by date
Future<dynamic> getDisciplinaryReportsByDate(
    String cycle, String initialDate, String finalDate) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/discipline/reports/',
      queryParameters: {
        'initialDate': initialDate,
        'finalDate': finalDate,
        'cycle': cycle
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    if (response.statusCode == 200) {
      // Handle UTF-8 decoding for Spanish characters
      if (response.data is String) {
        return response.data; //json.decode(response.data);
      }
      return response.data;
    } else {
      insertErrorLog(
          response.data.toString(), 'getDisciplinaryReportsByDate()');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(e.toString(),
        'getDisciplinaryReportsByDate($cycle, $initialDate, $finalDate)');
    return ApiCallsDio._handleDioError(e);
  }
}

//* Retrieves students by dynamic params
Future<dynamic> getStudentsByDynamicParam(
    String paramkey, String paramValue) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/students/all/simple',
      queryParameters: {
        'Param': paramkey,
        'param2': paramValue,
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    if (response.statusCode == 200) {
      // Handle UTF-8 decoding for Spanish characters
      if (response.data is String) {
        return response.data; //json.decode(response.data);
      }
      return response.data;
    } else {
      insertErrorLog(response.data.toString(), 'getStudentsByDynamicParam()');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(
        e.toString(), 'getStudentsByDynamicParam($paramkey, $paramValue)');
    return ApiCallsDio._handleDioError(e);
  }
}

//* gets teachers name,subject,grade and group by cycle to be used on disciplinary reports
Future<dynamic> getTeachersGradeGroupSubjectsByCycle(
  String cycle,
) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/teachers/list/$cycle',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    if (response.statusCode == 200) {
      // Handle UTF-8 decoding for Spanish characters
      if (response.data is String) {
        return response.data; //json.decode(response.data);
      }
      return response.data;
    } else {
      insertErrorLog(response.data.toString(),
          'getTeachersGradeGroupSubjectsByCycle($cycle)');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(
        e.toString(), 'getTeachersGradeGroupSubjectsByCycle($cycle)');
    return ApiCallsDio._handleDioError(e);
  }
}

Future<dynamic> getDisciplinaryCauses(
    int gradeSequence, int kindOfReport) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/discipline/causes/',
      queryParameters: {"grade": gradeSequence, "report": kindOfReport},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    if (response.statusCode == 200) {
      // Handle UTF-8 decoding for Spanish characters
      if (response.data is String) {
        return response.data; //json.decode(response.data);
      }
      return response.data;
    } else {
      insertErrorLog(response.data.toString(),
          'getDisciplinaryCauses( Kind of report: $kindOfReport , grade: $gradeSequence)');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(e.toString(),
        'getDisciplinaryCauses( Kind of report: $kindOfReport , grade: $gradeSequence)');
    return ApiCallsDio._handleDioError(e);
  }
}

Future<dynamic> createDisciplinaryReport(Map<String, dynamic> body) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/academic/discipline/report',
      data: body,
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    if (response.statusCode == 200) {
      // Handle UTF-8 decoding for Spanish characters
      if (response.data is String) {
        return response.data; //json.decode(response.data);
      }
      return response.data;
    } else {
      insertErrorLog(
          response.data.toString(), 'createDisciplinaryReport($body)');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'createDisciplinaryReport($body)');
    return ApiCallsDio._handleDioError(e);
  }
}

Future<dynamic> getFodac59FiltersData(String campus, String cycle,
    bool? includeNonActive, bool? noValidates) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/fodac59/filters/',
      queryParameters: {
        'campus': campus,
        'cycle': cycle,
        'noActive': includeNonActive.toString(),
        'noValidates': noValidates.toString(),
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      insertErrorLog(
          response.data.toString(), 'getFodac59FiltersData($campus, $cycle)');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getFodac59FiltersData($campus, $cycle)');
    return ApiCallsDio._handleDioError(e);
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
    bool includeNonActive,
    String studentId) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    var device = await getDeviceDetails();

    // Parse the device string as JSON
    // Map<String, dynamic> deviceData = json.decode(device);
    String computerName = device['computerName'] ?? 'Unknown';

    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/academic/fodac59/result',
      queryParameters: {
        'cycle': cycle,
        'campus': campus,
        'gradeSeq': gradeSeq,
        'group': group,
        'month': month,
        'student': studentId,
        'idSesion': devicePrefs.getInt('idSession'),
        'computerName': computerName,
        'includeNonActive': includeNonActive,
      },
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 35),
        receiveTimeout: const Duration(seconds: 35),
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      insertErrorLog(response.data.toString(), 'getFodac59Response()');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getFodac59Response()');
    return ApiCallsDio._handleDioError(e);
  }
}

// Function to retrieve attendance history by Employee number and between dates
Future<dynamic> getEmployeeAttendanceHistory(
    String initialDate, String finalDate) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/users/me/attendance/',
      queryParameters: {'fromDate': initialDate, 'toDate': finalDate},
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    if (response.statusCode == 200) {
      // Handle UTF-8 decoding for Spanish characters
      if (response.data is String) {
        return response.data; //json.decode(response.data);
      }
      return response.data;
    } else {
      insertErrorLog(
          response.data.toString(), 'getEmployeeAttendanceHistory()');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getEmployeeAttendanceHistory()');
    return ApiCallsDio._handleDioError(e);
  }
}

Future<dynamic> getActiveNotifications() async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.get(
      '${ApiCallsDio._baseUrl}/notifications/active/',
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      insertErrorLog(response.data.toString(), 'getActiveNotifications()');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'getEmployeeAttendanceHistory()');
    return ApiCallsDio._handleDioError(e);
  }
}

//*Creates a new notification
Future<dynamic> createNotification(
    Map<String, dynamic> notificationData) async {
  try {
    SharedPreferences devicePrefs = await SharedPreferences.getInstance();
    final response = await ApiCallsDio._dio.post(
      '${ApiCallsDio._baseUrl}/notifications/new/',
      data: notificationData,
      options: Options(
        headers: {'Authorization': devicePrefs.getString('token')!},
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      insertErrorLog(
          response.data.toString(), 'createNotification($notificationData)');
      return Future.error(response.data);
    }
  } on DioException catch (e) {
    insertErrorLog(e.toString(), 'createNotification($notificationData)');
    return ApiCallsDio._handleDioError(e);
  }
}
