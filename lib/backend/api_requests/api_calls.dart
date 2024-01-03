import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:oxschool/constants/connection.dart';
import 'package:oxschool/utils/device_information.dart';

import '../../flutter_flow/flutter_flow_util.dart';

import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class LoginUserCall {
  static Future<ApiCallResponse> call(
      {required String nip, required String device}) {
    return ApiManager.instance.makeApiCall(
      callName: 'LoginVerify',
      apiUrl: hostUrl + port + '/login/userlogin?nip=$nip&device=$device',
      callType: ApiCallType.GET,
      headers: {'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret},
      params: {
        'nip': nip,
        'device': device,
      },
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
      cache: true,
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
        cache: true);
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
      cache: true,
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
      cache: true,
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
      cache: true,
    );
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
