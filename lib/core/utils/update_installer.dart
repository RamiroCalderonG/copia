import 'dart:io';
//import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ftpconnect/ftpconnect.dart';

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
String pcPath =  '10.23.2.99';//dotenv.env['MACOS']!;
FTPConnect ftpConnection = FTPConnect(pcPath, user: 'Client', pass: 'SAre17204_', showLog: true, securityType: SecurityType.FTPES);
  
void runMacOsUpdateScript() async {
  String directoryPath = 'shared2';
  String scriptName = 'update.sh';
  //String localScriptPath = '/tmp/$scriptName';
  String downloadDirectory = "/Users/${Platform.environment['USER']}/Downloads/update.sh";

  try {
    await _downloadWithRetry();

    // Execute the downloaded script
    ProcessResult result = await Process.run('sh', [downloadDirectory], runInShell: true);
    if (result.exitCode != 0) {
      print("Script execution failed: ${result.stderr}");
    } else {
      print("Script executed successfully: ${result.stdout}");
    }

    // Delete the script file
    File(downloadDirectory).deleteSync();
    print("Script file deleted: $downloadDirectory");

  } catch (e) {
    ftpConnection.disconnect();
    print("Error: $e");
  }
}

Future<File> fileMock({fileName = 'update.sh', content = ''}) async {  
  try {
    String downloadDirectory = "/Users/${Platform.environment['USER']}/Downloads";
  final Directory directory = Directory(downloadDirectory)..createSync(recursive: true);
  final File file = File('${directory.path}/$fileName');
  await file.writeAsString(content);
  return file;
  } catch (e) {
   print(e.toString());
    rethrow; 
  }
  
}

Future<void> _downloadWithRetry() async {
  try {
    String fileName = 'update.sh';
    String remoteFilePath = '/Downloads/$fileName';
    await ftpConnection.connect();
    print('Connected to FTP server.');

    File downloadedFile = await fileMock(fileName: fileName);
    print('Local file created at: ${downloadedFile.path}');

    bool res = await ftpConnection.downloadFileWithRetry(
      remoteFilePath,
      downloadedFile,
      pRetryCount: 2,
      onProgress: (progressInPercent, totalReceived, fileSize) {
        print('Progress: $progressInPercent%, received: $totalReceived bytes, fileSize: $fileSize bytes');
      },
    );

    if (res) {
      print('File downloaded successfully to: ${downloadedFile.path}');
    } else {
      print('File download failed.');
    }

    await ftpConnection.disconnect();
    print('Disconnected from FTP server.');
  } catch (e) {
    await ftpConnection.disconnect();
    print('Downloading FAILED: ${e.toString()}');
  }
}



// Cleanup function to remove the local mount path
Future<void> cleanup(String localMountPath) async {
  print("Cleaning up: Unmounting and removing $localMountPath");
  await Process.run('umount', [localMountPath], runInShell: true);
  await Process.run('rm', ['-rf', localMountPath], runInShell: true);
}

//!NOT WORKING YET FOR ANDROID AND IOS, PENDING TO DEVELOP
