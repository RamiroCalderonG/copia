import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:oxschool/core/utils/device_information.dart';
import 'package:oxschool/data/Models/Logger.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list_dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:window_size/window_size.dart";
import 'core/config/flutter_flow/flutter_flow_theme.dart';
import 'core/config/flutter_flow/flutter_flow_util.dart';
import 'core/config/flutter_flow/internationalization.dart';
import 'core/config/flutter_flow/nav/nav.dart';
import 'core/reusable_methods/logger_actions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FileLogger.init();
  insertActionIntoLog('APP STARTED, ', Platform.operatingSystem);
  revealLoggerFileLocation();
  ApiCallsDio.initialize();

  usePathUrlStrategy();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(600, 500));
  }
  await getAppCurrentVersion();

  await FlutterFlowTheme.initialize();
  await dotenv.load(fileName: "lib/core/config/oxschool.env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  @override
  void dispose() {
    removeSharedPref();
    super.dispose();
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  void removeSharedPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isUserAdmin');
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OX School',
      localizationsDelegates: const [
        // FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      // locale: _locale,
      supportedLocales: const [Locale('en'), Locale('es')],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scrollbarTheme: const ScrollbarThemeData(),
          colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          scrollbarTheme: const ScrollbarThemeData(),
          colorSchemeSeed: Colors.blue.shade800),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
