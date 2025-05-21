import 'package:flutter/material.dart';

import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/data/Models/Student.dart';
import 'package:oxschool/presentation/Modules/academic/academic_reports/fodac_59_screen.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

class AcademicReportMainScreen extends StatefulWidget {
  const AcademicReportMainScreen({super.key});

  @override
  State<AcademicReportMainScreen> createState() =>
      _AcademicReportMainScreenState();
}

class _AcademicReportMainScreenState extends State<AcademicReportMainScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _selectedCategoryIndex = 0;
  List<Student> studentsList = [];
  Map<int?, String?> gardesGroups = {}; // GradeSequence : gradeName
  Map<int?, String?> gradeSeqGroup = {}; // GradeSequence : groupName
  late Future<dynamic> future;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    handleInitialLoading();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _categoryPanels = [
      Center(
          child: Fodac59Screen(
              studentsList: studentsList,
              gardesGroups: gradeSeqGroup,
              gradeSeqGroup: gradeSeqGroup)),
      Center(child: Text('Science Report Panel')),
      Center(child: Text('History Report Panel')),
      Center(child: Text('Geography Report Panel')),
      Center(child: Text('Language Report Panel')),
      Center(child: Text('Art Report Panel')),
      Center(child: Text('Music Report Panel')),
      Center(child: Text('Art Report Panel')),
      Center(child: Text('Music Report Panel')),
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Reportes'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reportes por categoría',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
              SizedBox(height: 8), // Reduced spacing
              CategoryList(
                selectedIndex: _selectedCategoryIndex,
                onCategorySelected: (index) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
              ),
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder(
                    future: future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).primaryText,
                              width: 1,
                            ),
                          ),
                          child: _categoryPanels[_selectedCategoryIndex],
                        );
                      } else {
                        return Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                        );
                      }
                    }),
              ),
            ],
          ),
        )));
  }

  //* Function that retrieves gardes, groups and students
  //* from the database and sets them to the state
  void handleInitialLoading() {
    try {
      retrieveData().then((value) {
        if (value.isNotEmpty) {
          setState(() {
            for (var item in value) {
              if (gardesGroups.isEmpty) {
                gardesGroups.addAll({item.gradoSecuencia: item.grado});
              } else {
                if (!gardesGroups.containsKey(item.gradoSecuencia)) {
                  gardesGroups.addAll({
                    item.gradoSecuencia: item.grado,
                  });
                }
              }
              gradeSeqGroup.addAll({item.gradoSecuencia: item.grupo});
            }
            studentsList = value;
          });
        }
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } catch (e) {
      showErrorFromBackend(context, e.toString());
    }
  }

  Future<List<Student>> retrieveData() async {
    try {
      future = getSimpleStudentsByCycle(currentCycle!.claCiclo!);
      return await future;
    } catch (e) {
      rethrow;
    }
  }
}

class CategoryItem {
  final IconData icon;
  final String label;

  CategoryItem({required this.icon, required this.label});
}

class CategoryList extends StatelessWidget {
  final List<CategoryItem> categories = [
    CategoryItem(icon: Icons.child_care, label: 'FO-DAC-59 \nKinder'),
    CategoryItem(
        icon: Icons.bar_chart_rounded, label: 'FO-DAC-60 y 04 \nSemestral'),
    CategoryItem(icon: Icons.view_week_rounded, label: 'FO-DAC-62 \nAnual'),
    CategoryItem(
        icon: Icons.search_off, label: 'Faltantes Captura y \nDeudores'),
    CategoryItem(icon: Icons.translate, label: 'FO-DAC-14 \nCompara Promedios'),
    CategoryItem(
        icon: Icons.palette, label: 'FO-DAC-15 \nPor Campus/Gdo/Alum.'),
    CategoryItem(
        icon: Icons.workspace_premium_rounded,
        label: 'FO-DAC-29 y \nFO-DAC-31'),
    CategoryItem(icon: Icons.adjust_rounded, label: 'FO-DAC-32  \nGdo y Gpo'),
    CategoryItem(icon: Icons.abc, label: 'FO-DAC-57 \npor Alumno'),
  ];

  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  CategoryList({this.selectedIndex = 0, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: CategoryTile(
                category: categories[index],
                isSelected: selectedIndex == index,
                onTap: () => onCategorySelected(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final CategoryItem category;
  final bool isSelected;
  final VoidCallback? onTap;

  CategoryTile({
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Colors.blue[100]
          : FlutterFlowTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 120,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: FlutterFlowTheme.of(context).primaryText,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 24,
                color: isSelected
                    ? Colors.blue
                    : FlutterFlowTheme.of(context).primaryText,
              ),
              SizedBox(height: 4),
              Flexible(
                child: Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? Colors.blue
                        : FlutterFlowTheme.of(context).primaryText,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
