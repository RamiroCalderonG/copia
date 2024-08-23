// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/presentation/Modules/enfermeria/no_data_avalibre.dart';
import 'package:oxschool/presentation/Modules/user/create_user.dart';
import 'package:oxschool/presentation/Modules/user/roles_screen.dart';
import 'package:oxschool/presentation/Modules/user/users_table_view.dart';
import 'package:oxschool/core/constants/User.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';

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
          print('Cant fetch  data from server');
        }
      }
    } catch (e) {
      isLoading = false;
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
    // refreshButton();
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
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    await getEventsList();

                    var response = await getRolesList();
                    tmpRolesList = jsonDecode(response);
                    setState(() {
                      isLoading = false;
                    });
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const RolesAndProfilesScreen()));
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
              TextButton.icon(
                  onPressed: () async {
                    refreshButton();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresca')),
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
