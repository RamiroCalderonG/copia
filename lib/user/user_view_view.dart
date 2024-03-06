import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oxschool/Models/User.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

class UserWindow extends StatefulWidget {
  const UserWindow({super.key});

  @override
  State<UserWindow> createState() => _UserWindowState();
}

class _UserWindowState extends State<UserWindow> {
  late Future<User> userFuture; // Future to hold the user data

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < 600) {
        return _smallScreenUserDisplay();
      } else {
        return _largerScreenUserDisplay();
      }
    });
  }

  Widget _smallScreenUserDisplay() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mi  perfil', style: TextStyle(color: Colors.white)),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: Stack(
          children: [_formContentsFields()],
        ));
  }

  Widget _largerScreenUserDisplay() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mi  perfil', style: TextStyle(color: Colors.white)),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background-header.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.all(30),
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: _formContentsFields()),
              ),
            ),
          ],
        ));
  }

  Widget _formContentsFields() {
    return Center(
        child: Column(
      children: <Widget>[
        Container(
          child: Center(
            child: Text(
              'Foto de empleado o inicial',
              style: TextStyle(fontFamily: 'Sora', fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(100),
          ),
          width: 200,
          height: 200,
          margin: EdgeInsets.all(15),
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(60)),
              child: Center(
                child: Text(
                  'Nombre de usuario',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Sora'),
                ),
              ),
            )),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 8),
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.purple.shade300,
                  borderRadius: BorderRadius.circular(60)),
              child: Center(
                child: Text(
                  'Numero de empleado',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Sora'),
                ),
              ),
            )),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 8),
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: BorderRadius.circular(60)),
              child: Center(
                child: Text(
                  'Puesto',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Sora'),
                ),
              ),
            )),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 30),
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.red.shade300,
                  borderRadius: BorderRadius.circular(60)),
              child: Center(
                child: Text(
                  'Campus',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Sora'),
                ),
              ),
            )),
          ],
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.green),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.attach_money_outlined),
                  label: const Text('Consulta  recibo nomina')),
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.abc),
                  label: const Text('Otra consulta')),
              ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.orange),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.create),
                  label: const Text('Cambiar contraseña')),
            ])
      ],
    ));
  }
}
