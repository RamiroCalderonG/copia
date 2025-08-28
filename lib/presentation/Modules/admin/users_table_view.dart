// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:oxschool/data/Models/User.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list_dio.dart';
import 'package:oxschool/presentation/Modules/admin/edit_user_screen.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/presentation/Modules/login_view/login_view_widget.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:trina_grid/trina_grid.dart';

class UsersTableView extends StatefulWidget {
  const UsersTableView({super.key});

  @override
  State<UsersTableView> createState() => _UsersTableViewState();
}

class _UsersTableViewState extends State<UsersTableView> {
  // List<TrinaRow> userRows = [];
  // ignore: prefer_typing_uninitialized_variables
  var toSee;
  bool isUserAdmin = currentUser!.isCurrentUserAdmin();
  bool confirmation = false;
  bool isSearching = true;
  bool isUpdatingIdLogin = false;
  late final TrinaGridStateManager stateManager;
  //Key usrsTableKey = UniqueKey();
  // ignore: prefer_typing_uninitialized_variables
  var listOfUsers;

  @override
  void initState() {
    for (var line in listOfUsersForGrid) {
      userRows.add(TrinaRow(
        cells: {
          'id': TrinaCell(value: line.userId.toString()),
          'employeeName': TrinaCell(value: line.employeeName),
          'employeeNumber': TrinaCell(value: line.employeeNumber),
          'userRole': TrinaCell(value: line.role),
          'isActive': TrinaCell(value: line.isActive),
          'campus': TrinaCell(value: line.claUn),
          // 'area': TrinaCell(value: user),
          'mail': TrinaCell(value: line.userEmail),
          'creation': TrinaCell(value: line.creationDate),
          'birthdate': TrinaCell(value: line.birthdate),
          'position': TrinaCell(value: line.work_area),
          'idLogin': TrinaCell(value: line.idLogin)
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

  void _restartTable() {
    setState(() {
      //usrsTableKey = UniqueKey();
    });
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
                    child: TrinaGrid(
                        columns: <TrinaColumn>[
                          TrinaColumn(
                            title: 'Id',
                            field: 'id',
                            type: TrinaColumnType.number(),
                            readOnly: true,
                            checkReadOnly: (row, cell) {
                              return true;
                            },
                            hide: true,
                            //sort: TrinaColumnSort.ascending,
                            width: 80,
                            // frozen: TrinaColumnFrozen.start
                          ),
                          TrinaColumn(
                            title: 'Numero de empleado',
                            field: 'employeeNumber',
                            width: 100,
                            type: TrinaColumnType.number(
                              format: '####',
                            ),
                            readOnly: false,
                            checkReadOnly: (row, cell) {
                              return false;
                            },
                          ),
                          TrinaColumn(
                            title: 'Nombre',
                            field: 'employeeName',
                            type: TrinaColumnType.text(),
                            readOnly: false,
                            checkReadOnly: (row, cell) {
                              return false;
                            },
                          ),

                          TrinaColumn(
                            title: 'Rol del usuario',
                            field: 'userRole',
                            type: TrinaColumnType.text(),
                            readOnly: false,
                            checkReadOnly: (row, cell) {
                              return false;
                            },
                          ),
                          TrinaColumn(
                            title: 'Campus',
                            field: 'campus',
                            type: TrinaColumnType.text(),
                            readOnly: false,
                            checkReadOnly: (row, cell) {
                              return false;
                            },
                          ),
                          TrinaColumn(
                            title: 'Baja',
                            field: 'isActive',
                            type: TrinaColumnType.text(),
                            width: 70,
                            readOnly: false,
                            checkReadOnly: (row, cell) {
                              return false;
                            },
                          ),
                          TrinaColumn(
                            title: 'e-mail',
                            field: 'mail',
                            type: TrinaColumnType.text(),
                            readOnly: false,
                            checkReadOnly: (row, cell) {
                              return false;
                            },
                          ),
                          TrinaColumn(
                            title: 'idLogin',
                            field: 'idLogin',
                            width: 150,
                            type: TrinaColumnType.number(
                              format: '####',
                            ),
                            readOnly: false,
                            checkReadOnly: (row, cell) {
                              return false;
                            },
                          ),
                          // TrinaColumn(
                          //   title: 'Fecha de alta',
                          //   field: 'creation',
                          //   type: TrinaColumnType.text(),
                          //   readOnly: true,
                          // ),
                          // TrinaColumn(
                          //     title: 'Posición',
                          //     field: 'position',
                          //     type: TrinaColumnType.text(),
                          //     readOnly: true)
                        ],
                        rows: userRows,
                        onRowSecondaryTap: (event) {
                          // Calculate position relative to the screen
                          final Offset globalPosition = event.offset;

                          showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                globalPosition.dx,
                                globalPosition.dy,
                                globalPosition.dx + 1,
                                globalPosition.dy + 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              color: Colors.white,
                              items: <PopupMenuEntry>[
                                PopupMenuItem(
                                  onTap: () async {
                                    toSee = event.row.cells.values;
                                    setState(() {
                                      isLoading = true;
                                    });
                                    try {
                                      User selectedUser = listOfUsersForGrid
                                          .firstWhere((iterableItem) =>
                                              iterableItem.employeeNumber ==
                                              event.row.cells.values
                                                  .elementAt(2)
                                                  .value);

                                      bool isCurrentlyActive = false;
                                      setState(() {
                                        if (selectedUser.isActive == 0) {
                                          //0 means that is active
                                          //when user is currently active
                                          isCurrentlyActive = true;
                                        } else if (selectedUser.isActive == 1) {
                                          // 1 means that is deactivated
                                          //when user is currently inactive
                                          isCurrentlyActive = false;
                                        }
                                      });

                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              icon: const Icon(Icons.warning),
                                              iconColor: Colors.yellow.shade300,
                                              title: const Text('Confirmar'),
                                              content: isCurrentlyActive
                                                  ? Text('Desactivar ususario?')
                                                  : Text('Activar ususario?'),
                                              actions: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: TextButton(
                                                      onPressed: () async {
                                                        int newIsActiveIntValue =
                                                            0;
                                                        setState(() {
                                                          if (isCurrentlyActive) {
                                                            //*IF user is currently active, set deactivate value
                                                            newIsActiveIntValue =
                                                                1;
                                                          } else {
                                                            newIsActiveIntValue =
                                                                0;
                                                          }
                                                          isCurrentlyActive =
                                                              !isCurrentlyActive;
                                                          confirmation = true;
                                                          isSearching = true;
                                                          selectedUser
                                                                  .isActive =
                                                              newIsActiveIntValue;
                                                        });
                                                        updateActiveUserStatus(
                                                                selectedUser)
                                                            .whenComplete(() {
                                                          for (var item
                                                              in listOfUsersForGrid) {
                                                            if (item.employeeNumber ==
                                                                selectedUser
                                                                    .employeeNumber) {
                                                              item.isActive =
                                                                  newIsActiveIntValue;
                                                            }
                                                          }

                                                          Navigator.of(context)
                                                              .pop();
                                                          isSearching = false;
                                                          _restartTable();
                                                        });
                                                      },
                                                      child:
                                                          const Text('Aceptar'),
                                                    )),
                                                    Expanded(
                                                        child: TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                userRows
                                                                    .clear();
                                                                for (var line
                                                                    in listOfUsersForGrid) {
                                                                  userRows.add(
                                                                      TrinaRow(
                                                                    cells: {
                                                                      'id': TrinaCell(
                                                                          value: line
                                                                              .userId
                                                                              .toString()),
                                                                      'employeeName':
                                                                          TrinaCell(
                                                                              value: line.employeeName),
                                                                      'employeeNumber':
                                                                          TrinaCell(
                                                                              value: line.employeeNumber),
                                                                      'userRole':
                                                                          TrinaCell(
                                                                              value: line.role),
                                                                      'isActive':
                                                                          TrinaCell(
                                                                              value: line.isActive),
                                                                      'campus': TrinaCell(
                                                                          value:
                                                                              line.claUn),
                                                                      // 'area': TrinaCell(value: user),
                                                                      'mail': TrinaCell(
                                                                          value:
                                                                              line.userEmail),
                                                                      'creation':
                                                                          TrinaCell(
                                                                              value: line.creationDate),
                                                                      'birthdate':
                                                                          TrinaCell(
                                                                              value: line.birthdate),
                                                                      // 'position':
                                                                      //     TrinaCell(
                                                                      //         value: line.work_area)
                                                                    },
                                                                  ));
                                                                }
                                                                isSearching =
                                                                    false;
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              });
                                                            },
                                                            child: const Text(
                                                                'Cancelar')))
                                                  ],
                                                )
                                              ],
                                            );
                                          });
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showErrorFromBackend(
                                          context, e.toString());
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  enabled: isUserAdmin,
                                  height: 48,
                                  child: Row(
                                    children: [
                                      Icon(
                                        event.row.cells.values
                                                    .elementAt(4)
                                                    .value ==
                                                1
                                            ? Icons.person_add
                                            : Icons.person_remove,
                                        size: 20,
                                        color: event.row.cells.values
                                                    .elementAt(4)
                                                    .value ==
                                                1
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          event.row.cells.values
                                                      .elementAt(4)
                                                      .value ==
                                                  1
                                              ? 'Activar usuario'
                                              : 'Desactivar usuario',
                                          style: TextStyle(
                                            color: event.row.cells.values
                                                        .elementAt(4)
                                                        .value ==
                                                    1
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  onTap: () async {
                                    tempUserId =
                                        event.row.cells.values.first.value;
                                    tempSelectedUsr?.clear();
                                    try {
                                      //Get selected User
                                      await getSingleUser(tempUserId!)
                                          .then((value) async {
                                        setState(() {
                                          areaList.clear();
                                        });
                                        await getWorkDepartmentList()
                                            .then((response) async {
                                          if (tmpRolesList.isEmpty) {
                                            await getRolesTempList()
                                                .catchError((onError) {
                                              showErrorFromBackend(
                                                  context, onError.toString());
                                            });
                                          }
                                        }).catchError((onError) {
                                          showErrorFromBackend(
                                              context, onError.toString());
                                        });
                                        //Get roles from DB

                                        var response = await getRolesList();
                                        tmpRolesList = response.data;
                                        updateUserScreen(context);
                                      }).catchError((error) {
                                        showErrorFromBackend(
                                            context, error.toString());
                                      });
                                      //Get departments from DB
                                    } catch (e) {
                                      showErrorFromBackend(
                                          context, e.toString());
                                    }
                                  },
                                  enabled: currentUser!.isCurrentUserAdmin(),
                                  height: 48,
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Modificar usuario',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: () {},
                                  enabled: false,
                                  height: 48,
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.lock_reset,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Cambiar contraseña (Próximamente)',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Historial de usuario'),
                                            content: const Text(
                                                'Historial de cambios del usuario'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cerrar'),
                                              )
                                            ],
                                          );
                                        });
                                  },
                                  height: 48,
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 20,
                                        color: Colors.purple,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Ver historial',
                                          style: TextStyle(
                                            color: Colors.purple,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  onTap: () async {
                                    bool hasError = false;
                                    try {
                                      setState(() {
                                        isUpdatingIdLogin = true;
                                      });
                                      User selectedUser = listOfUsersForGrid
                                          .firstWhere((iterableItem) =>
                                              iterableItem.employeeNumber ==
                                              event.row.cells.values
                                                  .elementAt(2)
                                                  .value);
                                      await updateUserIdLoginProcedure(
                                              selectedUser.employeeNumber!)
                                          .catchError((error) {
                                        hasError = true;
                                        showErrorFromBackend(
                                            context, error.toString());
                                      });
                                      setState(() {
                                        isUpdatingIdLogin = false;
                                      });

                                      // Only show success dialog if there was no error
                                      if (!hasError) {
                                        showSuccessDialog(context, 'Éxito',
                                            'IdLogin actualizado correctamente');
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isUpdatingIdLogin = false;
                                      });
                                      showErrorFromBackend(
                                          context, e.toString());
                                    }
                                  },
                                  enabled: currentUser!.isCurrentUserAdmin() &&
                                      !isUpdatingIdLogin,
                                  height: 48,
                                  child: Row(
                                    children: [
                                      if (isUpdatingIdLogin)
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.orange),
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.refresh,
                                          size: 20,
                                          color: Colors.orange,
                                        ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          isUpdatingIdLogin
                                              ? 'Actualizando...'
                                              : 'Actualizar idLogin',
                                          style: TextStyle(
                                            color: isUpdatingIdLogin
                                                ? Colors.grey
                                                : Colors.orange,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]);
                        },
                        mode: TrinaGridMode.select,
                        configuration: const TrinaGridConfiguration(),
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
                        createFooter: (stateManager) {
                          stateManager.setPageSize(50,
                              notify: false); // default 40
                          return TrinaPagination(stateManager);
                        },
                        onLoaded: (TrinaGridOnLoadedEvent event) {
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

Future<void> updateActiveUserStatus(User selectedUser) async {
  await changeUserActiveStatus(
      selectedUser.employeeNumber!, selectedUser.isActive!);
}

// void refreshGridData() {
//   if (userRows.isNotEmpty) {
//     userRows.clear();
//   }

//   for (var line in listOfUsersForGrid) {
//     userRows.add(TrinaRow(
//       cells: {
//         'id': TrinaCell(value: line.userId.toString()),
//         'employeeName': TrinaCell(value: line.employeeName),
//         'employeeNumber': TrinaCell(value: line.employeeNumber),
//         'userRole': TrinaCell(value: line.role),
//         'isActive': TrinaCell(value: line.isActive),
//         'campus': TrinaCell(value: line.claUn),
//         // 'area': TrinaCell(value: user),
//         'mail': TrinaCell(value: line.userEmail),
//         'creation': TrinaCell(value: line.creationDate),
//         'birthdate': TrinaCell(value: line.birthdate),
//         'position': TrinaCell(value: line.work_area)
//       },
//     ));
//   }
// }
