import 'package:flutter/material.dart';
import 'package:oxschool/constants/connection.dart';

import 'package:requests/requests.dart';

Future<int> postNurseryVisit(var jsonBody) async {
  var postResponse;
  try {
    var apiCall = await Requests.post(hostUrl + port + '/api/nursery-visit/',
        json: jsonBody, //We use a json style as body
        headers: {
          'X-Embarcadero-App-Secret': x_Embarcadero_App_Secret,
        },
        // port: 8081,
        persistCookies: false,
        timeoutSeconds: 7);
    // bodyEncoding: RequestBodyEncoding.FormURLEncoded);

    apiCall.raiseForStatus();

    // await Future.delayed(Duration(seconds: 3));

    postResponse = apiCall.content();

    print('New Record ID from server: $postResponse');

    return postResponse;

    // return postResponse;
  } catch (e) {
    print(e.toString());
  }
  return postResponse;
}
