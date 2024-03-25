import 'package:flutter/material.dart';
import 'package:oxschool/components/plutogrid_export_options.dart';
import 'package:oxschool/constants/User.dart';
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
    double cardHeight = screenHeight / 1.0;
    double cardWidth = MediaQuery.of(context).size.width * 0.9;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            children: [],
          ),
        ),
        if (isSearching)
          Expanded(
              child: Container(
            width: cardWidth,
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Listado de ususarios',
                      style: TextStyle(fontSize: 25.0),
                    ),
                    Divider(thickness: 3),
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
