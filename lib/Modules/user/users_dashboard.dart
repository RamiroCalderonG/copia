import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/Modules/enfermeria/no_data_avalibre.dart';
import 'package:oxschool/Modules/user/create_user.dart';
import 'package:oxschool/Modules/user/roles_screen.dart';
import 'package:oxschool/Modules/user/users_table_view.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/reusable_methods/reusable_functions.dart';
import 'package:oxschool/temp/users_temp_data.dart';
import 'package:oxschool/utils/loader_indicator.dart';

import '../../backend/api_requests/api_calls_list.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../reusable_methods/temp_data_functions.dart';
import '../../reusable_methods/user_functions.dart';

class UsersDashboard extends StatefulWidget {
  const UsersDashboard({super.key});

  @override
  State<UsersDashboard> createState() => _UsersDashboardState();
}

class _UsersDashboardState extends State<UsersDashboard> {
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
        print('Cant fetch  data from server');
      }
    } catch (e) {
      isLoading = false;
      AlertDialog(
        title: Text("Error"),
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

  void dispose() {
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RolesAndProfilesScreen()));
                  },
                  icon: Icon(Icons.verified_user),
                  label: Text('Administrar roles de usuarios')),
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
                  icon: FaIcon(FontAwesomeIcons.addressCard),
                  label: Text('Nuevo usuario')),
              TextButton.icon(
                  onPressed: () async {
                    refreshButton();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Refresca')),
              // TextButton.icon(
              //     onPressed: () {},
              //     icon: FaIcon(FontAwesomeIcons.download),
              //     label: Text('Exportar ususarios')),
              SizedBox(width: 20),
            ]),
            backgroundColor: FlutterFlowTheme.of(context).primary,
            title: Text('Administración de usuarios',
                style: TextStyle(color: Colors.white))),
        body: Stack(
          children: [
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < 600) {
                return Card(
                  child: Placeholder(),
                );
              } else {
                if (listOfUsersForGrid != null) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      child: UsersTableView());
                } else {
                  return NoDataAvailble();
                }
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
          contentPadding: EdgeInsets.all(50),
          title: const Text(
            'Nuevo usuario',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Sora'),
          ),
          content: NewUserScreen(),
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
