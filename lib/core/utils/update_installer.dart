import 'dart:io';
//import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//*Works for WINDOWS AND MACOS
void runUpdateScript() {
  String scriptUrl = Platform.isWindows
      ? r'\\10.23.2.99\Shared\update.bat' // Windows UNC path
      : r'//10.23.2.99/Shared/update.sh'; // Linux path

  if (Platform.isWindows) {
    Process.run('cmd.exe', ['/c', 'start', scriptUrl], runInShell: true)
        .then((ProcessResult result) {
      print("Update script executed successfully");
    }).catchError((e) {
      print("Failed to execute update script: $e");
    });
  } else if (Platform.isMacOS) {
    String networkPath = dotenv.env['MACOS_SCRIPT_URL']!;
    String localMountPath = "/Volumes/UpdateScript";
    Process.run('mkdir', ['-p', localMountPath], runInShell: true).then((_) {
      Process.run('mount_smbfs', [networkPath, localMountPath],
              runInShell: true)
          .then((_) {
        Process.run('sh', ['$localMountPath/update.sh'], runInShell: true)
            .then((ProcessResult result) {
          print("Update script executed successfully");
        }).catchError((e) {
          print("Failed to execute update script: $e");
        });
      }).catchError((e) {
        print("Failed to mount network share: $e");
      });
    });
  }
}

//!NOT WORKING YET FOR ANDROID AND IOS, PENDING TO DEVELOP
