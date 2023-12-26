import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oxschool/Models/Cycle.dart';
import 'package:oxschool/Models/User.dart';
import 'package:oxschool/constants/User.dart';

import '../utils/device_information.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'login_view_model.dart';
export 'login_view_model.dart';

class LoginViewWidget extends StatefulWidget {
  const LoginViewWidget({Key? key}) : super(key: key);

  @override
  _LoginViewWidgetState createState() => _LoginViewWidgetState();
}

class _LoginViewWidgetState extends State<LoginViewWidget> {
  late LoginViewModel _model;
  String currentDeviceData = '';
  // late User currentUser;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _model = createModel(context, () => LoginViewModel());

    _model.textController1 ??= TextEditingController();
    _model.textController2 ??= TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
            readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS =>
            readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.linux =>
            readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          TargetPlatform.windows =>
            readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS =>
            readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          TargetPlatform.fuchsia => <String, dynamic>{
              'Error:': 'Fuchsia platform isn\'t supported'
            },
        };
        currentDeviceData = deviceData.toString();
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;
    print(deviceData.toString());
    currentDeviceData = deviceData.toString();
    setState(() {
      deviceData = deviceData;
      currentDeviceData = deviceData.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    String? _text;
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, -1.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 32.0),
                    child: Container(
                      width: double.infinity,
                      height: 177.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
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
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          width: 2.0,
                        ),
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 24.0, 24.0, 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ox School',
                                style:
                                    FlutterFlowTheme.of(context).displaySmall,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 24.0),
                                child: Text(
                                  'Ingresa tus datos de acceso',
                                  style:
                                      FlutterFlowTheme.of(context).labelMedium,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: TextFormField(
                                  controller: _model.textController1,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintStyle:
                                        FlutterFlowTheme.of(context).bodyLarge,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context).bodyLarge,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: TextFormField(
                                  onFieldSubmitted: (value) async {
                                    try {
                                      var value = trimSpaces(
                                          _model.textController2.text);
                                      if (value.isNotEmpty) {
                                        // Log In user
                                        _model.apiResultxgr =
                                            await LoginUserCall.call(
                                                nip:
                                                    _model.textController2.text,
                                                device: currentDeviceData);
                                        if ((_model.apiResultxgr?.succeeded ??
                                            true)) {
                                          // Decode the JSON string into a Dart list
                                          List<dynamic> jsonList = json.decode(
                                              _model.apiResultxgr!.response!
                                                  .body);
                                          currentUser = userLogedIn(
                                              jsonList); //Store values into a const

                                          // Get currentCycle
                                          _model.apiResultxgr =
                                              await CurrentCicleCall.call();
                                          if ((_model.apiResultxgr?.succeeded ??
                                              true)) {
                                            jsonList = json.decode(_model
                                                .apiResultxgr!.response!.body);
                                            currentCycle = getcurrentCycle(
                                                jsonList); //parse from JSON
                                          }
                                          //GET User Permissions
                                          _model.apiResultxgr =
                                              await UserPermissionsCall.call(
                                                  idLogin: currentUser!.idLogin
                                                      .toString());
                                          if ((_model.apiResultxgr?.succeeded ??
                                              true)) {
                                            jsonList = json.decode(_model
                                                .apiResultxgr!.response!.body);
                                            userPermissions = jsonList;
                                          }

                                          context.goNamed(
                                            'MainWindow',
                                            extra: <String, dynamic>{
                                              kTransitionInfoKey:
                                                  TransitionInfo(
                                                hasTransition: true,
                                                transitionType:
                                                    PageTransitionType.fade,
                                              ),
                                            },
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                (_model.apiResultxgr
                                                            ?.jsonBody ??
                                                        '')
                                                    .toString(),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily: 'Roboto',
                                                          color:
                                                              Color(0xFF130C0D),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                              action: SnackBarAction(
                                                  label: 'Cerrar mensaje',
                                                  textColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .info,
                                                  backgroundColor:
                                                      Colors.black12,
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .hideCurrentSnackBar();
                                                  }),
                                              duration:
                                                  Duration(milliseconds: 9000),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                            ),
                                          );
                                        }

                                        setState(() {});
                                      } else {
                                        _model.textController2.text = '';
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Favor de verificar su contraseña',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily: 'Roboto',
                                                    color: Color(0xFF130C0D),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            action: SnackBarAction(
                                                label: 'Cerrar mensaje',
                                                textColor:
                                                    FlutterFlowTheme.of(context)
                                                        .info,
                                                backgroundColor: Colors.black12,
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                }),
                                            duration:
                                                Duration(milliseconds: 9000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      // _model.textController2.text = '';
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString(),
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Roboto',
                                                  color: Color(0xFF130C0D),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          action: SnackBarAction(
                                              label: 'Cerrar mensaje',
                                              textColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              backgroundColor: Colors.black12,
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                              }),
                                          duration:
                                              Duration(milliseconds: 9000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondary,
                                        ),
                                      );
                                    }
                                  },
                                  controller: _model.textController2,
                                  obscureText: !_model.passwordVisibility,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    hintStyle:
                                        FlutterFlowTheme.of(context).bodyLarge,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    suffixIcon: InkWell(
                                      onTap: () => setState(
                                        () => _model.passwordVisibility =
                                            !_model.passwordVisibility,
                                      ),
                                      focusNode: FocusNode(skipTraversal: true),
                                      child: Icon(
                                        _model.passwordVisibility
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 22.0,
                                      ),
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context).bodyLarge,
                                  validator: _model.textController2Validator
                                      .asValidator(context),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    context.goNamed(
                                      'MainWindow',
                                      extra: <String, dynamic>{
                                        kTransitionInfoKey: TransitionInfo(
                                          hasTransition: true,
                                          transitionType:
                                              PageTransitionType.fade,
                                        ),
                                      },
                                    );

                                    var value =
                                        trimSpaces(_model.textController2.text);

                                    if (value.isNotEmpty || value.length >= 6) {
                                      initPlatformState();
                                      if (currentUser?.employeeNumber != null) {
                                        currentUser?.clear();
                                      }
                                      // Log In user
                                      _model.apiResultxgr =
                                          await LoginUserCall.call(
                                              nip: _model.textController2.text,
                                              device: currentDeviceData);
                                      if ((_model.apiResultxgr?.succeeded ??
                                          true)) {
                                        // Decode the JSON string into a Dart list
                                        List<dynamic> jsonList = json.decode(
                                            _model
                                                .apiResultxgr!.response!.body);
                                        currentUser = userLogedIn(
                                            jsonList); //Store values into a const

                                        if (currentCycle?.claCiclo != null) {
                                          currentCycle?.clear();
                                        }

                                        // Get currentCycle
                                        _model.apiResultxgr =
                                            await CurrentCicleCall.call();
                                        if ((_model.apiResultxgr?.succeeded ??
                                            true)) {
                                          jsonList = json.decode(_model
                                              .apiResultxgr!.response!.body);
                                          currentCycle = getcurrentCycle(
                                              jsonList); //parse from JSON
                                        }
                                        //GET User Permissions
                                        _model.apiResultxgr =
                                            await UserPermissionsCall.call(
                                                idLogin: currentUser!.idLogin
                                                    .toString());
                                        if ((_model.apiResultxgr?.succeeded ??
                                            true)) {
                                          jsonList = json.decode(_model
                                              .apiResultxgr!.response!.body);
                                          userPermissions = jsonList;
                                        }

                                        context.goNamed(
                                          'MainWindow',
                                          extra: <String, dynamic>{
                                            kTransitionInfoKey: TransitionInfo(
                                              hasTransition: true,
                                              transitionType:
                                                  PageTransitionType.fade,
                                            ),
                                          },
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              (_model.apiResultxgr?.jsonBody ??
                                                      '')
                                                  .toString(),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily: 'Roboto',
                                                    color: Color(0xFF130C0D),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            action: SnackBarAction(
                                                label: 'Cerrar mensaje',
                                                textColor:
                                                    FlutterFlowTheme.of(context)
                                                        .info,
                                                backgroundColor: Colors.black12,
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                }),
                                            duration:
                                                Duration(milliseconds: 9000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }

                                      setState(() {});
                                    } else {
                                      _model.textController2.text = '';
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Favor de verificar su contraseña',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Roboto',
                                                  color: Color(0xFF130C0D),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          action: SnackBarAction(
                                              label: 'Cerrar mensaje',
                                              textColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              backgroundColor: Colors.black12,
                                              onPressed: () {
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                              }),
                                          duration:
                                              Duration(milliseconds: 9000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondary,
                                        ),
                                      );
                                    }
                                  },
                                  text: 'Ingresar',
                                  options: FFButtonOptions(
                                    width: 370.0,
                                    height: 44.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                        ),
                                    elevation: 3.0,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 4.0, 0.0, 4.0),
                                    child: Text(
                                      'Olvide mi contraseña',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        4.0, 4.0, 0.0, 4.0),
                                    child: Text(
                                      'Click aqui',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                    ),
                                  ),
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
      ),
    );
  }
}

User userLogedIn(List<dynamic> jsonList) {
  late User currentUser;

  // Iterate through the list and split each item into variables
  for (var item in jsonList) {
    int employeeNumber = item['NoEmpleado'];
    String employeeName = item['Nombre_Gafete'];
    int idLogin = item['idLogin'];
    int isTeacher = item['EsMaestro'];
    int isWorker = item['EsTrabajador'];
    String claUn = item['ClaUn'];
    String claLogin = item['ClaLogin'];
    // int notActive = item['Bajalogicasino'];

    currentUser = User(claLogin, claUn, employeeName, employeeNumber, idLogin,
        isWorker, isTeacher);
  }
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
