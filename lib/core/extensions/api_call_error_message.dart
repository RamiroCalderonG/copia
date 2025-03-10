import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:requests/requests.dart';

extension ApiErrorHandler on Exception {
  /// Returns a user-friendly error message based on the type of exception.
  String getErrorMessage() {
    if (this is TimeoutException) {
      return 'The request timed out. Please try again later.';
    } else if (this is SocketException) {
      return 'Unable to connect to the server. Please check your internet connection.';
    } else if (this is HTTPException) {
      final httpException = this as HTTPException;
      String jsonString = httpException.response.body.substring(
          httpException.response.body.indexOf('{'),
          httpException.response.body.lastIndexOf('}') + 1);
      // Parse the JSON string
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      // Retrieve the "description" and "status"
      String description = jsonData["description"];
      int status = jsonData["status"];

      return '$description ,Status: $status';
    } else {
      return 'An unexpected error occurred: ${this.toString()}';
    }
  }
}
