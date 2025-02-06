import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/data/Models/Event.dart';
import 'package:oxschool/data/Models/Module.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';

class RolesEventsAdministration extends StatefulWidget {
  final String roleName;
  final int roleId;
  const RolesEventsAdministration(
      {super.key, required this.roleName, required this.roleId});

  @override
  State<RolesEventsAdministration> createState() =>
      _RolesEventsAdministrationState();
}

class _RolesEventsAdministrationState extends State<RolesEventsAdministration> {
  late Future<void> refreshEventsAndRoles;
  List<Module> moduleListData = [];
  var fetchedEvents;

  @override
  void initState() {
    refreshEventsAndRoles = fetchData();
    roleHaveEvents();
    super.initState();
  }

  @override
  void dispose() {
    moduleListData.clear();
    super.dispose();
  }

  Future<dynamic> fetchData() async {
    moduleListData = await fetchModulesAndEventsDetailed().then((onValue) {
      return onValue;
    });
  }

  Future<void> roleHaveEvents() async {
    fetchedEvents =
        await fetchEventsByRole(widget.roleId).catchError((onError) {
      if (onError == 'Value is null') {
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Asigna permisos al rol: ${widget.roleName}'),
        ),
        body: FutureBuilder<void>(
          future: refreshEventsAndRoles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CustomLoadingIndicator());
            } else if (snapshot.hasError) {
              insertErrorLog(snapshot.error.toString(),
                  'RolesEventsAdministration() at loading screen');
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: moduleListData.length,
                itemBuilder: (context, index) {
                  final module = moduleListData[index];

                  if (module.eventsList == null || module.eventsList!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  Set<String> uniqueEventNames = {};

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Modulo: ${module.name}',
                          style:
                              const TextStyle(fontSize: 20, fontFamily: 'Sora'),
                        ),
                      ),
                      ...module.eventsList!.where((event) {
                        if (uniqueEventNames.contains(event.eventName)) {
                          return false; // Skip duplicates
                        }
                        uniqueEventNames.add(event.eventName);
                        return true;
                      }).map((event) {
                        if (fetchedEvents != null) {
                          // Find the matching API response entry
                          final apiEvent = fetchedEvents.firstWhere(
                            (apiItem) => apiItem["event_id"] == event.eventID,
                            orElse: () => null, // Ensure null safety
                          );

                          // If apiEvent is null, set isActive to false
                          bool isActive = (apiEvent != null &&
                                  apiEvent.containsKey("can_acces"))
                              ? apiEvent["can_acces"] as bool
                              : false;

                          event.isActive = isActive;
                          return PolicyCard(
                            policy: event, // Ensure UI reflects API data
                            roleID: widget.roleId,
                            onToggle: (updatedEvent) {
                              setState(() {
                                event.isActive = !event.isActive;
                              });
                            },
                          );
                        } else {
                          event.isActive = false;
                          return PolicyCard(
                            policy: event, // Ensure UI reflects API data
                            roleID: widget.roleId,
                            onToggle: (updatedEvent) {
                              setState(() {
                                event.isActive = !event.isActive;
                              });
                            },
                          );
                        }
                      }),
                    ],
                  );
                },
              );
            }
          },
        )
        // FutureBuilder<void>(
        //   future: refreshEventsAndRoles,
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return Center(child: CustomLoadingIndicator());
        //     } else if (snapshot.hasError) {
        //       insertErrorLog(snapshot.error.toString(),
        //           'RolesEventsAdministration() at loading screen');
        //       return Text('Error: ${snapshot.error}');
        //     } else {
        //       return ListView.builder(
        //         itemCount: moduleListData.length,
        //         itemBuilder: (context, index) {
        //           final module = moduleListData[index];

        //           if (module.eventsList == null || module.eventsList!.isEmpty) {
        //             return const SizedBox.shrink();
        //           }

        //           Set<String> uniqueEventNames = {};

        //           return Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Padding(
        //                 padding: const EdgeInsets.all(8.0),
        //                 child: Text(
        //                   'Modulo: ${module.name}',
        //                   style:
        //                       const TextStyle(fontSize: 20, fontFamily: 'Sora'),
        //                 ),
        //               ),
        //               ...module.eventsList!.where((event) {
        //                 if (uniqueEventNames.contains(event.eventName)) {
        //                   return false; // Skip duplicates
        //                 }
        //                 uniqueEventNames.add(event.eventName);
        //                 return true;
        //               }).map((event) {
        //                 // Find the matching API response entry
        //                 final apiEvent = fetchedEvents.firstWhere(
        //                   (apiItem) => apiItem["event_id"] == event.eventID,
        //                   orElse: () => null, // Handle missing entries
        //                 );

        //                 // Default to false if no match is found
        //                 bool isActive =
        //                     apiEvent != null ? apiEvent["can_acces"] : false;
        //                 event.isActive = isActive;

        //                 return PolicyCard(
        //                   policy: event, // Ensure UI reflects API data
        //                   roleID: widget.roleId,
        //                   onToggle: (updatedEvent) {
        //                     setState(() {
        //                       event.isActive = !event.isActive;
        //                     });
        //                   },
        //                 );
        //               }),
        //             ],
        //           );
        //         },
        //       );
        //     }
        //   },
        // )
        );
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
