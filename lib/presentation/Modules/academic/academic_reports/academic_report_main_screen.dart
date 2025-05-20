import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';

class AcademicReportMainScreen extends StatefulWidget {
  const AcademicReportMainScreen({super.key});

  @override
  State<AcademicReportMainScreen> createState() =>
      _AcademicReportMainScreenState();
}

class _AcademicReportMainScreenState extends State<AcademicReportMainScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reportes'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          bottom: TabBar(
            labelColor: Colors.white,
            controller: _tabController,
            tabs: const <Widget>[
              Tab(
                icon: Icon(Icons.abc),
                text: 'Boletas de Calificaciones',
              ),
              Tab(
                icon: Icon(
                  Icons.boy,
                ),
                text: 'Auditoría',
              ),
              Tab(
                icon: FaIcon(
                  FontAwesomeIcons.sheetPlastic,
                ),
                text: 'Promedios Bimestrales y Mensuales',
              ),
              Tab(
                icon: FaIcon(
                  FontAwesomeIcons.sheetPlastic,
                ),
                text: 'Otros Reportes',
              )
            ],
            indicatorColor: Colors.blueAccent,
          ),
        ),
        body: Center(
            child: Placeholder(
          child: TabBarView(
            key: const PageStorageKey('value'),
            controller: _tabController,
            children: const <Widget>[
              Placeholder(),
              Placeholder(),
              Placeholder(),
              Placeholder()
            ],
          ),
        )));
  }
}
