import 'package:flutter/material.dart';
import 'package:oxschool/presentation/Modules/academic/grades_modules_configuration.dart';
import 'package:oxschool/presentation/Modules/user/users_main_screen.dart';

import '../../presentation/Modules/enfermeria/nursery_main_screen.dart';
import '../../presentation/Modules/enfermeria/students_with_illness.dart';
import '../../presentation/Modules/academic/grades_main_screen.dart';
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
  'Configuracion Academica': GradesModuleConfiguration()
};

const mobilePages = [
  //Main
  MobileMainWindow(),
];

const Map<String, String> modulesMapped = {
  '': "FichaDeSalud()",
  "Procesos": "ServicesTicketHistory()",
  "Calificaciones": "GradesViewScreen()",
  "Administracion": "UsersDashboard()"
};

const Map<String, Icon> moduleIcons = {
  'Enfermeria': Icon(
    Icons.local_hospital,
  ),
  'Academico': Icon(Icons.school_rounded),
  'Servicios': Icon(Icons.density_small),
  'Nominas': Icon(Icons.groups),
  'Contraloria': Icon(Icons.payments),
  'Archivo Escolar': Icon(Icons.folder),
  'Administracion': Icon(Icons.admin_panel_settings)
};

const Map<String, Icon> eventsIcons = {
  'Ficha Medica de alumnos': Icon(Icons.medical_services_rounded),
  'Alumnos con padecimiento': Icon(Icons.accessible_outlined),
  'Calificaciones': Icon(Icons.grade),
  'Dashboard': Icon(Icons.dashboard)
};
