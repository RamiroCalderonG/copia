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
    try {
      runMacOsUpdateScript();
    } catch (e) {
      print("Function runMacOsUpdateScript failed: $e");
    }




  /*   Process.run('mkdir', ['-p', localMountPath], runInShell: true).then((_) {
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
    }); */
  }
}

void runMacOsUpdateScript() async {
  String networkPath = dotenv.env['MACOS']!;
  String localMountPath = "${Platform.environment['HOME']}/tmpOxschool";
  String scriptPath = "$localMountPath/update.sh";

  try {
    // Ensure the mount directory exists
    await Process.run('mkdir', ['-p', localMountPath], runInShell: true);

    // Print the command for debugging
    print('mount_smbfs //GUEST@${networkPath} $localMountPath');

    // Mount the SMB network share as Guest
    ProcessResult mountResult = await Process.run(
      'mount_smbfs',
      ['//GUEST@${networkPath}', localMountPath], runInShell: true
    );

    if (mountResult.exitCode != 0) {
      print("Failed to mount SMB share: ${mountResult.stderr}");
      await cleanup(localMountPath);
      return;
    }
    print("SMB Share mounted successfully.");

    // Check if the update script exists
    if (!File(scriptPath).existsSync()) {
      print("Error: Update script not found at $scriptPath");
      await cleanup(localMountPath);
      return;
    }

    // Give execute permissions to the script
    await Process.run('chmod', ['+x', scriptPath]);

    // Run the update script
    ProcessResult result = await Process.run(scriptPath, [], runInShell: true);
    if (result.exitCode != 0) {
      print("Update script execution failed: ${result.stderr}");
      await cleanup(localMountPath);
      return;
    }

    print("Update script executed successfully.");
  } catch (e) {
    print("Error: $e");
    await cleanup(localMountPath);
  }
}

// Cleanup function to remove the local mount path
Future<void> cleanup(String localMountPath) async {
  print("Cleaning up: Unmounting and removing $localMountPath");
  await Process.run('umount', [localMountPath], runInShell: true);
  await Process.run('rm', ['-rf', localMountPath], runInShell: true);
}

//!NOT WORKING YET FOR ANDROID AND IOS, PENDING TO DEVELOP
