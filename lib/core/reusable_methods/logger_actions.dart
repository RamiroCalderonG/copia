import 'package:flutter/foundation.dart';
import 'package:oxschool/data/Models/Logger.dart';

import 'translate_messages.dart';

void insertActionIntoLog(
  String tittle,
  var body,
) async {
  body.toString();
  // var message = body.split(" ").elementAt(0);
  var message = getMessageToDisplay(body);

  await FileLogger.log(tittle + message.toString());
}

void insertErrorLog(String message, String? action) async {
  await FileLogger.log('>>ERROR: $message, $action');
}

void insertAlertLog(String message) async {
  await FileLogger.log('>>ALERT: $message');
}

void revealLoggerFileLocation() async {
  final logPath = await FileLogger.getLogFilePath();
  if (kDebugMode) {
    print('Log file located at: $logPath');
  }
}
