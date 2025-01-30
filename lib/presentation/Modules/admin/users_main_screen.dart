// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
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
  var listOfUsers;

  Future<void> refreshButton() async {
    setState(() {
      isLoading = true;
      // isSateManagerActive = true;
    });
    try {
      listOfUsers = null;
      listOfUsersForGrid = null;
      userRows.clear();
      listOfUsers = await getUsers();
      if (listOfUsers != null) {
        setState(() {
          usersPlutoRowList = userRows;
          // super.initState();
          List<dynamic> jsonList = json.decode(listOfUsers);
          listOfUsersForGrid = parseUsersFromJSON(jsonList);
          // userRows = createPlutoRows(listOfUsersForGrid);
        });
      } else {
        if (kDebugMode) {
          insertErrorLog(
              'Cant fetch data from server, getUsers()', 'users_main_screen');
          print('Cant fetch  data from server');
        }
      }
    } catch (e) {
      isLoading = false;
      insertErrorLog(e.toString(), 'UsersMainScreen() , refreshButton');
      AlertDialog(
        title: const Text("Error"),
        content: Text(e.toString()),
      );
    }
    setState(() {
      isLoading = false;
      // isSateManagerActive = true;
    });
  }

  @override
  void initState() {
    isLoading = false;
    //refreshButton();
    super.initState();
  }

  @override
  void dispose() {
    tmpRolesList.clear();
    userRows.clear();
    // listOfUsersForGrid.clear();
    isLoading = false;
    areaList.clear();
    listOfUsers = null;
    listOfUsersForGrid = null;
    userRows.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            bottom: AppBar(automaticallyImplyLeading: false, actions: [
              TextButton.icon(
                  onPressed: () {
                    try {
                      //TODO: WHY DOES IT NEED TO BE IN TWO SEPARATE CALLS?
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
                  label: const Text('Administrar roles de usuarios')),
              TextButton.icon(
                  onPressed: () async {
                    campuseList.clear();
                    areaList.clear();
                    await getAllCampuse();
                    await getWorkDepartmentList();
                    var response = await getRolesList();
                    tmpRolesList = jsonDecode(response);

                    buildNewUserScreen(context);
                    await getEventsList();
                  },
                  icon: const FaIcon(FontAwesomeIcons.addressCard),
                  label: const Text('Nuevo usuario')),
              RefreshButton(
                onPressed: refreshButton,
              ),
              // TextButton.icon(
              //     onPressed: () async {
              //       refreshButton();
              //     },
              //     icon: const Icon(Icons.refresh),
              //     label: const Text('Refresca')),
              // TextButton.icon(
              //     onPressed: () {},
              //     icon: FaIcon(FontAwesomeIcons.download),
              //     label: Text('Exportar ususarios')),
              const SizedBox(width: 20),
            ]),
            backgroundColor: FlutterFlowTheme.of(context).primary,
            title: const Text('Administración de usuarios',
                style: TextStyle(color: Colors.white))),
        body: Stack(
          children: [
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              if (listOfUsersForGrid != null) {
                return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const UsersTableView());
              } else {
                return const NoDataAvailble();
              }
            }),
            if (isLoading) CustomLoadingIndicator()
          ],
        ));
  }
}

void buildNewUserScreen(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(50),
          title: const Text(
            'Nuevo usuario',
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
