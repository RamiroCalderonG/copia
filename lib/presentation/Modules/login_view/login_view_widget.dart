// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oxschool/data/Models/Cycle.dart';
import 'package:oxschool/data/Models/User.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/reusable_methods/logger_actions.dart';
import '../../../core/reusable_methods/translate_messages.dart';
import '../../components/confirm_dialogs.dart';
import '../../components/custom_scaffold_messenger.dart';

import '../../../core/utils/device_information.dart';
import '../../../core/utils/loader_indicator.dart';
import '../../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../../core/config/flutter_flow/flutter_flow_util.dart';
import '../../../core/config/flutter_flow/flutter_flow_widgets.dart';

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

  // late User currentUser;

  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadTapTimestamps();
    _startTimer();
    initPlatformState();
    _model = createModel(context, () => LoginViewModel());

    _model.textController1 ??= TextEditingController();
    _model.textController2 ??= TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    timer?.cancel();
    super.dispose();
  }

  _loadTapTimestamps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? timestamps = prefs.getStringList('tapTimestamps');
    if (timestamps != null) {
      setState(() {
        tapTimestamps =
            timestamps.map((timestamp) => int.parse(timestamp)).toList();
      });
      _updateRemainingTime();
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _updateRemainingTime();
      });
    });
  }

  void _updateRemainingTime() {
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (tapTimestamps.isNotEmpty) {
      int oldestTap = tapTimestamps.first;
      int timeElapsed = currentTime - oldestTap;
      remainingTime = timeLimit - timeElapsed;
    } else {
      remainingTime = 0;
    }
  }

  _saveTapTimestamps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tapTimestamps',
        tapTimestamps.map((timestamp) => timestamp.toString()).toList());
  }

  _deleteTapTimestamps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('tapTimestamps');
  }

  // Custom function to trim spaces
  String trimSpaces(String input) {
    return input.replaceAll(RegExp(r'\s+'), ''); // This removes all spaces
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            // Await the deviceInfoPlugin.androidInfo call
            var androidInfo = await deviceInfoPlugin.androidInfo;
            deviceData = await readAndroidBuildData(androidInfo);
            break;
          case TargetPlatform.iOS:
            var iosInfo = await deviceInfoPlugin.iosInfo;
            deviceData = await readIosDeviceInfo(iosInfo);
            break;
          case TargetPlatform.linux:
            var linuxInfo = await deviceInfoPlugin.linuxInfo;
            deviceData = await readLinuxDeviceInfo(linuxInfo);
            break;
          case TargetPlatform.windows:
            var windowsInfo = await deviceInfoPlugin.windowsInfo;
            deviceData = await readWindowsDeviceInfo(windowsInfo);
            break;
          case TargetPlatform.macOS:
            var macOsInfo = await deviceInfoPlugin.macOsInfo;
            deviceData = await readMacOsDeviceInfo(macOsInfo);
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
        // devicePrefs.setString('ip', deviceIP);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    FetchDeviceIp();

    if (!mounted) return;

    currentDeviceData = deviceData.toString();
    setState(() {
      deviceData = deviceData;
      currentDeviceData = deviceData.toString();
      deviceInformation = deviceData;
    });
  }

  @override
  Widget build(BuildContext context) {
    // String? _text;
    Map<String, dynamic> apiBody = {};
    // ignore: prefer_typing_uninitialized_variables
    var apiResponse;

    dynamic loginButtonFunction() async {
      int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // Remove timestamps older than the time limit
      tapTimestamps = tapTimestamps
          .where((timestamp) => currentTime - timestamp <= timeLimit)
          .toList();

      if (tapTimestamps.length < tapLimit) {
        tapTimestamps.add(currentTime);
        _saveTapTimestamps();
        _updateRemainingTime();
        try {
          var value = trimSpaces(_model.textController2.text);
          var emplNumberValue = trimSpaces(_model.textController1.text);

          Map<String, dynamic> nip = {'Nip': value};
          apiBody.addEntries(nip.entries);
          Map<String, dynamic> employeeNumber = {
            'employeeNumber': _model.textController1.text
          };
          apiBody.addEntries(employeeNumber.entries);
          Map<String, dynamic> device = {'device': currentDeviceData};
          apiBody.addEntries(device.entries);
          Map<String, dynamic> deviceIp = {'ip_address': deviceIP};
          apiBody.addEntries(deviceIp.entries);
          SharedPreferences devicePrefs = await SharedPreferences.getInstance();
          devicePrefs.setString('ip', deviceIP);

          if (value.isNotEmpty && emplNumberValue.isNotEmpty) {
            apiResponse = await loginUser(apiBody);
            if (apiResponse.statusCode == 200) {
              List<dynamic> jsonList = json.decode(apiResponse.body);
              currentUser = parseLogedInUserFromJSON(jsonList);

              getUserPermissions(currentUser!.userId);

              apiResponse = await getCycle(
                  0); //CurrentCicleCall.call().timeout(Duration(seconds: 7));
              if (apiResponse != null) {
                List<dynamic> jsonList = json.decode(apiResponse);

                currentCycle = getcurrentCycle(jsonList);
              }

              if ((currentCycle != null)) {
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
              Map<String, dynamic> jsonMap = jsonDecode(apiResponse.body);
              String description = jsonMap['description'];

              var firstWord = getMessageToDisplay(description);

              showErrorFromBackend(context, firstWord);
            }

            setState(() {});
          } else {
            _model.textController2.text = '';
            showEmptyFieldAlertDialog(context,
                'Verificar información, usuario y/o contraseña no pueden estar en blanco');
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          insertErrorLog(e.toString(), 'LOGIN BUTTON');

          var displayMessage = getMessageToDisplay(e.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                displayMessage,
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Roboto',
                      color: const Color(0xFF130C0D),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              action: SnackBarAction(
                  label: 'Cerrar mensaje',
                  textColor: FlutterFlowTheme.of(context).info,
                  backgroundColor: Colors.black12,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }),
              duration: const Duration(milliseconds: 5000),
              backgroundColor: FlutterFlowTheme.of(context).secondary,
            ),
          );
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
          )),
        );
      }
      setState(() {});
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth > 600) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
          child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage('assets/images/background-header.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  SafeArea(
                    top: true,
                    child: Align(
                      alignment: const AlignmentDirectional(0.0, -1.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 32.0, 0.0, 32.0),
                              child: Container(
                                width: double.infinity,
                                height: 177.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/images/logoRedondoOx.png',
                                    width: 300.0,
                                    height: 284.0,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 12.0, 12.0, 12.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width /
                                    2, //double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    width: 2.0,
                                  ),
                                ),
                                child: Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24.0, 24.0, 24.0, 24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ox School',
                                          style: FlutterFlowTheme.of(context)
                                              .displaySmall,
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 24.0),
                                          child: Text(
                                            'Ingresa tus datos de acceso',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 16.0),
                                          child: TextFormField(
                                            autofocus: true,
                                            enableSuggestions: true,
                                            controller: _model.textController1,
                                            obscureText: false,
                                            keyboardType: TextInputType.number,
                                            maxLength: 8,
                                            decoration: InputDecoration(
                                              labelText: 'Numero de empleado',
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyLarge,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge,
                                            validator: _model
                                                .textController1Validator
                                                .asValidator(context),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 16.0),
                                          child: TextFormField(
                                            // autofocus: true,
                                            // When the user press enter or send key
                                            onFieldSubmitted: (value) async {
                                              if (_model.textController1.text !=
                                                      '' &&
                                                  _model.textController2.text !=
                                                      '') {
                                                insertActionIntoLog(
                                                    'LOG IN BY: ',
                                                    _model
                                                        .textController1.text);

                                                setState(() {
                                                  isLoading = true;
                                                });
                                                await loginButtonFunction()
                                                    .whenComplete(() {
                                                  isLoading = false;
                                                });
                                              } else {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                showEmptyFieldAlertDialog(
                                                    context,
                                                    'Verificar información, usuario y/o contraseña no pueden estar en blanco');
                                              }
                                            },
                                            controller: _model.textController2,
                                            obscureText:
                                                !_model.passwordVisibility,
                                            decoration: InputDecoration(
                                              labelText: 'Contraseña',
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyLarge,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              suffixIcon: InkWell(
                                                onTap: () => setState(
                                                  () => _model
                                                          .passwordVisibility =
                                                      !_model
                                                          .passwordVisibility,
                                                ),
                                                focusNode: FocusNode(
                                                    skipTraversal: true),
                                                child: Icon(
                                                  _model.passwordVisibility
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 22.0,
                                                ),
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge,
                                            validator: _model
                                                .textController2Validator
                                                .asValidator(context),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 16.0),
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              if (_model.textController1.text !=
                                                      '' &&
                                                  _model.textController2.text !=
                                                      '') {
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                                await loginButtonFunction()
                                                    .whenComplete(() {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                });
                                              } else {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                showEmptyFieldAlertDialog(
                                                    context,
                                                    'Verificar información, usuario y/o contraseña no pueden estar en blanco');
                                              }
                                              // setState(() {
                                              //   isLoading = true;
                                              // });
                                              // ScaffoldMessenger.of(context)
                                              //     .hideCurrentSnackBar();
                                              // insertActionIntoLog('LOG IN BY: ',
                                              //     _model.textController1.text);
                                              // revealLoggerFileLocation();
                                              // await loginButtonFunction()
                                              //     .whenComplete(() {
                                              //   setState(() {
                                              //     isLoading = false;
                                              //   });
                                              // });
                                            },
                                            text: 'Ingresar',
                                            options: FFButtonOptions(
                                              width: 370.0,
                                              height: 44.0,
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 0.0, 0.0, 0.0),
                                              iconPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color: Colors.white,
                                                      ),
                                              elevation: 3.0,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 4.0, 0.0, 4.0),
                                                child: TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    _displayForgotPassword(
                                                        context);
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Olvide mi contraseña',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Sora',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                        ),
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isLoading) CustomLoadingIndicator()
                ],
              )),
        );
      } else {
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
          child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              body: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage('assets/images/background-header.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  SafeArea(
                    top: true,
                    child: Align(
                      alignment: const AlignmentDirectional(0.0, -1.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 32.0, 0.0, 32.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 3,
                                height: 177.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    'assets/images/logoRedondoOx.png',
                                    width: 300.0,
                                    height: 284.0,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 12.0, 12.0, 12.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                // /    3, //double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    width: 2.0,
                                  ),
                                ),
                                child: Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24.0, 24.0, 24.0, 24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ox School',
                                          style: FlutterFlowTheme.of(context)
                                              .displaySmall,
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 24.0),
                                          child: Text(
                                            'Ingresa tus datos de acceso',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 16.0),
                                          child: TextFormField(
                                            autofocus: true,
                                            enableSuggestions: true,
                                            controller: _model.textController1,
                                            obscureText: false,
                                            keyboardType: TextInputType.number,
                                            maxLength: 8,
                                            decoration: InputDecoration(
                                              labelText: 'Numero de empleado',
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge,
                                            validator: _model
                                                .textController2Validator
                                                .asValidator(context),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 16.0),
                                          child: TextFormField(
                                            // autofocus: true,
                                            onFieldSubmitted: (value) async {
                                              if (_model.textController1.text !=
                                                      '' &&
                                                  _model.textController2.text !=
                                                      '') {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                await loginButtonFunction()
                                                    .whenComplete(() {
                                                  isLoading = false;
                                                });
                                              } else {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                insertActionIntoLog(
                                                    'LOG IN BY: ',
                                                    _model
                                                        .textController1.text);
                                              }
                                            },
                                            controller: _model.textController2,
                                            obscureText:
                                                !_model.passwordVisibility,
                                            decoration: InputDecoration(
                                              labelText: 'Contraseña',
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              suffixIcon: InkWell(
                                                onTap: () => setState(
                                                  () => _model
                                                          .passwordVisibility =
                                                      !_model
                                                          .passwordVisibility,
                                                ),
                                                focusNode: FocusNode(
                                                    skipTraversal: true),
                                                child: Icon(
                                                  _model.passwordVisibility
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 22.0,
                                                ),
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge,
                                            validator: _model
                                                .textController2Validator
                                                .asValidator(context),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 16.0),
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              if (_model.textController1.text !=
                                                      '' &&
                                                  _model.textController2.text !=
                                                      '') {
                                                await loginButtonFunction()
                                                    .whenComplete(() {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                });
                                              } else {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              }
                                            },
                                            text: 'Ingresar',
                                            options: FFButtonOptions(
                                              width: 370.0,
                                              height: 44.0,
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 0.0, 0.0, 0.0),
                                              iconPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color: Colors.white,
                                                      ),
                                              elevation: 3.0,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 4.0, 0.0, 4.0),
                                                child: TextButton(
                                                  onPressed: () {
                                                    _displayForgotPassword(
                                                        context);
                                                  },
                                                  child: Text(
                                                    'Olvide mi contraseña',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily: 'Sora',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                        ),
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isLoading) CustomLoadingIndicator()
                ],
              )),
        );
      }
    });
  }
}

TextEditingController _textFieldController = TextEditingController();

Future<void> _displayForgotPassword(BuildContext context) async {
  _textFieldController.text = '';
  bool isLoading = false; // Flag to track loading state

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text(
            'Recuperar contraseña',
            style: TextStyle(fontFamily: 'Sora'),
          ),
          content: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : TextFormField(
                  autofocus: true,
                  controller: _textFieldController,
                  decoration: const InputDecoration(
                    hintText: "Numero de empleado",
                    helperText: 'Ingrese su numero de empleado',
                    icon: Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un número de empleado válido';
                    }
                    return null;
                  },
                ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: isLoading
                  ? null // Disable the button when loading
                  : () async {
                      setState(() {
                        isLoading = true; // Start loading animation
                      });

                      if (_textFieldController.text.isNotEmpty ||
                          _textFieldController.text != '') {
                        var responseCode = await sendUserPasswordToMail(
                            _textFieldController.text,
                            deviceInformation.toString(),
                            deviceIP);
                        if (responseCode == 200) {
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    "Solicitud enviada",
                                    style: TextStyle(fontFamily: 'Sora'),
                                  ),
                                  content: const Text(
                                      "Si los resultados coinciden, recibirá en su correo su contraseña"),
                                  icon: (const Icon(Icons.beenhere_outlined)),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              });
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    "Error",
                                    style: TextStyle(fontFamily: 'Sora'),
                                  ),
                                  content: Text(responseCode.toString()),
                                  icon: (const Icon(Icons.error_outline)),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              });
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              icon: const Icon(Icons.error_outline),
                              title: const Text(
                                "Error",
                                style: TextStyle(fontFamily: 'Sora'),
                              ),
                              content: const Text(
                                "Por favor, ingrese un número de empleado válido",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      setState(() {
                        isLoading = false; // Stop loading animation
                      });
                    },
              child: const Text('OK'),
            ),
          ],
        );
      });
    },
  );
}

User parseLogedInUserFromJSON(List<dynamic> jsonList) {
  late User currentUser;
  // late List<dynamic> events = [];

  for (var i = 0; i < jsonList.length; i++) {
    if (i == 0) {
      int employeeNumber = jsonList[i]['NoEmpleado'];
      String employeeName = jsonList[i]['Nombre_Gafete'];
      String claUn = jsonList[i]['ClaUn'];
      String role = jsonList[i]['RoleName'];
      int userId = jsonList[i]['id'];
      String token = 'Bearer ';
      token = token + jsonList[1]['token'];
      String schoolEmail = jsonList[i]['user_email'];
      String usergenre = jsonList[i]['genre'];
      int isActive = jsonList[i]['bajalogicasino'];
      String? department = jsonList[i]['department'];
      String? position = jsonList[i]['position'];
      String? dateTime = jsonList[i]['createdAt'];
      String? birthdate = jsonList[i]['birthdate'];
      bool? isTeacher = jsonList[i]['is_teacher'];
      currentUser = User(
          claUn,
          employeeName,
          employeeNumber,
          role,
          userId,
          token,
          schoolEmail,
          usergenre,
          isActive,
          department,
          position,
          dateTime,
          birthdate,
          isTeacher);
    }
  }
  userToken = currentUser.token;
  return currentUser;
}

Cycle getcurrentCycle(List<dynamic> jsonList) {
  late Cycle currentCycle;

  for (var item in jsonList) {
    String claCiclo = item['ClaCiclo'];
    String fecIniCiclo = item['FecIniCiclo'];
    String fecFinCiclo = item['FecFinCiclo'];
    currentCycle = Cycle(claCiclo, fecIniCiclo, fecFinCiclo);
  }

  return currentCycle;
}

// ignore: non_constant_identifier_names
Future FetchDeviceIp() async {
  deviceIP = await getDeviceIP();
}
