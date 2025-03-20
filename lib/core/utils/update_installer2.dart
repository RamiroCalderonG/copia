import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';


class UpdateInstaller extends StatefulWidget {
  const UpdateInstaller({super.key});

  @override
  _UpdateInstallerState createState() => _UpdateInstallerState();
}

class _UpdateInstallerState extends State<UpdateInstaller> {
  final StreamController<double> _progressController = StreamController<double>();
  

  @override
  void dispose() {
    _progressController.close();
    super.dispose();
  }

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

    Directory tempDir = await getApplicationDocumentsDirectory();
    String savepath = "${tempDir.path}/$platformPackageName";

      // Download the zip file
      String downloadDirectory = "/Users/${Platform.environment['USER']}/Downloads";
      String zipFilePath = path.join(downloadDirectory, platformPackageName);
      await downloadFile(urlDownloadLink, savepath);

      // Unzip the file
      await unzipFile(savepath, tempDir.path);

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

  Future<void> downloadFile(String url, String filePath) async {
    Dio dio = Dio();
    try {
      await dio.download(
        url,
        filePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer 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',
            'Accept': 'application/octet-stream'
          },
        ),
        onReceiveProgress: (count, total) {
          double progress = (count / total) * 100;
          _progressController.add(progress);
          print("Progress: ${progress.toStringAsFixed(0)}%");
        },
      );
      print("Download completed: $filePath");
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
        result = await Process.run('cmd.exe', ['/c', 'start', scriptPath], runInShell: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Installer"),
      ),
      body: Center(
        child: StreamBuilder<double>(
          stream: _progressController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(value: snapshot.data! / 100),
                  SizedBox(height: 20),
                  Text("${snapshot.data!.toStringAsFixed(0)}%"),
                ],
              );
            } else {
              return ElevatedButton(
                onPressed: runUpdateScript,
                child: Text("Start Update"),
              );
            }
          },
        ),
      ),
    );
  }
}