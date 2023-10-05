import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/enfermeria/enfermeria_widget.dart';
import 'package:oxschool/enfermeria/ficha_de_salud.dart';
import 'package:oxschool/flutter_flow/flutter_flow_util.dart';
import 'package:oxschool/login_view/login_view_widget.dart';
import 'package:oxschool/main.dart';
import '../constants/Student.dart';
import '../grades/grades_view.dart';
import '../models/user.dart';

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
              padding: EdgeInsets.all(10),
              height: 200,
              color: Colors.transparent,
              child: const Center(
                  child: const Image(
                image: AssetImage('assets/images/logoRedondoOx.png'),
                fit: BoxFit.fill,
              ))),
          ExpansionTile(
            title: const Text('Enfermeria'),
            leading: const Icon(Icons.supervised_user_circle_outlined),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FichaDeSalud()));
                },
              ),
              ListTile(
                title: const Text(
                  'Otra cosa',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(Icons.grid_4x4_outlined),
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
            title: const Text('Calificaciones'),
            leading: const Icon(Icons.face),
            childrenPadding: const EdgeInsets.only(left: 60),
            children: [
              ListTile(
                title: const Text(
                  'Capturar calificaciones',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: Icon(Icons.add),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GradesViewScreen()));
                },
              ),
              ListTile(
                title: const Text('Otra cosa'),
                leading: const Icon(Icons.grid_on),
                onTap: () {},
              )
            ],
          ),
          ExpansionTile(
            title: const Text('Otro modulo'),
            leading: const Icon(Icons.store),
            childrenPadding: const EdgeInsets.only(left: 60),
            children: [
              ListTile(
                title: const Text(
                  'Accion de modulo',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(Icons.point_of_sale),
                onTap: () {
                  // Navigator.pop(context);
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => PointOfSale()));
                },
              ),
              ListTile(
                title: const Text(
                  'Otra accion',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(Icons.grid_on_outlined),
                onTap: () {},
              ),
              ListTile(
                title: const Text(
                  'Cosas',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(Icons.grid_on_outlined),
                onTap: () {},
              ),
              ListTile(
                title: const Text(
                  'Mas cosas',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                leading: const Icon(
                  Icons.add_circle,
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
            onTap: () {
              // clearStudentData();
              clearUserData();

              context.goNamed(
                '_initialize',
                extra: <String, dynamic>{
                  kTransitionInfoKey: TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.leftToRight,
                  ),
                },
              );
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
            padding: EdgeInsets.only(bottom: 10.4),
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
