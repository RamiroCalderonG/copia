import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

//*Works for WINDOWS AND MACOS
void runUpdateScript() {
  String scriptUrl = Platform.isWindows
      ? r'\\10.23.2.99/Shared/update.bat'
      : r'\\10.23.2.99/Shared/update.sh';

  if (Platform.isWindows) {
    Process.run('cmd.exe', ['/c', scriptUrl], runInShell: true)
        .then((ProcessResult result) {
      print("Update script executed successfully");
    }).catchError((e) {
      print("Failed to execute update script: $e");
    });
  } else if (Platform.isMacOS) {
    String networkPath = "smb://10.23.2.99/Shared/update.sh";
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
