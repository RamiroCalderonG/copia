import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/DataTransferObjects/Role_module_relationship_dto.dart';

import 'package:oxschool/data/Models/Event.dart';
import 'package:oxschool/data/Models/Role.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list_dio.dart';
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
        actions: [],
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
                  List<RoleModuleRelationshipDto> moduleEvents =
                      groupedEvents[moduleName]!;

                  // Group events by screenName
                  Map<String, List<RoleModuleRelationshipDto>>
                      groupedByScreenName = {};
                  for (var event in moduleEvents) {
                    if (!groupedByScreenName.containsKey(event.screenName)) {
                      groupedByScreenName[event.screenName!] = [];
                    }
                    groupedByScreenName[event.screenName]!.add(event);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 10, left: 12, right: 12),
                        child: Wrap(
                          spacing: 8.0,
                          children: [
                            Divider(
                              thickness: 3,
                            ),
                            SwitchListTile(
                              title: Text(
                                'Modulo: $moduleName',
                                style: const TextStyle(
                                    fontSize: 20, fontFamily: 'Sora'),
                              ),
                              activeColor: Colors.green,
                              value:
                                  moduleEvents.first.canAccessModule ?? false,
                              onChanged: (value) {
                                var moduleId;
                                setState(() {
                                  for (var event in moduleEvents) {
                                    event.canAccessModule = value;
                                    moduleId = event.moduleId;
                                  }
                                });
                                updateStatusAccess(
                                    widget.roleID, 0, value, moduleId);
                              },
                            ),
                          ],
                        ),
                      ),
                      ...groupedByScreenName.entries.map((entry) {
                        String screenName = entry.key;
                        List<RoleModuleRelationshipDto> screenEvents =
                            entry.value;
                        bool hasScreenAccess =
                            screenEvents.first.canAccessScreen!;

                        return Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SwitchListTile(
                                secondary: Icon(Icons.star),
                                title: Text(
                                  'Ventana: $screenName',
                                ),
                                activeColor: Colors.green,
                                value: hasScreenAccess,
                                onChanged: (value) {
                                  var screenId;
                                  setState(() {
                                    for (var event in screenEvents) {
                                      event.canAccessScreen = value;
                                      screenId = event.screenId;
                                    }
                                  });
                                  updateStatusAccess(
                                      widget.roleID, 1, value, screenId);
                                },
                              ),
                              ...screenEvents.map((event) {
                                return Padding(
                                  padding: EdgeInsets.only(left: 50, right: 20),
                                  child: SwitchListTile(
                                    secondary: Icon(
                                      Icons.circle,
                                      size: 12,
                                    ),
                                    title: Text('Evento: ${event.eventName!}'),
                                    activeColor: Colors.green,
                                    value: event.canAccessEvent!,
                                    onChanged: (value) {
                                      var eventId;
                                      setState(() {
                                        event.canAccessEvent = value;
                                        eventId = event.eventId;
                                      });
                                      updateStatusAccess(
                                          widget.roleID, 2, value, eventId);
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
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
                              WidgetStateProperty.all(Colors.indigo),
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

  Future<void> refreshEvents(int? idRole) async {
    try {
      roleModuleRelationshipDto =
          await fetchEventsByRole(idRole!); // Get events by role

      // Group events by module name
      groupedEvents = {};
      for (var item in roleModuleRelationshipDto) {
        if (!groupedEvents.containsKey(item.moduleName)) {
          groupedEvents[item.moduleName!] = [];
        }
        groupedEvents[item.moduleName]!.add(item);
      }

      setState(() {});
    } catch (e) {
      insertErrorLog(e.toString(), 'refreshEvents() | $idRole');
      return Future.error(e.toString());
    }
  }

  Future<void> updateStatusAccess(
      int roleId, int flag, bool status, int item) async {
    try {
      await updateModuleAccessByRole(roleId, flag, status, item);
      //await updateModuleAccessByRole(moduleName, roleId, status);
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
      {super.key,
      required this.policy,
      required this.roleID,
      required this.onToggle});

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
