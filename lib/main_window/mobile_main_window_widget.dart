import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/components/create_service_ticket.dart';
import 'package:oxschool/components/drawer_menu.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/main_window/main_window_widget.dart';
import 'package:oxschool/user/user_view_view.dart';

import '../constants/url_links.dart';

class MobileMainWindow extends StatefulWidget {
  const MobileMainWindow({super.key});

  @override
  State<MobileMainWindow> createState() => _MobileMainWindowState();
}

class _MobileMainWindowState extends State<MobileMainWindow> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
                                  color: Colors
                                      .black87) // FlutterFlowTheme.of(context).bodyMedium,
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

    return Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: Opacity(opacity: 1, child: DrawerClass()),
        body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
                  appBar,
                ],
            floatHeaderSlivers: true,
            body: Placeholder(
              strokeWidth: 0.0,
              child: menuListItems,
            )
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
            ));
  }
}
