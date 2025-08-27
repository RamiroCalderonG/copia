// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/version.dart';
import 'package:oxschool/core/reusable_methods/device_functions.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:oxschool/core/utils/version_updater.dart';
import 'package:oxschool/data/Models/Cycle.dart';
import 'package:oxschool/data/Models/User.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list_dio.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:flutter/material.dart';
import 'package:oxschool/presentation/Modules/login_view/recover_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/reusable_methods/logger_actions.dart';
import '../../components/confirm_dialogs.dart';
import '../../components/custom_scaffold_messenger.dart';
import '../../../core/utils/device_information.dart';
import '../../../core/config/flutter_flow/flutter_flow_util.dart';

import 'login_view_model.dart';
export 'login_view_model.dart';

class LoginViewWidget extends StatefulWidget {
  const LoginViewWidget({super.key});

  @override
  _LoginViewWidgetState createState() => _LoginViewWidgetState();
}

// ignore: prefer_typing_uninitialized_variables
var deviceIP;
bool isLoading = false;

class _LoginViewWidgetState extends State<LoginViewWidget> {
  late LoginViewModel _model;
  String currentDeviceData = '';
  static const int tapLimit = 4;
  static const int timeLimit = 3 * 60; // 3 minutes in seconds

  List<int> tapTimestamps = [];
  int remainingTime = 0;
  Timer? timer;
  //bool isDebugging = false;
  final List<String> _suggestedDomains = ['oxschool.edu.mx'];
  String? _suggestedDomain;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    UpdateChecker.checkForUpdate(context);
    _loadTapTimestamps();
    _startTimer();
    initPlatformState();
    storeCurrentDeviceIsMobile();
    isLoading = false;
    _model = createModel(context, () => LoginViewModel());

    _model.textController1 ??= TextEditingController();
    _model.textController2 ??= TextEditingController();
    _model.textController1!.addListener(() {
      final text = _model.textController1.text;
      if (text.contains('@')) {
        final atIndex = text.indexOf('@');
        final domainPart = text.substring(atIndex + 1);

        if (domainPart.isEmpty) {
          setState(() {
            _suggestedDomain = _suggestedDomains.first;
          });
        } else if (!_suggestedDomains.any((d) => d.startsWith(domainPart))) {
          setState(() {
            _suggestedDomain = null;
          });
        }
      } else {
        setState(() {
          _suggestedDomain = null;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    timer?.cancel();
    super.dispose();
  }

  void _applySuggestion() {
    if (_suggestedDomain != null) {
      final currentText = _model.textController1!.text;
      final atIndex = currentText.indexOf('@');
      if (atIndex != -1) {
        _model.textController1!.text =
            currentText.substring(0, atIndex + 1) + _suggestedDomain!;
      } else {
        _model.textController1!.text = '$currentText@${_suggestedDomain!}';
      }
      setState(() {
        _suggestedDomain = null;
      });
    }
  }

  Future<void> _loadTapTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamps = prefs.getStringList('tapTimestamps') ?? [];
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    setState(() {
      tapTimestamps = timestamps
          .map((e) => int.parse(e))
          .where((timestamp) => currentTime - timestamp <= timeLimit)
          .toList();
    });

    if (tapTimestamps.length >= tapLimit) {
      _updateRemainingTime();
    }
  }

  void _startTimer() {
    if (tapTimestamps.length >= tapLimit) {
      _updateRemainingTime();
    }
  }

  void _saveTapTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'tapTimestamps', tapTimestamps.map((e) => e.toString()).toList());
  }

  void _updateRemainingTime() {
    if (tapTimestamps.length >= tapLimit) {
      int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int oldestTap = tapTimestamps.first;
      remainingTime = timeLimit - (currentTime - oldestTap);
      if (remainingTime > 0) {
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            remainingTime--;
          });
          if (remainingTime <= 0) {
            timer.cancel();
            _loadTapTimestamps();
          }
        });
      }
    }
  }

  void _deleteTapTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('tapTimestamps');
    setState(() {
      tapTimestamps.clear();
      remainingTime = 0;
    });
  }

  String trimSpaces(String input) {
    return input.trim();
  }

  void _displayForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecoverPasswordScreen()),
    );
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            var androidInfo = await deviceInfoPlugin.androidInfo;
            deviceData = readAndroidBuildData(androidInfo);
            break;
          case TargetPlatform.iOS:
            var iosInfo = await deviceInfoPlugin.iosInfo;
            deviceData = readIosDeviceInfo(iosInfo);
            break;
          case TargetPlatform.linux:
            var linuxInfo = await deviceInfoPlugin.linuxInfo;
            deviceData = readLinuxDeviceInfo(linuxInfo);
            break;
          case TargetPlatform.windows:
            var windowsInfo = await deviceInfoPlugin.windowsInfo;
            deviceData = readWindowsDeviceInfo(windowsInfo);
            break;
          case TargetPlatform.macOS:
            var macOsInfo = await deviceInfoPlugin.macOsInfo;
            deviceData = readMacOsDeviceInfo(macOsInfo);
            break;
          case TargetPlatform.fuchsia:
            deviceData = <String, dynamic>{
              'Error:': 'Fuchsia platform isn\'t supported'
            };
            break;
        }

        currentDeviceData = deviceData.toString();
        SharedPreferences devicePrefs = await SharedPreferences.getInstance();
        devicePrefs.setString('device', currentDeviceData);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    await fetchDeviceIp();

    if (!mounted) return;

    currentDeviceData = deviceData.toString();
    setState(() {
      deviceInformation = deviceData;
    });
  }

  Future<void> fetchDeviceIp() async {
    deviceIP = await getDeviceIP();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      key: scaffoldKey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background-header.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Container(
            color: Colors.black.withOpacity(0.1),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 40,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 450,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 32),
                        _buildLoginForm(theme, colorScheme, isMobile),
                        const SizedBox(height: 24),
                        _buildVersionInfo(theme, colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: isLoading
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: colorScheme.surface,
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            )
          : null,
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/1_OS_color.png',
        width: 180,
        height: 180,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildLoginForm(
      ThemeData theme, ColorScheme colorScheme, bool isMobile) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Ox School',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tus datos de acceso',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Email Field
            TextFormField(
              controller: _model.textController1,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                hintText: 'usuario@oxschool.edu.mx',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: colorScheme.primary,
                ),
                suffix: _suggestedDomain != null
                    ? GestureDetector(
                        onTap: _applySuggestion,
                        child: Text(
                          '@$_suggestedDomain',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                counterText: '',
              ),
              validator: _model.textController1Validator.asValidator(context),
            ),
            const SizedBox(height: 20),

            // Password Field
            TextFormField(
              controller: _model.textController2,
              textInputAction: TextInputAction.done,
              obscureText: !_model.passwordVisibility,
              maxLength: 50,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText: 'Ingresa tu contraseña',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _model.passwordVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: () => setState(() {
                    _model.passwordVisibility = !_model.passwordVisibility;
                  }),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                counterText: '',
              ),
              validator: _model.textController2Validator.asValidator(context),
              onFieldSubmitted: (_) async {
                isLoading ? null : await _handleLogin();
              },
            ),
            const SizedBox(height: 32),

            // Login Button
            FilledButton(
              onPressed: () async {
                isLoading ? null : await _handleLogin();
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    FlutterFlowTheme.of(context).primary, //colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      color: colorScheme.primary,
                    )
                  : Text(
                      'Ingresar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            // Forgot Password Button
            TextButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _displayForgotPassword(context);
                setState(() {
                  isLoading = false;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      // decoration: BoxDecoration(
      //   color: Colors.white.withOpacity(0.1),
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: Colors.white.withOpacity(0.2),
      //     width: 1,
      //   ),
      // ),
      child: Column(
        children: [
          Text(
            'Versión $current_version',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: () {
              UpdateChecker.manuallyUpdate(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Actualizar Manualmente',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // if (isDebugging) ...[
          //   const SizedBox(height: 8),
          //   Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //     decoration: BoxDecoration(
          //       color: Colors.orange.withOpacity(0.2),
          //       borderRadius: BorderRadius.circular(8),
          //       border: Border.all(
          //         color: Colors.orange.withOpacity(0.3),
          //       ),
          //     ),
          //     child: Text(
          //       'MODO DEBUG',
          //       style: theme.textTheme.bodySmall?.copyWith(
          //         color: Colors.orange,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_model.textController1!.text.isEmpty ||
        _model.textController2!.text.isEmpty) {
      showEmptyFieldAlertDialog(context,
          'Verificar información, usuario y/o contraseña no pueden estar en blanco');
      return;
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Map<String, dynamic> apiBody = {};

    // Remove timestamps older than the time limit
    tapTimestamps = tapTimestamps
        .where((timestamp) => currentTime - timestamp <= timeLimit)
        .toList();

    if (tapTimestamps.length < tapLimit) {
      tapTimestamps.add(currentTime);
      _saveTapTimestamps();
      _updateRemainingTime();

      try {
        setState(() {
          isLoading = true;
        });

        var value = trimSpaces(_model.textController2!.text);
        var emailValue = trimSpaces(_model.textController1!.text).toLowerCase();

        Map<String, dynamic> nip = {'password': value};
        apiBody.addEntries(nip.entries);
        Map<String, dynamic> employeeNumber = {
          'email': _model.textController1!.text.toLowerCase()
        };
        apiBody.addEntries(employeeNumber.entries);
        Map<String, dynamic> device = {'device': deviceInformation};
        apiBody.addEntries(device.entries);
        Map<String, dynamic> deviceIp = {'local': deviceIP};
        apiBody.addEntries(deviceIp.entries);

        SharedPreferences devicePrefs = await SharedPreferences.getInstance();
        devicePrefs.setString('ip', deviceIP);

        if (value.isNotEmpty && emailValue.isNotEmpty) {
          // Attempt login
          var apiResponse = await loginUser(apiBody);
          Map<String, dynamic> jsonData = apiResponse.data;
          devicePrefs.setString(
              'token', 'Bearer ${jsonData['token']}'); // Store token
          devicePrefs.setInt('idSession', jsonData['idSession']);

          // GET user data
          apiResponse = await getCurrentUserData(
              devicePrefs.getString('token')!); // Get user information
          jsonData = apiResponse.data; //json.decode(apiResponse.data);

          currentUser = User.fromJson(jsonData);

          // GET USER ROLE AND PERMISSIONS
          await getRoleListOfPermissions(jsonData);
          await getUserAccessRoutes();

          apiResponse = await getCycle(1);
          if (apiResponse != null) {
            Map<String, dynamic> jsonList = apiResponse.data;
            currentCycle = getcurrentCycle(jsonList);
          }

          if (currentCycle != null) {
            if (Platform.isAndroid || Platform.isIOS) {
              context.goNamed(
                'MobileMainView',
                extra: <String, dynamic>{
                  kTransitionInfoKey: const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                  ),
                },
              );
            } else {
              context.goNamed(
                'MainWindow',
                extra: <String, dynamic>{
                  kTransitionInfoKey: const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                  ),
                },
              );
              _deleteTapTimestamps();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(customScaffoldMesg(
                context,
                'Error en conección, vuelva a intentar Code: Cycle',
                null));
          }
        } else {
          _model.textController2!.text = '';
          showEmptyFieldAlertDialog(context,
              'Verificar información, usuario y/o contraseña no pueden estar en blanco');
        }
      } catch (e) {
        insertErrorLog(e.toString(), 'LOGIN BUTTON');
        showErrorFromBackend(context, e.toString());
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      insertAlertLog('ANTISPAM ACTIVATED ON: LOGIN SCREEN');
      // Show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, espere ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')} minutos antes de volver a intentar, Code: 429',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Sora'),
          ),
        ),
      );
    }
  }
}

// Global functions
Cycle getcurrentCycle(Map<String, dynamic> jsonList) {
  late Cycle currentCycle;

  String claCiclo = jsonList['cycle'];
  String fecIniCiclo = jsonList['initialDate'];
  String fecFinCiclo = jsonList['finalDate'];

  currentCycle = Cycle(claCiclo, fecIniCiclo, fecFinCiclo);

  return currentCycle;
}
