import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/Models/User.dart';
import 'package:oxschool/Modules/enfermeria/expandable_fab.dart';
import 'package:oxschool/Modules/user/create_user.dart';
import 'package:oxschool/components/plutogrid_export_options.dart';
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

List<PlutoRow> userRows = [];

class _UsersDashboardState extends State<UsersDashboard> {
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    stateManager = PlutoGridStateManager(
      rows: userRows,
      columns: employeeDashboardColumns,
    );
    // stateManager. rows(widget.userRows);
  }

  void updateRows(List<PlutoRow> newRows) {
    setState(() {
      stateManager.getNewRows(newRows);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<PlutoColumn> employeeDashboardColumns = <PlutoColumn>[
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
          title: 'Rol',
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
          title: 'Activo',
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
    ];

    final List<PlutoColumnGroup> columnGroups = [
      PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: false),
      PlutoColumnGroup(title: 'Información Gral', fields: [
        'employeeName',
        'employeeNumber',
        'userRole',
        'claun',
      ]),
      PlutoColumnGroup(title: 'Status', children: [
        // PlutoColumnGroup(
        //     title: 'A', fields: ['userRole'], expandedColumn: true),
        PlutoColumnGroup(title: 'Activo', fields: ['isActive', 'mail']),
      ]),
    ];

    // final List<PlutoRow> userRows = [
    //   PlutoRow(
    //     cells: {
    //       'id': PlutoCell(value: '001'),
    //       'employeeName': PlutoCell(value: 'Mike'),
    //       'employeeNumber': PlutoCell(value: 20),
    //       'userRole': PlutoCell(value: 'Programmer'),
    //       'joinDate': PlutoCell(value: '2021-01-01'),
    //       'isActive': PlutoCell(value: 'True'),
    //       'campuse': PlutoCell(value: 'Campuse1'),
    //       'area': PlutoCell(value: 'Area1'),
    //       'mail': PlutoCell(value: 'mail1@mail.com')
    //     },
    //   ),
    //   PlutoRow(
    //     cells: {
    //       'id': PlutoCell(value: '002'),
    //       'employeeName': PlutoCell(value: 'Mike'),
    //       'employeeNumber': PlutoCell(value: 20),
    //       'userRole': PlutoCell(value: 'Designer'),
    //       'joinDate': PlutoCell(value: '2021-01-01'),
    //       'isActive': PlutoCell(value: 'True'),
    //       'campuse': PlutoCell(value: 'Campuse1'),
    //       'area': PlutoCell(value: 'Area2'),
    //       'mail': PlutoCell(value: 'mail2@mail.com')
    //     },
    //   ),
    //   PlutoRow(
    //     cells: {
    //       'id': PlutoCell(value: '003'),
    //       'employeeName': PlutoCell(value: 'Mike'),
    //       'employeeNumber': PlutoCell(value: 20),
    //       'userRole': PlutoCell(value: 'None'),
    //       'joinDate': PlutoCell(value: '2021-01-01'),
    //       'isActive': PlutoCell(value: 'False'),
    //       'campuse': PlutoCell(value: 'Campuse1'),
    //       'area': PlutoCell(value: 'Area3'),
    //       'mail': PlutoCell(value: 'mail3@mail.com')
    //     },
    //   ),
    // ];

    return Scaffold(
        appBar: AppBar(
            bottom: AppBar(automaticallyImplyLeading: false, actions: [
              TextButton.icon(
                  onPressed: () async {
                    buildNewUserScreen(context);
                  },
                  icon: FaIcon(FontAwesomeIcons.addressCard),
                  label: Text('Agregar ususario')),
              TextButton.icon(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      await populateUsersGrid().whenComplete(() {
                        setState(() {
                          isLoading = false;
                        });
                      });
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                        AlertDialog(
                          title: Text("Error"),
                          content: Text(e.toString()),
                        );
                      });
                    }
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
            title: Text('Administración de ususarios',
                style: TextStyle(color: Colors.white))),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              child: PlutoGrid(
                onRowSecondaryTap: (event) {
                  // Show menu at a fixed position
                  final RenderBox overlay = Overlay.of(context)
                      .context
                      .findRenderObject() as RenderBox;
                  showMenu(
                    context: context,
                    position: RelativeRect.fromRect(
                      Rect.fromPoints(
                        overlay.localToGlobal(Offset.zero),
                        overlay.localToGlobal(
                            overlay.size.bottomRight(Offset.zero)),
                      ),
                      Offset.zero & overlay.size,
                    ),
                    items: <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Text('Option 1'),
                        onTap: () {
                          // Handle Option 1
                        },
                      ),
                      PopupMenuItem(
                        child: Text('Option 2'),
                        onTap: () {
                          // Handle Option 2
                        },
                      ),
                      // Add more options as needed
                    ],
                  );
                },
                mode: PlutoGridMode.popup,
                columns: employeeDashboardColumns,
                rows: stateManager.userRows,
                columnGroups: columnGroups,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  event.stateManager
                      .setSelectingMode(PlutoGridSelectingMode.cell);
                  stateManager = event.stateManager;
                  // stateManager = event.stateManager;
                  // stateManager.setShowColumnFilter(true);
                },
                onChanged: (PlutoGridOnChangedEvent event) {
                  print(event);
                },
                configuration: const PlutoGridConfiguration(),
                rowColorCallback: (rowColorContext) {
                  if (rowColorContext.row.cells.entries
                          .elementAt(5)
                          .value
                          .value ==
                      'False') {
                    return Colors.red.shade50;
                  } else if (rowColorContext.row.cells.entries
                          .elementAt(4)
                          .value
                          .value ==
                      'Two') {
                    return Colors.red.shade50;
                  }
                  return Colors.transparent;
                },
                createHeader: (stateManager) =>
                    Header(stateManager: stateManager),
                createFooter: (stateManager) {
                  stateManager.setPageSize(50, notify: false); // default 40
                  return PlutoPagination(stateManager);
                },
              ),
            ),
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

List<PlutoRow> createPlutoRows(List<User> users) {
  List<PlutoRow> rows = [];
  for (var user in users) {
    PlutoRow row = PlutoRow(
      cells: {
        'id': PlutoCell(value: user.userId.toString()),
        'employeeName': PlutoCell(value: user.employeeName),
        'employeeNumber': PlutoCell(value: user.employeeNumber),
        'userRole': PlutoCell(value: user.role),
        'isActive': PlutoCell(value: user.isActive),
        'campus': PlutoCell(value: user.claUn),
        // 'area': PlutoCell(value: user),
        'mail': PlutoCell(value: user.userEmail)
      },
    );
    rows.add(row);
  }

  return rows;
}

dynamic populateUsersGrid() async {
  List<User> users = [];

  var listOfUsers = await getUsers();
  users = await parseUsersFromJSON(listOfUsers);
  userRows = await createPlutoRows(users);
  // return users;
}
