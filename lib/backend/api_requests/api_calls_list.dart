import 'package:flutter/material.dart';
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

// Function to delete an allowed medicine from a student
//Pending to complete
Future<int> deleteNurseryStudent(var idValue) async {
  var postResponse;
  try {
    var apiCall = await Requests.put(hostUrl + port + '/api/student-meds/',
        // json: jsonBody, //We use a json style as body
        queryParameters: {'id': idValue},
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
        },
        persistCookies: false,
        timeoutSeconds: 7);

    apiCall.raiseForStatus();

    postResponse = apiCall.content();
    return postResponse;
  } catch (e) {
    print(e.toString());
  }
  return postResponse;
}
