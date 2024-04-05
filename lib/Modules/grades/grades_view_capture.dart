import 'package:flutter/material.dart';
import 'package:oxschool/Modules/grades/gardes_per_student.dart';

import '../../flutter_flow/flutter_flow_theme.dart';
import 'grades_by_asignature.dart';

class GradesViewScreen extends StatefulWidget {
  const GradesViewScreen({super.key});

  @override
  State<GradesViewScreen> createState() => _GradesViewScreenState();
}

class _GradesViewScreenState extends State<GradesViewScreen>
    with TickerProviderStateMixin {
  bool showGrid = false; // Flag to control grid visibility

  late final TabController _tabController;
  bool isSearching = false; // Add a state variable to track search status

  onTap() {
    isSearching = false;
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
    // _tabController = TabController(vsync: this, length: nurseryTabs.length);
    _tabController.addListener(onTap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [],
          bottom: TabBar(
            labelColor: Colors.white,
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.person, color: Colors.white),
                text: 'Carga por alumno',
              ),
              Tab(
                icon: Icon(Icons.contact_emergency),
                text: 'Carga por materia',
              ),
            ],
            indicatorColor: Colors.blueAccent,
          ),
          title: Text('Calificaciones', style: TextStyle(color: Colors.white)),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[GradesPerStudent(), GradesByAsignature()],
        ));
  }
}
