import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';


class UpdateInstaller extends StatefulWidget {
  const UpdateInstaller({super.key});

  @override
  _UpdateInstallerState createState() => _UpdateInstallerState();
}

class _UpdateInstallerState extends State<UpdateInstaller> {
  final StreamController<double> _progressController = StreamController<double>();
  final StreamController<double> _unzipProgressController = StreamController<double>();
  bool _isUnzipping = false;
  bool _showWaitMessage = false;
  String directoryToDisplay = '';

  @override
  void dispose() {
    _progressController.close();
    _unzipProgressController.close();
    super.dispose();
  }

  @override
  void initState()
  {
    super.initState();
    runUpdateScript();

  }

  void runUpdateScript() async {
  String platformPackageName = '';
  String urlDownloadLink = '';
  int assetId = 0;

  try {
    final response = await http.get(
    Uri.parse(
      "https://api.github.com/repos/ericksanr/OXSClientSideREST/releases/latest",
    ),
    headers: {
      'Authorization': 'Bearer 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'
    },
  ).catchError((onError){
    print(onError);
    throw Future.error(onError);
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<dynamic> assets = data["assets"];

    if (Platform.isWindows) {
      platformPackageName = 'windows.zip';
    } else if (Platform.isMacOS) {
      //scriptPackage = "update.sh";
      platformPackageName = "macOs.zip";
    }

    // Find download links for the .zip and .sh files
    for (var item in assets) {
      if (item["name"].toString().toLowerCase() == platformPackageName.toLowerCase()) {
        urlDownloadLink = item["url"];
        break;
      }
    }

    // Get the temporary directory
    Directory? tempDir = await getLibraryDirectory();
    if (tempDir == null) {
      throw Exception("Failed to get temporary directory");
    }
    setState(() {
      directoryToDisplay = tempDir.path;
    });
    String savepath = "${tempDir.path}/$platformPackageName";
    //String scriptFilePath = path.join(tempDir.path, scriptPackage);

    // Download the .zip file
    await downloadFile(urlDownloadLink, savepath);

    setState(() {
      _isUnzipping = true;
    });
    
    //Execute script
    runAppleScript();

  } else {
    throw Exception("Failed to fetch latest version: ${response.statusCode}");
  }
  } catch (e) {
    print(e);
    throw Future.error(e);   
  }

  
}

void runAppleScript() async {
  try {
    String scriptPath = "/Users/${Platform.environment['USER']}/oxsUpdaterHelper";
    await Process.run('chmod', ['+x', scriptPath], runInShell: true);
    ProcessResult result = await Process.run(scriptPath, [], runInShell: true);
    print("Output: ${result.stdout}");
    print("Error: ${result.stderr}");
  } catch (e) {
    print("Failed to execute AppleScript $e");
  }
}

Future<void> downloadFile(String url, String filePath) async {
  Dio dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 5000), // 5 seconds
      receiveTimeout: Duration(seconds: 30000), // 30 seconds
      responseType: ResponseType.stream,
    ),
  );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("\nActualizacion en curso, por favor espere...", style: TextStyle(fontFamily: 'Sora'),),
      ),
      body: Center(
        child: StreamBuilder<double>(
          stream: _isUnzipping ? _unzipProgressController.stream : _progressController.stream,
          builder: (context, snapshot) {
            if (_showWaitMessage) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  //Text(directoryToDisplay),
                ],
              );
            } else if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(value: snapshot.data! / 100),
                  SizedBox(height: 20),
                  Text("${snapshot.data!.toStringAsFixed(0)}%"),
                  //Text(directoryToDisplay)
                ],
              );
            } else if (snapshot.hasError){
              setState(() {
                _showWaitMessage = false;
              });
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(snapshot.error.toString()),
                  ElevatedButton(onPressed: (){
                    runUpdateScript();
                  }, child: Text('Reintentar'))
                ]
              );
            }
            else {
              return Center(child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Por favor espere, actualización en curso,'),
                  CustomLoadingIndicator()
                ],
              ));
            }
          },
        ),
      ),
    );
  }
}