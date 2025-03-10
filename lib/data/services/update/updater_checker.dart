import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:process_run/shell.dart';

class UpdateChecker {
  String currentVersion = '1.0.0';

  Future<void> checkForUpdate(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version; //Get current Version

    currentVersion = version;

    try {
      final response = await checkForUpdates();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['version'];
        final downloadUrl = data['downloadurl'];

        if (_isNewVersionAvailable(latestVersion)) {
          _showUpdateDialog(context, latestVersion, downloadUrl);
        }
      } else {
        print('Failed to check for updates: ${response.statusCode}');
      }
    } catch (e) {
      insertErrorLog(e.toString(), "UPDATE CHECKER ERROR: ");
      showErrorFromBackend(context, e.toString());
    }
  }

  bool _isNewVersionAvailable(String latestVersion) {
    return latestVersion.compareTo(currentVersion) > 0;
  }

  void _showUpdateDialog(
      BuildContext context, String latestVersion, String downloadUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Available"),
        content: Text(
            "A new version ($latestVersion) is available. Would you like to download it?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Later"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadAndInstall(downloadUrl);
            },
            child: Text("Update Now"),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstall(String url) async {
    final downloadPath = "${Directory.systemTemp.path}/app_update.exe";

    try {
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final file = File(downloadPath);
        await response.pipe(file.openWrite());
        print('Downloaded to $downloadPath');

        // Launch installer
        if (Platform.isWindows) {
          await Process.run(downloadPath, []);
        } else if (Platform.isMacOS) {
          await Process.run('open', [downloadPath]);
        }

        // Close the app
        restartApp();
      } else {
        print('Failed to download update: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading update: $e');
    }
  }

  void restartApp() async {
    final shell = Shell();
    await shell.run('''
    flutter run
  ''');
    exit(0);
  }
}
