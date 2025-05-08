import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/presentation/Modules/academic/discipline/discipline_history_grid.dart';

class DisciplineScreen extends StatefulWidget {
  const DisciplineScreen({super.key});

  @override
  State<DisciplineScreen> createState() => _DisciplineScreenState();
}

class _DisciplineScreenState extends State<DisciplineScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> data = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disciplina académica',
            style: TextStyle(color: Colors.white)),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        bottom: TabBar(
          indicatorColor: Color.fromARGB(255, 37, 127, 245),
          labelColor: Colors.white,
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.list),
              text: 'Listado de reportes',
            ),
            Tab(
              icon: Icon(Icons.add),
              text: 'Nuevo reporte',
            ),
            Tab(
              icon: Icon(Icons.crop_square_sharp),
              text: 'Próximamente',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          DisciplineHistoryGrid(gridData: data),
          Center(child: Text("Crear reporte")),
          Center(child: Text("Otra opción")),
        ],
      ),
    );
  }
}
