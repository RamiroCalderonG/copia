// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/num_extensions.dart';
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
import 'package:path_provider/path_provider.dart';
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
  bool isSearching = false;
  bool isUpdatingIdLogin = false;
  bool isBussy = false;
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
          'mail': TrinaCell(value: line.userEmail),
          'creation': TrinaCell(value: line.creationDate ?? ''),
          'birthdate': TrinaCell(value: line.birthdate ?? ''),
          'area': TrinaCell(value: line.work_area ?? ''),
          'idLogin': TrinaCell(value: line.idLogin),
          'isTeacher': TrinaCell(value: line.isTeacher ?? false),
          'work_position': TrinaCell(value: line.work_position ?? ''),
        },
      ));
    }
    areaList.clear();
    super.initState();
  }

  @override
  void dispose() {
    areaList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border(
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.people,
                color: Color(0xFF2196F3),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Gestión de Usuarios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
        ),
        if (isSearching)
          Container(
            height: 4,
            child: const LinearProgressIndicator(
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
        const Divider(
          thickness: 1,
          height: 1,
        ),
        Expanded(
            child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8),
          child: Card(
            elevation: 8.0,
            shadowColor: const Color(0x42000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFAFAFA),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                              title: 'No. Empleado',
                              field: 'employeeNumber',
                              width: 120,
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
                              width: 260,
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
                              width: 100,
                              readOnly: false,
                              checkReadOnly: (row, cell) {
                                return false;
                              },
                            ),
                            TrinaColumn(
                              title: 'Estado',
                              field: 'isActive',
                              type: TrinaColumnType.text(),
                              width: 100,
                              readOnly: false,
                              checkReadOnly: (row, cell) {
                                return false;
                              },
                              renderer: (rendererContext) {
                                bool isActive = rendererContext.cell.value ==
                                    0; // 0 = active, 1 = inactive
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text(
                                    isActive ? 'Activo' : 'Inactivo',
                                    style: TextStyle(
                                      color: isActive
                                          ? const Color(0xFF2E7D32)
                                          : const Color(
                                              0xFFD32F2F), // Green for active, Red for inactive
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
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
                              width: 80,
                              type: TrinaColumnType.number(
                                format: '####',
                              ),
                              readOnly: false,
                              checkReadOnly: (row, cell) {
                                return false;
                              },
                            ),
                            TrinaColumn(
                                title: 'Es Maestro',
                                field: 'isTeacher',
                                type: TrinaColumnType.boolean(
                                  trueText: '✓ Sí',
                                  falseText: '✗ No',
                                ),
                                readOnly: false,
                                checkReadOnly: (row, cell) {
                                  return false;
                                },
                                width: 100),
                            TrinaColumn(
                                title: 'Puesto',
                                field: 'work_position',
                                type: TrinaColumnType.text(),
                                readOnly: false,
                                checkReadOnly: (row, cell) {
                                  return false;
                                },
                                width: 150),
                            TrinaColumn(
                                title: 'Área',
                                field: 'area',
                                type: TrinaColumnType.text(),
                                readOnly: false,
                                checkReadOnly: (row, cell) {
                                  return false;
                                },
                                width: 150),
                            TrinaColumn(
                              title: 'Fec. de Nacimiento',
                              field: 'birthdate',
                              type: TrinaColumnType.text(),
                              readOnly: false,
                              checkReadOnly: (row, cell) {
                                return false;
                              },
                              width: 130,
                            ),
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
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                      color: Color(0xFFE0E0E0), width: 1),
                                ),
                                elevation: 12,
                                shadowColor: const Color(0x42000000),
                                color: const Color(0xFFFFFFFF),
                                surfaceTintColor: const Color(0xFFFFFFFF),
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
                                          } else if (selectedUser.isActive ==
                                              1) {
                                            // 1 means that is deactivated
                                            //when user is currently inactive
                                            isCurrentlyActive = false;
                                          }
                                        });
                                        var response = await showConfirmationDialog(
                                            context,
                                            isCurrentlyActive
                                                ? '¿Desactivar usuario?'
                                                : '¿Activar usuario?',
                                            'Esta acción ${isCurrentlyActive ? 'desactivará' : 'activará'} al usuario ${selectedUser.employeeName}. ¿Desea continuar?');
                                        if (response.isEqual(1)) {
                                          //Yes
                                          int newIsActiveIntValue = 0;
                                          setState(() {
                                            if (isCurrentlyActive) {
                                              //*IF user is currently active, set deactivate value
                                              newIsActiveIntValue = 1;
                                            } else {
                                              newIsActiveIntValue = 0;
                                            }
                                            isCurrentlyActive =
                                                !isCurrentlyActive;
                                            confirmation = true;
                                            isSearching = true;
                                            selectedUser.isActive =
                                                newIsActiveIntValue;
                                          });
                                          updateActiveUserStatus(selectedUser)
                                              .whenComplete(() {
                                            for (var item
                                                in listOfUsersForGrid) {
                                              if (item.employeeNumber ==
                                                  selectedUser.employeeNumber) {
                                                item.isActive =
                                                    newIsActiveIntValue;
                                              }
                                            }
                                            Navigator.of(context).pop();
                                            setState(() {
                                              isSearching = false;
                                            });
                                          });
                                          setState(() {
                                            isSearching = false;
                                          });
                                        } else {
                                          return;
                                        }
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
                                    enabled: currentUser!.isCurrentUserAdmin(),
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: event.row.cells.values
                                                          .elementAt(4)
                                                          .value ==
                                                      1
                                                  ? Colors.green.shade50
                                                  : Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              event.row.cells.values
                                                          .elementAt(4)
                                                          .value ==
                                                      1
                                                  ? Icons.person_add
                                                  : Icons.person_remove,
                                              size: 18,
                                              color: event.row.cells.values
                                                          .elementAt(4)
                                                          .value ==
                                                      1
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
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
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
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
                                                showErrorFromBackend(context,
                                                    onError.toString());
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
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE3F2FD),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: Color(0xFF1976D2),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Modificar usuario',
                                              style: TextStyle(
                                                color: Color(0xFF1976D2),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // PopupMenuItem(
                                  //     onTap: () {},
                                  //     enabled:
                                  //         currentUser!.isCurrentUserAdmin(),
                                  //     height: 48,
                                  //     padding: const EdgeInsets.symmetric(
                                  //         horizontal: 16, vertical: 8),
                                  //     child: Container(
                                  //       padding: const EdgeInsets.symmetric(
                                  //           horizontal: 8, vertical: 4),
                                  //       decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(8),
                                  //         color: Colors.transparent,
                                  //       ),
                                  //       child: Row(
                                  //         children: [
                                  //           Container(
                                  //             padding: const EdgeInsets.all(6),
                                  //             decoration: BoxDecoration(
                                  //               color: Color.fromARGB(
                                  //                   255, 209, 209, 209),
                                  //               borderRadius:
                                  //                   BorderRadius.circular(8),
                                  //             ),
                                  //             child: const Icon(
                                  //               Icons.lock_reset,
                                  //               size: 20,
                                  //               color: Colors.grey,
                                  //             ),
                                  //           ),
                                  //           SizedBox(width: 8),
                                  //           Expanded(
                                  //             child: Text(
                                  //               'Cambiar contraseña (Próximamente)',
                                  //               style: TextStyle(
                                  //                 color: Colors.grey,
                                  //                 fontWeight: FontWeight.w500,
                                  //                 fontSize: 14,
                                  //               ),
                                  //               overflow: TextOverflow.ellipsis,
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     )),
                                  PopupMenuItem(
                                    enabled: currentUser!.isCurrentUserAdmin(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
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
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 244, 200, 241),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.history,
                                              size: 20,
                                              color: Colors.purple,
                                            ),
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
                                    enabled:
                                        currentUser!.isCurrentUserAdmin() &&
                                            !isUpdatingIdLogin,
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isUpdatingIdLogin
                                                  ? Colors.grey.shade100
                                                  : Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: isUpdatingIdLogin
                                                ? SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.orange
                                                                  .shade700),
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.refresh,
                                                    size: 18,
                                                    color:
                                                        Colors.orange.shade700,
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              isUpdatingIdLogin
                                                  ? 'Actualizando...'
                                                  : 'Actualizar idLogin',
                                              style: TextStyle(
                                                color: isUpdatingIdLogin
                                                    ? Colors.grey.shade600
                                                    : Colors.orange.shade700,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                          } else if (selectedUser.isActive ==
                                              1) {
                                            // 1 means that is deactivated
                                            //when user is currently inactive
                                            isCurrentlyActive = false;
                                          }
                                        });
                                        var response = await showConfirmationDialog(
                                            context,
                                            '¡Atención!',
                                            'Esta acción cambiará la contraseña al usuario ${selectedUser.employeeName}. ¿Desea continuar?');
                                        if (response.isEqual(1)) {
                                          //Yes
                                          int newIsActiveIntValue = 0;
                                          setState(() {
                                            if (isCurrentlyActive) {
                                              //*IF user is currently active, set deactivate value
                                              newIsActiveIntValue = 1;
                                            } else {
                                              newIsActiveIntValue = 0;
                                            }
                                            isCurrentlyActive =
                                                !isCurrentlyActive;
                                            confirmation = true;
                                            isSearching = true;
                                            selectedUser.isActive =
                                                newIsActiveIntValue;
                                          });
                                          // TODO: Create change password function
                                          // updateActiveUserStatus(selectedUser)
                                          //     .whenComplete(() {
                                          //   for (var item
                                          //       in listOfUsersForGrid) {
                                          //     if (item.employeeNumber ==
                                          //         selectedUser.employeeNumber) {
                                          //       item.isActive =
                                          //           newIsActiveIntValue;
                                          //     }
                                          //   }
                                          //   Navigator.of(context).pop();
                                          //   setState(() {
                                          //     isSearching = false;
                                          //   });
                                          // });
                                          setState(() {
                                            isSearching = false;
                                          });
                                        } else {
                                          return;
                                        }
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
                                    enabled: currentUser!.isCurrentUserAdmin(),
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(Icons.lock_sharp,
                                                size: 18,
                                                color: Colors.cyan.shade300),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Cambiar contraseña',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Colors.cyan.shade300,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]);
                          },
                          mode: TrinaGridMode.select,
                          configuration: TrinaGridConfiguration(
                            style: TrinaGridStyleConfig(
                              gridBorderColor: const Color(0xFFE0E0E0),
                              activatedBorderColor: const Color(0xFF2196F3),
                              activatedColor:
                                  const Color(0xFF2196F3).withOpacity(0.1),
                              inactivatedBorderColor: const Color(0xFFBDBDBD),
                              cellColorInEditState: const Color(0xFFE3F2FD),
                              cellColorInReadOnlyState: const Color(0xFFF5F5F5),
                              columnTextStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF424242),
                              ),
                              cellTextStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF212121),
                              ),
                              gridBackgroundColor: const Color(0xFFFFFFFF),
                              rowHeight: 50,
                            ),
                            columnSize: TrinaGridColumnSizeConfig(
                              autoSizeMode: TrinaAutoSizeMode.scale,
                              resizeMode: TrinaResizeMode.normal,
                            ),
                          ),
                          rowColorCallback: (rowColorContext) {
                            // Enhanced row coloring with consistent colors for both themes
                            if (rowColorContext.row.cells.entries
                                    .elementAt(5)
                                    .value
                                    .value ==
                                1) {
                              return const Color(0xFFFFEBEE).withOpacity(0.8);
                            } else if (rowColorContext.row.cells.entries
                                    .elementAt(4)
                                    .value
                                    .value ==
                                1) {
                              return const Color(0xFFFFEBEE).withOpacity(0.8);
                            }
                            // Alternating row colors for better readability
                            return rowColorContext.rowIdx % 2 == 0
                                ? Colors.transparent
                                : const Color(0xFFF8F9FA).withOpacity(0.8);
                          },
                          createFooter: (stateManager) {
                            stateManager.setPageSize(50, notify: false);
                            return Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFFAFAFA),
                                border: Border(
                                  top: BorderSide(
                                      color: Color(0xFFE0E0E0), width: 1),
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                              child: TrinaPagination(stateManager),
                            );
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
