import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../flutter_flow/flutter_flow_util.dart';

import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class LoginVerifyCall {
  static Future<ApiCallResponse> call({
    String? nip = '',
  }) {
    return ApiManager.instance.makeApiCall(
      callName: 'LoginVerify',
      apiUrl: 'http://10.0.0.36:8080/login/loginverify?nip=$nip',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'nip': nip,
      },
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
      callName: 'cicles',
      apiUrl: "http://10.0.0.36:8080/api/cicles/1",
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
    );
  }
}

class FamilyCall {
  static Future<ApiCallResponse> call({String? claFam}) {
    return ApiManager.instance.makeApiCall(
        callName: 'family',
        apiUrl: "http://192.168.45.7:8080/api/family/$claFam/",
        callType: ApiCallType.GET,
        headers: {},
        params: {},
        returnBody: true,
        encodeBodyUtf8: false,
        decodeUtf8: false,
        cache: true);
  }
}

class NurseryStudentCall {
  static Future<ApiCallResponse> call(
      {String? apPaterno, apMaterno, claUn, claCiclo}) {
    return ApiManager.instance.makeApiCall(
      callName: 'NursingStudent',
      apiUrl: "http://10.0.0.36:8080/api/nursing/student",
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'ClaCiclo': claCiclo,
        'ClaUn': claUn,
        'ApPaterno': apPaterno,
        'ApMaterno': apMaterno
      },
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
