import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/Models/Event.dart';
import 'package:oxschool/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

import '../../reusable_methods/temp_data_functions.dart';

class PoliciesScreen extends StatefulWidget {
  final int roleID;
  const PoliciesScreen({super.key, required this.roleID});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  late Future<void> _refreshEventsFuture;
  List<Event> eventsToDisplay = [];

  @override
  void initState() {
    _refreshEventsFuture = refreshEvents(widget.roleID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos : '),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // navigate to create new policy screen
            },
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
                          style:
                              const TextStyle(fontSize: 20, fontFamily: 'Sora'),
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
          }
        },
      ),
    );
  }

  Future<void> refreshEvents(int? idRole) async {
    var response = await getEventsByRole(idRole);
    var policyList = jsonDecode(response);

    // Map to group events by moduleName
    Map<String, List<Event>> groupedEvents = {};

    for (var jsonItem in policyList) {
      Event event = Event(0, jsonItem['event'], jsonItem['is_active'],
          jsonItem['module'], true);

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
            // Text(
            //   policy.eventName,
            //   style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            // ),
            SwitchListTile(
              title: Text(policy.eventName),
              value: policy.isActive,
              onChanged: (value) async {
                onToggle(policy); // Call the callback function
                // print(policy.eventName);
                // print(value.toString() + ' ' + roleID.toString());
                var idValue = getEventIDbyName(policy.eventName);
                await modifyActiveOfEventRole(idValue, value, roleID);
              },
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TextButton(
                //   onPressed: () {
                //     // navigate to view policy details screen
                //   },
                //   child: Text('View'),
                // ),
                // TextButton(
                //   onPressed: () {
                //     // navigate to edit policy screen
                //   },
                //   child: Text('Edit'),
                // ),
                // conditionally render buttons based on permissions
                // if (/* has permission to contact radiologist */)
                //   TextButton(
                //     onPressed: () {
                //       // navigate to contact radiologist screen
                //     },
                //     child: Text('Contact Radiologist'),
                //   ),
                // if (/* has permission to approve requests */)
                //   TextButton(
                //     onPressed: () {
                //       // navigate to approve request screen
                //     },
                //     child: Text('Approve Request'),
                //   ),
                // if (/* has permission to add permissions */)
                //   TextButton(
                //     onPressed: () {
                //       // navigate to add permission screen
                //     },
                //     child: Text('Add Permission'),
                //   ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
