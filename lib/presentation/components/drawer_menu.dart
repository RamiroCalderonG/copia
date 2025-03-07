import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/presentation/Modules/enfermeria/nursery_main_screen.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_util.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Modules/academic/grades_main_screen.dart';
import '../Modules/services_ticket/processes/services_main_screen.dart';

class DrawerClass extends StatefulWidget {
  const DrawerClass({super.key});

  @override
  State<DrawerClass> createState() => _DrawerClassState();
}

class _DrawerClassState extends State<DrawerClass> {
  //final FirebaseAuth _ath = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
          child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              height: 200,
              color: Colors.transparent,
              child: const Center(
                  child: Image(
                image: AssetImage('assets/images/logoRedondoOx.png'),
                fit: BoxFit.fill,
              ))),
          ExpansionTile(
            title: const Text('Enfermeria'),
            leading: const Icon(Icons.healing),
            childrenPadding: const EdgeInsets.only(left: 60),
            children: [
              ListTile(
                title: const Text(
                  'Ficha medica de alumnos',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(Icons.folder),
                //const Image(image: AssetImage('assets/images/user-add.png')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NurseryMainScreen()));
                },
              ),
              ListTile(
                title: const Text(
                  'Alumnos con Padecimiento',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(Icons.grid_4x4),
                onTap: () {
                  // Navigator.pop(context);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => ));
                },
              )
            ],
          ),
          ExpansionTile(
            title: const Text('Academic Jr. & Middle School'),
            leading: const Icon(Icons.grade),
            childrenPadding: const EdgeInsets.only(left: 60),
            children: [
              ListTile(
                title: const Text(
                  'Calificaciones',
                  // style: TextStyle(fontFamily: 'Sora'),
                ),
                leading: const Icon(Icons.school),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GradesMainScreen()));
                },
              ),
              ListTile(
                title: const Text('Disciplina'),
                leading: const Icon(Icons.directions_run_outlined),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Reportes'),
                leading: const Icon(Icons.note),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Reconocimientos'),
                leading: const FaIcon(FontAwesomeIcons.award),
                onTap: () {},
              ),
              const ListTile(
                title: Text('Bajo rendimiento'),
                leading: FaIcon(FontAwesomeIcons.arrowDown),
              ),
              const ListTile(
                title: Text('Indicadores'),
                leading: FaIcon(FontAwesomeIcons.chartColumn),
              ),
              const ListTile(
                title: Text('Configure'),
                leading: FaIcon(FontAwesomeIcons.gears),
              )
            ],
          ),
          ExpansionTile(
            title: const Text('Servicios'),
            leading: const Icon(Icons.density_small_sharp),
            childrenPadding: const EdgeInsets.only(left: 60),
            children: [
              ListTile(
                title: const Text(
                  'Procesos',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(Icons.grid_view_sharp),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ServicesTicketHistory()));
                },
              ),
              ListTile(
                title: const Text(
                  'Consultas',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(Icons.info),
                onTap: () {},
              ),
              ListTile(
                title: const Text(
                  'Reportes',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(Icons.grid_on_outlined),
                onTap: () {},
              ),
              ListTile(
                title: const Text(
                  'Indicadores',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(
                  Icons.bar_chart,
                ),
                onTap: () {},
              ),
              ListTile(
                title: const Text(
                  'Administracion',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(
                  Icons.settings,
                ),
                onTap: () {},
              )
            ],
          ),
          ExpansionTile(
            title: const Text('Otro modulo'),
            leading: const Icon(Icons.business),
            childrenPadding: const EdgeInsets.only(left: 60),
            children: [
              ListTile(
                title: const Text('Pestaña de modulo'),
                leading: const Icon(Icons.info),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Otra cosa'),
                leading: const Icon(Icons.list_alt),
                onTap: () {
                  // Navigator.pop(context);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const ServicesDashboard()));
                },
              )
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text('Cerrar Sesion'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () async {
              // clearStudentData();
              logOutCurrentUser(currentUser!);
              context.goNamed(
                '_initialize',
                extra: <String, dynamic>{
                  kTransitionInfoKey: const TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.leftToRight,
                  ),
                },
              );
               clearUserData();
              clearTempData();
                SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
              // Navigator.pop(context);
              // Navigator.pushReplacement(context,
              //     MaterialPageRoute(builder: (context) => LoginViewWidget()));
            },
          ),
          const Divider(
            height: 180,
            color: Colors.transparent,
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 10.4),
            alignment: Alignment.topCenter,
            child: Text(
              'Hola: ${currentUser?.employeeName}',
              style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          )
        ],
      )),
    );
  }
}
