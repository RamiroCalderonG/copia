import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/services_functions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/data/Models/ServiceTicketRequest.dart';
import 'package:oxschool/data/datasources/temp/services_temp.dart';
import 'package:oxschool/presentation/Modules/services_ticket/processes/ticket_requests_dashboard/processes_services.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';

class TicketRequestSummary extends StatefulWidget {
  const TicketRequestSummary({Key? key, required this.isSelectedRequestsIMade})
      : super(key: key);
  final bool isSelectedRequestsIMade;

  @override
  _TicketRequestSummaryState createState() => _TicketRequestSummaryState();
}

class _TicketRequestSummaryState extends State<TicketRequestSummary>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  bool canCreateTicket = false;
  bool canEditTicket = false;
  bool canAssignTicket = false;
  List<Map<String, dynamic>> usersMapsL = [];
  List<String> employeeList = <String>[];

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    enableDisableEvents();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    totalTickets = 0;
    assigned = 0;
    onProgress = 0;
    closed = 0;
    overdue = 0;
    unassigned = 0;
    assignedTickets.clear();
    unassignedTickets.clear();
    onProgressTickets.clear();
    closedTickets.clear();
    overdueTickets.clear();
    usersMapsL.clear();
    employeeList.clear();
    super.dispose();
  }

  void enableDisableEvents() {
    for (var element in currentUser!.userRole!.roleModuleRelationships!) {
      if (element.eventId == 20 && element.canAccessEvent == true) {
        setState(() {
          canAssignTicket = true;
        });
      }
      if (element.eventId == 19 && element.canAccessEvent == true) {
        setState(() {
          canCreateTicket = true;
        });
      }
      if (element.eventId == 21 && element.canAccessEvent == true) {
        setState(() {
          canEditTicket = true;
        });
      }
    }
  }

  void getEmployeesNames(List<Map<String, dynamic>> usersLists) {
    setState(() {
      employeeList.clear();
      for (var element in usersLists) {
        if (element['name'] != null) {
          employeeList.add(element['name'].toString());
        }
      }
    });
  }

  void fetchUsersList(int filter, String dept) {
    var userResponse = getUsersList(filter, dept).then((value) {
      usersMapsL = value;
      getEmployeesNames(value);
    }).onError((error, stacktrace) {
      insertErrorLog(error.toString(),
          'Error al obtener la lista de empleados | fetchUsersList()');
    });
  }

  @override
  Widget build(BuildContext context) {

    dynamic assignSupportTicketWidget( String observations, String description, int ticketiD, List<dynamic> deptMembers  ){
      List<String> names = [];

      for (var element in deptMembers) {
        names.add(element["userName"]);
      }

      return Wrap(
        spacing: 2,
        children: [
          Row(
            children: [
            Text('Ticket #${ticketiD.toString()}')
          ],),
          Row(
            children: [
              Text('Descripción: $description'),
            ],
          ),
          Row(
            children: [
              Text('Observations: $observations')
            ],
          ),
          Row(
            children: [
              DropdownMenu<String>(
                    label: const Text(
                      ' Usuario ',
                     style: TextStyle(fontSize: 12),
                    ),
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                    initialSelection: names.first,
                    onSelected: (String? value) {
                      setState(() {
                        
                      });
                    },
                    dropdownMenuEntries: names
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList(),
                  ),
            ],
          )
        ],
      );
    }


    final TabBar tabBar = TabBar(
      controller: _tabController,
      indicatorColor: const Color.fromARGB(255, 254, 0, 0),
      tabs: <Widget>[
        Tab(
          icon: Icon(
            Icons.adjust,
          ),
          child: unassignedTickets.isNotEmpty
              ? Text('Sin asignar: ${unassignedTickets.length.toString()}')
              : const Text('Sin asignar'),
        ),
        Tab(
          icon: Icon(Icons.person_add),
          child: assignedTickets.isNotEmpty
              ? Text('Asignados: ${assignedTickets.length.toString()}')
              : const Text('Asignados'),
        ),
        Tab(
          icon: Icon(Icons.work_history),
          child: onProgressTickets.isNotEmpty
              ? Text('En proceso: ${onProgressTickets.length.toString()}')
              : const Text('En proceso'),
        ),
        Tab(
          icon: Icon(Icons.timer_off_outlined),
          child: overdueTickets.isNotEmpty
              ? Text('Vencidos: ${overdueTickets.length.toString()}')
              : const Text('Vencidos'),
        ),
        Tab(
          icon: Icon(Icons.check_circle_outline),
          //text: 'Cerrados',
          child: closedTickets.isNotEmpty
              ? Text('Cerrados: ${closedTickets.length.toString()}')
              : const Text('Cerrados'),
        ),
      ],
    );

    final TabBarView tabBarView =
        TabBarView(controller: _tabController, children: <Widget>[
      unassignedTickets.isNotEmpty
          ? ListView.builder(
              itemCount: unassignedTickets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    shadowColor: FlutterFlowTheme.of(context).primaryText,
                    child: ListTile(
                      trailing: canAssignTicket ? IconButton(
                        onPressed: () async {
                          //Validate if role can asignate Ticket
                          var response = await validateEventStatus(20);

                             showDialog(context: context, builder: (
                              BuildContext context){
                            return AlertDialog(
                              scrollable: true,
                              content: 
                              assignSupportTicketWidget(
                                unassignedTickets[index].observations ?? 'Sin observaciones', 
                                unassignedTickets[index].description, 
                                unassignedTickets[index].idReqServ, response),
                            );
                          }); 

                      }, 
                      icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.deepPurpleAccent,),
                      tooltip: 'Asignar ticket',
                      ) : null,
                      leading: IconButton(
                        icon: Icon(Icons.check_circle_outline,
                            color: Colors.blue),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Material(
                                  type: MaterialType.transparency,
                                  child: TicketDetail(
                                    ticketId:
                                        unassignedTickets[index].idReqServ,
                                    observations:
                                        unassignedTickets[index].observations,
                                    description:
                                        unassignedTickets[index].description,
                                    deadLine: unassignedTickets[index].deadLine,
                                    requestDate: unassignedTickets[index]
                                        .serviceRequestDate,
                                    closureDate:
                                        unassignedTickets[index].closureDate,
                                    creationDate: unassignedTickets[index]
                                        .serviceCreationDate,
                                    assignedTo:
                                        unassignedTickets[index].assignedTo,
                                    reportedBy:
                                        unassignedTickets[index].reportedBy,
                                    isSelectedRequestsIMade:
                                        widget.isSelectedRequestsIMade,
                                  ),
                                );
                              });
                        },
                      ),
                      title: Text(
                          '${unassignedTickets[index].idReqServ.toString()} : ${unassignedTickets[index].description}'),
                      subtitle: Text(
                          ' * Observaciones: ${unassignedTickets[index].observations}'),
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text('No hay tickets sin asignar')),
      assignedTickets.isNotEmpty
          ? ListView.builder(
              itemCount: assignedTickets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    shadowColor: FlutterFlowTheme.of(context).primaryText,
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.check_circle_outline,
                            color: Colors.blue),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Material(
                                  type: MaterialType.transparency,
                                  child: TicketDetail(
                                    ticketId: assignedTickets[index].idReqServ,
                                    observations:
                                        assignedTickets[index].observations,
                                    description:
                                        assignedTickets[index].description,
                                    deadLine: assignedTickets[index].deadLine,
                                    requestDate: assignedTickets[index]
                                        .serviceRequestDate,
                                    closureDate:
                                        assignedTickets[index].closureDate,
                                    creationDate: assignedTickets[index]
                                        .serviceCreationDate,
                                    assignedTo:
                                        assignedTickets[index].assignedTo,
                                    reportedBy:
                                        assignedTickets[index].reportedBy,
                                    isSelectedRequestsIMade:
                                        widget.isSelectedRequestsIMade,
                                  ),
                                );
                              });
                        },
                      ),
                      title: Text(
                          '${assignedTickets[index].idReqServ.toString()} : ${assignedTickets[index].description}'),
                      subtitle: Text(
                          ' * Observaciones: ${assignedTickets[index].observations}'),
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text('No hay tickets asignados')),
      onProgressTickets.isNotEmpty
          ? ListView.builder(
              itemCount: onProgressTickets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    shadowColor: FlutterFlowTheme.of(context).primaryText,
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.check_circle_outline,
                            color: Colors.blue),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Material(
                                  type: MaterialType.transparency,
                                  child: TicketDetail(
                                    ticketId:
                                        onProgressTickets[index].idReqServ,
                                    observations:
                                        onProgressTickets[index].observations,
                                    description:
                                        onProgressTickets[index].description,
                                    deadLine: onProgressTickets[index].deadLine,
                                    requestDate: onProgressTickets[index]
                                        .serviceRequestDate,
                                    closureDate:
                                        onProgressTickets[index].closureDate,
                                    creationDate: onProgressTickets[index]
                                        .serviceCreationDate,
                                    assignedTo:
                                        onProgressTickets[index].assignedTo,
                                    reportedBy:
                                        onProgressTickets[index].reportedBy,
                                    isSelectedRequestsIMade:
                                        widget.isSelectedRequestsIMade,
                                  ),
                                );
                              });
                        },
                      ),
                      title: Text(
                          '${onProgressTickets[index].idReqServ.toString()} : ${onProgressTickets[index].description.toCapitalized}'),
                      subtitle: Text(
                          ' * Observaciones: ${onProgressTickets[index].observations}'),
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text('No hay tickets en proceso')),
      overdueTickets.isNotEmpty
          ? ListView.builder(
              itemCount: overdueTickets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    shadowColor: FlutterFlowTheme.of(context).primaryText,
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.check_circle_outline,
                            color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Material(
                                  type: MaterialType.transparency,
                                  child: TicketDetail(
                                    ticketId: overdueTickets[index].idReqServ,
                                    observations:
                                        overdueTickets[index].observations,
                                    description:
                                        overdueTickets[index].description,
                                    deadLine: overdueTickets[index].deadLine,
                                    requestDate: overdueTickets[index]
                                        .serviceRequestDate,
                                    closureDate:
                                        overdueTickets[index].closureDate,
                                    creationDate: overdueTickets[index]
                                        .serviceCreationDate,
                                    assignedTo:
                                        overdueTickets[index].assignedTo,
                                    reportedBy:
                                        overdueTickets[index].reportedBy,
                                    isSelectedRequestsIMade:
                                        widget.isSelectedRequestsIMade,
                                  ),
                                );
                              });
                        },
                      ),
                      title: Text(
                          '${overdueTickets[index].idReqServ.toString()} : ${overdueTickets[index].description}'),
                      subtitle: Text(
                          ' * Observaciones: ${overdueTickets[index].observations}'),
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text('No hay tickets vencidos')),
      closedTickets.isNotEmpty
          ? ListView.builder(
              itemCount: closedTickets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    shadowColor: FlutterFlowTheme.of(context).primaryText,
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Material(
                                  type: MaterialType.transparency,
                                  child: TicketDetail(
                                    ticketId: closedTickets[index].idReqServ,
                                    observations:
                                        closedTickets[index].observations,
                                    description:
                                        closedTickets[index].description,
                                    deadLine: closedTickets[index].deadLine,
                                    requestDate:
                                        closedTickets[index].serviceRequestDate,
                                    closureDate:
                                        closedTickets[index].closureDate,
                                    creationDate: closedTickets[index]
                                        .serviceCreationDate,
                                    assignedTo: closedTickets[index].assignedTo,
                                    reportedBy: closedTickets[index].reportedBy,
                                    isSelectedRequestsIMade:
                                        widget.isSelectedRequestsIMade,
                                  ),
                                );
                              });
                        },
                      ),
                      title: Text(
                          '${closedTickets[index].idReqServ.toString()} : ${closedTickets[index].description}'),
                      subtitle: Text(
                          ' * Observaciones: ${closedTickets[index].observations}'),
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text('No hay tickets cerrados')),
    ]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: FlutterFlowTheme.of(context).primaryBackground,
              border: Border.all(
                color: const Color.fromARGB(255, 145, 158, 172),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 197, 214, 234),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: tabBar,
                ),
                Expanded(
                  child: tabBarView,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
