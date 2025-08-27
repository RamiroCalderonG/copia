import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:path_provider/path_provider.dart';

/*
 * Widget that downloads latest version 
 * Then open zip file and execute update script
 * Only works for Windows and MacOS for now
 */
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
        }
        if (Platform.isWindows) {
          // Get the temporary directory
          tempDir = await getTemporaryDirectory();
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
            'Authorization': 'Bearer ${dotenv.env['GITHUBHEADER']!}',
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
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1024;

    // Responsive values
    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 16.0);
    final verticalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    final cardPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 24.0);
    final titleFontSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 18.0);
    final spacingBetweenSections = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.system_update, size: isDesktop ? 28 : 24),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                "Actualización en curso",
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine layout based on screen size
            if (isDesktop && constraints.maxWidth > 1200) {
              return _buildDesktopLayout(theme, horizontalPadding,
                  verticalPadding, cardPadding, spacingBetweenSections);
            } else if (isTablet) {
              return _buildTabletLayout(theme, horizontalPadding,
                  verticalPadding, cardPadding, spacingBetweenSections);
            } else {
              return _buildMobileLayout(theme, horizontalPadding,
                  verticalPadding, cardPadding, spacingBetweenSections);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, double horizontalPadding,
      double verticalPadding, double cardPadding, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        children: [
          // Main update content
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: StreamBuilder<double>(
                stream: _isUnzipping
                    ? _unzipProgressController.stream
                    : _progressController.stream,
                builder: (context, snapshot) {
                  if (_showWaitMessage) {
                    return _buildWaitingState();
                  } else if (snapshot.hasData) {
                    return _buildProgressState(snapshot.data!);
                  } else if (snapshot.hasError) {
                    setState(() {
                      _showWaitMessage = false;
                    });
                    return _buildErrorState(snapshot.error.toString());
                  } else {
                    return _buildInitialState();
                  }
                },
              ),
            ),
          ),

          SizedBox(height: spacing),

          // Console logs section
          Expanded(
            flex: 2,
            child: _buildConsoleSection(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(ThemeData theme, double horizontalPadding,
      double verticalPadding, double cardPadding, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        children: [
          // Main update content
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: StreamBuilder<double>(
                stream: _isUnzipping
                    ? _unzipProgressController.stream
                    : _progressController.stream,
                builder: (context, snapshot) {
                  if (_showWaitMessage) {
                    return _buildWaitingState();
                  } else if (snapshot.hasData) {
                    return _buildProgressState(snapshot.data!);
                  } else if (snapshot.hasError) {
                    setState(() {
                      _showWaitMessage = false;
                    });
                    return _buildErrorState(snapshot.error.toString());
                  } else {
                    return _buildInitialState();
                  }
                },
              ),
            ),
          ),

          SizedBox(height: spacing),

          // Console logs section
          Expanded(
            flex: 3,
            child: _buildConsoleSection(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, double horizontalPadding,
      double verticalPadding, double cardPadding, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Row(
        children: [
          // Main update content
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: StreamBuilder<double>(
                stream: _isUnzipping
                    ? _unzipProgressController.stream
                    : _progressController.stream,
                builder: (context, snapshot) {
                  if (_showWaitMessage) {
                    return _buildWaitingState();
                  } else if (snapshot.hasData) {
                    return _buildProgressState(snapshot.data!);
                  } else if (snapshot.hasError) {
                    setState(() {
                      _showWaitMessage = false;
                    });
                    return _buildErrorState(snapshot.error.toString());
                  } else {
                    return _buildInitialState();
                  }
                },
              ),
            ),
          ),

          SizedBox(width: spacing),

          // Console logs section
          Expanded(
            flex: 2,
            child: _buildConsoleSection(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleSection(ThemeData theme) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1024;

    final consolePadding = isDesktop ? 20.0 : (isTablet ? 16.0 : 12.0);
    final headerPadding = isDesktop ? 20.0 : (isTablet ? 16.0 : 12.0);
    final fontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : 12.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: headerPadding, vertical: headerPadding * 0.75),
            decoration: BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isDesktop ? 16 : 12),
                topRight: Radius.circular(isDesktop ? 16 : 12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isDesktop ? 14 : 12,
                  height: isDesktop ? 14 : 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: isDesktop ? 14 : 12,
                  height: isDesktop ? 14 : 12,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: isDesktop ? 14 : 12,
                  height: isDesktop ? 14 : 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Console Output",
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(consolePadding),
              itemCount: _consoleLogs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isDesktop ? 40 : 35,
                        child: Text(
                          "${index + 1}".padLeft(3, '0'),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: 'Courier',
                            fontSize: fontSize - 1,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _consoleLogs[index],
                          style: TextStyle(
                            color: Colors.green[400],
                            fontFamily: 'Courier',
                            fontSize: fontSize - 1,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1024;

    final titleFontSize = isDesktop ? 22.0 : (isTablet ? 20.0 : 18.0);
    final subtitleFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final spacing = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: CircularProgressIndicator(
            strokeWidth: isDesktop ? 4 : 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          "Procesando actualización...",
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing / 3),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
          child: Text(
            "Por favor no cierre la aplicación",
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressState(double progress) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1024;

    final progressSize = isDesktop ? 160.0 : (isTablet ? 140.0 : 120.0);
    final strokeWidth = isDesktop ? 10.0 : (isTablet ? 9.0 : 8.0);
    final percentageFontSize = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);
    final titleFontSize = isDesktop ? 22.0 : (isTablet ? 20.0 : 18.0);
    final directoryFontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : 12.0);
    final spacing = isDesktop ? 40.0 : (isTablet ? 36.0 : 32.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust sizes based on available space
        final adjustedProgressSize =
            constraints.maxHeight < 400 ? progressSize * 0.8 : progressSize;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: adjustedProgressSize,
              height: adjustedProgressSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: adjustedProgressSize,
                    height: adjustedProgressSize,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: strokeWidth,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    "${progress.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: percentageFontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
              child: Text(
                _isUnzipping
                    ? "Extrayendo archivos..."
                    : "Descargando actualización...",
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: spacing / 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 24),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: isDesktop ? 6 : 4,
              ),
            ),
            if (directoryToDisplay.isNotEmpty) ...[
              SizedBox(height: spacing / 2),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 20 : 16,
                      vertical: isDesktop ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Directorio: $directoryToDisplay",
                    style: TextStyle(
                      fontSize: directoryFontSize,
                      color: Colors.grey[700],
                      fontFamily: 'Courier',
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: isDesktop ? 2 : 1,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1024;

    final iconSize = isDesktop ? 64.0 : (isTablet ? 56.0 : 48.0);
    final titleFontSize = isDesktop ? 22.0 : (isTablet ? 20.0 : 18.0);
    final errorFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final buttonPadding = isDesktop ? 48.0 : (isTablet ? 40.0 : 32.0);
    final spacing = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            size: iconSize,
            color: Colors.red,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          "Error en la actualización",
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing / 2),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: isDesktop ? 200 : (isTablet ? 150 : 120),
            ),
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: SingleChildScrollView(
              child: Text(
                error,
                style: TextStyle(
                  fontSize: errorFontSize,
                  color: Colors.red[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(height: spacing),
        ElevatedButton.icon(
          onPressed: () {
            runUpdateScript();
          },
          icon: Icon(Icons.refresh, size: isDesktop ? 24 : 20),
          label: Text(
            "Reintentar",
            style: TextStyle(fontSize: isDesktop ? 16 : 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: buttonPadding, vertical: isDesktop ? 20 : 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: isDesktop ? 4 : 2,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1024;

    final iconSize = isDesktop ? 64.0 : (isTablet ? 56.0 : 48.0);
    final titleFontSize = isDesktop ? 22.0 : (isTablet ? 20.0 : 18.0);
    final subtitleFontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final spacing = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 28 : 24)),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.download,
            size: iconSize,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          "Iniciando actualización...",
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing / 3),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
          child: Text(
            "Por favor espere mientras se prepara la descarga",
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: spacing),
        CustomLoadingIndicator(),
      ],
    );
  }
}
