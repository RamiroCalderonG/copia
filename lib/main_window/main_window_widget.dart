import 'package:oxschool/components/drawer_menu.dart';
import 'package:oxschool/components/main_window_carousel.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/constants/url_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '/components/side_nav04_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_window_model.dart';
export 'main_window_model.dart';

class MainWindowWidget extends StatefulWidget {
  const MainWindowWidget({Key? key}) : super(key: key);

  @override
  _MainWindowWidgetState createState() => _MainWindowWidgetState();
}

class _MainWindowWidgetState extends State<MainWindowWidget> {
  late MainWindowModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainWindowModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: Opacity(opacity: 1, child: DrawerClass()),
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: false,
              leading: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: IconButton(
                    hoverColor: Colors.black12,
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      scaffoldKey.currentState!.openDrawer();
                    },
                  )),
              title: Text(
                'Ox School',
                style: TextStyle(
                    color: Colors
                        .white), //FlutterFlowTheme.of(context).headlineSmall,
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                      '${currentUser?.employeeName?.toLowerCase().trimRight()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          color: Colors
                              .white) // FlutterFlowTheme.of(context).bodyMedium,
                      ),
                )
              ],
              centerTitle: true,
              elevation: 2.0,
            )
          ],
          body: Builder(
            builder: (context) {
              return SafeArea(
                top: false,
                child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 10.0, 16.0, 5.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 20.0, top: 10.0),
                                    child: MainCarousel()),
                                Divider(
                                  thickness: 0.5,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'Hola de nuevo',
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          fontFamily: 'Sora',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'Disciplina, Moralidad, Trabajo y Eficiencia',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                  ),
                                ),
                                // Padding(
                                //   padding: EdgeInsetsDirectional.fromSTEB(
                                //       16.0, 0.0, 16.0, 0.0),
                                //   child: FFButtonWidget(
                                //     onPressed: () {
                                //       print('Button pressed ...');
                                //     },
                                //     text: 'Get Started',
                                //     options: FFButtonOptions(
                                //       width: 200.0,
                                //       height: 50.0,
                                //       padding: EdgeInsetsDirectional.fromSTEB(
                                //           0.0, 0.0, 0.0, 0.0),
                                //       iconPadding:
                                //           EdgeInsetsDirectional.fromSTEB(
                                //               0.0, 0.0, 0.0, 0.0),
                                //       color:
                                //           FlutterFlowTheme.of(context).primary,
                                //       textStyle: FlutterFlowTheme.of(context)
                                //           .titleMedium
                                //           .override(
                                //             fontFamily: 'Inter',
                                //             color: Colors.white,
                                //           ),
                                //       elevation: 2.0,
                                //       borderRadius: BorderRadius.circular(10.0),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              children: [
                                GestureDetector(
                                  child: Text('Ox School',
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Sora',
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                          )),
                                  onTap: () {
                                    Uri _url = Uri.parse(oxlinks[0]);
                                    launchUrl(_url);
                                  },
                                ),
                                SizedBox(height: 2.0),
                                GestureDetector(
                                  child: Text(
                                    'Ox High School',
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Sora',
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                        ),
                                  ),
                                  onTap: () {
                                    Uri _url = Uri.parse(oxlinks[1]);
                                    launchUrl(_url);
                                  },
                                ),
                                SizedBox(height: 8.0),
                              ],
                            ))
                      ],
                    )),
              );
            },
          ),
        ),
      ),
    );
  }
}
