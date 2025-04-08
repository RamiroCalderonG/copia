import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';

import 'complaints.dart';
import 'evaluate_dept.dart';
import 'evaluate_service.dart';
import 'improvement_project.dart';
import 'ticket_requests_dashboard/processes_services.dart';

class ServicesTicketHistory extends StatefulWidget {
  const ServicesTicketHistory({super.key});

  @override
  State<ServicesTicketHistory> createState() => _ServicesTicketHistoryState();
}

class _ServicesTicketHistoryState extends State<ServicesTicketHistory>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late AnimationController controller;

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
    // _tabController.addListener(onTap);
  }

  @override
  void dispose(){
    _tabController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final servicesDetail = Stack(
    //   children: [
    //     Column(
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.all(16.0),
    //           child: Column(
    //             children: [const Placeholder()],
    //           ),
    //         )
    //       ],
    //     )
    //   ],
    // );

    return Material(
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            labelColor: Colors.white,
            controller: _tabController,
            tabs: const <Widget>[
              Tab(
                icon: Icon(
                  Icons.list_alt,
                ),
                text: 'Estatus de ticket de servicio',
              ),
              Tab(
                icon: Icon(Icons.text_increase),
                text: 'Evaluacion de departamentos',
              ),
              Tab(
                icon: Icon(Icons.pan_tool_alt_rounded),
                text: 'Evaluar servicio',
              ),
              Tab(
                icon: Icon(Icons.record_voice_over_rounded),
                text: 'Quejas',
              ),
              Tab(
                icon: Icon(Icons.arrow_circle_up_outlined),
                text: 'Proyecto de mejora',
              )
            ],
            indicatorColor: Colors.blueAccent,
          ),
          title: const Text('Ticket de servicio ',
              style: TextStyle(color: Colors.white)),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            Processes(),
            EvaluateDept(),
            EvaluateServices(),
            Complaints(),
            ImprovementProject()
          ],
        ),
      ),
    );
  }
}
