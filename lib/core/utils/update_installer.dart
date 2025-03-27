import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final StreamController<double> _progressController =
      StreamController<double>();
  final StreamController<double> _unzipProgressController =
      StreamController<double>();
  final List<String> _consoleLogs = [];
  final ScrollController _scrollController = ScrollController();
  bool _isUnzipping = false;
  bool _showWaitMessage = false;
  String directoryToDisplay = '';

  void _addLog(String message) {
    setState(() {
      _consoleLogs.add(message);
    });

    // Auto-scroll to the bottom of the console
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _progressController.close();
    _unzipProgressController.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    runUpdateScript();
  }

  void runUpdateScript() async {
    String platformPackageName = '';
    String urlDownloadLink = '';
    int assetId = 0;

    try {
      _addLog('Initiate download...');
      final response = await http.get(
        Uri.parse(dotenv.env['GITHUBREPOURL']!),
        headers: {'Authorization': 'Bearer ${dotenv.env['GITHUBHEADER']!}'},
      ).catchError((onError) {
        _addLog(onError);
        throw Future.error(onError);
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> assets = data["assets"];

        if (Platform.isWindows) {
          platformPackageName = dotenv.env['WINDOWSPLATFORMNAME']!;
        } else if (Platform.isMacOS) {
          //scriptPackage = "update.sh";
          platformPackageName = dotenv.env['MACOSPLATFORMNAME']!;
        }

        // Find download links for the .zip and .sh files
        for (var item in assets) {
          if (item["name"].toString().toLowerCase() ==
              platformPackageName.toLowerCase()) {
            urlDownloadLink = item["url"];
            break;
          }
        }
        Directory tempDir = Directory.systemTemp; // Assignement to avoid null

        if (Platform.isMacOS) {
          // Get the temporary directory
          tempDir = await getLibraryDirectory();
          if (tempDir == null) {
            throw Exception("Failed to get temporary directory");
          }
        }
        if (Platform.isWindows) {
          // Get the temporary directory
          tempDir = await getTemporaryDirectory();
          if (tempDir == null) {
            throw Exception("Failed to get temporary directory");
          }
        }

        setState(() {
          directoryToDisplay = tempDir.path;
        });
        String savepath = "${tempDir.path}/$platformPackageName";

        // Download the .zip file
        await downloadFile(urlDownloadLink, savepath);

        setState(() {
          _isUnzipping = true;
        });

        if (Platform.isMacOS) {
          //Execute script
          runAppleScript();
        }
        if (Platform.isWindows) {
          //Unzip the file
          unzipWindowsFile(savepath, tempDir.path);
          //Execute script
          runWindowsScript(tempDir.path);
        }
      } else {
        _addLog(response.body + response.statusCode.toString());
        throw Exception(
            "Failed to fetch latest version: ${response.statusCode}");
      }
    } catch (e) {
      _addLog(e.toString());
      throw Future.error(e);
    }
  }

  void runAppleScript() async {
    try {
      String scriptPath =
          "/Users/${Platform.environment['USER']}/oxsUpdaterHelper";
      await Process.run('chmod', ['+x', scriptPath], runInShell: true);
      ProcessResult result =
          await Process.run(scriptPath, [], runInShell: true);
      _addLog("Output: ${result.stdout}");
      _addLog("Error: ${result.stderr}");
    } catch (e) {
      _addLog("Failed to execute AppleScript $e");
    }
  }

  void runWindowsScript(String scriptLocation) async {
    try {
      String scriptPath = '$scriptLocation/updaterHelper.bat';
      _addLog('Executing script at: $scriptPath');

      // Check if the file exists
      if (!File(scriptPath).existsSync()) {
        _addLog('Error: Script file does not exist at $scriptPath');
        return;
      }

      // Run the script and capture output
      ProcessResult result =
          await Process.run(scriptPath, [], runInShell: true);
      _addLog('Output: ${result.stdout}');
      _addLog('Error: ${result.stderr}');

      // Check the exit code
      if (result.exitCode != 0) {
        _addLog('Script failed with exit code: ${result.exitCode}');
      } else {
        _addLog('Script executed successfully.');
      }
    } catch (e) {
      _addLog('Failed to execute Windows script: $e');
      throw Exception(e.toString());
    }
  }

  void unzipWindowsFile(String zipLocationPath, String destinationDir) async {
    try {
      //Log the start of the unzip process
      _addLog("Starting to unzip files...");

      //Validate if zip exists
      final zipFile = File(zipLocationPath);
      if (!zipFile.existsSync()) {
        _addLog("Error: Zip file not found");
        return;
      }

      // Read the zip file as bytes
      final bytes = zipFile.readAsBytesSync();

      // Decode the zip file
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extract the contents of the zip file
      for (final file in archive) {
        final fileName = '$destinationDir/${file.name}';
        if (file.isFile) {
          final outputFile = File(fileName);
          outputFile.createSync(recursive: true);
          outputFile.writeAsBytesSync(file.content as List<int>);
        } else {
          Directory(fileName).createSync(recursive: true);
        }
      }
      // Log the completion of the unzip process
      _addLog('Unzipping completed successfully to $destinationDir');
    } catch (e) {
      _addLog('Error while unzipping file: $e');
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
            'Authorization':
                'Bearer ${dotenv.env['GITHUBHEADER']!}', // 'Bearer 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',
            'Accept': 'application/octet-stream'
          },
        ),
        onReceiveProgress: (count, total) {
          double progress = (count / total) * 100;
          _progressController.add(progress);
          _addLog("Progress: ${progress.toStringAsFixed(0)}%");
        },
      );
      _addLog("Download completed: $filePath");
    } catch (e) {
      _addLog(e.toString());
      throw Exception("Failed to download file: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "\nActualización en curso, por favor espere...",
          style: TextStyle(fontFamily: 'Sora'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: StreamBuilder<double>(
                stream: _isUnzipping
                    ? _unzipProgressController.stream
                    : _progressController.stream,
                builder: (context, snapshot) {
                  if (_showWaitMessage) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
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
                      ],
                    );
                  } else if (snapshot.hasError) {
                    setState(() {
                      _showWaitMessage = false;
                    });
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(snapshot.error.toString()),
                          ElevatedButton(
                              onPressed: () {
                                runUpdateScript();
                              },
                              child: Text('Reintentar'))
                        ]);
                  } else {
                    return Center(
                        child: Column(
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
          ),
          Divider(),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _consoleLogs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 8.0),
                    child: Text(
                      _consoleLogs[index],
                      style:
                          TextStyle(color: Colors.green, fontFamily: 'Courier'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(
  //         "\nActualizacion en curso, por favor espere...",
  //         style: TextStyle(fontFamily: 'Sora'),
  //       ),
  //     ),
  //     body: Center(
  //       child: StreamBuilder<double>(
  //         stream: _isUnzipping
  //             ? _unzipProgressController.stream
  //             : _progressController.stream,
  //         builder: (context, snapshot) {
  //           if (_showWaitMessage) {
  //             return Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 CircularProgressIndicator(),
  //               ],
  //             );
  //           } else if (snapshot.hasData) {
  //             return Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 CircularProgressIndicator(value: snapshot.data! / 100),
  //                 SizedBox(height: 20),
  //                 Text("${snapshot.data!.toStringAsFixed(0)}%"),
  //               ],
  //             );
  //           } else if (snapshot.hasError) {
  //             setState(() {
  //               _showWaitMessage = false;
  //             });
  //             return Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Text(snapshot.error.toString()),
  //                   ElevatedButton(
  //                       onPressed: () {
  //                         runUpdateScript();
  //                       },
  //                       child: Text('Reintentar'))
  //                 ]);
  //           } else {
  //             return Center(
  //                 child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text('Por favor espere, actualización en curso,'),
  //                 CustomLoadingIndicator()
  //               ],
  //             ));
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }
}
