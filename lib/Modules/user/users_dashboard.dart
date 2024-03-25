import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/Models/User.dart';
import 'package:oxschool/Modules/enfermeria/expandable_fab.dart';
import 'package:oxschool/Modules/enfermeria/no_data_avalibre.dart';
import 'package:oxschool/Modules/user/create_user.dart';
import 'package:oxschool/Modules/user/edit_user_screen.dart';
import 'package:oxschool/Modules/user/users_table_view.dart';
import 'package:oxschool/components/plutogrid_export_options.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/temp/users_temp_data.dart';
import 'package:oxschool/utils/loader_indicator.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../backend/api_requests/api_calls_list.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../reusable_methods/user_functions.dart';

class UsersDashboard extends StatefulWidget {
  const UsersDashboard({super.key});

  @override
  State<UsersDashboard> createState() => _UsersDashboardState();
}

class _UsersDashboardState extends State<UsersDashboard> {
  // late final PlutoGridStateManager stateManager;
  // bool isSateManagerActive = true;
  bool isUserAdmin = verifyUserAdmin(currentUser!);
  bool confirmation = false;
  var listOfUsers;
  // List<PlutoRow> userRows = [];

  //  List<PlutoColumn> employeeDashboardColumns = <PlutoColumn>[
  //   PlutoColumn(
  //       title: 'Id',
  //       field: 'id',
  //       type: PlutoColumnType.text(),
  //       readOnly: true,
  //       sort: PlutoColumnSort.ascending,
  //       width: 80,
  //       frozen: PlutoColumnFrozen.start),
  //   PlutoColumn(
  //       title: 'Nombre',
  //       field: 'employeeName',
  //       type: PlutoColumnType.text(),
  //       readOnly: true),
  //   PlutoColumn(
  //       title: 'Numero de empleado',
  //       field: 'employeeNumber',
  //       type: PlutoColumnType.number(),
  //       readOnly: true),
  //   PlutoColumn(
  //       title: 'Rol del usuario',
  //       field: 'userRole',
  //       type: PlutoColumnType.text(),
  //       readOnly: true),
  //   // PlutoColumn(
  //   //     title: 'Fecha de Ingreso',
  //   //     field: 'joinDate',
  //   //     type: PlutoColumnType.date(),
  //   //     readOnly: true),
  //   PlutoColumn(
  //       title: 'Campus',
  //       field: 'campus',
  //       type: PlutoColumnType.text(),
  //       readOnly: true),
  //   // PlutoColumn(
  //   //     title: 'Departamento',
  //   //     field: 'area',
  //   //     type: PlutoColumnType.text(),
  //   //     readOnly: true),
  //   PlutoColumn(
  //       title: 'Baja',
  //       field: 'isActive',
  //       type: PlutoColumnType.text(),
  //       width: 70,
  //       readOnly: true),
  //   PlutoColumn(
  //       title: 'e-mail',
  //       field: 'mail',
  //       type: PlutoColumnType.text(),
  //       readOnly: true),
  //   // PlutoColumn(
  //   //   title: 'Foto',
  //   //   field: 'photo',
  //   //   type: PlutoColumnType.text()),

  //   // PlutoColumn(
  //   //   title: 'salary',
  //   //   field: 'salary',
  //   //   type: PlutoColumnType.currency(),
  //   //   footerRenderer: (rendererContext) {
  //   //     return PlutoAggregateColumnFooter(
  //   //       rendererContext: rendererContext,
  //   //       formatAsCurrency: true,
  //   //       type: PlutoAggregateColumnType.sum,
  //   //       format: '#,###',
  //   //       alignment: Alignment.center,
  //   //       titleSpanBuilder: (text) {
  //   //         return [
  //   //           const TextSpan(
  //   //             text: 'Sum',
  //   //             style: TextStyle(color: Colors.red),
  //   //           ),
  //   //           const TextSpan(text: ' : '),
  //   //           TextSpan(text: text),
  //   //         ];
  //   //       },
  //   //     );
  //   //   },
  //   // ),
  // ];

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

  // void updateRows(List<PlutoRow> newRows) {
  //   setState(() {
  //     // stateManager.getNewRows();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // final List<PlutoColumnGroup> columnGroups = [
    //   PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: false),
    //   PlutoColumnGroup(title: 'Información Gral', fields: [
    //     'employeeName',
    //     'employeeNumber',
    //     'userRole',
    //     'claun',
    //   ]),
    //   PlutoColumnGroup(title: 'Status', children: [
    //     // PlutoColumnGroup(
    //     //     title: 'A', fields: ['userRole'], expandedColumn: true),
    //     PlutoColumnGroup(title: 'Activo', fields: ['isActive', 'mail']),
    //   ]),
    // ];

    // var usersGridBody = PlutoGrid(
    //   onRowSecondaryTap: (event) {
    //     // Show menu at a fixed position
    //     final RenderBox overlay =
    //         Overlay.of(context).context.findRenderObject() as RenderBox;
    //     showMenu(
    //       context: context,
    //       position: RelativeRect.fromRect(
    //         Rect.fromPoints(
    //           overlay.localToGlobal(event.offset),
    //           overlay.localToGlobal(overlay.size.bottomRight(event.offset)),
    //         ),
    //         Offset.zero & overlay.size,
    //       ),
    //       items: <PopupMenuEntry>[
    //         PopupMenuItem(
    //           child: Text('Dar de baja usuario'),
    //           onTap: () async {
    //             setState(() {
    //               isLoading = true;
    //             });
    //             debugPrint('id: ' + event.row.cells.values.first.value);

    //             try {
    //               showDialog(
    //                   context: context,
    //                   builder: (BuildContext context) {
    //                     return AlertDialog(
    //                       icon: const Icon(Icons.warning),
    //                       iconColor: Colors.yellow,
    //                       title: const Text('Confirmar'),
    //                       content: const Text('Dar de baja ususario?'),
    //                       actions: [
    //                         Row(
    //                           children: [
    //                             Expanded(
    //                                 child: TextButton(
    //                                     onPressed: () {
    //                                       setState(() {
    //                                         confirmation = true;
    //                                       });
    //                                     },
    //                                     child: Text('Si'))),
    //                             Expanded(
    //                                 child: TextButton(
    //                                     onPressed: () {
    //                                       Navigator.of(context).pop();
    //                                     },
    //                                     child: Text('No')))
    //                           ],
    //                         )
    //                       ],
    //                     );
    //                   });
    //               if (confirmation) {
    //                 await deleteUser(event.row.cells.values.first.value)
    //                     .whenComplete(() {
    //                   listOfUsers = null;
    //                   listOfUsersForGrid = null;
    //                   userRows.clear();
    //                   setState(() {
    //                     refreshButton();

    //                     isLoading = false;
    //                   });
    //                 });
    //               }
    //             } catch (e) {
    //               setState(() {
    //                 isLoading = false;
    //               });
    //               if (e != null) {
    //                 showDialog(
    //                     context: context,
    //                     builder: (BuildContext context) {
    //                       return AlertDialog(
    //                         icon: Icon(Icons.error),
    //                         title: Text('Error'),
    //                         content: Text(e.toString()),
    //                       );
    //                     });
    //               }
    //             }
    //             setState(() {
    //               refreshButton();
    //               isLoading = false;
    //             });

    //             // Handle Option 1
    //           },
    //           enabled: isUserAdmin,
    //         ),
    //         PopupMenuItem(
    //           child: Text('Modificar usuario'),
    //           onTap: () async {
    //             tempUserId = event.row.cells.values.first.value;
    //             await getSingleUser(null);
    //             updateUserScreen(context);
    //             // Handle Option 2
    //           },
    //           enabled: isUserAdmin,
    //         ),
    //       ],
    //     );
    //   },
    //   mode: PlutoGridMode.readOnly,
    //   columns: employeeDashboardColumns,
    //   rows: usersPlutoRowList,
    //   // columnGroups: columnGroups,
    //   onLoaded: (PlutoGridOnLoadedEvent event) {
    //     stateManager = event.stateManager;
    //     stateManager.setShowColumnFilter(true);
    //     // stateManager = event.stateManager;
    //     // stateManager = event.stateManager;
    //     // stateManager.setShowColumnFilter(true);
    //   },
    //   // onChanged: (PlutoGridOnChangedEvent event) {
    //   //   print(event);
    //   // },
    //   configuration: const PlutoGridConfiguration(),
    //   rowColorCallback: (rowColorContext) {
    //     if (rowColorContext.row.cells.entries.elementAt(5).value.value == 1) {
    //       return Colors.red.shade50;
    //     } else if (rowColorContext.row.cells.entries.elementAt(4).value.value ==
    //         1) {
    //       return Colors.red.shade50;
    //     }
    //     return Colors.transparent;
    //   },
    //   createHeader: (stateManager) => Header(stateManager: stateManager),
    //   createFooter: (stateManager) {
    //     stateManager.setPageSize(50, notify: false); // default 40
    //     return PlutoPagination(stateManager);
    //   },
    // );

    return Scaffold(
        appBar: AppBar(
            bottom: AppBar(automaticallyImplyLeading: false, actions: [
              TextButton.icon(
                  onPressed: () async {},
                  icon: Icon(Icons.verified_user),
                  label: Text('Administrar roles de usuarios')),
              TextButton.icon(
                  onPressed: () async {
                    buildNewUserScreen(context);
                  },
                  icon: FaIcon(FontAwesomeIcons.addressCard),
                  label: Text('Agregar usuario')),
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
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Container(
                        padding: const EdgeInsets.all(15),
                        child: UsersTableView()),
                  );
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

// void updateUserScreen(BuildContext context) {
//   showDialog(
//       context: context,
//       builder: (BuildContextcontext) {
//         return AlertDialog(
//           contentPadding: EdgeInsets.all(20),
//           title: const Text(
//             'Editar usuario',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontFamily: 'Sora'),
//           ),
//           content: EditUserScreen(),
//           actions: <Widget>[
//             TextButton(
//               style: TextButton.styleFrom(
//                 textStyle: Theme.of(context).textTheme.labelLarge,
//               ),
//               child: const Text('Cancelar'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 selectedUser = null;
//               },
//             )
//           ],
//         );
//       });
// }

// List<PlutoRow> createPlutoRows(List<User> users) {
//   List<PlutoRow> rows = [];
//   for (var user in users) {
//     rows.add(PlutoRow(
//       cells: {
//         'id': PlutoCell(value: user.userId.toString()),
//         'employeeName': PlutoCell(value: user.employeeName),
//         'employeeNumber': PlutoCell(value: user.employeeNumber),
//         'userRole': PlutoCell(value: user.role),
//         'isActive': PlutoCell(value: user.isActive),
//         'campus': PlutoCell(value: user.claUn),
//         // 'area': PlutoCell(value: user),
//         'mail': PlutoCell(value: user.userEmail)
//       },
//     ));

//     // PlutoRow row = ;
//     // rows.add(row);
//   }
//   return rows;
// }
