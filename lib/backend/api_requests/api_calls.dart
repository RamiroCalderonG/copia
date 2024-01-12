import 'dart:convert';

import 'package:oxschool/constants/connection.dart';

import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class LoginUserCall {
  static Future<ApiCallResponse> call(
      {required String nip,
      required String device,
      required String ip_address}) {
    return ApiManager.instance.makeApiCall(
      callName: 'LoginVerify',
      apiUrl: hostUrl + port + '/login/userlogin?nip=$nip&device=$device',
      callType: ApiCallType.GET,
      headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
      params: {'nip': nip, 'device': device, 'l1': ip_address},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      bodyType: BodyType.JSON,
      cache: false,
    );
  }
}

class UserPermissionsCall {
  static Future<ApiCallResponse> call({
    required String idLogin,
  }) {
    return ApiManager.instance.makeApiCall(
      callName: 'permissions',
      apiUrl: hostUrl + port + '/api/user/permissions?idLogin=$idLogin',
      callType: ApiCallType.GET,
      headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
      params: {'idLogin': idLogin},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
    );
  }
}

class CurrentCicleCall {
  static Future<ApiCallResponse> call() {
    return ApiManager.instance.makeApiCall(
      callName: 'cycles',
      apiUrl: hostUrl + port + '/api/cycles/1',
      callType: ApiCallType.GET,
      headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
    );
  }
}

class FamilyCall {
  //Call to get family details by family number
  static Future<ApiCallResponse> call({String? claFam}) {
    return ApiManager.instance.makeApiCall(
        callName: 'family',
        apiUrl: hostUrl + port + '/api/family/$claFam/',
        callType: ApiCallType.GET,
        headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
        params: {},
        returnBody: true,
        encodeBodyUtf8: false,
        decodeUtf8: false,
        cache: false);
  }
}

class NurseryStudentCall {
  //To get Student info used by Nursery dept.
  static Future<ApiCallResponse> call(
      {required String apPaterno, apMaterno, nombre, claUn, claCiclo}) {
    return ApiManager.instance.makeApiCall(
      callName: 'NursingStudent',
      apiUrl: hostUrl + port + '/api/nursery/student',
      callType: ApiCallType.GET,
      headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
      params: {
        'ClaCiclo': claCiclo,
        'ClaUn': claUn,
        'ApPaterno': apPaterno,
        'ApMaterno': apMaterno,
        'Nombre': nombre
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
    );
  }
}

class NurseryStudentMedication {
  static Future<ApiCallResponse> call({required String matricula}) {
    return ApiManager.instance.makeApiCall(
      callName: 'NurseryMedication',
      apiUrl: hostUrl + port + '/api/nursery/medication',
      callType: ApiCallType.GET,
      headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
      params: {"matricula": matricula},
      returnBody: true,
      cache: false,
    );
  }
}

class NurseryHistoryCall {
  static Future<ApiCallResponse> call({required String matricula}) {
    return ApiManager.instance.makeApiCall(
      callName: 'NurseryHistory',
      apiUrl: hostUrl + port + '/api/nursery/history',
      callType: ApiCallType.GET,
      headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
      params: {"matricula": matricula},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
    );
  }
}

class CausesCall {
  static Future<ApiCallResponse> call({required String claCausa}) {
    return ApiManager.instance.makeApiCall(
      callName: 'Causes',
      apiUrl: hostUrl + port + '/api/causes',
      callType: ApiCallType.GET,
      headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
      params: {"ClaCausa": claCausa},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
    );
  }
}

//Pending to add Log data to store at
class NurseryPainListCall {
  static Future<ApiCallResponse> call({required String dataLog}) {
    return ApiManager.instance.makeApiCall(
        callName: 'Nursery-Pain-List',
        apiUrl: hostUrl + port + '/api/nursery-pain-list',
        callType: ApiCallType.GET,
        headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
        params: {},
        returnBody: true,
        encodeBodyUtf8: false,
        decodeUtf8: false,
        cache: true);
  }
}

class NurseryWoundsCall {
  static Future<ApiCallResponse> call({required String dataLog}) {
    return ApiManager.instance.makeApiCall(
      callName: 'Nursery-Wounds',
      apiUrl: hostUrl + port + '/api/nursery-wounds',
      callType: ApiCallType.GET,
      headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
    );
  }
}

class EmployeeCall {
  static Future<ApiCallResponse> call(
      {required String campus,
      required String employeeID,
      required String logData,
      required String param,
      required String ip}) {
    return ApiManager.instance.makeApiCall(
        callName: 'Employees',
        apiUrl: hostUrl + port + '/api/employee',
        callType: ApiCallType.GET,
        headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
        params: {
          "Required": param,
          "campus": campus,
          "employeeID": employeeID,
          "l1": ip
        },
        returnBody: true,
        encodeBodyUtf8: false,
        decodeUtf8: false,
        cache: false);
  }
}

class TeacherCall {
  static Future<ApiCallResponse> call({
    required String ipData,
    required String campus,
    required int grade,
    required String group,
    required String param,
    required String cycle,
  }) {
    return ApiManager.instance.makeApiCall(
        callName: 'Teacher',
        apiUrl: hostUrl + port + '/api/Employee/Teacher',
        callType: ApiCallType.GET,
        headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
        params: {
          "ClaUn": campus,
          "ClaCiclo": cycle,
          "Grado": grade,
          "Grupo": group,
          "deviceInfo": ipData,
          "param": param,
        },
        returnBody: true,
        encodeBodyUtf8: false,
        decodeUtf8: false,
        cache: false);
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list);
  } catch (_) {
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar);
  } catch (_) {
    return isList ? '[]' : '{}';
  }
}
