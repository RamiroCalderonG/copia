// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_super_parameters, avoid_function_literals_in_foreach_calls

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/constants/url_links.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/core/utils/device_information.dart';
import 'package:oxschool/core/utils/temp_data.dart';
import 'package:oxschool/data/services/backend/validate_user_permissions.dart';
import 'package:oxschool/presentation/Modules/user/user_view_screen.dart';
import 'package:get/get.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/reusable_methods/logger_actions.dart';
import '../services_ticket/processes/create_service_ticket.dart';
import '../../../core/constants/screens.dart';
import '../../components/quality_dialogs.dart';
import '../../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../../core/config/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'main_window_model.dart';
export 'main_window_model.dart';

class MainWindowWidget extends StatefulWidget {
  const MainWindowWidget({super.key});

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
    currentUser?.clear();
    eventsList?.clear();
    deviceData.clear();

    // clearUserData();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainWindowModel());
    saveUserRoleToSharedPref();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    insertAlertLog('USER LOGED IN: ${currentUser!.employeeNumber.toString()}');
  }

  void saveUserRoleToSharedPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var isUserAdmin = verifyUserAdmin(currentUser!); //Retrives user role

    await prefs.setBool('isUserAdmin', isUserAdmin);
    currentUser!.userRole!.roleModuleRelationships =
        await fetchEventsByRole(currentUser!.userRole!.roleID);
  }

  final ExpansionTileController controller =
      ExpansionTileController(); //Controller for ExpansionTile

  @override
  Widget build(BuildContext context) {
    Controller c = Get.put(Controller());

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: Opacity(
          opacity: 1,
          child: _createDrawer(context),
        ),
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            _buildAppHeader(context),
          ],
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        28.0, 5.0, 16.0, 10.0),
                    child: Column(
                      children: [
                        _buildIconsLinksGrid(context),
                        _buildFooterText(context),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      automaticallyImplyLeading: false,
      toolbarHeight: 95.0,
      title: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return constraints.maxWidth < 600
              ? _buildSmallScreenAppBar(context)
              : _buildLargeScreenAppBar(context);
        },
      ),
      bottom: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        leading: IconButton(
          hoverColor: Colors.black12,
          icon: const Icon(
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
              bool? isEnabled = canRoleConsumeEvent("Crear ticket de servicio");
              if (isEnabled != null && isEnabled == true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateServiceTicket(),
                  ),
                );
              } else {
                showInformationDialog(context, 'Error',
                    'No cuenta con permisos, consulte con el administrador');
              }
            },
            child: const Text(
              'Crear Ticket de Servicio',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallScreenAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 10.5)),
        Image.asset(
          Theme.of(context).brightness == Brightness.light
              ? 'assets/images/1_OS_color.png'
              : 'assets/images/logoBlancoOx.png',
          fit: BoxFit.fill,
          height: 50,
          filterQuality: FilterQuality.high,
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildLargeScreenAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 10.5)),
        Image.asset(
          Theme.of(context).brightness == Brightness.light
              ? 'assets/images/1_OS_color.png'
              : 'assets/images/logoBlancoOx.png',
          fit: BoxFit.fill,
          height: 50,
          filterQuality: FilterQuality.high,
        ),
        const Spacer(flex: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const UserWindow(),
                      ));
                    },
                    tooltip: 'Consultar mi información',
                    icon: const Icon(
                      Icons.person,
                      size: 30,
                    ),
                    color: const Color.fromRGBO(235, 48, 69, 0.988),
                  ),
                  Text(
                    ' ${currentUser?.employeeName?.trimRight().capitalize}',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Sora',
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 20,
                        ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 15, right: 5)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconsLinksGrid(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 50.0,
            mainAxisSpacing: 50.0,
            childAspectRatio: 1.9,
          ),
          padding: const EdgeInsets.only(left: 10, right: 10),
          itemCount: oxlinks.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Uri url = Uri.parse(oxlinks[index]);
                launchUrlDirection(url);
              },
              child: HoverCard(
                imagePath: gridMainWindowIcons[index],
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? gridMainWindowColors[index]
                        : gridDarkColorsMainWindow[index],
                title: mainWindowGridTitles[index],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooterText(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(9),
        child: Text(
          'Disciplina, Moralidad, Trabajo y Eficiencia',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Sora',
                color: FlutterFlowTheme.of(context).primaryText,
              ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return constraints.maxWidth < 600
            ? _buildSmallScreenBottomBar(context)
            : _buildLargeScreenBottomBar(context);
      },
    );
  }

  Widget _buildSmallScreenBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      width: MediaQuery.of(context).size.width,
      height: 100,
      color: const Color.fromRGBO(23, 76, 147, 1),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                showMision(context);
              },
              child: Text(
                'Misión',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Sora',
                      color: FlutterFlowTheme.of(context).info,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                showVision(context);
              },
              child: Text(
                'Visión',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Sora',
                      color: FlutterFlowTheme.of(context).info,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                qualityPolitic(context);
              },
              child: Text(
                'Politica de calidad',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Sora',
                      color: FlutterFlowTheme.of(context).info,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 13,
      color: const Color.fromRGBO(23, 76, 147, 1),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    showMision(context);
                  },
                  child: const Text(
                    'Misión',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    showVision(context);
                  },
                  child: const Text(
                    'Visión',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawer(BuildContext context) {
    final controller = ScrollController();

    return Drawer(
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                currentUser!.employeeName!.toTitleCase,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 18,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              accountEmail: Text(
                currentUser!.employeeNumber!.toString(),
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: FlutterFlowTheme.of(context).accent4,
                child: const Image(
                  image: AssetImage('assets/images/logoRedondoOx.png'),
                ),
              ),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
              ),
            ),
            MyExpansionTileList(),
            const Divider(thickness: 3),
            ListTile(
              title: const Text('Cerrar sesión'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () async {
                logOutCurrentUser(currentUser!);
                context.goNamed(
                  '_initialize',
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.leftToRight,
                    ),
                  },
                );
                clearUserData();
                clearTempData();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
              },
            ),
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

  // ignore: use_key_in_widget_constructors
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
            child: SizedBox(
              width: 100,
              height: 100,
              child: Card(
                margin: const EdgeInsets.all(2.0),
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
                        ? const Color.fromARGB(54, 204, 201, 201)
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
                          color:
                              FlutterFlowTheme.of(context).hoverCardTextColor,
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
            child: SizedBox(
              width: 100,
              height: 100,
              child: Card(
                margin: const EdgeInsets.all(2.0),
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
                  padding: EdgeInsets.all(isHovered ? 30 : 40),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? const Color.fromARGB(146, 251, 247, 247)
                        : widget.backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: GestureDetector(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Image.asset(
                            widget.imagePath,
                            color: FlutterFlowTheme.of(context).info,
                            fit: BoxFit.fill,
                            scale: 15,
                            alignment: Alignment.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context)
                                  .hoverCardTextColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Sora',
                            ),
                          ),
                        )
                        // const SizedBox(height: 7), // Add spacing
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
  //final List<dynamic> elementList;
  //final List<String> modulesList;

  const MyExpansionTileList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawerState();
}

class Controller extends GetxController {
  var title = "Dashboard".obs;
}

class _DrawerState extends State<MyExpansionTileList> {
  final Controller c = Get.find();

  List<Widget> _getChildren() {
    List<Widget> children = [];

    // Iterate through uniqueItems to create ExpansionTiles
    uniqueItems.forEach((moduleMap) {
      String moduleName = moduleMap.keys.first;
      List<String> screens = moduleMap[moduleName]!;

      List<Widget> screensMenuChildren = [];

      // Create ListTile for each screen
      screens.forEach((screen) {
        screensMenuChildren.add(
          ListTile(
            title: Text(
              screen,
              style: const TextStyle(fontFamily: 'Sora', fontSize: 15),
            ),
            onTap: () {
              // Find the appropriate route from accessRoutes
              var route = accessRoutes.firstWhere(
                (element) => element.containsKey(screen),
                orElse: () => {},
              );

              if (route.isNotEmpty) {
                context.pushNamed(
                  route[screen]!,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                    ),
                  },
                );
              }
            },
          ),
        );
      });

      // Create ExpansionTile for the current module
      children.add(
        ExpansionTile(
          title: Text(
            moduleName,
            style: const TextStyle(fontFamily: 'Sora', fontSize: 18),
          ),
          leading: moduleIcons[moduleName],
          children: screensMenuChildren,
        ),
      );
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _getChildren(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}


/*

class _DrawerState extends State<MyExpansionTileList> {
  final Controller c = Get.find();
  List<Widget> _getChildren() {
    List<Widget> children = [];
    List<Widget> screensMenuChildren = [];

//TODO: CONTINUE HERE!!
    currentUser!.userRole!.moduleScreenList!.forEach((module) {
      currentUser!.userRole!.screenEventList!.forEach((screen) {
      screensMenuChildren.add(ListTile(
        title: Text(screen.entries.first.key, style: const TextStyle(fontFamily: 'Sora', fontSize: 15), ),
         onTap: () {
          //String? route = accessRoutes[screen];
          Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => accessRoutes as Widget));
      }
      ),
     
      );
    });
      children.add(
        ExpansionTile(
          title: Text(
            module.entries.first.key, 
            style: const TextStyle(fontFamily: 'Sora', fontSize: 18),
          ),
          leading: moduleIcons[module],
          children: screensMenuChildren,
          
        ),
      );
      
    },);
    
/* 
    // Iterate over modulesMap to create ExpansionTiles for each module
    modulesList.forEach((module) {
      
      screens.forEach((screen) {
        screensMenuChildren.add(ListTile(
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
          leading: const Icon(
            Icons.arrow_right_sharp,
            size: 10,
          ),
        ));
      });

      children.add(
        ExpansionTile(
          title: Text(
            module,
            style: const TextStyle(fontFamily: 'Sora', fontSize: 18),
          ),
          leading: moduleIcons[module],
          children: screensMenuChildren,
          // leading: Icon(
          //   Icons.subdirectory_arrow_right_rounded,
          //   size: ,
          // ),
        ),
      );
    }); */

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _getChildren(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

*/