import '../Modules/enfermeria/ficha_de_salud.dart';
import '../Modules/grades/grades_view_capture.dart';
import '../Modules/services_ticket/processes/services_main_screen.dart';
import '../login_view/login_view_widget.dart';
import '../main_window/main_window_widget.dart';
import '../main_window/mobile_main_window_widget.dart';

const pages = [
  //Login
  LoginViewWidget(),
  //Main
  MainWindowWidget(),
  //Nursery
  FichaDeSalud(),
  //Grades
  GradesViewScreen(),
  //Service Ticket
  ServicesTicketHistory(),
  //
];

const mobilePages = [
  //Main
  MobileMainWindow(),
];
