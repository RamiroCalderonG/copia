import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oxschool/core/constants/version.dart';
import 'package:oxschool/core/utils/update_installer.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:updat/theme/chips/default_with_check_for.dart';
import 'package:updat/updat.dart';
import 'package:updat/updat_window_manager.dart';
import 'package:url_launcher/url_launcher.dart';
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
          String downloadUrl = getDownloadUrl(data);
          if (downloadUrl.isNotEmpty) {
            showUpdateDialog(context, downloadUrl);
          }
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

  static void showUpdateDialog(BuildContext context, String downloadUrl) {
    showDialog(
      context: context,
      builder: (context) => 
      UpdatWindowManager(
      getLatestVersion: () async {
        // Github gives us a super useful latest endpoint, and we can use it to get the latest stable release
        final response = await http.get(Uri.parse(
          "https://api.github.com/repos/ericksanr/OXSClientSideREST/releases",
        ),
        headers: {
          'Authorization' : 'Bearer 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'
        }
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data["name"];
        } else {
          throw Exception("Failed to fetch latest version: ${response.statusCode}");
        }
      },
       
      getBinaryUrl: (version) async {
        // Github also gives us a great way to download the binary for a certain release (as long as we use a consistent naming scheme)

        // Make sure that this link includes the platform extension with which to save your binary.
        // If you use https://exapmle.com/latest/macos for instance then you need to create your own file using `getDownloadFileLocation`
        return "https://github.com/ericksanr/OXSClientSideREST/releases/download/$version/sidekick-${Platform.operatingSystem}-$version.$platformExt";
      },
      appName: "Update Oxschool", // This is used to name the downloaded files.
      /* getChangelog: (_, __) async {
        // That same latest endpoint gives us access to a markdown-flavored release body. Perfect!
        final data = await http.get(Uri.parse(
          "https://api.github.com/repos/fluttertools/sidekick/releases/latest",
        ));
        return jsonDecode(data.body)["body"];
      }, */
      updateChipBuilder: defaultChipWithCheckFor,
      currentVersion: '0.0.1',
      callback: (status) {},
      child: Scaffold(
        /*floatingActionButton: UpdatWidget(
          getLatestVersion: () async {
            // Github gives us a super useful latest endpoint, and we can use it to get the latest stable release
            final data = await http.get(Uri.parse(
              "https://api.github.com/repos/fluttertools/sidekick/releases/latest",
            ));
    
            // Return the tag name, which is always a semantically versioned string.
            return jsonDecode(data.body)["tag_name"];
          },
          getBinaryUrl: (version) async {
            // Github also gives us a great way to download the binary for a certain release (as long as we use a consistent naming scheme)
    
            // Make sure that this link includes the platform extension with which to save your binary.
            // If you use https://exapmle.com/latest/macos for instance then you need to create your own file using `getDownloadFileLocation`
            return "https://github.com/fluttertools/sidekick/releases/download/$version/sidekick-${Platform.operatingSystem}-$version.$platformExt";
          },
          appName: "Updat Example", // This is used to name the downloaded files.
          getChangelog: (_, __) async {
            // That same latest endpoint gives us access to a markdown-flavored release body. Perfect!
            final data = await http.get(Uri.parse(
              "https://api.github.com/repos/fluttertools/sidekick/releases/latest",
            ));
            return jsonDecode(data.body)["body"];
          },
          updateChipBuilder: floatingExtendedChipWithSilentDownload,
          currentVersion: '0.0.1',
          callback: (status) {
            print(status);
          },
        ),*/
        body: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(left: 50, right: 50),
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Actualizacion detectada",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.code_rounded),
                        onPressed: () {
                          //launchUrlString("https://github.com/aguilaair/updat");
                        },
                        label: const Text("Actualizar ahora"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.open_in_browser_rounded,
                          color: Color(0xff1890ff),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          //launchUrlString("https://pub.dev/packages/updat");
                        },
                        label: const Text(
                          "Actualizar mas tarde",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              return Colors
                                  .white; // Use the component's default.
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                      "Hello! Try customizing the update widget's display text and colors."),
                  const Divider(
                    height: 20,
                  ),
                  Wrap(
                    spacing: 40,
                    runSpacing: 20,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Change the theme:"),
                          const SizedBox(
                            height: 22,
                          ),
                          /* Switch(
                              value: ThemeModeManager.of(context)!._themeMode ==
                                  ThemeMode.dark,
                              onChanged: (value) {
                                ThemeModeManager.of(context)!.themeMode =
                                    value ? ThemeMode.dark : ThemeMode.light;
                              }), */
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
      /* AlertDialog(
        title: Text("Update Available"),
        content: Text("A new version is available. Do you want to update?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Later"),
          ),
          TextButton(
            onPressed: () async {
              runUpdateScript();
            },
            child: Text("Update"),
          ),
        ],
      ), */
    );
  }
}



/* Widget updateWWindowManagerTest() = UpdatWindowManager(
      getLatestVersion: () async {
        // Github gives us a super useful latest endpoint, and we can use it to get the latest stable release
        final data = await http.get(Uri.parse(
          "https://github.com/ericksanr/OXSClientSideREST/releases/latest",
        ),
        headers: {
          'Authorization' : 'token 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'
        }
        );

        // Return the tag name, which is always a semantically versioned string.
        return jsonDecode(data.body)["tag_name"];
      },
      getBinaryUrl: (version) async {
        // Github also gives us a great way to download the binary for a certain release (as long as we use a consistent naming scheme)

        // Make sure that this link includes the platform extension with which to save your binary.
        // If you use https://exapmle.com/latest/macos for instance then you need to create your own file using `getDownloadFileLocation`
        return "https://github.com/ericksanr/OXSClientSideREST/releases/download/$version/sidekick-${Platform.operatingSystem}-$version.$platformExt";
      },
      appName: "Updat Example", // This is used to name the downloaded files.
      /* getChangelog: (_, __) async {
        // That same latest endpoint gives us access to a markdown-flavored release body. Perfect!
        final data = await http.get(Uri.parse(
          "https://api.github.com/repos/fluttertools/sidekick/releases/latest",
        ));
        return jsonDecode(data.body)["body"];
      }, */
      //updateChipBuilder: floatingExtendedChipWithSilentDownload,
      currentVersion: '0.0.1',
      callback: (status) {},
      child: Scaffold(
        /*floatingActionButton: UpdatWidget(
          getLatestVersion: () async {
            // Github gives us a super useful latest endpoint, and we can use it to get the latest stable release
            final data = await http.get(Uri.parse(
              "https://api.github.com/repos/fluttertools/sidekick/releases/latest",
            ));
    
            // Return the tag name, which is always a semantically versioned string.
            return jsonDecode(data.body)["tag_name"];
          },
          getBinaryUrl: (version) async {
            // Github also gives us a great way to download the binary for a certain release (as long as we use a consistent naming scheme)
    
            // Make sure that this link includes the platform extension with which to save your binary.
            // If you use https://exapmle.com/latest/macos for instance then you need to create your own file using `getDownloadFileLocation`
            return "https://github.com/fluttertools/sidekick/releases/download/$version/sidekick-${Platform.operatingSystem}-$version.$platformExt";
          },
          appName: "Updat Example", // This is used to name the downloaded files.
          getChangelog: (_, __) async {
            // That same latest endpoint gives us access to a markdown-flavored release body. Perfect!
            final data = await http.get(Uri.parse(
              "https://api.github.com/repos/fluttertools/sidekick/releases/latest",
            ));
            return jsonDecode(data.body)["body"];
          },
          updateChipBuilder: floatingExtendedChipWithSilentDownload,
          currentVersion: '0.0.1',
          callback: (status) {
            print(status);
          },
        ),*/
        body: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(left: 50, right: 50),
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Updat Flutter Demo",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.code_rounded),
                        onPressed: () {
                          launchUrlString("https://github.com/aguilaair/updat");
                        },
                        label: const Text("View the code"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.open_in_browser_rounded,
                          color: Color(0xff1890ff),
                        ),
                        onPressed: () {
                          launchUrlString("https://pub.dev/packages/updat");
                        },
                        label: const Text(
                          "View the Package",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return Colors
                                  .white; // Use the component's default.
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                      "Hello! Try customizing the update widget's display text and colors."),
                  const Divider(
                    height: 20,
                  ),
                  Wrap(
                    spacing: 40,
                    runSpacing: 20,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Change the theme:"),
                          const SizedBox(
                            height: 22,
                          ),
                          Switch(
                              value: ThemeModeManager.of(context)!._themeMode ==
                                  ThemeMode.dark,
                              onChanged: (value) {
                                ThemeModeManager.of(context)!.themeMode =
                                    value ? ThemeMode.dark : ThemeMode.light;
                              }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
 */
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
