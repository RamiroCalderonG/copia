//GET LIST OF CAUSES
import 'dart:convert';

import 'package:oxschool/backend/api_requests/api_calls.dart';

Future<List<String>> getPainList(int causeCla) async {
  List<dynamic> jsonList;
  List<dynamic> model;
  List<String> causesLst = [];

  var apiResultxgr =
      await NurseryPainListCall.call(claCausa: causeCla.toString())
          .timeout(Duration(seconds: 12));

  if (apiResultxgr.succeeded) {
    jsonList = json.decode(apiResultxgr.response!.body);
    model = (jsonDecode(jsonList as String) as List<dynamic>).cast<String>();

    nurseryCauses = causeFromJSON(jsonList);

    causesLst = model.map((cause) => cause.nomCause).toList();

    return causesLst;
  } else {
    print("Error en llamada a causas");
    // Throw an exception or return an empty list based on your error handling strategy
    throw Exception("Failed to fetch causes");
  }
}
