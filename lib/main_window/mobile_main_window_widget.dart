import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:oxschool/constants/User.dart';

import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/flutter_flow/flutter_flow_util.dart';
import 'package:oxschool/main_window/main_window_widget.dart';
import 'package:oxschool/Modules/user/user_view_screen.dart';

import '../constants/url_links.dart';

class MobileMainWindow extends StatefulWidget {
  const MobileMainWindow({super.key});

  @override
  State<MobileMainWindow> createState() => _MobileMainWindowState();
}

class _MobileMainWindowState extends State<MobileMainWindow> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
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
    Controller c = Get.put(Controller());
    //Define appbar for mobile version
    final appBar = SliverAppBar(
      pinned: false,
      floating: true,
      snap: true,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      automaticallyImplyLeading: false,
      toolbarHeight: 70.0,
      title: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 200) {
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
                  height: 40,
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
                Padding(padding: EdgeInsets.only(left: 5.5)),
                Center(
                  child: Image.asset(
                    Theme.of(context).brightness == Brightness.light
                        ? 'assets/images/1_OS_color.png' //igth theme image
                        : 'assets/images/logoBlancoOx.png', //Dark theme image
                    fit: BoxFit.fill,
                    height: 40,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const UserWindow()));
                            },
                            icon: const Icon(Icons.person),
                            iconSize: 30.2,
                            color: Color.fromRGBO(235, 48, 69, 0.988),
                          ),
                          Text(
                              '${currentUser?.employeeName?.toLowerCase().trimRight()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 18,
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText) // FlutterFlowTheme.of(context).bodyMedium,
                              ),
                          // Padding(padding: EdgeInsets.only(left: 5, right: 5)),
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
            Icons.menu,
            size: 30,
            // size: 40.5,
          ),
          onPressed: () async {
            scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
    );

// LIST OF CARDS TO SHOW
    final menuListItems = Center(
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(5),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, childAspectRatio: 3),

            // physics: NeverScrollableScrollPhysics(),
            itemCount: oxlinks.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Uri _url = Uri.parse(oxlinks[index]);
                  launchUrlDirection(_url);
                },
                child: HoverCard(
                  imagePath: gridMainWindowIcons[index],
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? gridMainWindowColors[index] //igth theme image
                          : gridDarkColorsMainWindow[index], //Dark theme image

                  title: mainWindowGridTitles[index],
                ),
              );
            }),
      ),
    );

    Widget _createDrawer(
        BuildContext context, Future<http.Response> userEvents) {
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
                  child: Image(
                      image: AssetImage('assets/images/logoRedondoOx.png')),
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
                  // clearStudentData();
                  // clearUserData();

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
          headerSliverBuilder: (context, _) => [
            appBar,
          ],
          floatHeaderSlivers: true,
          body: Placeholder(
            strokeWidth: 0.0,
            child: menuListItems,
          ),

          // body: Builder(
          //   builder: (context) {
          //     return SafeArea(
          //         top: false,
          //         child: Align(
          //           alignment: AlignmentDirectional(0.0, 0.0),
          //           child: Column(
          //             children: [],
          //           ),
          //         ));
          //   },
          // ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromRGBO(82, 170, 94, 1.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          tooltip: 'Menu rapido',
          onPressed: () {},
          child: PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 1,
                child: Text('Crear ticket de servicio'),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Text('Consultar recibo de nomina'),
              ),
              PopupMenuItem<int>(
                value: 3,
                child: Text('Consulta huellas en checador'),
              ),
            ],
            onSelected: (value) {
              // Handle the selected option here
            },
            child: const Icon(Icons.add, size: 28),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF0299FF),
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.home,
                    color: Color.fromRGBO(43, 217, 254, 1.0),
                    size: 35.5,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 35.5,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

final menuListItems = Center(
  child: Container(
    padding: EdgeInsets.all(5),
    margin: EdgeInsets.all(5),
    child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, childAspectRatio: 3),

        // physics: NeverScrollableScrollPhysics(),
        itemCount: oxlinks.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Uri _url = Uri.parse(oxlinks[index]);
              launchUrlDirection(_url);
            },
            child: HoverCard(
              imagePath: gridMainWindowIcons[index],
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? gridMainWindowColors[index] //igth theme image
                  : gridDarkColorsMainWindow[index], //Dark theme image

              title: mainWindowGridTitles[index],
            ),
          );
        }),
  ),
);

Widget mobileViewBody() {
  return Placeholder(
    strokeWidth: 0.0,
    child: menuListItems,
  );
}
