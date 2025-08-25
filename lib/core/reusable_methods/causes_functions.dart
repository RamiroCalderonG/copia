import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls.dart';

//GET LIST OF CAUSES
Future<List<String>> getCauses(int causeCla) async {
  List<dynamic> jsonList;
  List<String> causesLst = [];

  var apiResultxgr = await CausesCall.call(claCausa: causeCla.toString())
      .timeout(const Duration(seconds: 15));

  if (apiResultxgr.succeeded) {
    // Parse the JSON response
    //jsonList =  json.decode(apiResultxgr.response!.body);

    // Extract nomCausa into causesLst
    //causesLst = List<String>.from(jsonList.map((json) => json['NomCausa']));

    return causesLst;
  } else {
    if (kDebugMode) {
      print("Error en llamada a causas${apiResultxgr.response!.body}");
    }
    // Throw an exception or return an empty list based on your error handling strategy
    throw Exception("Failed to fetch causes");
  }
}
