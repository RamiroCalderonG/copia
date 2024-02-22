import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
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
    const List<String> grade_groups = <String>[
      //TO STORE The teacher groups
      '1 A',
      '1 B',
      '1 C',
      '1 D'
    ];
    const List<String> months = <String>['Enero', 'Febrero', 'Marzo', 'Abril'];
    String? groupSelected;

    String? dropDownValue;
    bool pause = true;

    // final DropdownButton groupButton = DropdownButton<String>(
    //   value: groupSelected,
    //   // icon: const Icon(Icons.calendar_month),
    //   elevation: 16,
    //   style: const TextStyle(color: Colors.white),
    //   underline: Container(
    //     height: 2,
    //     color: Colors.white,
    //   ),
    //   onChanged: (String? value) {
    //     // This is called when the user selects an item.
    //     setState(() {
    //       groupSelected = value!;
    //     });
    //   },
    //   items: months.map<DropdownMenuItem<String>>((String value) {
    //     return DropdownMenuItem<String>(
    //       value: value,
    //       child: Text(value),
    //     );
    //   }).toList(),
    // );

    final DropdownMenu monthSelectorButton = DropdownMenu<String>(
        initialSelection: months.first,
        onSelected: (String? value) {
          setState(() {
            dropDownValue = value;
          });
        },
        dropdownMenuEntries:
            months.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    final DropdownMenu groupSelectorButton = DropdownMenu<String>(
        initialSelection: grade_groups.first,
        onSelected: (String? value) {
          setState(() {
            groupSelected = value;
          });
        },
        dropdownMenuEntries:
            grade_groups.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList());

    return Scaffold(
        appBar: AppBar(
          actions: [
            SizedBox(width: 100),
            Container(
                padding: EdgeInsets.all(1),
                child: Row(
                  children: [
                    SizedBox(width: 50),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            'Grado y Grupo:    ',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold),
                          ),
                          groupSelectorButton,
                        ],
                      ),
                    ),
                    SizedBox(width: 50),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            'Mes:    ',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold),
                          ),
                          monthSelectorButton,
                        ],
                      ),
                    ),
                    SizedBox(width: 50),
                    Container(
                      padding: EdgeInsets.all(2),
                      child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              pause = !pause;
                            });

                            LoadingIndicator(
                                indicatorType: Indicator.ballPulse,
                                colors: [Colors.red],
                                backgroundColor: Colors.black87,
                                strokeWidth: 2,
                                pause: pause,
                                pathBackgroundColor: Colors.black);
                          },
                          icon: Icon(Icons.search),
                          label: Text('Buscar')),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(2),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400]),
                          onPressed: () {},
                          icon: Icon(Icons.save),
                          label: Text('Guardar')),
                    ),
                    SizedBox(width: 10),
                  ],
                )),
          ],
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
