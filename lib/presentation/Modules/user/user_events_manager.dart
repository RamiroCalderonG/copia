import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/DataTransferObjects/RoleModuleRelationshipDto.Dart';
import 'package:oxschool/data/Models/Event.dart';
import 'package:oxschool/data/Models/Role.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/presentation/Modules/admin/roles_events_admin.dart';

import '../../../core/reusable_methods/temp_data_functions.dart';

class PoliciesScreen extends StatefulWidget {
  final int roleID;
  final String roleName;
  final List<Role> roleListData;

  const PoliciesScreen(
      {super.key,
      required this.roleID,
      required this.roleName,
      required this.roleListData});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  late Future<void> _refreshEventsFuture;
  List<Event> eventsToDisplay = [];
  List<RoleModuleRelationshipDto> roleScreensRelationship = [];
  Map<String, bool> matchedValue = {};
  Map<String, List<RoleModuleRelationshipDto>> groupedEvents = {};
  List<RoleModuleRelationshipDto> roleModuleRelationshipDto = [];

  @override
  void initState() {
    _refreshEventsFuture = refreshEvents(widget.roleID);
    super.initState();
  }

  @override
  void dispose() {
    eventsToDisplay.clear();
    roleScreensRelationship.clear();
    groupedEvents.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permisos asignados al rol: ${widget.roleName}'),
        actions: [
          if (currentUser!.isAdmin!)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RolesEventsAdministration(
                        roleName: widget.roleName, roleId: widget.roleID)));
              },
              label: Text(
                'Agregar permisos',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.indigo),
              ),
            ),
        ],
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
      body: FutureBuilder<void>(
        future: _refreshEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (groupedEvents.isNotEmpty) {
              return ListView.builder(
                itemCount: groupedEvents.keys.length,
                itemBuilder: (context, index) {
                  String moduleName = groupedEvents.keys.elementAt(index);
                  List<RoleModuleRelationshipDto> moduleEvents = groupedEvents[moduleName]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 10, left: 12, right: 12),
                        child: Text(
                          'Modulo: $moduleName',
                          style: const TextStyle(
                              fontSize: 20, fontFamily: 'Sora'),
                        ),
                      ),
                      ...moduleEvents.map((event) {
                        bool hasAccess = event.canAccessEvent!;

                        return Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: SwitchListTile(
                            title: Text(event.eventName!),
                            subtitle: hasAccess
                                ? Text(
                                    'Tiene acceso a ',
                                    style: TextStyle(color: Colors.green),
                                  )
                                : Text(
                                    'No tiene acceso a ',
                                    style: TextStyle(color: Colors.red),
                                  ),
                            value: hasAccess,
                            onChanged: (value) {
                              setState(() {
                                event.canAccessEvent = value;
                              });
                              updateModuleAccesStatus(widget.roleID,
                                  event.moduleName!, value);
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: const Text(
                        'No se encuentran eventos para el rol seleccionado',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RolesEventsAdministration(
                                  roleName: widget.roleName,
                                  roleId: widget.roleID)));
                        },
                        label: Text(
                          'Agregar permisos',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.indigo),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }

 /*  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permisos asignados al rol: ${widget.roleName}'),
        actions: [
          if (currentUser!.isAdmin!)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RolesEventsAdministration(
                        roleName: widget.roleName, roleId: widget.roleID)));
              },
              label: Text(
                'Agregar permisos',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.indigo),
              ),
            ),
        ],
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
      body: FutureBuilder<void>(
        future: _refreshEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (eventsToDisplay.isNotEmpty) {
              return ListView.builder(
                itemCount: eventsToDisplay.length,
                itemBuilder: (context, index) {
                  final currentEvent = eventsToDisplay[index];
                  String moduleName = currentEvent.moduleName;

                  bool hasAccess = matchedValue[moduleName] ?? false;

                  final previousEvent =
                      index > 0 ? eventsToDisplay[index - 1] : null;

                  final showModuleName = previousEvent == null ||
                      currentEvent.moduleName != previousEvent.moduleName;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showModuleName)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15, bottom: 10, left: 12, right: 12),
                          child: Stack(
                            children: [
                              Text(
                                'Modulo: ${currentEvent.moduleName}',
                                style: const TextStyle(
                                    fontSize: 20, fontFamily: 'Sora'),
                              ),
                              SwitchListTile(
                                subtitle: hasAccess
                                    ? Text(
                                        'Tiene acceso al modulo',
                                        style: TextStyle(color: Colors.green),
                                      )
                                    : Text(
                                        'No tiene acceso al modulo',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                value: hasAccess,
                                onChanged: (event) {
                                  setState(() {
                                    matchedValue[moduleName] = event;
                                  });
                                  updateModuleAccesStatus(widget.roleID,
                                      currentEvent.moduleName, event);
                                },
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: PolicyCard(
                          policy: currentEvent,
                          roleID: widget.roleID,
                          onToggle: (event) {
                            setState(() {
                              event.canAcces = !event.canAcces;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: const Text(
                        'No se encuentran eventos para el rol seleccionado',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RolesEventsAdministration(
                                  roleName: widget.roleName,
                                  roleId: widget.roleID)));
                        },
                        label: Text(
                          'Agregar permisos',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.indigo),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
 */
  Future<void> refreshEvents(int? idRole) async {
    // Get events by role
        try {
         roleModuleRelationshipDto =
        await fetchEventsByRole(idRole!); 
        } catch (e) {
          insertErrorLog(e.toString(), 'refreshEvents() | $idRole');
          throw Future.error(e.toString());
        }




/* 

    await fetchScreensByRoleId(idRole).then((result) {
      roleScreensRelationship = result;
      try {
        Map<String, bool> tempRoleModuleMap = {};
        for (var item in roleScreensRelationship) {
          if (!tempRoleModuleMap.containsKey(item.moduleName)) {
            tempRoleModuleMap[item.moduleName] = item.canRoleAccessModule;
          }
        }
        Map<String, List<Event>> groupedEvents = {};
        for (var jsonItem in eventsByRoleResponse) {
          Event event = Event(
              jsonItem['event_id'],
              jsonItem['event_name'],
              jsonItem['event_active'],
              jsonItem['module_description'],
              idRole,
              jsonItem['can_access']);

          if (groupedEvents.containsKey(event.moduleName)) {
            groupedEvents[event.moduleName]!.add(event);
          } else {
            groupedEvents[event.moduleName] = [event];
          }
        }
        setState(() {
          eventsToDisplay =
              groupedEvents.values.expand((events) => events).toList();
          matchedValue = tempRoleModuleMap;
        });
      } catch (e) {
        insertErrorLog(e.toString(), 'refreshEvents()');
        return Future.error(e.toString());
      }
    }); */
  }

  Future<void> updateModuleAccesStatus(
      int roleId, String moduleName, bool status) async {
    try {
      await updateModuleAccessByRole(moduleName, roleId, status);
    } catch (e) {
      insertErrorLog(e.toString(), 'updateModuleAccesStatus()');
      return Future.error(e.toString());
    }
  }
}

class PolicyCard extends StatelessWidget {
  final Event policy;
  final int roleID;
  final Function(Event) onToggle;

  const PolicyCard(
      {super.key, required this.policy, required this.roleID, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(policy.eventName),
              value: policy.canAcces,
              onChanged: (value) async {
                onToggle(policy);
                policy.canAcces = value;
                await modifyActiveOfEventRole(policy.eventID, value, roleID);
              },
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
