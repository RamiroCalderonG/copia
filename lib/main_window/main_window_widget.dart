import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:oxschool/constants/User.dart';
import 'package:oxschool/constants/url_links.dart';
import 'package:oxschool/Modules/user/user_view_screen.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:oxschool/temp/users_temp_data.dart';

import '../Modules/services_ticket/processes/create_service_ticket.dart';
import '../constants/screens.dart';
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

// var _selectedPageIndex = 0;
// late PageController _pageController;

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
    // ignore: unused_local_variable
    Controller c = Get.put(Controller());
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
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Sora',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText, // FlutterFlowTheme.of(context).bodyMedium,
                                  )),
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
            Icons.menu_open_outlined,
            size: 38.5,
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
                            child: const Text(''),
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
              padding: EdgeInsets.only(left: 10, right: 10),
              // shrinkWrap: true,
              itemCount: oxlinks.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Uri _url = Uri.parse(oxlinks[index]);
                    launchUrlDirection(_url);
                  },
                  child: HoverCard(
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
        drawer: Opacity(
            opacity: 1,
            child: _createDrawer(context, userEvents) //DrawerClass()
            ),
        body: NestedScrollView(
          // physics: NeverScrollableScrollPhysics(),
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
                          flex: 3,
                          child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  28.0, 5.0, 16.0, 10.0),
                              child: Column(
                                children: [
                                  iconsLinksGrid,
                                  Align(
                                      alignment:
                                          AlignmentDirectional.bottomCenter,
                                      child: Container(
                                        margin: EdgeInsets.all(9),
                                        child: Text(
                                          'Disciplina, Moralidad, Trabajo y Eficiencia',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Sora',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                        ),
                                      ))
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
                                  padding: EdgeInsets.only(top: 10),
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
                                          ],
                                        ),
                                      ],
                                    )),
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

  Widget _createDrawer(BuildContext context, Future<http.Response> userEvents) {
    final _controller = ScrollController();

    return Drawer(
      child: SingleChildScrollView(
        controller: _controller,
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                currentUser!.employeeName!,
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18,
                    color: FlutterFlowTheme.of(context).primaryText),
              ),
              accountEmail: Text(
                currentUser!.employeeNumber!.toString(),
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    color: FlutterFlowTheme.of(context).primaryText),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: FlutterFlowTheme.of(context).accent4,
                child:
                    Image(image: AssetImage('assets/images/logoRedondoOx.png')),
                // Text(currentUser!.employeeName![0],
                //     style: TextStyle(fontFamily: 'Sora', fontSize: 20)),
              ),
              decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground),
            ),
            new FutureBuilder(
                future: userEvents,
                builder: (BuildContext context,
                    AsyncSnapshot<http.Response> response) {
                  if (!response.hasData) {
                    return const Center(
                      child: const Text('Loading...'),
                    );
                  } else if (response.data!.statusCode != 200) {
                    return const Center(
                      child: const Text('Error Loading'),
                    );
                  } else {
                    List<dynamic> json = jsonDecode(response.data!.body);
                    return MyExpansionTileList(elementList: json);
                  }
                }),
            Divider(thickness: 3),
            ListTile(
              title: Text('Cerrar sesión'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () {
                // Clear any necessary data or variables
                // clearStudentData();
                // clearUserData();
                setState(() {
                  currentUser?.clear();
                  currentCycle?.clear();
                  eventsList?.clear();
                  deviceIp = '';
                  cleatTempData();
                });

                // Navigate to the initial screen

                context.goNamed(
                  '_initialize',
                  extra: <String, dynamic>{
                    kTransitionInfoKey: TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.leftToRight,
                    ),
                  },
                );
                // Navigator.pop(context);
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (context) => LoginViewWidget()));
              },
            )
          ],
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
      },
    );
  }
}

class MyExpansionTileList extends StatefulWidget {
  // BuildContext context;
  final List<dynamic> elementList;

  MyExpansionTileList({Key? key, required this.elementList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawerState();
}

class Controller extends GetxController {
  var title = "Dashboard".obs;
}

class _DrawerState extends State<MyExpansionTileList> {
  final Controller c = Get.find();
  List<Widget> _getChildren(final List<dynamic> userEvents) {
    List<Widget> children = [];

    // Map to store unique module titles and their screen classes
    Map<String, List<String>> modulesMap = {};

    // Iterate over userEvents to populate modulesMap
    userEvents.forEach((element) {
      element.forEach((module, screens) {
        if (!modulesMap.containsKey(module)) {
          modulesMap[module] = [];
        }
        screens.forEach((screenClass, description) {
          modulesMap[module]!.add('$screenClass');
        });
      });
    });

    // Iterate over modulesMap to create ExpansionTiles for each module
    modulesMap.forEach((module, screens) {
      List<Widget> subMenuChildren = [];
      screens.forEach((screen) {
        subMenuChildren.add(ListTile(
          title: Text(
            screen,
            style: const TextStyle(fontFamily: 'Sora', fontSize: 15),
          ),
          onTap: () {
            String moduleKey = screen;
            // ignore: unused_local_variable
            String? moduleValue;

            modulesMapped.forEach((k, v) {
              if (k == moduleKey) {
                moduleValue = v;
              }
            });
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => pageRoutes[screen]));

            // print('Selected screen: $screen');
          },
          leading: Icon(
            Icons.arrow_right_sharp,
            size: 10,
          ),
        ));
      });

      children.add(
        ExpansionTile(
          title: Text(
            module,
            style: TextStyle(fontFamily: 'Sora', fontSize: 18),
          ),
          children: subMenuChildren,
          leading: moduleIcons[module],
          // leading: Icon(
          //   Icons.subdirectory_arrow_right_rounded,
          //   size: ,
          // ),
        ),
      );
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: _getChildren(widget.elementList),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
