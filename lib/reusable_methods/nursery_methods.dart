//GET LIST OF CAUSES
import 'dart:convert';

import 'package:oxschool/backend/api_requests/api_calls.dart';

Future<List<String>> getPainList(String logger) async {
  List<dynamic> jsonList;
  List<String> resultPainList = [];

  var apiResultxgr = await NurseryPainListCall.call(dataLog: logger)
      .timeout(Duration(seconds: 15));

  if (apiResultxgr.succeeded) {
    // Parse the JSON response
    jsonList = json.decode(apiResultxgr.response!.body);

    // Extract 'painList' values into a List<String>
    resultPainList =
        List<String>.from(jsonList.map((json) => json['NomCausa']));

    return resultPainList;
  } else {
    print("Error en llamada a dolores");
    // Throw an exception or return an empty list based on your error handling strategy
    throw Exception("Failed to fetch");
  }
}

Future<List<String>> getWoundsList(String logger) async {
  List<dynamic> jsonList;
  List<String> resultWoundsList = [];

  var apiResultxgr = await NurseryWoundsCall.call(dataLog: logger)
      .timeout(Duration(seconds: 15));

  if (apiResultxgr.succeeded) {
    // Parse the JSON response
    jsonList = json.decode(apiResultxgr.response!.body);

    // Extract 'painList' values into a List<String>
    resultWoundsList =
        List<String>.from(jsonList.map((json) => json['NomCausa']));

    return resultWoundsList;
  } else {
    print("Error en llamada a dolores");
    // Throw an exception or return an empty list based on your error handling strategy
    throw Exception("Failed to fetch");
  }
}
