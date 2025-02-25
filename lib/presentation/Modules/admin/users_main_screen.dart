// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/core/reusable_methods/device_functions.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/Role.dart';
import 'package:oxschool/data/Models/User.dart';
import 'package:oxschool/presentation/Modules/enfermeria/no_data_avalibre.dart';
import 'package:oxschool/presentation/Modules/user/create_user.dart';
import 'package:oxschool/presentation/Modules/user/roles_screen.dart';
import 'package:oxschool/presentation/Modules/admin/users_table_view.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';
import 'package:oxschool/presentation/components/mobile_FloatingActionButton.dart';

import '../../../data/services/backend/api_requests/api_calls_list.dart';
import '../../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../../core/reusable_methods/temp_data_functions.dart';
import '../../../core/reusable_methods/user_functions.dart';

class UsersMainScreen extends StatefulWidget {
  const UsersMainScreen({super.key});

  @override
  State<UsersMainScreen> createState() => _UsersMainScreenState();
}

class _UsersMainScreenState extends State<UsersMainScreen> {
  bool isUserAdmin = verifyUserAdmin(currentUser!);
  bool confirmation = false;
  Key _key = UniqueKey();
  late Future<dynamic> loadingCOntroller;
  bool isLoading = true;
  bool isDeviceMobile = false;

  void _restartScreen() async {
    _key = UniqueKey();
    loadingCOntroller = refreshButton();
    //await refreshButton();
    // setState(() {
    //   refreshButton();
    // });
  }

  Future<dynamic> refreshButton() async {
    isDeviceMobile = await isCurrentDeviceMobile();
    setState(() {
      isLoading = true;
      listOfUsersForGrid.clear();
      userRows.clear();
    });
    try {
      await getUsers().then((response) {
        if (response != null) {
          List<dynamic> jsonList = json.decode(response);
          setState(() {
            usersPlutoRowList = userRows;
            for (var item in jsonList) {
              User newUser = User.usersSimplifiedList(item);
              listOfUsersForGrid.add(newUser);
            }
          });
          return response;
          // listOfUsersForGrid = parseUsersFromJSON(jsonList);
        } else {
          if (kDebugMode) {
            insertErrorLog(
                'Cant fetch data from server, getUsers()', 'users_main_screen');
            print('Cant fetch  data from server');
          }
        }
        return response;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        insertErrorLog(e.toString(), 'UsersMainScreen() , refreshButton');
        showErrorFromBackend(context, e.toString());
      });
    }
    setState(() {
      isLoading = false;
      // isSateManagerActive = true;
    });
  }

  @override
  void initState() {
    isLoading = false;
    loadingCOntroller = refreshButton();
    super.initState();
  }

  @override
  void dispose() {
    tmpRolesList.clear();
    userRows.clear();
    // listOfUsersForGrid.clear();
    isLoading = false;
    areaList.clear();
    listOfUsersForGrid.clear();
    userRows.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar mobileAppBar = AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  children: [
                    IconButton(
                        tooltip: 'Administrar roles de usuarios',
                        padding: const EdgeInsets.all(3),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.lightBlue)),
                        onPressed: () {
                          try {
                            getEventsTempList().whenComplete(() async {
                              await getRolesTempList().whenComplete(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RolesAndProfilesScreen()));
                              });
                            });
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });
                            insertErrorLog(e.toString(), 'UsersMainScreen()');
                            showErrorFromBackend(context, e.toString());
                          }
                        },
                        icon: const Icon(Icons.verified_user)),
                    Text('Administrar roles')
                  ],
                ),
              ),
              // const SizedBox(width: 10),
              Flexible(
                child: Column(
                  children: [
                    IconButton(
                        padding: const EdgeInsets.all(3),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        style: ButtonStyle(
                            backgroundColor:
                                const WidgetStatePropertyAll(Colors.lightBlue)),
                        tooltip: 'Nuevo usuario',
                        onPressed: () async {
                          try {
                            campuseList.clear();
                            areaList.clear();
                            await getAllCampuse().then((response) async {
                              await getWorkDepartmentList();
                              await getRolesList().then((onValue) async {
                                tmpRolesList = jsonDecode(onValue.body);
                                for (var item in tmpRolesList) {
                                  Role newRole = Role.fromJson(item);
                                  tmpRoleObjectslist.add(newRole);
                                }
                                await getEventsList().then((onValue) {
                                  setState(() {
                                    buildNewUserScreen(context);
                                  });
                                });
                              });
                            }).onError((error, stacktrace) {
                              insertErrorLog(
                                  error.toString(), stacktrace.toString());
                            });
                          } catch (e) {
                            insertErrorLog(
                                e.toString(), 'users_main_screen 159');
                            setState(() {
                              isLoading = false;
                              showErrorFromBackend(context, e.toString());
                            });
                          }
                        },
                        icon: const Icon(Icons.add)),
                    Text('Nuevo Usuario')
                  ],
                ),
              ),
              // const SizedBox(width: 10),
              Flexible(
                  child: Column(
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(3),
                    color: const Color.fromARGB(255, 255, 255, 255),
                    style: ButtonStyle(
                        backgroundColor:
                            const WidgetStatePropertyAll(Colors.lightBlue)),
                    tooltip: 'Refrescar',
                    icon: const Icon(Icons.refresh),
                    onPressed: _restartScreen,
                  ),
                  Text('Refrescar')
                ],
              )),
            ],
          ),
        ));

    return Scaffold(
      key: _key,
      appBar: AppBar(
          bottom: isDeviceMobile
              ? mobileAppBar
              : AppBar(automaticallyImplyLeading: false, actions: [
                  TextButton.icon(
                      onPressed: () {
                        try {
                          //?WHY DOES IT NEED TO BE IN TWO SEPARATE CALLS?
                          getEventsTempList().whenComplete(() async {
                            await getRolesTempList().whenComplete(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RolesAndProfilesScreen()));
                            });
                          });
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          insertErrorLog(e.toString(), 'UsersMainScreen()');
                          showErrorFromBackend(context, e.toString());
                        }
                      },
                      icon: const Icon(Icons.verified_user),
                      label: Text('Administrar roles de usuarios')),
                  TextButton.icon(
                      onPressed: () async {
                        try {
                          campuseList.clear();
                          areaList.clear();
                          await getAllCampuse().then((response) async {
                            await getWorkDepartmentList();
                            await getRolesList().then((onValue) async {
                              tmpRolesList = jsonDecode(onValue.body);
                              for (var item in tmpRolesList) {
                                Role newRole = Role.fromJson(item);
                                tmpRoleObjectslist.add(newRole);
                              }
                              await getEventsList().then((onValue) {
                                setState(() {
                                  buildNewUserScreen(context);
                                });
                              });
                            });
                          }).onError((error, stacktrace) {
                            insertErrorLog(
                                error.toString(), stacktrace.toString());
                          });
                        } catch (e) {
                          insertErrorLog(e.toString(), 'users_main_screen 159');
                          setState(() {
                            isLoading = false;
                            showErrorFromBackend(context, e.toString());
                          });
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.addressCard),
                      label: const Text('Nuevo usuario')),
                  RefreshButton(
                    onPressed: _restartScreen,
                  ),
                  // const SizedBox(width: 20),
                ]),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          title: const Text('Administración de usuarios',
              style: TextStyle(color: Colors.white))),
      body: FutureBuilder(
          future: loadingCOntroller,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const UsersTableView());
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomLoadingIndicator();
            } else if (snapshot.hasError) {
              return Placeholder(
                  child: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                ),
              ));
            } else {
              return const NoDataAvailble();
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          isDeviceMobile ? mobileFloatingActionButton(context) : null,

      // Stack(
      //   children: [
      //     LayoutBuilder(
      //         builder: (BuildContext context, BoxConstraints constraints) {
      //       if (listOfUsersForGrid != null) {
      //         return SizedBox(
      //             width: MediaQuery.of(context).size.width,
      //             child: const UsersTableView());
      //       } else {
      //         return const NoDataAvailble();
      //       }
      //     }),
      //     if (isLoading) CustomLoadingIndicator()
      //   ],
      // )
    );
  }
}

void buildNewUserScreen(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(50),
          title: const Text(
            ' Crear nuevo usuario',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Sora'),
          ),
          content: const NewUserScreen(),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
