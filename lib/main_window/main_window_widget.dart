import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/components/create_service_ticket.dart';
import 'package:oxschool/components/drawer_menu.dart';
import 'package:oxschool/components/mobile_main_items_list.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/constants/url_links.dart';
import 'package:oxschool/user/user_view_view.dart';

import '../components/quality_dialogs.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'main_window_model.dart';
export 'main_window_model.dart';

class MainWindowWidget extends StatefulWidget {
  const MainWindowWidget({Key? key}) : super(key: key);

  @override
  _MainWindowWidgetState createState() => _MainWindowWidgetState();
}

class _MainWindowWidgetState extends State<MainWindowWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isHovered = false;

  late MainWindowModel _model;

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainWindowModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  final ExpansionTileController controller =
      ExpansionTileController(); //Controller for ExpansionTile

  @override
  Widget build(BuildContext context) {
    final appHeader = SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      automaticallyImplyLeading: false,
      toolbarHeight: 95.0,
      title: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            // For smaller screens, display a simplified AppBar
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(left: 10.5)),
                Image.asset(
                  Theme.of(context).brightness == Brightness.light
                      ? 'assets/images/1_OS_color.png' //igth theme image
                      : 'assets/images/logoBlancoOx.png', //Dark theme image
                  fit: BoxFit.fill,
                  height: 50,
                  filterQuality: FilterQuality.high,
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            );
          } else {
            // For larger screens, display the original AppBar
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(left: 10.5)),
                Image.asset(
                  Theme.of(context).brightness == Brightness.light
                      ? 'assets/images/1_OS_color.png' //igth theme image
                      : 'assets/images/logoBlancoOx.png', //Dark theme image
                  fit: BoxFit.fill,
                  height: 50,
                  filterQuality: FilterQuality.high,
                ),
                Spacer(
                  flex: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const UserWindow()));
                              },
                              icon: const Icon(Icons.person),
                              color: Color.fromRGBO(235, 48, 69, 0.988)),

                          // Text(
                          //   'Ing. Sanchez',
                          //   style: TextStyle(
                          //       fontFamily: 'Sora',
                          //       fontStyle: FontStyle.normal,
                          //       fontSize: 20),
                          // ),
                          Text(
                              '${currentUser?.employeeName?.toLowerCase().trimRight()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 20,
                                  color: Colors
                                      .black87) // FlutterFlowTheme.of(context).bodyMedium,
                              ),
                          Padding(
                              padding: EdgeInsets.only(left: 15, right: 15)),
                          IconButton(
                              onPressed: () {},
                              icon: FaIcon(FontAwesomeIcons.facebookF),
                              color: Color.fromRGBO(235, 48, 69, 0.988)),
                          Padding(
                              padding: EdgeInsets.only(left: 15, right: 15)),
                          IconButton(
                              onPressed: () {},
                              icon: FaIcon(FontAwesomeIcons.instagram),
                              color: Color.fromRGBO(235, 48, 69, 0.988)),
                          Padding(
                              padding: EdgeInsets.only(left: 15, right: 15)),
                          IconButton(
                              onPressed: () {},
                              icon: FaIcon(FontAwesomeIcons.youtube),
                              color: Color.fromRGBO(235, 48, 69, 0.988)),

                          Padding(padding: EdgeInsets.only(left: 15, right: 5)),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            );
          }
        },
      ),
      bottom: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        leading: IconButton(
          hoverColor: Colors.black12,
          icon: Icon(
            Icons.menu_open_rounded,
            // size: 40.5,
          ),
          onPressed: () async {
            scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Crear Ticket de servicio'),
                        content: CreateServiceTicket(),
                        actions: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: Theme.of(context).textTheme.labelLarge,
                            ),
                            child: const Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
              child: const Text('Crear Ticket de Servicio',
                  style: TextStyle(
                      fontFamily: 'Sora', fontSize: 16, color: Colors.white)))
        ],
      ),
    );

    final iconsLinksGrid = Expanded(
        flex: 2,
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          child: GridView.builder(
              // physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 50.0,
                  mainAxisSpacing: 50.0,
                  childAspectRatio: 1.9),
              // padding: EdgeInsets.only(left: 10, right: 10),
              shrinkWrap: true,
              itemCount: oxlinks.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Uri _url = Uri.parse(oxlinks[index]);
                    launchUrlDirection(_url);
                  },
                  child: MainViewItemList(
                    imagePath: gridMainWindowIcons[index],
                    backgroundColor: Theme.of(context).brightness ==
                            Brightness.light
                        ? gridMainWindowColors[index] //igth theme image
                        : gridDarkColorsMainWindow[index], //Dark theme image

                    title: mainWindowGridTitles[index],
                  ),
                );
              }),
        ));

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: Opacity(opacity: 1, child: DrawerClass()),
        body: NestedScrollView(
          physics: NeverScrollableScrollPhysics(),
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            appHeader,
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
                                  16.0, 5.0, 16.0, 30.0),
                              child: Row(
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: Column(
                                      // mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 40.0, 10.0, 0.0),
                                          child: Text(
                                            'Disciplina, Moralidad, \n Trabajo y Eficiencia',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  iconsLinksGrid
                                  //---------HERE--------
                                ],
                              )),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                              if (constraints.maxWidth < 600) {
                                return Container(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    width: MediaQuery.of(context).size.width,
                                    height: 100,
                                    color: Color.fromRGBO(23, 76, 147, 1),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        TextButton(
                                            onPressed: () {
                                              showMision(context);
                                            },
                                            child: Text('Misión',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily: 'Sora',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                        ))),
                                        TextButton(
                                            onPressed: () {
                                              showVision(context);
                                            },
                                            child: Text('Visión',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily: 'Sora',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                        ))),
                                        TextButton(
                                            onPressed: () {
                                              qualityPolitic(context);
                                            },
                                            child: Text('Politica de calidad',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily: 'Sora',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                        )))
                                      ],
                                    ));
                              } else {
                                return Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height / 13,
                                  color: Color.fromRGBO(23, 76, 147, 1),
                                  child: Row(children: <Widget>[
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  showMision(context);
                                                },
                                                child: Text('Misión',
                                                    style: TextStyle(
                                                        fontFamily: 'Sora',
                                                        fontSize: 16,
                                                        color: Colors.white))),
                                          ],
                                        ),
                                      ],
                                    )),
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  showVision(context);
                                                },
                                                child: Text('Visión',
                                                    style: TextStyle(
                                                      fontFamily: 'Sora',
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ))),
                                          ],
                                        ),
                                      ],
                                    )),
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  qualityPolitic(context);
                                                },
                                                child: const Text(
                                                    'Politica de calidad',
                                                    style: TextStyle(
                                                        fontFamily: 'Sora',
                                                        fontSize: 16,
                                                        color: Colors.white))),

                                            // TextButton(
                                            //     onPressed: () {
                                            //       showDialog(
                                            //           context: context,
                                            //           builder: (BuildContext
                                            //               context) {
                                            //             return AlertDialog(
                                            //               title: const Text(
                                            //                   'text'),
                                            //               content:
                                            //                   NewStudentNurseryVisit(),
                                            //               actions: <Widget>[
                                            //                 TextButton(
                                            //                   style: TextButton
                                            //                       .styleFrom(
                                            //                     textStyle: Theme.of(
                                            //                             context)
                                            //                         .textTheme
                                            //                         .labelLarge,
                                            //                   ),
                                            //                   child: const Text(
                                            //                       'Cerrar'),
                                            //                   onPressed: () {
                                            //                     Navigator.of(
                                            //                             context)
                                            //                         .pop();
                                            //                   },
                                            //                 ),
                                            //               ],
                                            //             );
                                            //           });
                                            //     },
                                            //     child: Text(
                                            //       'Otra opcion',
                                            //       style: FlutterFlowTheme.of(
                                            //               context)
                                            //           .titleSmall
                                            //           .override(
                                            //             fontFamily: 'Sora',
                                            //             color:
                                            //                 FlutterFlowTheme.of(
                                            //                         context)
                                            //                     .info,
                                            //           ),
                                            //     ))
                                          ],
                                        ),
                                      ],
                                    )),
                                    // Column(
                                    //   children: [Text('Hola'), Text('Hola2')],
                                    // ),
                                  ]),
                                );
                              }
                            })),
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

class HoverCard extends StatefulWidget {
  final String imagePath;
  final Color backgroundColor;
  final String title;

  HoverCard({
    required this.imagePath,
    required this.backgroundColor,
    required this.title,
  });

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 215) {
          return MouseRegion(
            onEnter: (_) {
              setState(() {
                isHovered = true;
              });
            },
            onExit: (_) {
              setState(() {
                isHovered = false;
              });
            },
            child: Container(
              width: 100,
              height: 100,
              child: Card(
                margin: EdgeInsets.all(2.0),
                elevation: isHovered ? 10 : 0,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                color: widget.backgroundColor,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                  padding: EdgeInsets.all(isHovered ? 20 : 10),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? Color.fromRGBO(73, 73, 73, 1)
                        : widget.backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: GestureDetector(
                    child: Center(
                      child: Text(
                        widget.title,
                        textScaleFactor: 0.8,
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return MouseRegion(
            onEnter: (_) {
              setState(() {
                isHovered = true;
              });
            },
            onExit: (_) {
              setState(() {
                isHovered = false;
              });
            },
            child: Container(
              width: 100,
              height: 100,
              child: Card(
                margin: EdgeInsets.all(2.0),
                elevation: isHovered ? 10 : 0,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                color: widget.backgroundColor,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                  padding: EdgeInsets.all(isHovered ? 20 : 10),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? Color.fromRGBO(73, 73, 73, 1)
                        : widget.backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: GestureDetector(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.fill,
                            scale: 15,
                            // width: constraints.maxWidth * 0.5, // Adjust image width
                            // height:
                            // constraints.maxHeight * 0.5, // Adjust image height
                            alignment: Alignment.center,
                          ),
                        ),
                        SizedBox(height: 7), // Add spacing
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sora',
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
        // return MouseRegion(
        //   onEnter: (_) {
        //     setState(() {
        //       isHovered = true;
        //     });
        //   },
        //   onExit: (_) {
        //     setState(() {
        //       isHovered = false;
        //     });
        //   },
        //   child: Container(
        //     width: 100,
        //     height: 100,
        //     // width: constraints.maxWidth, // Use max width available
        //     // height: constraints.maxHeight, // Use max height available
        //     child: Card(
        //       margin: EdgeInsets.all(2.0),
        //       elevation: isHovered ? 10 : 0,
        //       shadowColor: Colors.black,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12.0),
        //         side: BorderSide(
        //           color: Theme.of(context).colorScheme.outline,
        //         ),
        //       ),
        //       color: widget.backgroundColor,
        //       child: AnimatedContainer(
        //         duration: const Duration(milliseconds: 200),
        //         curve: Curves.ease,
        //         padding: EdgeInsets.all(isHovered ? 20 : 10),
        //         decoration: BoxDecoration(
        //           color: isHovered
        //               ? Color.fromRGBO(73, 73, 73, 1)
        //               : widget.backgroundColor,
        //           borderRadius: BorderRadius.circular(15),
        //         ),
        //         child: GestureDetector(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.center,
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: <Widget>[
        //               Container(
        //                 child: Image.asset(
        //                   widget.imagePath,
        //                   fit: BoxFit.fill,
        //                   scale: 15,
        //                   // width: constraints.maxWidth * 0.5, // Adjust image width
        //                   // height:
        //                   // constraints.maxHeight * 0.5, // Adjust image height
        //                   alignment: Alignment.center,
        //                 ),
        //               ),
        //               SizedBox(height: 7), // Add spacing
        //               Align(
        //                 alignment: Alignment.bottomCenter,
        //                 child: Text(
        //                   widget.title,
        //                   style: TextStyle(
        //                     color: Colors.white,
        //                     fontWeight: FontWeight.bold,
        //                     fontFamily: 'Sora',
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // );
      },
    );
  }
}

// class HoverCard extends StatefulWidget {
//   final String imagePath;
//   final Color backgroundColor;
//   final String title;

//   HoverCard({
//     required this.imagePath,
//     required this.backgroundColor,
//     required this.title,
//   });

//   @override
//   _HoverCardState createState() => _HoverCardState();
// }

// class _HoverCardState extends State<HoverCard> {
//   bool isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) {
//         setState(() {
//           isHovered = true;
//         });
//       },
//       onExit: (_) {
//         setState(() {
//           isHovered = false;
//         });
//       },
//       child: Card(
//           margin: EdgeInsets.all(1.0),
//           elevation: isHovered ? 40 : 0,
//           shadowColor: Colors.black,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               side: BorderSide(
//                 color: Theme.of(context).colorScheme.outline,
//               )),
//           // shadowColor: Colors.black87,
//           color: widget.backgroundColor,
//           child: Center(
//               child: InkWell(
//                   onTap: () {},
//                   onHover: (hovering) {
//                     setState(
//                       () => isHovered = hovering,
//                     );
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     curve: Curves.ease,
//                     padding: EdgeInsets.all(isHovered ? 45 : 30),
//                     decoration: BoxDecoration(
//                       color: isHovered ? Colors.green : widget.backgroundColor,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.max,
//                       children: <Widget>[
//                         Container(
//                           // padding: EdgeInsets.all(10),
//                           child: Image.asset(
//                             widget.imagePath,
//                             fit: BoxFit.fill,
//                             scale: 10,
//                             alignment: Alignment.topCenter,
//                           ),
//                         ),
//                         Align(
//                           alignment: Alignment.bottomCenter,
//                           child: Text(
//                             widget.title,
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: 'Sora'),
//                           ),
//                         )
//                       ],
//                     ),
//                   ))
//               // clipBehavior: Clip.none,

//               )),
//     );
//   }
// }










//---------------------------------------------------------------------------------------------------------------------



// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:oxschool/components/drawer_menu.dart';
// import 'package:oxschool/constants/User.dart';
// import 'package:oxschool/constants/url_links.dart';
// import 'package:oxschool/enfermeria/new_student_visit.dart';
// import 'package:oxschool/flutter_flow/flutter_flow_icon_button.dart';
// import 'package:oxschool/user/user_view_view.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../components/quality_dialogs.dart';
// import '/components/side_nav04_widget.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/flutter_flow/flutter_flow_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'main_window_model.dart';
// export 'main_window_model.dart';

// class MainWindowWidget extends StatefulWidget {
//   const MainWindowWidget({Key? key}) : super(key: key);

//   @override
//   _MainWindowWidgetState createState() => _MainWindowWidgetState();
// }

// class _MainWindowWidgetState extends State<MainWindowWidget> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   bool isHovered = false;

//   late MainWindowModel _model;

//   @override
//   void dispose() {
//     _model.dispose();

//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => MainWindowModel());

//     WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appHeader = SliverAppBar(
//       pinned: true,
//       floating: false,
//       snap: false,
//       backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
//       automaticallyImplyLeading: false,
//       toolbarHeight: 95.0,
//       title: LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//           if (constraints.maxWidth < 600) {
//             // For smaller screens, display a simplified AppBar
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(padding: EdgeInsets.only(left: 10.5)),
//                 Image.asset(
//                   Theme.of(context).brightness == Brightness.light
//                       ? 'assets/images/1_OS_color.png' //igth theme image
//                       : 'assets/images/logoBlancoOx.png', //Dark theme image
//                   fit: BoxFit.fill,
//                   height: 50,
//                   filterQuality: FilterQuality.high,
//                 ),
//                 Spacer(
//                   flex: 1,
//                 ),
//               ],
//             );
//           } else {
//             // For larger screens, display the original AppBar
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(padding: EdgeInsets.only(left: 10.5)),
//                 Image.asset(
//                   Theme.of(context).brightness == Brightness.light
//                       ? 'assets/images/1_OS_color.png' //igth theme image
//                       : 'assets/images/logoBlancoOx.png', //Dark theme image
//                   fit: BoxFit.fill,
//                   height: 50,
//                   filterQuality: FilterQuality.high,
//                 ),
//                 Spacer(
//                   flex: 1,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Row(
//                         children: [
//                           IconButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => UserWindow()));
//                               },
//                               icon: const Icon(Icons.person),
//                               color: Color.fromRGBO(235, 48, 69, 0.988)),
//                           Text(
//                             'Ing. Sanchez',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 fontFamily: 'Sora',
//                                 fontStyle: FontStyle.normal,
//                                 fontSize: 20),
//                           ),
//                           // Text(
//                           //     '${currentUser?.employeeName?.toLowerCase().trimRight()}',
//                           //     textAlign: TextAlign.center,
//                           //     style: TextStyle(
//                           //         fontFamily: 'Roboto',
//                           //         fontSize: 20,
//                           //         fontStyle: FontStyle
//                           //             .normal) // FlutterFlowTheme.of(context).bodyMedium,
//                           //     ),
//                           Padding(
//                               padding: EdgeInsets.only(left: 15, right: 15)),
//                           IconButton(
//                               onPressed: () {},
//                               icon: FaIcon(FontAwesomeIcons.facebookF),
//                               color: Color.fromRGBO(235, 48, 69, 0.988)),
//                           Padding(
//                               padding: EdgeInsets.only(left: 15, right: 15)),
//                           IconButton(
//                               onPressed: () {},
//                               icon: FaIcon(FontAwesomeIcons.instagram),
//                               color: Color.fromRGBO(235, 48, 69, 0.988)),
//                           Padding(
//                               padding: EdgeInsets.only(left: 15, right: 15)),
//                           IconButton(
//                               onPressed: () {},
//                               icon: FaIcon(FontAwesomeIcons.youtube),
//                               color: Color.fromRGBO(235, 48, 69, 0.988)),
//                           Padding(padding: EdgeInsets.only(left: 15, right: 5)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             );
//           }
//         },
//       ),
//       bottom: AppBar(
//           backgroundColor: FlutterFlowTheme.of(context).primary,
//           leading: IconButton(
//             hoverColor: Colors.black12,
//             icon: FaIcon(
//               FontAwesomeIcons.circleChevronLeft,
//               color: Colors.white,
//             ),
//             onPressed: () async {
//               scaffoldKey.currentState!.openDrawer();
//             },
//           )),
//     );

//     final iconsLinksGrid = Expanded(
//         flex: 2,
//         child: Container(
//           padding: EdgeInsets.all(5),
//           margin: EdgeInsets.all(5),
//           child: GridView.builder(
//               // physics: NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 50.0,
//                   mainAxisSpacing: 50.0,
//                   childAspectRatio: 1.9),
//               // padding: EdgeInsets.only(left: 10, right: 10),
//               shrinkWrap: true,
//               itemCount: oxlinks.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return GestureDetector(
//                   onTap: () {
//                     Uri _url = Uri.parse(oxlinks[index]);
//                     launchUrlDirection(_url);
//                   },
//                   child: HoverCard(
//                     imagePath: gridMainWindowIcons[index],
//                     backgroundColor: Theme.of(context).brightness ==
//                             Brightness.light
//                         ? gridMainWindowColors[index] //igth theme image
//                         : gridDarkColorsMainWindow[index], //Dark theme image

//                     title: mainWindowGridTitles[index],
//                   ),
//                 );
//               }),
//         ));

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
//       child: Scaffold(
//         key: scaffoldKey,
//         backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
//         drawer: Opacity(opacity: 1, child: DrawerClass()),
//         body: NestedScrollView(
//           // physics: NeverScrollableScrollPhysics(),
//           floatHeaderSlivers: true,
//           headerSliverBuilder: (context, _) => [
//             SliverAppBar(
//               pinned: false,
//               floating: true,
//               snap: true,
//               backgroundColor: FlutterFlowTheme.of(context).primary,
//               automaticallyImplyLeading: false,
//               leading: Align(
//                 alignment: AlignmentDirectional(0.0, 0.0),
//                 child: FFButtonWidget(
//                   onPressed: () async {
//                     // OnTap
//                     scaffoldKey.currentState!.openDrawer();
//                   },
//                   text: '',
//                   icon: Icon(
//                     Icons.menu_rounded,
//                     size: 35.0,
//                   ),
//                   options: FFButtonOptions(
//                     height: 40.0,
//                     padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
//                     iconPadding:
//                         EdgeInsetsDirectional.fromSTEB(5.0, 5.0, 5.0, 5.0),
//                     color: FlutterFlowTheme.of(context).primary,
//                     textStyle: TextStyle(
//                       color: Colors.white,
//                     ),
//                     borderSide: BorderSide(
//                       color: Colors.transparent,
//                       width: 1.0,
//                     ),
//                     borderRadius: BorderRadius.circular(8.0),
//                     hoverElevation: 4.0,
//                   ),
//                 ),
//               ),
//               title: Text(
//                 'Ox School',
//                 style: FlutterFlowTheme.of(context).headlineSmall,
//               ),
//               actions: [
//                 Text(
//                   '${currentUser?.employeeName!.toLowerCase()}',
//                   style: FlutterFlowTheme.of(context).bodyMedium,
//                 ),
//               ],
//               centerTitle: true,
//               elevation: 4.0,
//             )
//           ],
//           body: Builder(
//             builder: (context) {
//               return SafeArea(
//                   top: false,
//                   child: Align(
//                     alignment: AlignmentDirectional(0.0, 0.0),
//                     child: Padding(
//                         padding: EdgeInsetsDirectional.fromSTEB(
//                             16.0, 16.0, 16.0, 16.0),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.max,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       16.0, 5.0, 16.0, 30.0),
//                                   child: Row(
//                                     children: [
//                                       // Align(
//                                       //   alignment: AlignmentDirectional.topStart,
//                                       //   child: Column(
//                                       //     // mainAxisSize: MainAxisSize.max,
//                                       //     mainAxisAlignment:
//                                       //         MainAxisAlignment.start,
//                                       //     crossAxisAlignment:
//                                       //         CrossAxisAlignment.center,
//                                       //     children: [
//                                       //       Padding(
//                                       //         padding:
//                                       //             EdgeInsetsDirectional.fromSTEB(
//                                       //                 20.0, 40.0, 10.0, 0.0),
//                                       //         child: Text(
//                                       //           'Disciplina, Moralidad, \n Trabajo y Eficiencia',
//                                       //           style: FlutterFlowTheme.of(context)
//                                       //               .bodyMedium
//                                       //               .override(
//                                       //                 fontFamily: 'Inter',
//                                       //                 color: FlutterFlowTheme.of(
//                                       //                         context)
//                                       //                     .secondaryText,
//                                       //               ),
//                                       //         ),
//                                       //       ),
//                                       //     ],
//                                       //   ),
//                                       // ),
//                                       iconsLinksGrid
//                                     ],
//                                   )),
//                             ),
//                             Align(
//                               alignment: Alignment.bottomCenter,
//                               child: LayoutBuilder(builder:
//                                   (BuildContext context,
//                                       BoxConstraints constraints) {
//                                 //For smaller screens
//                                 if (constraints.maxWidth < 600) {
//                                   return Container(
//                                       padding:
//                                           EdgeInsets.only(top: 10, bottom: 10),
//                                       width: MediaQuery.of(context).size.width,
//                                       height: 100,
//                                       color: Color.fromRGBO(23, 76, 147, 1),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: <Widget>[
//                                           TextButton(
//                                               onPressed: () {
//                                                 showMision(context);
//                                               },
//                                               child: Text('Misión',
//                                                   style: FlutterFlowTheme.of(
//                                                           context)
//                                                       .titleSmall
//                                                       .override(
//                                                         fontFamily: 'Sora',
//                                                         color:
//                                                             FlutterFlowTheme.of(
//                                                                     context)
//                                                                 .info,
//                                                       ))),
//                                           TextButton(
//                                               onPressed: () {
//                                                 showVision(context);
//                                               },
//                                               child: Text('Visión',
//                                                   style: FlutterFlowTheme.of(
//                                                           context)
//                                                       .titleSmall
//                                                       .override(
//                                                         fontFamily: 'Sora',
//                                                         color:
//                                                             FlutterFlowTheme.of(
//                                                                     context)
//                                                                 .info,
//                                                       ))),
//                                           TextButton(
//                                               onPressed: () {
//                                                 qualityPolitic(context);
//                                               },
//                                               child: Text('Politica de calidad',
//                                                   style: FlutterFlowTheme.of(
//                                                           context)
//                                                       .titleSmall
//                                                       .override(
//                                                         fontFamily: 'Sora',
//                                                         color:
//                                                             FlutterFlowTheme.of(
//                                                                     context)
//                                                                 .info,
//                                                       )))
//                                         ],
//                                       ));
//                                 } else {
//                                   return Container(
//                                     padding:
//                                         EdgeInsets.only(top: 10, bottom: 10),
//                                     width: MediaQuery.of(context).size.width,
//                                     height:
//                                         MediaQuery.of(context).size.height / 13,
//                                     color: Color.fromRGBO(23, 76, 147, 1),
//                                     child: Row(children: <Widget>[
//                                       Expanded(
//                                           child: Column(
//                                         children: [
//                                           Column(
//                                             children: [
//                                               TextButton(
//                                                   onPressed: () {
//                                                     showMision(context);
//                                                   },
//                                                   child: Text(
//                                                     'Misión',
//                                                     style: FlutterFlowTheme.of(
//                                                             context)
//                                                         .titleSmall
//                                                         .override(
//                                                           fontFamily: 'Sora',
//                                                           color: FlutterFlowTheme
//                                                                   .of(context)
//                                                               .info,
//                                                         ),
//                                                   )),
//                                             ],
//                                           ),
//                                         ],
//                                       )),
//                                       Expanded(
//                                           child: Column(
//                                         children: [
//                                           Column(
//                                             children: [
//                                               TextButton(
//                                                   onPressed: () {
//                                                     showVision(context);
//                                                   },
//                                                   child: Text(
//                                                     'Visión',
//                                                     style: FlutterFlowTheme.of(
//                                                             context)
//                                                         .titleSmall
//                                                         .override(
//                                                           fontFamily: 'Sora',
//                                                           color: FlutterFlowTheme
//                                                                   .of(context)
//                                                               .info,
//                                                         ),
//                                                   )),
//                                               // TextButton(
//                                               //     onPressed: () {
//                                               //       showDialog(
//                                               //           context: context,
//                                               //           builder:
//                                               //               (BuildContext context) {
//                                               //             return AlertDialog(
//                                               //               title: const Text(
//                                               //                   'Crear Ticket de servicio'),
//                                               //               content:
//                                               //                   CreateServiceTicket(),
//                                               //               actions: <Widget>[
//                                               //                 TextButton(
//                                               //                   style: TextButton
//                                               //                       .styleFrom(
//                                               //                     textStyle: Theme.of(
//                                               //                             context)
//                                               //                         .textTheme
//                                               //                         .labelLarge,
//                                               //                   ),
//                                               //                   child: const Text(
//                                               //                       'Ok'),
//                                               //                   onPressed: () {
//                                               //                     Navigator.of(
//                                               //                             context)
//                                               //                         .pop();
//                                               //                   },
//                                               //                 ),
//                                               //               ],
//                                               //             );
//                                               //           });
//                                               //     },
//                                               //     child: Text(
//                                               //       'Crear Ticket de Servicio',
//                                               //       style:
//                                               //           FlutterFlowTheme.of(context)
//                                               //               .titleSmall
//                                               //               .override(
//                                               //                 fontFamily: 'Sora',
//                                               //                 color: FlutterFlowTheme
//                                               //                         .of(context)
//                                               //                     .info,
//                                               //               ),
//                                               //     ))
//                                             ],
//                                           ),
//                                         ],
//                                       )),
//                                       Expanded(
//                                           child: Column(
//                                         children: [
//                                           Column(
//                                             children: [
//                                               TextButton(
//                                                   onPressed: () {
//                                                     qualityPolitic(context);
//                                                   },
//                                                   child: Text(
//                                                     'Politica de calidad',
//                                                     style: FlutterFlowTheme.of(
//                                                             context)
//                                                         .titleSmall
//                                                         .override(
//                                                           fontFamily: 'Sora',
//                                                           color: FlutterFlowTheme
//                                                                   .of(context)
//                                                               .info,
//                                                         ),
//                                                   )),

//                                               // TextButton(
//                                               //     onPressed: () {
//                                               //       showDialog(
//                                               //           context: context,
//                                               //           builder:
//                                               //               (BuildContext context) {
//                                               //             return AlertDialog(
//                                               //               title:
//                                               //                   const Text('text'),
//                                               //               content:
//                                               //                   NewStudentNurseryVisit(),
//                                               //               actions: <Widget>[
//                                               //                 TextButton(
//                                               //                   style: TextButton
//                                               //                       .styleFrom(
//                                               //                     textStyle: Theme.of(
//                                               //                             context)
//                                               //                         .textTheme
//                                               //                         .labelLarge,
//                                               //                   ),
//                                               //                   child: const Text(
//                                               //                       'Cerrar'),
//                                               //                   onPressed: () {
//                                               //                     Navigator.of(
//                                               //                             context)
//                                               //                         .pop();
//                                               //                   },
//                                               //                 ),
//                                               //               ],
//                                               //             );
//                                               //           });
//                                               //     },
//                                               //     child: Text(
//                                               //       'Otra opcion',
//                                               //       style:
//                                               //           FlutterFlowTheme.of(context)
//                                               //               .titleSmall
//                                               //               .override(
//                                               //                 fontFamily: 'Sora',
//                                               //                 color: FlutterFlowTheme
//                                               //                         .of(context)
//                                               //                     .info,
//                                               //               ),
//                                               //     ))
//                                             ],
//                                           ),
//                                         ],
//                                       )),
//                                       // Column(
//                                       //   children: [Text('Hola'), Text('Hola2')],
//                                       // ),
//                                     ]),
//                                   );
//                                 }
//                               }),
//                             )
//                           ],
//                         )),
//                   ));
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class HoverCard extends StatefulWidget {
//   final String imagePath;
//   final Color backgroundColor;
//   final String title;

//   HoverCard({
//     required this.imagePath,
//     required this.backgroundColor,
//     required this.title,
//   });

//   @override
//   _HoverCardState createState() => _HoverCardState();
// }

// class _HoverCardState extends State<HoverCard> {
//   bool isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (BuildContext context, BoxConstraints constraints) {
//         if (constraints.maxWidth < 200) {
//           //IF SCREEN IS SMALLER THAN THIS, WILL SHOW ANOTHER THING, FOR SMALLER SCREENS
//           return MouseRegion(
//               onEnter: (_) {
//                 setState(() {
//                   isHovered = true;
//                 });
//               },
//               onExit: (_) {
//                 setState(() {
//                   isHovered = false;
//                 });
//               },
//               child: Container(
//                 width: MediaQuery.of(context).size.width / 9,
//                 height: MediaQuery.of(context).size.height / 9,
//                 child: Card(
//                   margin: EdgeInsets.all(2.0),
//                   elevation: isHovered ? 10 : 0,
//                   shadowColor: Colors.black,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     side: BorderSide(
//                       color: Theme.of(context).colorScheme.outline,
//                     ),
//                   ),
//                   color: widget.backgroundColor,
//                   child: Container(
//                     //    <-----------SHOW RED CONTAINERS
//                     color: Colors.red,
//                   ),
//                   // child: AnimatedContainer(
//                   //   duration: const Duration(milliseconds: 200),
//                   //   curve: Curves.ease,
//                   //   padding: EdgeInsets.all(isHovered ? 20 : 10),
//                   //   decoration: BoxDecoration(
//                   //     color: isHovered
//                   //         ? Color.fromRGBO(73, 73, 73, 1)
//                   //         : widget.backgroundColor,
//                   //     borderRadius: BorderRadius.circular(15),
//                   //   ),
//                   //   child: GestureDetector(
//                   //     child: Center(
//                   //       child: Text(
//                   //         widget.title,
//                   //         textScaleFactor: 0.8,
//                   //         softWrap: true,
//                   //         style: TextStyle(
//                   //           color: Colors.white,
//                   //           fontWeight: FontWeight.bold,
//                   //           fontFamily: 'Sora',
//                   //         ),
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                 ),
//               ));
//           /*
//           return MouseRegion(
//             onEnter: (_) {
//               setState(() {
//                 isHovered = true;
//               });
//             },
//             onExit: (_) {
//               setState(() {
//                 isHovered = false;
//               });
//             },
//             child: Container(
//               width: 100,
//               height: 100,
//               child: Card(
//                 margin: EdgeInsets.all(2.0),
//                 elevation: isHovered ? 10 : 0,
//                 shadowColor: Colors.black,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                   side: BorderSide(
//                     color: Theme.of(context).colorScheme.outline,
//                   ),
//                 ),
//                 color: widget.backgroundColor,
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   curve: Curves.ease,
//                   padding: EdgeInsets.all(isHovered ? 20 : 10),
//                   decoration: BoxDecoration(
//                     color: isHovered
//                         ? Color.fromRGBO(73, 73, 73, 1)
//                         : widget.backgroundColor,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: GestureDetector(
//                     child: Center(
//                       child: Text(
//                         widget.title,
//                         textScaleFactor: 0.8,
//                         softWrap: true,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Sora',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         */
//         } else {
//           return MouseRegion(
//             onEnter: (_) {
//               setState(() {
//                 isHovered = true;
//               });
//             },
//             onExit: (_) {
//               setState(() {
//                 isHovered = false;
//               });
//             },
//             child: Container(
//               width: 100,
//               height: 100,
//               child: Card(
//                 margin: EdgeInsets.all(2.0),
//                 elevation: isHovered ? 10 : 0,
//                 shadowColor: Colors.black,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                   side: BorderSide(
//                     color: Theme.of(context).colorScheme.outline,
//                   ),
//                 ),
//                 color: widget.backgroundColor,
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   curve: Curves.ease,
//                   padding: EdgeInsets.all(isHovered ? 20 : 10),
//                   decoration: BoxDecoration(
//                     color: isHovered
//                         ? Color.fromRGBO(73, 73, 73, 1)
//                         : widget.backgroundColor,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: GestureDetector(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Container(
//                           child: Image.asset(
//                             widget.imagePath,
//                             fit: BoxFit.fill,
//                             scale: 15,
//                             // width: constraints.maxWidth * 0.5, // Adjust image width
//                             // height:
//                             // constraints.maxHeight * 0.5, // Adjust image height
//                             alignment: Alignment.center,
//                           ),
//                         ),
//                         SizedBox(height: 7), // Add spacing
//                         Align(
//                           alignment: Alignment.bottomCenter,
//                           child: Text(
//                             widget.title,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Sora',
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }
//         // return MouseRegion(
//         //   onEnter: (_) {
//         //     setState(() {
//         //       isHovered = true;
//         //     });
//         //   },
//         //   onExit: (_) {
//         //     setState(() {
//         //       isHovered = false;
//         //     });
//         //   },
//         //   child: Container(
//         //     width: 100,
//         //     height: 100,
//         //     // width: constraints.maxWidth, // Use max width available
//         //     // height: constraints.maxHeight, // Use max height available
//         //     child: Card(
//         //       margin: EdgeInsets.all(2.0),
//         //       elevation: isHovered ? 10 : 0,
//         //       shadowColor: Colors.black,
//         //       shape: RoundedRectangleBorder(
//         //         borderRadius: BorderRadius.circular(12.0),
//         //         side: BorderSide(
//         //           color: Theme.of(context).colorScheme.outline,
//         //         ),
//         //       ),
//         //       color: widget.backgroundColor,
//         //       child: AnimatedContainer(
//         //         duration: const Duration(milliseconds: 200),
//         //         curve: Curves.ease,
//         //         padding: EdgeInsets.all(isHovered ? 20 : 10),
//         //         decoration: BoxDecoration(
//         //           color: isHovered
//         //               ? Color.fromRGBO(73, 73, 73, 1)
//         //               : widget.backgroundColor,
//         //           borderRadius: BorderRadius.circular(15),
//         //         ),
//         //         child: GestureDetector(
//         //           child: Column(
//         //             crossAxisAlignment: CrossAxisAlignment.center,
//         //             mainAxisAlignment: MainAxisAlignment.center,
//         //             children: <Widget>[
//         //               Container(
//         //                 child: Image.asset(
//         //                   widget.imagePath,
//         //                   fit: BoxFit.fill,
//         //                   scale: 15,
//         //                   // width: constraints.maxWidth * 0.5, // Adjust image width
//         //                   // height:
//         //                   // constraints.maxHeight * 0.5, // Adjust image height
//         //                   alignment: Alignment.center,
//         //                 ),
//         //               ),
//         //               SizedBox(height: 7), // Add spacing
//         //               Align(
//         //                 alignment: Alignment.bottomCenter,
//         //                 child: Text(
//         //                   widget.title,
//         //                   style: TextStyle(
//         //                     color: Colors.white,
//         //                     fontWeight: FontWeight.bold,
//         //                     fontFamily: 'Sora',
//         //                   ),
//         //                 ),
//         //               ),
//         //             ],
//         //           ),
//         //         ),
//         //       ),
//         //     ),
//         //   ),
//         // );
//       },
//     );
//   }
// }
