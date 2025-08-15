import 'package:flutter/material.dart';
import 'package:oxschool/presentation/Modules/academic/school%20grades/grades_modules_configuration.dart';
import 'package:oxschool/presentation/Modules/admin/employee_performance_eval.dart';
import 'package:oxschool/presentation/Modules/admin/users_main_screen.dart';

import '../../presentation/Modules/enfermeria/nursery_main_screen.dart';
import '../../presentation/Modules/enfermeria/students_with_illness.dart';
import '../../presentation/Modules/academic/school grades/grades_main_screen.dart';
import '../../presentation/Modules/services_ticket/processes/services_main_screen.dart';
import '../../presentation/Modules/login_view/login_view_widget.dart';
import '../../presentation/Modules/main_window/main_window_widget.dart';
import '../../presentation/Modules/main_window/mobile_main_window_widget.dart';

const Map<String, dynamic> pageRoutes = {
  'Login': LoginViewWidget(),
  'Main': MainWindowWidget(),
  'Ficha Medica de alumnos': NurseryMainScreen(),
  'Calificaciones': GradesMainScreen(),
  'Procesos': ServicesTicketHistory(),
  'Dashboard': UsersMainScreen(),
  'Alumnos con padecimientos': StudentsIlness(),
  'Configuracion Academica': GradesModuleConfiguration(),
  'Evaluación de desempeño': EmployeePerformanceEvaluationDashboard()
};

const mobilePages = [
  //Main
  MobileMainWindow(),
];
List<Map<String, dynamic>> accessRoutes = [];

const Map<String, String> modulesMapped = {
  '': "FichaDeSalud()",
  "Procesos": "ServicesTicketHistory()",
  "Calificaciones": "GradesViewScreen()",
  "Administración": "UsersDashboard()"
};

const Map<String, Icon> moduleIcons = {
  'Enfermería': Icon(
    Icons.local_hospital,
  ),
  'Académico': Icon(Icons.school_rounded),
  'Servicios': Icon(Icons.density_small),
  'Nóminas': Icon(Icons.groups),
  'Contraloría': Icon(Icons.payments),
  'Archivo Escolar': Icon(Icons.folder),
  'Administración': Icon(Icons.admin_panel_settings),
  'Cafetería': Icon(Icons.fastfood_sharp)
};

// const Map<String, Icon> eventsIcons = {
//   'Ficha Medica de alumnos': Icon(Icons.medical_services_rounded),
//   'Alumnos con padecimiento': Icon(Icons.accessible_outlined),
//   'Calificaciones': Icon(Icons.grade),
//   'Dashboard': Icon(Icons.dashboard)
// };
