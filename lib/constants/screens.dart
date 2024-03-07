import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Modules/enfermeria/ficha_de_salud.dart';
import '../Modules/grades/grades_view_capture.dart';
import '../Modules/services_ticket/processes/services_main_screen.dart';
import '../login_view/login_view_widget.dart';
import '../main_window/main_window_widget.dart';
import '../main_window/mobile_main_window_widget.dart';

const Map<String, dynamic> pageRoutes = {
  'Login': LoginViewWidget(),
  'Main': MainWindowWidget(),
  'Ficha Medica de alumnos': FichaDeSalud(),
  'Calificaciones': GradesViewScreen(),
  'Procesos': ServicesTicketHistory(),
};

const mobilePages = [
  //Main
  MobileMainWindow(),
];

const Map<String, String> modulesMapped = {
  '': "FichaDeSalud()",
  "Procesos": "ServicesTicketHistory()",
  "Calificaciones": "GradesViewScreen()",
};

const Map<String, Icon> moduleIcons = {
  'Enfermeria': Icon(
    Icons.local_hospital,
  ),
  'Academico': Icon(Icons.school_rounded),
  'Servicios': Icon(Icons.density_small),
  'Nominas': Icon(Icons.groups),
  'Contraloria': Icon(Icons.payments),
  'Archivo Escolar': Icon(Icons.folder)
};

const Map<String, Icon> eventsIcons = {
  'Ficha Medica de alumnos': Icon(Icons.medical_services_rounded),
  'Alumnos con padecimiento': Icon(Icons.accessible_outlined),
  'Calificaciones': Icon(Icons.grade),
};
