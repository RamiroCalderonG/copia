import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
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

  @override
  void initState() {
    //Download events and roles to populate the list
    _refreshEventsFuture = refreshEvents(widget.roleID);
    super.initState();
  }

  @override
  void dispose() {
    eventsToDisplay.clear();
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
                  final previousEvent =
                      index > 0 ? eventsToDisplay[index - 1] : null;

                  final showModuleName = previousEvent == null ||
                      currentEvent.moduleName != previousEvent.moduleName;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showModuleName)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Modulo: ${currentEvent.moduleName}',
                            style: const TextStyle(
                                fontSize: 20, fontFamily: 'Sora'),
                          ),
                        ),
                      PolicyCard(
                        policy: currentEvent,
                        roleID: widget.roleID,
                        onToggle: (event) {
                          setState(() {
                            event.isActive =
                                !event.isActive; // Toggle the isActive status
                          });
                        },
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
                        backgroundColor: WidgetStateProperty.all(Colors.indigo),
                      ),
                    ),
                  )
                ],
              ));
            }
          }
        },
      ),
    );
  }

  Future<void> refreshEvents(int? idRole) async {
    var eventsByRoleResponse =
        await fetchEventsByRole(idRole!); //Get events by role
    try {
      // Map to group events by moduleName
      Map<String, List<Event>> groupedEvents = {};

      for (var jsonItem in eventsByRoleResponse) {
        Event event = Event(jsonItem['event_id'], jsonItem['event_name'],
            jsonItem['event_active'], jsonItem['module_description'], idRole);

        // Check if the moduleName already exists in the map
        if (groupedEvents.containsKey(event.moduleName)) {
          groupedEvents[event.moduleName]!.add(event);
        } else {
          groupedEvents[event.moduleName] = [event];
        }
      }
      setState(() {
        eventsToDisplay =
            groupedEvents.values.expand((events) => events).toList();
      });
    } catch (e) {
      insertErrorLog(e.toString(), 'refreshEvents()');
      return Future.error(e.toString());
    }
  }
}

class PolicyCard extends StatelessWidget {
  final Event policy;
  final int roleID;
  final Function(Event) onToggle;

  // ignore: use_key_in_widget_constructors
  const PolicyCard(
      {required this.policy, required this.roleID, required this.onToggle});

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
              value: policy.isActive,
              onChanged: (value) async {
                onToggle(policy);
                //var idValue = getEventIDbyName(policy.eventName);
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
