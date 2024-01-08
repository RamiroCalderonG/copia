import 'dart:convert';

import 'package:oxschool/Models/Cause.dart';
import 'package:oxschool/backend/api_requests/api_calls.dart';
import 'package:oxschool/constants/Student.dart';
import 'package:oxschool/enfermeria/new_student_visit.dart';

//GET LIST OF CAUSES
Future<List<String>> getCauses(int causeCla) async {
  List<dynamic> jsonList;
  late List<Cause> model;
  List<String> causesLst = [];

  var apiResultxgr = await CausesCall.call(claCausa: causeCla.toString())
      .timeout(Duration(seconds: 12));

  if (apiResultxgr.succeeded) {
    jsonList = json.decode(apiResultxgr.response!.body);
    model = jsonList.map((json) => Cause.fromJson(json)).toList();

    nurseryCauses = causeFromJSON(jsonList);

    causesLst = model.map((cause) => cause.nomCause).toList();

    return causesLst;
  } else {
    print("Error en llamada a causas");
    // Throw an exception or return an empty list based on your error handling strategy
    throw Exception("Failed to fetch causes");
  }
}
