import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disciplina académica'),
        bottom: TabBar(
          indicatorColor: Color.fromARGB(255, 37, 127, 245),
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
        children: const <Widget>[
          Center(child: Text("It's cloudy here")),
          Center(child: Text("It's rainy here")),
          Center(child: Text("It's sunny here")),
        ],
      ),
    );
  }
}
