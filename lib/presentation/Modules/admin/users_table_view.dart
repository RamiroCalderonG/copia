// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/presentation/Modules/admin/edit_user_screen.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/presentation/Modules/login_view/login_view_widget.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:pluto_grid/pluto_grid.dart';

class UsersTableView extends StatefulWidget {
  const UsersTableView({super.key});

  @override
  State<UsersTableView> createState() => _UsersTableViewState();
}

class _UsersTableViewState extends State<UsersTableView> {
  List<PlutoRow> userRows = [];
  // ignore: prefer_typing_uninitialized_variables
  var toSee;
  bool isUserAdmin = currentUser!.isCurrentUserAdmin();
  bool confirmation = false;
  bool isSearching = true;
  late final PlutoGridStateManager stateManager;
  // ignore: prefer_typing_uninitialized_variables
  var listOfUsers;

  @override
  void initState() {
    for (var line in listOfUsersForGrid) {
      userRows.add(PlutoRow(
        cells: {
          'id': PlutoCell(value: line.userId.toString()),
          'employeeName': PlutoCell(value: line.employeeName),
          'employeeNumber': PlutoCell(value: line.employeeNumber),
          'userRole': PlutoCell(value: line.role),
          'isActive': PlutoCell(value: line.isActive),
          'campus': PlutoCell(value: line.claUn),
          // 'area': PlutoCell(value: user),
          'mail': PlutoCell(value: line.userEmail),
          'creation': PlutoCell(value: line.creationDate),
          'birthdate': PlutoCell(value: line.birthdate),
          'position': PlutoCell(value: line.work_area)
        },
      ));
    }
    areaList.clear();
    super.initState();
  }

  @override
  void dispose() {
    //stateManager.dispose();
    areaList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(1),
          child: Column(
            children: [],
          ),
        ),
        if (isSearching)
          const SizedBox(
            height: 5,
          ),
        const Divider(
          thickness: 1,
        ),
        Expanded(
            child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(2),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: PlutoGrid(
                        columns: <PlutoColumn>[
                          PlutoColumn(
                              title: 'Id',
                              field: 'id',
                              type: PlutoColumnType.number(),
                              readOnly: true,
                              sort: PlutoColumnSort.ascending,
                              width: 80,
                              frozen: PlutoColumnFrozen.start),
                          PlutoColumn(
                              title: 'Nombre',
                              field: 'employeeName',
                              type: PlutoColumnType.text(),
                              readOnly: true),
                          PlutoColumn(
                              title: 'Numero de empleado',
                              field: 'employeeNumber',
                              type: PlutoColumnType.number(),
                              readOnly: true),
                          PlutoColumn(
                              title: 'Rol del usuario',
                              field: 'userRole',
                              type: PlutoColumnType.text(),
                              readOnly: true),
                          PlutoColumn(
                              title: 'Campus',
                              field: 'campus',
                              type: PlutoColumnType.text(),
                              readOnly: true),
                          PlutoColumn(
                              title: 'Baja',
                              field: 'isActive',
                              type: PlutoColumnType.text(),
                              width: 70,
                              readOnly: true),
                          PlutoColumn(
                              title: 'e-mail',
                              field: 'mail',
                              type: PlutoColumnType.text(),
                              readOnly: true),
                          PlutoColumn(
                            title: 'Fecha de alta',
                            field: 'creation',
                            type: PlutoColumnType.text(),
                            readOnly: true,
                          ),
                          PlutoColumn(
                              title: 'Posición',
                              field: 'position',
                              type: PlutoColumnType.text(),
                              readOnly: true)
                        ],
                        rows: userRows,
                        onRowSecondaryTap: (event) {
                          final RenderBox overlay = Overlay.of(context)
                              .context
                              .findRenderObject() as RenderBox;
                          showMenu(
                              context: context,
                              position: RelativeRect.fromRect(
                                  Rect.fromPoints(
                                    overlay.localToGlobal(event.offset),
                                    overlay.localToGlobal(
                                        overlay.size.bottomRight(event.offset)),
                                  ),
                                  Offset.zero & overlay.size),
                              items: <PopupMenuEntry>[
                                PopupMenuItem(
                                  onTap: () async {
                                    toSee = event.row.cells.values;
                                    setState(() {
                                      isLoading = true;
                                    });
                                    try {
                                      if (event.row.cells.values
                                              .elementAt(4)
                                              .value ==
                                          0) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                icon: const Icon(Icons.warning),
                                                iconColor:
                                                    Colors.yellow.shade300,
                                                title: const Text('Confirmar'),
                                                content: const Text(
                                                    'Desactivar usuario?'),
                                                actions: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: TextButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            confirmation = true;
                                                            isSearching = true;
                                                          });
                                                          await changeUserActiveStatus(
                                                              event.row.cells
                                                                  .values
                                                                  .elementAt(2)
                                                                  .value
                                                                  .toString(),
                                                              1);
                                                          isSearching = false;
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text('Si'),
                                                      )),
                                                      Expanded(
                                                          child: TextButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  isSearching =
                                                                      false;
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                });
                                                              },
                                                              child: const Text(
                                                                  'No')))
                                                    ],
                                                  )
                                                ],
                                              );
                                            });
                                        if (confirmation == true) {
                                          await deleteUser(
                                                  event //NOT BEING USED, REMOVE?
                                                      .row
                                                      .cells
                                                      .values
                                                      .first
                                                      .value)
                                              .whenComplete(() {
                                            listOfUsers = null;
                                            listOfUsersForGrid = null;
                                            userRows.clear();
                                            setState(() {
                                              isLoading = false;
                                            });
                                          });
                                        }
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                icon: const Icon(Icons.warning),
                                                iconColor: Colors.yellow,
                                                title: const Text('Confirmar'),
                                                content: const Text(
                                                    'Activar usuario?'),
                                                actions: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            confirmation = true;
                                                            isSearching = true;
                                                          });
                                                          if (confirmation ==
                                                              true) {
                                                            changeUserActiveStatus(
                                                                event.row.cells
                                                                    .values
                                                                    .elementAt(
                                                                        2)
                                                                    .value
                                                                    .toString(),
                                                                0);
                                                          }
                                                          setState(() {
                                                            isSearching = false;
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        },
                                                        child: const Text('Si'),
                                                      )),
                                                      Expanded(
                                                          child: TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'No')))
                                                    ],
                                                  )
                                                ],
                                              );
                                            });
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              icon: const Icon(Icons.error),
                                              title: const Text('Error'),
                                              content: Text(e.toString()),
                                            );
                                          });
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  enabled: isUserAdmin,
                                  child: event.row.cells.values
                                              .elementAt(4)
                                              .value ==
                                          1
                                      ? const Text('Activar usuario')
                                      : const Text('Desactivar usuario'),
                                ),
                                PopupMenuItem(
                                  onTap: () async {
                                    tempUserId =
                                        event.row.cells.values.first.value;
                                    tempSelectedUsr?.clear();
                                    await getSingleUser(null);
                                    areaList.clear();
                                    await getWorkDepartmentList();
                                    var response = await getRolesList();
                                    tmpRolesList = jsonDecode(response);

                                    updateUserScreen(context);
                                  },
                                  enabled: isUserAdmin,
                                  child: const Text('Modificar ususario'),
                                ),
                                PopupMenuItem(
                                  child: const Text('Cambiar contraseña'),
                                  onTap: () {},
                                )
                              ]);
                        },
                        // onRowDoubleTap: (event) async {
                        //   tempUserId = event.row.cells.values.first.value;
                        //   tmpRolesList.clear();
                        //   tempSelectedUsr?.clear();
                        //   await getSingleUser(null);
                        //   areaList.clear();
                        //   await getWorkDepartmentList();
                        //   var response = await getRolesList();
                        //   tmpRolesList = jsonDecode(response);
                        //   updateUserScreen(context);
                        // },
                        mode: PlutoGridMode.select,
                        configuration: const PlutoGridConfiguration(),
                        rowColorCallback: (rowColorContext) {
                          if (rowColorContext.row.cells.entries
                                  .elementAt(5)
                                  .value
                                  .value ==
                              1) {
                            return Colors.red.shade50;
                          } else if (rowColorContext.row.cells.entries
                                  .elementAt(4)
                                  .value
                                  .value ==
                              1) {
                            return Colors.red.shade50;
                          }
                          return Colors.transparent;
                        },
                        // createHeader: (stateManager) =>
                        //     PlutoGridHeader(stateManager: stateManager),
                        createFooter: (stateManager) {
                          stateManager.setPageSize(50,
                              notify: false); // default 40
                          return PlutoPagination(stateManager);
                        },
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          stateManager = event.stateManager;
                          stateManager.setShowColumnFilter(true);
                        }),
                  )
                ],
              ),
            ),
          ),
        ))
      ],
    );
  }
}

void updateUserScreen(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContextcontext) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20),
          title: const Text(
            'Editar usuario',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Sora'),
          ),
          content: const EditUserScreen(),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                selectedUser = null;
              },
            )
          ],
        );
      });
}
