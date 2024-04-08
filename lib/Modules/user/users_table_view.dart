import 'package:flutter/material.dart';
import 'package:oxschool/Modules/user/edit_user_screen.dart';
import 'package:oxschool/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/components/plutogrid_export_options.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/login_view/login_view_widget.dart';
import 'package:oxschool/reusable_methods/user_functions.dart';
import 'package:oxschool/temp/users_temp_data.dart';
import 'package:pluto_grid/pluto_grid.dart';

class UsersTableView extends StatefulWidget {
  const UsersTableView({super.key});

  @override
  State<UsersTableView> createState() => _UsersTableViewState();
}

class _UsersTableViewState extends State<UsersTableView> {
  List<PlutoRow> userRows = [];
  var toSee;
  bool isUserAdmin = verifyUserAdmin(currentUser!);
  bool confirmation = false;
  bool isSearching = true;
  late final PlutoGridStateManager stateManager;
  var listOfUsers;

  @override
  void initState() {
    super.initState();

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
          'mail': PlutoCell(value: line.userEmail)
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            children: [],
          ),
        ),
        if (isSearching)
          SizedBox(
            height: 5,
          ),
        Divider(
          thickness: 1,
        ),
        Expanded(
            child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(2),
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
                              type: PlutoColumnType.text(),
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
                          // PlutoColumn(
                          //     title: 'Fecha de Ingreso',
                          //     field: 'joinDate',
                          //     type: PlutoColumnType.date(),
                          //     readOnly: true),
                          PlutoColumn(
                              title: 'Campus',
                              field: 'campus',
                              type: PlutoColumnType.text(),
                              readOnly: true),
                          // PlutoColumn(
                          //     title: 'Departamento',
                          //     field: 'area',
                          //     type: PlutoColumnType.text(),
                          //     readOnly: true),
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
                          // PlutoColumn(
                          //   title: 'Foto',
                          //   field: 'photo',
                          //   type: PlutoColumnType.text()),

                          // PlutoColumn(
                          //   title: 'salary',
                          //   field: 'salary',
                          //   type: PlutoColumnType.currency(),
                          //   footerRenderer: (rendererContext) {
                          //     return PlutoAggregateColumnFooter(
                          //       rendererContext: rendererContext,
                          //       formatAsCurrency: true,
                          //       type: PlutoAggregateColumnType.sum,
                          //       format: '#,###',
                          //       alignment: Alignment.center,
                          //       titleSpanBuilder: (text) {
                          //         return [
                          //           const TextSpan(
                          //             text: 'Sum',
                          //             style: TextStyle(color: Colors.red),
                          //           ),
                          //           const TextSpan(text: ' : '),
                          //           TextSpan(text: text),
                          //         ];
                          //       },
                          //     );
                          //   },
                          // ),
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
                                  child: event.row.cells.values
                                              .elementAt(4)
                                              .value ==
                                          1
                                      ? Text('Activar usuario')
                                      : Text('Desactivar usuario'),
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
                                                        onPressed: () {
                                                          setState(() {
                                                            confirmation = true;
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        },
                                                        child: Text('Si'),
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
                                                              child:
                                                                  Text('No')))
                                                    ],
                                                  )
                                                ],
                                              );
                                            });
                                        if (confirmation == true) {
                                          await deleteUser(event
                                                  .row.cells.values.first.value)
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
                                                            activateUser(
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
                                                        child: Text('Si'),
                                                      )),
                                                      Expanded(
                                                          child: TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child:
                                                                  Text('No')))
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
                                              icon: Icon(Icons.error),
                                              title: Text('Error'),
                                              content: Text(e.toString()),
                                            );
                                          });
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  enabled: isUserAdmin,
                                ),
                                PopupMenuItem(
                                  child: Text('Modificar ususario'),
                                  onTap: () async {
                                    tempUserId =
                                        event.row.cells.values.first.value;
                                    await getSingleUser(null);
                                    updateUserScreen(context);
                                  },
                                  enabled: isUserAdmin,
                                ),
                                PopupMenuItem(
                                  child: Text('Cambiar contraseña'),
                                  onTap: () {},
                                )
                              ]);
                        },
                        onRowDoubleTap: (event) async {
                          tempUserId = event.row.cells.values.first.value;
                          await getSingleUser(null);
                          updateUserScreen(context);
                        },
                        mode: PlutoGridMode.readOnly,
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
                        createHeader: (stateManager) =>
                            Header(stateManager: stateManager),
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
          contentPadding: EdgeInsets.all(20),
          title: const Text(
            'Editar usuario',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Sora'),
          ),
          content: EditUserScreen(),
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
