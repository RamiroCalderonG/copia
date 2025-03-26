import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_util.dart';
import 'package:oxschool/core/utils/_update_installer.dart';
import 'package:oxschool/core/utils/update_installer.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'dart:io';

class UpdateChecker {
  // static const String updateUrl = "http://10.23.2.99:/Shared/update_info.json";

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await getLatestAppVersion();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;
        String latestVersion = data["version"];

        if (latestVersion.compareTo(currentVersion) > 0) {
          showUpdateDialog(context);
        }
      }
    } catch (e) {
      print("Update check failed: $e");
    }
  }

  static String getDownloadUrl(Map<String, dynamic> data) {
    if (Platform.isWindows) return data["urlWindows"];
    if (Platform.isMacOS) return data["urlMacOs"];
    if (Platform.isAndroid) return data["urlAndroid"];
    if (Platform.isIOS) return data["urlIos"];
    return "";
  }

  static void showUpdateDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
                title: Text("Update Available"),
                content:  
                    Text("A new version is available. Do you want to update?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Later"),
                  ),
                  TextButton(
                    onPressed: () async {
                      context.goNamed('UpdaterScreen', extra: <String, dynamic>{
                      kTransitionInfoKey: const TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                      ),
                    },); 
                      //runUpdateScript();
                    },
                    child: Text("Update"),
                  ),
                ],
              ));
  }
}

    String get platformExt {
  switch (Platform.operatingSystem) {
    case 'windows':
      {
        return 'msix';
      }

    case 'macos':
      {
        return 'dmg';
      }

    case 'linux':
      {
        return 'AppImage';
      }
    default:
      {
        return 'zip';
      }
  }
}
