import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // For timestamps

class FileLogger {
  static File? _logFile;

  // Initialize the log file in the appropriate directory
  static Future<void> init() async {
    final directory = await getApplicationSupportDirectory();
    final logPath = '${directory.path}/ERPOxschool.txt';
    _logFile = File(logPath);

    if (!await _logFile!.exists()) {
      await _logFile!.create();
    }
  }

  // Write a log message to the file
  static Future<void> log(String message) async {
    if (_logFile == null) {
      await init(); // Initialize the log file if not done yet
    }

    final timestamp = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    final logMessage = '[$timestamp] $message\n';

    await _logFile!.writeAsString(logMessage, mode: FileMode.append);
  }

  // Retrieve log file path for debugging purposes
  static Future<String> getLogFilePath() async {
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}/ERPOxschool.txt';
  }
}
