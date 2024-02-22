import 'package:flutter/material.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/constants/connection.dart';

import 'package:requests/requests.dart';

//Function to post new visit from a student to nursery
Future<int> postNurseryVisit(var jsonBody) async {
  var postResponse;
  try {
    var apiCall = await Requests.post(hostUrl + port + '/api/nursery-visit/',
        json: jsonBody, //We use a json style as body
        headers: {
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
    ErrorDescription(e.toString());
  }
  return postResponse;
}

Future<String> searchEmployee(String employeeNumber) async {
  var postResponse;
  try {
    var apiCall = await Requests.get(
        hostUrl + port + '/api/employee/' + employeeNumber.trim(),
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
  var responseCode;
  try {
    var apiCall =
        await Requests.put(hostUrl + port + '/api/student-meds/' + idValue,
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
    debugPrint(e.toString());
  }
  return responseCode;
}
