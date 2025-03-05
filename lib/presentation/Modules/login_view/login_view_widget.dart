// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oxschool/core/reusable_methods/device_functions.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:oxschool/data/Models/Cycle.dart';
import 'package:oxschool/data/Models/User.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:flutter/material.dart';
import 'package:oxschool/presentation/Modules/login_view/recover_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/reusable_methods/logger_actions.dart';
import '../../../core/reusable_methods/translate_messages.dart';
import '../../../core/reusable_methods/user_functions.dart';
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
  bool isDebugging = false;
  final List<String> _suggestedDomains = ['oxschool.edu.mx'];
  String? _suggestedDomain;

  // late User currentUser;

  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
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
        final localPart = text.substring(0, atIndex);
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
    isLoading = false;
    // _model.textController1!.dispose();
    // _model.textController2!.dispose();
    super.dispose();
  }

  void _applySuggestion() {
    if (_suggestedDomain != null) {
      final atIndex = _model.textController1.text.indexOf('@');
      if (atIndex != -1) {
        final localPart = _model.textController1.text.substring(0, atIndex);
        setState(() {
          _model.textController1.text = '$localPart@$_suggestedDomain';
          _model.textController1!.selection = TextSelection.fromPosition(
            TextPosition(offset: _model.textController1.text.length),
          );
        });
      }
    }
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

    dynamic handleLogin() async {
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
          var emailValue =
              trimSpaces(_model.textController1.text).toLowerCase();

          Map<String, dynamic> nip = {'password': value};
          apiBody.addEntries(nip.entries);
          Map<String, dynamic> employeeNumber = {
            'email': _model.textController1.text.toLowerCase()
          };
          apiBody.addEntries(employeeNumber.entries);
          Map<String, dynamic> device = {'device': currentDeviceData};
          apiBody.addEntries(device.entries);
          Map<String, dynamic> deviceIp = {'local': deviceIP};
          apiBody.addEntries(deviceIp.entries);
          SharedPreferences devicePrefs = await SharedPreferences.getInstance();
          devicePrefs.setString('ip', deviceIP);

          if (value.isNotEmpty && emailValue.isNotEmpty) {
            //Attempt login
            await loginUser(apiBody).then((response) async {
              apiResponse = response;
              List<dynamic> jsonList;
              Map<String, dynamic> jsonData = jsonDecode(apiResponse.body);
              devicePrefs.setString('token', 'Bearer ' + jsonData['token']); //Store token
              // jsonData['token'] = '';

              //GET user data
              apiResponse =
                  await getCurrentUserData(devicePrefs.getString('token')!); //Get user information
              jsonData = json.decode(apiResponse.body);

              currentUser = User.fromJson(jsonData);

              //GET USER ROLE AND PERMISSIONS
                await getRoleListOfPermissions(jsonData).whenComplete(()async{
                  await getUserAccessRoutes();
                }).catchError((error){
                  throw Future.error(error.toString);
                });
              
              //await getUserRoleAndAcces(currentUser!.roleID!);

              apiResponse = await getCycle(
                  1); //CurrentCicleCall.call().timeout(Duration(seconds: 7));
              if (apiResponse != null) {
                Map<String, dynamic> jsonList = json.decode(apiResponse.body);

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
            }).onError((error, stackTrace) {
              insertErrorLog(error.toString(), 'loginUser | $apiBody');
              showErrorFromBackend(context, error.toString());
            });
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
          showErrorFromBackend(context, e.toString());
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
                                            textInputAction:
                                                TextInputAction.next,
                                            autofocus: true,
                                            enableSuggestions: true,
                                            controller: _model.textController1,
                                            obscureText: false,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            maxLength: 50,
                                            decoration: InputDecoration(
                                              labelText: 'E-mail',
                                              suffix: _suggestedDomain != null
                                                  ? GestureDetector(
                                                      onTap: _applySuggestion,
                                                      child: Text(
                                                        '@$_suggestedDomain',
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      ),
                                                    )
                                                  : null,
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyLarge,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color.fromARGB(
                                                      206, 1, 58, 203),
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
                                                await handleLogin()
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
                                                      .secondaryBackground,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color.fromARGB(
                                                      206, 1, 58, 203),
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
                                            //
                                            onPressed: () async {
                                              if (kDebugMode &&
                                                  _model.textController1.text
                                                      .isEmpty &&
                                                  _model.textController2.text
                                                      .isEmpty) {
                                                setState(() {
                                                  isDebugging = true;
                                                  setUserDataForDebug();
                                                  isLoading = false;
                                                });
                                                if (Platform.isAndroid ||
                                                    Platform.isIOS) {
                                                  context.goNamed(
                                                      'MobileMainView',
                                                      extra: <String, dynamic>{
                                                        kTransitionInfoKey:
                                                            const TransitionInfo(
                                                          hasTransition: true,
                                                          transitionType:
                                                              PageTransitionType
                                                                  .fade,
                                                        ),
                                                      });
                                                } else {
                                                  context.goNamed(
                                                    'MainWindow',
                                                    extra: <String, dynamic>{
                                                      kTransitionInfoKey:
                                                          const TransitionInfo(
                                                        hasTransition: true,
                                                        transitionType:
                                                            PageTransitionType
                                                                .fade,
                                                      ),
                                                    },
                                                  );
                                                }
                                              } else {
                                                if (_model.textController1
                                                            .text !=
                                                        '' &&
                                                    _model.textController2
                                                            .text !=
                                                        '') {
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                  await handleLogin()
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
                                            textInputAction:
                                                TextInputAction.next,
                                            autofocus: true,
                                            enableSuggestions: true,
                                            controller: _model.textController1,
                                            obscureText: false,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            maxLength: 50,
                                            decoration: InputDecoration(
                                              labelText: 'E-mail',
                                              suffix: _suggestedDomain != null
                                                  ? GestureDetector(
                                                      onTap: _applySuggestion,
                                                      child: Text(
                                                        '@$_suggestedDomain',
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      ),
                                                    )
                                                  : null,
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color.fromARGB(
                                                      206, 1, 58, 203),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color.fromARGB(
                                                      225, 255, 0, 0),
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
                                                await handleLogin()
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
                                                      .secondaryBackground,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color.fromARGB(
                                                      206, 1, 58, 203),
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
                                              if (kDebugMode &&
                                                  _model.textController1.text
                                                      .isEmpty &&
                                                  _model.textController2.text
                                                      .isEmpty) {
                                                setState(() {
                                                  isDebugging = true;
                                                  setUserDataForDebug();
                                                  isLoading = false;
                                                });
                                                context.goNamed(
                                                  'MainWindow',
                                                  extra: <String, dynamic>{
                                                    kTransitionInfoKey:
                                                        const TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                                  },
                                                );
                                              } else {
                                                if (_model.textController1
                                                            .text !=
                                                        '' &&
                                                    _model.textController2
                                                            .text !=
                                                        '') {
                                                  await handleLogin()
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

// TextEditingController _textFieldController = TextEditingController();
bool displayTokenGenerator = true;

Future<void> _displayForgotPassword(BuildContext context) async {
  // _textFieldController.text = '';
  bool isLoading = false; // Flag to track loading state

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return RecoverPasswordScreen();
      });
    },
  );
}

/* User parseLogedInUserFromJSON(Map<String, dynamic> jsonList, String userToken) {
  late User currentUser;
  // late List<dynamic> events = [];

  // for (var i = 0; i < jsonList.length; i++) {
  // if (i == 0) {
  int employeeNumber = jsonList['employeeNumber'];
  String employeeName = jsonList['userFullName'];
  String claUn = jsonList['userCampus'];
  String role = jsonList['userRole']['name'];
  int userId = jsonList['id'];
  String token = 'Bearer ';
  token = token + userToken;
  String schoolEmail = jsonList['userMail'];
  String? usergenre = jsonList['genre'];
  int isActive = jsonList['status'];
  String? department = jsonList['userDept'];
  String? position = jsonList['userPosition'];
  //String? dateTime = jsonList[i]['createdAt'];
  //String? birthdate = jsonList[i]['birthdate'];
  bool? isTeacher = jsonList['userTeacher'];
  bool? isAdmin = jsonList['userRole']['isAdmin'];
  int roleId = jsonList['userRole']['id'];
  bool canUpdatePassword = jsonList['userCanUpdatePassword'];
  bool isAcademicCoord = jsonList['userRole']['isAcademicCoordinator'];

  currentUser = User(
      claUn,
      employeeName,
      employeeNumber,
      role,
      userId,
      token,
      schoolEmail,
      //usergenre,
      isActive,
      department,
      position,
      null,
      null,
      isTeacher,
      isAdmin,
      roleId,
      canUpdatePassword,
      isAcademicCoord);
  // }
  // }
  userToken = currentUser.token;
  return currentUser;
} */

Cycle getcurrentCycle(Map<String, dynamic> jsonList) {
  late Cycle currentCycle;

  String claCiclo = jsonList['cycle'];
  String fecIniCiclo = jsonList['initialDate'];
  String fecFinCiclo = jsonList['finalDate'];

  currentCycle = Cycle(claCiclo, fecIniCiclo, fecFinCiclo);

  return currentCycle;
}

// ignore: non_constant_identifier_names
Future FetchDeviceIp() async {
  deviceIP = await getDeviceIP();
}
