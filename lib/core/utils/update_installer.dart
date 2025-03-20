import 'dart:convert';
import 'dart:io';
//import 'package:dio/dio.dart';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';


void runUpdateScript() async {
  String platformPackageName = '';
  String urlDownloadLink = '';
  int assetId = 0;

  final response = await http.get(
      Uri.parse(
        "https://api.github.com/repos/ericksanr/OXSClientSideREST/releases/latest",
      ),
      headers: {
        'Authorization': 'Bearer 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'
      });
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<dynamic> assets = data["assets"];

    if (Platform.isWindows) {
      platformPackageName = 'windows.zip';
    } else if (Platform.isMacOS) {
      platformPackageName = "macos.zip";
    }
    for (var item in assets) {
      if (item["name"].toString().toLowerCase() == platformPackageName.toLowerCase()) {
        urlDownloadLink = item["url"];
        break;
      }
    }

    // Download the zip file
    String downloadDirectory =
        "/Users/${Platform.environment['USER']}/Downloads";
    String zipFilePath = path.join(downloadDirectory, platformPackageName);
    var zipedFile = await downloadFile(urlDownloadLink, zipFilePath, platformPackageName);

    Directory tempDir = await getApplicationDocumentsDirectory();
    String savepath = tempDir.path;


    // Unzip the file
    await unzipFile(zipedFile!, savepath!);

    // Execute the script
    String scriptName = Platform.isWindows ? "update.bat" : "update.sh";
    String scriptPath = path.join(downloadDirectory, scriptName);
    await executeScript(scriptPath);

    // Delete the zip file
    File(zipFilePath).deleteSync();
    print("Zip file deleted: $zipFilePath");
  } else {
    throw Exception("Failed to fetch latest version: ${response.statusCode}");
  }
}

Future<String?> downloadFile(String url, String filePath, String fileName) async {
  try {
    Dio dio = Dio();
    Directory tempDir = await getApplicationDocumentsDirectory();
    String savepath = "${tempDir.path}/$fileName";

    //Download file
    await dio.download(url, savepath, options: Options(
      headers: {
      'Authorization': 'Bearer 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', 
      'Accept' : 'application/octet-stream'}), onReceiveProgress: (count, total) {
      print("Progress: ${((count / total) * 100).toStringAsFixed(0)}%");
    },);
    print("Download completed: $savepath");
    return savepath;

  } catch (e) {
    print(e.toString());
    throw Exception("Failed to download file: ${e.toString()}");
  }
}

Future<void> unzipFile(String zipFilePath, String destinationDir) async {
  try {
    final bytes = File(zipFilePath).readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  for (final file in archive) {
    final fileName = path.join(destinationDir, file.name);
    if (file.isFile) {
      final data = file.content as List<int>;
      File(fileName)
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory(fileName).create(recursive: true);
    }
  }
  print("File unzipped to: $destinationDir");
  } catch (e) {
    print(e.toString());
    throw Exception("Failed to unzip file: ${e.toString()}");
  }
  
}

Future<void> executeScript(String scriptPath) async {
  try {
    ProcessResult result;
    if (Platform.isWindows) {
      result = await Process.run('cmd.exe', ['/c', 'start', scriptPath],
          runInShell: true);
    } else if (Platform.isMacOS) {
      result = await Process.run('sh', [scriptPath], runInShell: true);
    } else {
      throw Exception("Unsupported platform: ${Platform.operatingSystem}");
    }

    if (result.exitCode != 0) {
      print("Script execution failed: ${result.stderr}");
    } else {
      print("Script executed successfully: ${result.stdout}");
    }

    // Close the Flutter app
    exit(0);
  } catch (e) {
    print("Error executing script: $e");
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
    String downloadDirectory = "${Platform.environment['HOME']}";
  final Directory directory = Directory(downloadDirectory)..createSync(recursive: true);
  final File file = File('${directory.path}/$fileName');
  await file.writeAsString(content);
  return file;
  } catch (e) {
   print(e.toString());
    rethrow; 
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


 