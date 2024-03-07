import 'package:flutter/material.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/constants/connection.dart';

import 'package:requests/requests.dart';

import 'package:http/http.dart' as http;

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
    throw FormatException(e.toString());
  }
  // return responseCode;
}

Future<dynamic> getEvents(var userId) async {
  var responseCode;
  try {
    var apiCall = await Requests.put(hostUrl + port + '/api/events',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
        },
        persistCookies: false,
        timeoutSeconds: 8);

    apiCall.raiseForStatus();
    responseCode = apiCall.content();
    return responseCode;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<dynamic> getRolesList() async {
  var response;
  try {
    var apiCall = await Requests.put(hostUrl + port + '/api/roles',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
        },
        persistCookies: false,
        timeoutSeconds: 8);

    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

//TODO: IMPLEMENT ENDPOINT ON BACKEND
Future<dynamic> getUserEvents() async {
  var response;
  try {
    var apiCall = await Requests.put(hostUrl + port + '/api/user/events',
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
          'token': currentUser!.token
        },
        persistCookies: true,
        timeoutSeconds: 10);
    apiCall.raiseForStatus();
    response = apiCall.content();
    return response;
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<http.Response> getUserEvents2(int userId) async {
  try {
    Uri address = Uri(
        scheme: 'http',
        host: '10.0.0.36',
        port: 8080,
        path: '/api/user/events',
        queryParameters: {'id': '${userId.toString()}'});
    var response = http.get(address, headers: {
      'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
      'token': currentUser!.token
    });
    userEvents = response;
    return response;
  } catch (e) {
    print(e.toString());
    return throw FormatException(e.toString());
  }
}
